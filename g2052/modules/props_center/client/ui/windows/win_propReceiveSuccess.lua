local WinPropReceiveSuccess = M

function WinPropReceiveSuccess:init()
  WinBase.init(self, "PropReceiveSuccess.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPropReceiveSuccess:initUI()
  self.imgPanel = self:child("PropReceiveSuccess-panel")
  self.imgBg = self:child("PropReceiveSuccess-Bg")
  self.lytHeadPanel = self:child("PropReceiveSuccess-HeadPanel")
  self.imgHeadIcon = self:child("PropReceiveSuccess-HeadIcon")
  self.imgHeadFrame = self:child("PropReceiveSuccess-HeadFrame")
  self.imgArrowIcon = self:child("PropReceiveSuccess-arrowIcon")
  self.lytPropPanel = self:child("PropReceiveSuccess-PropPanel")
  self.propWidget = UIMgr:new_widget("propItem1")
  self.lytPropPanel:AddChildWindow(self.propWidget)
  self.propWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WinPropReceiveSuccess:initEvent()
end

function WinPropReceiveSuccess:subscribeEvent()
end

function WinPropReceiveSuccess:initView(itemId, fromUserId)
  self.propWidget:invoke("reload", itemId)
  self.imgHeadIcon:SetImage(World.cfg.defaultAvatar or "set:default_icon.json image:header_icon")
  local cache = UserInfoCache.GetCache(fromUserId)
  if cache and cache.picUrl and #cache.picUrl > 0 then
    self.imgHeadIcon:SetImageUrl(cache.picUrl)
  else
    AsyncProcess.GetUserDetail(fromUserId, function(data)
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

function WinPropReceiveSuccess:onHide()
  UI:closeWnd("propReceiveSuccess")
end

function WinPropReceiveSuccess:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("propReceiveSuccess")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPropReceiveSuccess:onOpen(itemId, fromUserId)
  self:initView(itemId, fromUserId)
  self:subscribeEvent()
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
  self.countDown = World.LightTimer("WinPropGiveSuccess CountDown", 20 * World.cfg.receivePropTime, function()
    self:onHide()
    return false
  end)
end

function WinPropReceiveSuccess:onClose()
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

return WinPropReceiveSuccess
