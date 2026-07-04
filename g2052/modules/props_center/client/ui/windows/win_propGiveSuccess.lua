local WinPropGiveSuccess = M

function WinPropGiveSuccess:init()
  WinBase.init(self, "PropGiveSuccess.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPropGiveSuccess:initUI()
  self.imgPanel = self:child("PropGiveSuccess-panel")
  self.imgBg = self:child("PropGiveSuccess-Bg")
  self.lytHeadPanel = self:child("PropGiveSuccess-HeadPanel")
  self.imgHeadIcon = self:child("PropGiveSuccess-HeadIcon")
  self.imgHeadFrame = self:child("PropGiveSuccess-HeadFrame")
  self.imgArrowIcon = self:child("PropGiveSuccess-arrowIcon")
  self.lytPropPanel = self:child("PropGiveSuccess-PropPanel")
  self.propWidget = UIMgr:new_widget("propItem1")
  self.lytPropPanel:AddChildWindow(self.propWidget)
  self.propWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WinPropGiveSuccess:initEvent()
end

function WinPropGiveSuccess:subscribeEvent()
end

function WinPropGiveSuccess:initView(itemId, targetUserId)
  self.propWidget:invoke("reload", itemId)
  self.imgHeadIcon:SetImage(World.cfg.defaultAvatar or "set:default_icon.json image:header_icon")
  local cache = UserInfoCache.GetCache(targetUserId)
  if cache and cache.picUrl and #cache.picUrl > 0 then
    self.imgHeadIcon:SetImageUrl(cache.picUrl)
  else
    AsyncProcess.GetUserDetail(targetUserId, function(data)
      if not data then
        return
      end
      if data.picUrl and #data.picUrl > 0 then
        self.imgHeadIcon:SetImageUrl(data.picUrl)
      else
        self.imgHeadIcon:SetImage(World.cfg.defaultAvatar or "set:default_icon.json image:header_icon")
      end
    end)
  end
end

function WinPropGiveSuccess:onHide()
  UI:closeWnd("propGiveSuccess")
end

function WinPropGiveSuccess:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("propGiveSuccess")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPropGiveSuccess:onOpen(itemId, targetUserId)
  self:initView(itemId, targetUserId)
  self:subscribeEvent()
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
  self.countDown = World.LightTimer("WinPropGiveSuccess CountDown", 20 * World.cfg.givePropSuccessTime, function()
    self:onHide()
    return false
  end)
end

function WinPropGiveSuccess:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
end

return WinPropGiveSuccess
