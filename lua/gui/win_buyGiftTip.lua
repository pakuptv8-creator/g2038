function M:init()
  self._allEvent = {}
  
  self.itemCells = {}
  WinBase.init(self, "buyGiftTip.json", false)
  self:initWnd()
end

function M:initWnd()
  self.close = self:child("buyGiftTip-closeBtn")
  self.cormfirmBtn = self:child("buyGiftTip-cormfirmBtn")
  self.buyGiftTipTitleText = self:child("buyGiftTip-title")
  self.buyGiftTipTitleText:SetText(Lang:toText("ui_buy_gift_tip_title"))
  self.itemList = self:child("buyGiftTip-itemList")
  self.itemview = UIMgr:new_widget("grid_view")
  self.itemList:AddChildWindow(self.itemview)
  self.itemview:SetMoveAble(false)
  self.itemview:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self:initEvent()
end

function M:updateItemList(itemInfo, titleStr)
  if titleStr then
    self.buyGiftTipTitleText:SetText(Lang:toText(titleStr))
  else
    self.buyGiftTipTitleText:SetText(Lang:toText("ui_buy_gift_tip_title"))
  end
  self.itemview:RemoveAllItems()
  self.itemview:InitConfig(6, 0, #itemInfo)
  for index, info in pairs(itemInfo or {}) do
    local cell = UIMgr:new_widget("pokemon_gift_item_cell")
    cell:invoke("updateInfo", info)
    self.itemview:AddItem(cell)
  end
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self:child("buyGiftTip"), 1280, 720)
end

function M:initEvent()
  self:subscribe(self.close, UIEvent.EventButtonClick, function()
    if Me:getGainFirstOrangePet() == 1 then
      Me:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.TIME)
    end
    UI:closeWnd(self)
  end)
  self:subscribe(self.cormfirmBtn, UIEvent.EventButtonClick, function()
    if Me:getGainFirstOrangePet() == 1 then
      Me:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.TIME)
    end
    UI:closeWnd(self)
  end)
end

function M:onShow(isShow, itemDate, titleStr)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("buyGiftTip", itemDate, titleStr)
    end
  else
    self:onHide()
  end
end

function M:onOpen(itemDate, titleStr)
  self:updateItemList(itemDate, titleStr)
end

function M:onClose()
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
end

return M
