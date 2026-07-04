local WinCandyAcceptSuccess = M

function WinCandyAcceptSuccess:init()
  WinBase.init(self, "CandyAcceptSuccess.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinCandyAcceptSuccess:initUI()
  self.imgPanel = self:child("CandyAcceptSuccess-panel")
  self.imgBg = self:child("CandyAcceptSuccess-Bg")
  self.lytHeadPanel = self:child("CandyAcceptSuccess-HeadPanel")
  self.imgHeadIcon = self:child("CandyAcceptSuccess-HeadIcon")
  self.imgHeadFrame = self:child("CandyAcceptSuccess-HeadFrame")
  self.imgArrowIcon = self:child("CandyAcceptSuccess-arrowIcon")
  self.imgCandyIcon = self:child("CandyAcceptSuccess-CandyIcon")
end

function WinCandyAcceptSuccess:initEvent()
end

function WinCandyAcceptSuccess:subscribeEvent()
end

function WinCandyAcceptSuccess:initView(targetUserId)
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
  self.countDown = World.LightTimer("WinPropGiveSuccess CountDown", 20 * World.cfg.halloweenSetting.acceptSuccessTime, function()
    self:onHide()
    return false
  end)
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

function WinCandyAcceptSuccess:onHide()
  UI:closeWnd("candyAcceptSuccess")
end

function WinCandyAcceptSuccess:onShow(isShow, targetUserId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("candyAcceptSuccess", targetUserId)
    else
      self:initView(targetUserId)
    end
  else
    self:onHide()
  end
end

function WinCandyAcceptSuccess:onOpen(targetUserId)
  self:initView(targetUserId)
  self:subscribeEvent()
end

function WinCandyAcceptSuccess:onClose()
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

return WinCandyAcceptSuccess
