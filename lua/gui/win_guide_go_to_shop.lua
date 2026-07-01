function M:init()
  WinBase.init(self, "GuideGotoShop.json", false)
  
  self:initWnd()
end

function M:initWnd()
  self.close = self:child("GuideGotoShop-close")
  self.gotoShopBtn = self:child("GuideGotoShop-gotoshopBtn")
  self.gotoShopBtnText = self:child("GuideGotoShop-gotoshopBtnText")
  self.gotoShopBtnText:SetText(Lang:toText("gui_gui_daily_lottery_goto_shop"))
  self.titleText = self:child("GuideGotoShop-title")
  self.detailDecText = self:child("GuideGotoShop-detailDec")
  self:initEvent()
end

function M:initEvent()
  self:subscribe(self.close, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.gotoShopBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
    UI:closeWnd("dailyLottery")
    UI:getWnd("pokemonRegularGift"):onShow(true)
    Me:gameBehaviorReport("RegularGift_openByLottery", 1)
  end)
end

function M:onShow(isShow, detailDec)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("guide_go_to_shop")
    end
    self.titleText:SetText(Lang:toText("gui_guide_goto_shop_title"))
    self.detailDecText:SetText(detailDec)
  else
    self:onHide()
  end
end

function M:onOpen()
end

function M:onClose()
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
  if self.showTimer then
    LuaTimer:cancel(self.showTimer)
    self.showTimer = nil
  end
end

return M
