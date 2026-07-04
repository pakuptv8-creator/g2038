local WinGame_badge_desc = M

function WinGame_badge_desc:init()
  WinBase.init(self, "game_badge_desc.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinGame_badge_desc:initUI()
  self.lstGameBadgeDescMask = self:child("game_badge_desc-Mask")
  self.imgGameBadgeDescDescUrl = self:child("game_badge_desc-DescUrl")
  self.imgGameBadgeDescDesc = self:child("game_badge_desc-Desc")
  self.txtGameBadgeDescText = self:child("game_badge_desc-Text")
  self.btnGameBadgeDescClose = self:child("game_badge_desc-Close")
end

function WinGame_badge_desc:initEvent()
  self:subscribe(self.btnGameBadgeDescClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinGame_badge_desc:subscribeEvent()
end

function WinGame_badge_desc:initView(data)
  self.imgGameBadgeDescDescUrl:SetImageUrl(data.guidePic)
  self.txtGameBadgeDescText:SetText(data.guideDesc)
end

function WinGame_badge_desc:onHide()
  UI:closeWnd("game_badge_desc")
end

function WinGame_badge_desc:onShow(isShow, data)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("game_badge_desc", data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGame_badge_desc:onOpen(data)
  self:initView(data)
  self:subscribeEvent()
end

function WinGame_badge_desc:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinGame_badge_desc
