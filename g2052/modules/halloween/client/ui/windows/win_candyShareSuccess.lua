local WinCandyShareSuccess = M

function WinCandyShareSuccess:init()
  WinBase.init(self, "CandyShareSuccess.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinCandyShareSuccess:initUI()
  self.imgPanel = self:child("CandyShareSuccess-panel")
  self.imgBg = self:child("CandyShareSuccess-Bg")
  self.lytHeadPanel = self:child("CandyShareSuccess-HeadPanel")
  self.imgHeadIcon = self:child("CandyShareSuccess-HeadIcon")
  self.imgHeadFrame = self:child("CandyShareSuccess-HeadFrame")
  self.imgArrowIcon = self:child("CandyShareSuccess-arrowIcon")
  self.imgCandyIcon = self:child("CandyShareSuccess-CandyIcon")
end

function WinCandyShareSuccess:initEvent()
end

function WinCandyShareSuccess:subscribeEvent()
end

function WinCandyShareSuccess:initView(targetUserId)
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
  self.countDown = World.LightTimer("WinPropGiveSuccess CountDown", 20 * World.cfg.halloweenSetting.shareSuccessTime, function()
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

function WinCandyShareSuccess:onHide()
  UI:closeWnd("candyShareSuccess")
end

function WinCandyShareSuccess:onShow(isShow, targetUserId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("candyShareSuccess", targetUserId)
    else
      self:initView(targetUserId)
    end
  else
    self:onHide()
  end
end

function WinCandyShareSuccess:onOpen(targetUserId)
  self:initView(targetUserId)
  self:subscribeEvent()
end

function WinCandyShareSuccess:onClose()
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

return WinCandyShareSuccess
