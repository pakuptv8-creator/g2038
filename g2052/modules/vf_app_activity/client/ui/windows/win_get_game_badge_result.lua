local WinGet_game_badge_result = M

function WinGet_game_badge_result:init()
  WinBase.init(self, "get_game_badge_result.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinGet_game_badge_result:initUI()
  self.imgGetGameBadgeResultBG = self:child("get_game_badge_result-BG")
  self.imgGetGameBadgeResultTitle = self:child("get_game_badge_result-Title")
  self.lytGetGameBadgeResultReward = self:child("get_game_badge_result-Reward")
  self.imgGetGameBadgeResultRewardBg = self:child("get_game_badge_result-RewardBg")
  self.imgGetGameBadgeResultIcon = self:child("get_game_badge_result-Icon")
  self.btnGetGameBadgeResultClose = self:child("get_game_badge_result-Close")
  self.btnGetGameBadgeResultConfirm = self:child("get_game_badge_result-Confirm")
  self.txtConfirmTxt = self:child("get_game_badge_result-ConfirmText")
  self.txtConfirmTxt:SetText(Lang:toText("g2052.gui.confirm"))
end

function WinGet_game_badge_result:initEvent()
  self:subscribe(self.btnGetGameBadgeResultClose, UIEvent.EventButtonClick, function()
    UI:openWnd("game_badge_desc", self.data)
    self:onHide()
  end)
  self:subscribe(self.btnGetGameBadgeResultConfirm, UIEvent.EventButtonClick, function()
    UI:openWnd("game_badge_desc", self.data)
    self:onHide()
  end)
  self:subscribe(self.imgGetGameBadgeResultIcon, UIEvent.EventWindowClick, function()
    UI:openWnd("game_badge_desc", self.data)
    self:onHide()
  end)
end

function WinGet_game_badge_result:subscribeEvent()
end

function WinGet_game_badge_result:initView(data)
  self.data = data
  self.imgGetGameBadgeResultIcon:SetImageUrl(data.badgeIcon)
end

function WinGet_game_badge_result:onHide()
  UI:closeWnd("get_game_badge_result")
end

function WinGet_game_badge_result:onShow(isShow, data)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("get_game_badge_result", data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGet_game_badge_result:onOpen(data)
  self:initView(data)
  self:subscribeEvent()
end

function WinGet_game_badge_result:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinGet_game_badge_result
