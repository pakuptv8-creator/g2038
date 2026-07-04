local WinAnnouncementSlide = M
local AnnouncementConfig = T(Config, "AnnouncementConfig")

function WinAnnouncementSlide:init()
  WinBase.init(self, "AnnouncementSlide.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinAnnouncementSlide:initUI()
  self.imgMask = self:child("AnnouncementSlide-Mask")
  self.btnClose = self:child("AnnouncementSlide-Close")
  self.lytScrollPanel = self:child("AnnouncementSlide-ScrollPanel")
  self.txtTitle = self:child("AnnouncementSlide-Title")
  self.txtTitle:SetText(Lang:toText("g2052.gui.announcement.main_title"))
  self.lstContent = UIMgr:new_widget("grid_view")
  self.lstContent:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lstContent:InitConfig(0, 15, 1)
  self.lstContent:SetAutoColumnCount(false)
  self.lytScrollPanel:AddChildWindow(self.lstContent)
end

function WinAnnouncementSlide:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinAnnouncementSlide:subscribeEvent()
end

function WinAnnouncementSlide:initListShow()
  local allList = AnnouncementConfig:getAllCfgs()
  for id, val in pairs(allList) do
    local cell = UIMgr:new_widget("announcementItem")
    cell:invoke("initAnnouncementItemData", val)
    self.lstContent:AddItem(cell)
  end
end

function WinAnnouncementSlide:initView()
  if not self.isInit then
    self:initListShow()
    self.isInit = true
  end
end

function WinAnnouncementSlide:onHide()
  UI:closeWnd("announcementSlide")
end

function WinAnnouncementSlide:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("announcementSlide")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinAnnouncementSlide:onOpen()
  self:initView()
  self:subscribeEvent()
  self.startShowTime = os.time()
end

function WinAnnouncementSlide:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.startShowTime then
    local defaultData = {
      news_ui_time = os.time() - self.startShowTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "news_ui_open", defaultData, Me)
  end
end

return WinAnnouncementSlide
