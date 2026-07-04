local WinLimitedTimeConfirmCommon = M
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitedTimeConfirmCommon:init()
  WinBase.init(self, "LimitedTimeConfirmCommon.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeConfirmCommon:initUI()
  self.lytWnd = self:child("LimitedTimeConfirmCommon-wnd")
  self.imgWndBg = self:child("LimitedTimeConfirmCommon-wnd_bg")
  self.imgTopImg = self:child("LimitedTimeConfirmCommon-topImg")
  self.txtTitle = self:child("LimitedTimeConfirmCommon-title")
  self.txtGiftTitle = self:child("LimitedTimeConfirmCommon-GiftTitle")
  self.lytGoodsPanel = self:child("LimitedTimeConfirmCommon-GoodsPanel")
  self.lytDetails = self:child("LimitedTimeConfirmCommon-details")
  self.txtRewardDesc = self:child("LimitedTimeConfirmCommon-reward_desc")
  self.imgLAdorn = self:child("LimitedTimeConfirmCommon-l_adorn")
  self.imgRAdorn0 = self:child("LimitedTimeConfirmCommon-r_adorn_0")
  self.imgDetailsBg = self:child("LimitedTimeConfirmCommon-details_bg")
  self.lytDescPanel = self:child("LimitedTimeConfirmCommon-descPanel")
  self.txtDecText = self:child("LimitedTimeConfirmCommon-dec_text")
  self.imgPriceBg = self:child("LimitedTimeConfirmCommon-priceBg")
  self.imgDiaIcon = self:child("LimitedTimeConfirmCommon-DiaIcon")
  self.txtInitPrice = self:child("LimitedTimeConfirmCommon-InitPrice")
  self.imgLine = self:child("LimitedTimeConfirmCommon-Line")
  self.txtFinalPrice = self:child("LimitedTimeConfirmCommon-finalPrice")
  self.txtSignalPrice = self:child("LimitedTimeConfirmCommon-signalPrice")
  self.imgPerIcon = self:child("LimitedTimeConfirmCommon-PerIcon")
  self.txtPerText1 = self:child("LimitedTimeConfirmCommon-PerText1")
  self.txtPerText2 = self:child("LimitedTimeConfirmCommon-PerText2")
  self.btnClose = self:child("LimitedTimeConfirmCommon-close")
  self.imgCloseImg = self:child("LimitedTimeConfirmCommon-closeImg")
  self.btnCancelBtn = self:child("LimitedTimeConfirmCommon-CancelBtn")
  self.imgCancelIcon = self:child("LimitedTimeConfirmCommon-CancelIcon")
  self.txtCancelText = self:child("LimitedTimeConfirmCommon-CancelText")
  self.btnConfirmBtn = self:child("LimitedTimeConfirmCommon-ConfirmBtn")
  self.imgConfirmIcon = self:child("LimitedTimeConfirmCommon-ConfirmIcon")
  self.txtConfirmText = self:child("LimitedTimeConfirmCommon-ConfirmText")
  self.goodsGridView = UIMgr:new_widget("grid_view", self.lytGoodsPanel)
  self.goodsGridView:SetMoveAble(true)
  self.goodsGridView:SetvScorllMoveAble(false)
  self.goodsGridView:SethScorllMoveAble(true)
  self.goodsGridView:InitConfig(15, 0, 1)
  self.goodsGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.goodsAdapter = UIMgr:new_adapter("common", 89, 89, "limitedTimeConfirmItem", "LimitedTimeConfirmItem.json")
  self.goodsGridView:invoke("setAdapter", self.goodsAdapter)
  self.gvDescTxt = UIMgr:new_widget("grid_view")
  self.lytDescPanel:AddChildWindow(self.gvDescTxt)
  self.gvDescTxt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDescTxt:SetAutoColumnCount(false)
  self.gvDescTxt:InitConfig(0, 5, 1)
  self.gvDescTxt:AddItem(self.txtDecText)
  self.txtPerText2:SetText(Lang:toText("gui.limit.time.combined.off"))
  self.txtCancelText:SetText(Lang:toText("gui.limit.time.activity.cancel.tips"))
  self.txtConfirmText:SetText(Lang:toText("gui.limit.time.activity.confirm.tips"))
end

function WinLimitedTimeConfirmCommon:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnCancelBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnConfirmBtn, UIEvent.EventButtonClick, function()
    if self.activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT then
      Me:clientBuyLimitDiscountGift(self.data)
    elseif self.activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT then
      Me:clientBuyLimitOptionalGift(self.data)
    end
    self:onHide()
  end)
