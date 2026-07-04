local WinAnnouncement = M

function WinAnnouncement:init()
  WinBase.init(self, "Announcement.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinAnnouncement:initUI()
  self.imgMask = self:child("Announcement-Mask")
  self.lytContent = self:child("Announcement-Content")
  self.imgLoading = self:child("Announcement-Loading")
  self.imgAnnounce = self:child("Announcement-AnnounceImage")
  self.btnClose = self:child("Announcement-Close")
  local cfg = World.cfg.announcementSetting
  if cfg then
    local cfgSize = cfg.urlUI.imageSize
    self.lytContent:SetHeight({
      0,
      cfgSize.h
    })
    self.lytContent:SetWidth({
      0,
      cfgSize.w
    })
  end
  self.btnClose:SetVisible(false)
end

function WinAnnouncement:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinAnnouncement:subscribeEvent()
end

function WinAnnouncement:initView()
  if self.hasInitImage and not World.cfg.announcementSetting.debug then
    return
  end
  self.btnClose:SetVisible(false)
  local typ = World.cfg.announcementSetting.webImage or "announcementImage"
  AsyncProcess.GetModImageUrlByType(function(data)
    local picUrl = data.data or ""
    if picUrl == "" then
    end
    self.imgAnnounce:SetImageUrl(picUrl)
    self.hasInitImage = true
    self:autoShowCloseBtn()
  end, typ)
end

function WinAnnouncement:autoShowCloseBtn()
  local time = World.cfg.announcementSetting.viewTime or 3
  World.Timer(20 * time, function()
    self.btnClose:SetVisible(true)
    return false
  end)
end

function WinAnnouncement:onHide()
  UI:closeWnd("announcement")
end

function WinAnnouncement:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("announcement")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinAnnouncement:onOpen()
  self:initView()
  self:subscribeEvent()
  self.startShowTime = os.time()
end

function WinAnnouncement:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.startShowTime then
    local defaultData = {
      news_ui_time = os.time() - self.startShowTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "news_ui_open", defaultData, Me)
  end
end

return WinAnnouncement