end

function WinLimitedTimeConfirmCommon:subscribeEvent()
end

function WinLimitedTimeConfirmCommon:initView(activityType, data)
  self.activityType = activityType
  self.data = data
  if data.percent and data.percent ~= "" then
    self.imgPerIcon:SetVisible(true)
    self.txtPerText1:SetText(data.percent)
  else
    self.imgPerIcon:SetVisible(false)
  end
  if data.initPrice and data.initPrice > 0 then
    self.txtFinalPrice:SetText(data.finalPrice)
    self.txtInitPrice:SetText(data.initPrice)
    local strW = self.txtInitPrice:GetFont():GetStringWidth(data.initPrice)
    self.imgLine:SetWidth({
      0,
      strW + 10
    })
    self.txtSignalPrice:SetVisible(false)
    self.txtInitPrice:SetVisible(true)
  else
    self.txtInitPrice:SetVisible(false)
    self.txtSignalPrice:SetVisible(true)
    self.txtSignalPrice:SetText(data.finalPrice)
  end
  local totalCount = #data.giftContent
  self.goodsGridView:InitConfig(15, 0, totalCount)
  self.goodsAdapter:setData(data.giftContent)
  local giftDesc = ""
  if totalCount <= 1 then
    self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.buy.one.title"))
    self.txtRewardDesc:SetText(Lang:toText("gui.limit.time.activity.buy.one.desc"))
    local itemInfo = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[1])
    local itemData = LimitedTimeActivityGameMgr:getItemInfo(itemInfo)
    if itemInfo.showName and itemInfo.showName ~= "" then
      self.txtGiftTitle:SetText(Lang:toText(itemInfo.showName or ""))
    else
      self.txtGiftTitle:SetText(Lang:toText(itemData.itemName or ""))
    end
  else
    self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.buy.title"))
    self.txtRewardDesc:SetText(Lang:toText("gui.limit.time.activity.gift.desc"))
    self.txtGiftTitle:SetText(Lang:toText(data.giftName or ""))
  end
  for i = 1, totalCount do
    local itemInfo = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[i])
    if itemInfo then
      local itemData = LimitedTimeActivityGameMgr:getItemInfo(itemInfo)
      local goodsName = ""
      if itemInfo.showName and itemInfo.showName ~= "" then
        goodsName = Lang:toText(itemInfo.showName or "")
      else
        goodsName = Lang:toText(itemData.itemName or "")
      end
      local count = itemData.itemCount or 0
      if count <= 1 then
        if giftDesc ~= "" then
          giftDesc = giftDesc .. "\n"
        end
        giftDesc = giftDesc .. goodsName
      else
        if giftDesc ~= "" then
          giftDesc = giftDesc .. "\n"
        end
        giftDesc = giftDesc .. goodsName .. "x" .. count
      end
      if totalCount == 1 then
        if itemInfo.showDesc and itemInfo.showDesc ~= "" then
          giftDesc = Lang:toText(itemInfo.showDesc)
        else
          giftDesc = goodsName .. "x" .. count
        end
      end
    end
  end
  self.txtDecText:SetText(giftDesc)
end

function WinLimitedTimeConfirmCommon:onHide()
  UI:closeWnd("limitedTimeConfirmCommon")
end

function WinLimitedTimeConfirmCommon:onShow(isShow, activityType, data)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeConfirmCommon", activityType, data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeConfirmCommon:onOpen(activityType, data)
  self:initView(activityType, data)
  self:subscribeEvent()
end

function WinLimitedTimeConfirmCommon:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitedTimeConfirmCommon
