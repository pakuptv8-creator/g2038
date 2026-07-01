local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
local RegularGiftConfig = T(Config, "RegularGiftConfig")
local LuaTimer = T(Lib, "LuaTimer")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local giftTypeBgRes = {
  [1] = {
    darkBgRes = "set:pokemon_regular_gift.json image:img_0_green_dark",
    lightBgRes = "set:pokemon_regular_gift.json image:img_0_green_light",
    titleBgRes = "set:pokemon_regular_gift.json image:img_9_giftnameboard_green",
    giftIconRes = "set:pokemon_regular_gift.json image:img_0_regulargift_1"
  },
  [2] = {
    darkBgRes = "set:pokemon_regular_gift.json image:img_0_blue_dark",
    lightBgRes = "set:pokemon_regular_gift.json image:img_0_blue_light",
    titleBgRes = "set:pokemon_regular_gift.json image:img_9_giftnameboard_blue",
    giftIconRes = "set:pokemon_regular_gift.json image:img_0_regulargift_2"
  },
  [3] = {
    darkBgRes = "set:pokemon_regular_gift.json image:img_0_purple_dark",
    lightBgRes = "set:pokemon_regular_gift.json image:img_0_purple_light",
    titleBgRes = "set:pokemon_regular_gift.json image:img_9_giftnameboard_purple",
    giftIconRes = "set:pokemon_regular_gift.json image:img_0_regulargift_3"
  }
}

function M:init()
  widget_base.init(self, "PokemonRegularItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonRegularItemPanel = self:child("PokemonRegularItem-Panel")
  self.imgPokemonRegularItemBg1 = self:child("PokemonRegularItem-Bg1")
  self.imgPokemonRegularItemBg2 = self:child("PokemonRegularItem-Bg2")
  self.imgPokemonRegularItemGiftIcon = self:child("PokemonRegularItem-gift-icon")
  self.lytPokemonRegularItemTitlePanel = self:child("PokemonRegularItem-titlePanel")
  self.imgPokemonRegularItemTitleBg = self:child("PokemonRegularItem-TitleBg")
  self.txtPokemonRegularItemTitleTxt = self:child("PokemonRegularItem-TitleTxt")
  self.txtPokemonRegularItemRemainCounts = self:child("PokemonRegularItem-remainCounts")
  self.btnPokemonRegularItemBuyBtn = self:child("PokemonRegularItem-buyBtn")
  self.lytPokemonRegularItemBtnDiscount = self:child("PokemonRegularItem-btn-discount")
  self.imgPokemonRegularItemDisDiaIcon = self:child("PokemonRegularItem-dis-diaIcon")
  self.txtPokemonRegularItemDisPrice = self:child("PokemonRegularItem-dis-price")
  self.txtPokemonRegularItemDisFirstPrice = self:child("PokemonRegularItem-dis-firstPrice")
  self.imgPokemonRegularItemDisLine = self:child("PokemonRegularItem-dis-line")
  self.lytPokemonRegularItemBtnNorCount = self:child("PokemonRegularItem-btn-norCount")
  self.imgPokemonRegularItemNorDiaIcon = self:child("PokemonRegularItem-nor-diaIcon")
  self.txtPokemonRegularItemNorPrice = self:child("PokemonRegularItem-nor-price")
  self.imgPokemonRegularItemTimeIcon = self:child("PokemonRegularItem-timeIcon")
  self.txtPokemonRegularItemRemainTime = self:child("PokemonRegularItem-remainTime")
  self.lytPokemonRegularItemGoodsPanel = self:child("PokemonRegularItem-goodsPanel")
  self.lytPokemonRegularItemGoodItem1 = self:child("PokemonRegularItem-goodItem1")
  self.imgPokemonRegularItemGoodItemBg1 = self:child("PokemonRegularItem-goodItemBg1")
  self.imgPokemonRegularItemGoodItemIcon1 = self:child("PokemonRegularItem-goodItemIcon1")
  self.txtPokemonRegularItemGoodItemNum1 = self:child("PokemonRegularItem-goodItemNum1")
  self.lytPokemonRegularItemGoodItem2 = self:child("PokemonRegularItem-goodItem2")
  self.imgPokemonRegularItemGoodItemBg2 = self:child("PokemonRegularItem-goodItemBg2")
  self.imgPokemonRegularItemGoodItemIcon2 = self:child("PokemonRegularItem-goodItemIcon2")
  self.txtPokemonRegularItemGoodItemNum2 = self:child("PokemonRegularItem-goodItemNum2")
  self.lytPokemonRegularItemGoodItem3 = self:child("PokemonRegularItem-goodItem3")
  self.imgPokemonRegularItemGoodItemBg3 = self:child("PokemonRegularItem-goodItemBg3")
  self.imgPokemonRegularItemGoodItemIcon3 = self:child("PokemonRegularItem-goodItemIcon3")
  self.txtPokemonRegularItemGoodItemNum3 = self:child("PokemonRegularItem-goodItemNum3")
  self.lytPokemonRegularItemGoodItem4 = self:child("PokemonRegularItem-goodItem4")
  self.imgPokemonRegularItemGoodItemBg4 = self:child("PokemonRegularItem-goodItemBg4")
  self.imgPokemonRegularItemGoodItemIcon4 = self:child("PokemonRegularItem-goodItemIcon4")
  self.txtPokemonRegularItemGoodItemNum4 = self:child("PokemonRegularItem-goodItemNum4")
  self.lytPokemonRegularItemGoodItem5 = self:child("PokemonRegularItem-goodItem5")
  self.imgPokemonRegularItemGoodItemBg5 = self:child("PokemonRegularItem-goodItemBg5")
  self.imgPokemonRegularItemGoodItemIcon5 = self:child("PokemonRegularItem-goodItemIcon5")
  self.txtPokemonRegularItemGoodItemNum5 = self:child("PokemonRegularItem-goodItemNum5")
  self.lytPokemonRegularItemGoodItem6 = self:child("PokemonRegularItem-goodItem6")
  self.imgPokemonRegularItemGoodItemBg6 = self:child("PokemonRegularItem-goodItemBg6")
  self.imgPokemonRegularItemGoodItemIcon6 = self:child("PokemonRegularItem-goodItemIcon6")
  self.txtPokemonRegularItemGoodItemNum6 = self:child("PokemonRegularItem-goodItemNum6")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemonRegularItem btnPokemonRegularItemBuyBtn event : EventButtonClick", self.btnPokemonRegularItemBuyBtn, UIEvent.EventButtonClick, function()
    if os.time() - UI:getWnd("pokemonRegularGift").isBuyingRegularTime <= 0 then
      return
    end
    if UI:getWnd("pokemonRegularGift").isBuyingRegularBtn then
      return
    end
    local item = RegularGiftConfig:getConfigById(self.itemData.id)
    if self:checkItemMoney(item) then
      UI:getWnd("pokemonRegularGift").isBuyingRegularBtn = true
      UI:getWnd("pokemonRegularGift").isBuyingRegularTime = os.time()
      Me:sendPacket({
        pid = "requestBugRegularGift",
        itemId = self.itemData.id,
        buyCount = 1
      }, function(success)
        if success then
          Me:playSoundByKey("buy_success")
        end
      end)
    elseif item.currencyType == 3 then
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_not_sufficient_funds", function(ret)
        if not ret then
          return
        end
        UI:openWnd("pokemon_gold_exchange")
      end)
    else
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_lack_money", function(ret)
        if not ret then
          return
        end
        Interface.onRecharge(1)
      end)
    end
  end)
  for i = 1, 6 do
    self:subscribe(self["lytPokemonRegularItemGoodItem" .. i], UIEvent.EventWindowClick, function(window, dx, dy)
      if self.fullNameList[i] then
        UI:getWnd("pokemonItemDetail"):onShow(self.fullNameList[i], dx, dy)
      end
    end)
  end
end

function M:checkItemMoney(item)
  local totalPrice = item.finalPrice
  if totalPrice == 0 then
    return true
  elseif item.isPay then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if totalPrice <= asset then
        return true
      else
      end
    end
  else
    if totalPrice <= Coin:countByCoinName(Me, Coin:coinNameByCoinId(item.currencyType)) then
      return true
    else
    end
  end
  return false
end

function M:initRegularGiftItem(data)
  self.itemData = data
  local parentType = Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED
  local parentKey
  if self.itemData.tabId == 1 then
    parentKey = "RegularGiftTabDayBtn"
  elseif self.itemData.tabId == 2 then
    parentKey = "RegularGiftTabWeekBtn"
  elseif self.itemData.tabId == 3 then
    parentKey = "RegularGiftTabMonthBtn"
  end
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_BUY_BTN_RED, self.btnPokemonRegularItemBuyBtn, 0, 0, self.itemData.id, nil, parentType, parentKey)
  self.imgPokemonRegularItemBg1:SetImage(giftTypeBgRes[data.giftType].darkBgRes)
  self.imgPokemonRegularItemBg2:SetImage(giftTypeBgRes[data.giftType].lightBgRes)
  self.imgPokemonRegularItemTitleBg:SetImage(giftTypeBgRes[data.giftType].titleBgRes)
  self.imgPokemonRegularItemGiftIcon:SetImage(data.giftTypeIcon)
  self.txtPokemonRegularItemTitleTxt:SetText(Lang:toText(data.giftName))
  if data.discount == 0 then
    self.lytPokemonRegularItemBtnNorCount:SetVisible(true)
    self.lytPokemonRegularItemBtnDiscount:SetVisible(false)
    self.txtPokemonRegularItemNorPrice:SetText(data.finalPrice)
  else
    self.lytPokemonRegularItemBtnDiscount:SetVisible(true)
    self.lytPokemonRegularItemBtnNorCount:SetVisible(false)
    self.txtPokemonRegularItemDisFirstPrice:SetText(data.originalPrice)
    self.txtPokemonRegularItemDisPrice:SetText(data.finalPrice)
  end
  local currencyIcon = "set:pokemonMain.json image:icon_coin"
  if data.currencyType == 0 or data.currencyType == 4 then
    currencyIcon = "set:pokemonMain.json image:icon_dimond"
  end
  self.imgPokemonRegularItemDisDiaIcon:SetImage(currencyIcon)
  self.imgPokemonRegularItemNorDiaIcon:SetImage(currencyIcon)
  self:initGoodList(data.giftContent)
end

function M:initGoodList(giftContent)
  self.fullNameList = {}
  for i = 1, 6 do
    if giftContent[i] then
      self["lytPokemonRegularItemGoodItem" .. i]:SetVisible(true)
      local goodInfo = RegularGiftItemConfig:getConfigById(giftContent[i])
      self["txtPokemonRegularItemGoodItemNum" .. i]:SetText(tostring(BigInteger.Create(goodInfo.itemCount)))
      self["imgPokemonRegularItemGoodItemBg" .. i]:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", goodInfo.rarity))
      if goodInfo.itemType == 1 then
        local setting = require("common.setting")
        local cfg = setting:fetch("item", goodInfo.itemName)
        self.fullNameList[i] = goodInfo.itemName
        if cfg then
          self["imgPokemonRegularItemGoodItemIcon" .. i]:SetImage(cfg.icon)
        end
      else
        self.fullNameList[i] = nil
        self["imgPokemonRegularItemGoodItemIcon" .. i]:SetImage(goodInfo.icon)
      end
    else
      self["lytPokemonRegularItemGoodItem" .. i]:SetVisible(false)
    end
  end
  if #giftContent == 2 then
    local firstXPos1 = self.lytPokemonRegularItemGoodItem1:GetXPosition()
    self.lytPokemonRegularItemGoodItem1:SetXPosition({
      firstXPos1[1],
      firstXPos1[2] - 39.0
    })
    local firstXPos2 = self.lytPokemonRegularItemGoodItem2:GetXPosition()
    self.lytPokemonRegularItemGoodItem2:SetXPosition({
      firstXPos2[1],
      firstXPos2[2] - 39.0
    })
  end
end

function M:updateRemainCounts(curBuyNum)
  if self.itemData.buyCount > 0 then
    local remainCount = self.itemData.buyCount - curBuyNum
    self.txtPokemonRegularItemRemainCounts:SetVisible(true)
    local countTxt = string.format(Lang:toText("gui_regular_remain_count"), remainCount)
    self.txtPokemonRegularItemRemainCounts:SetText(countTxt)
    if 0 < remainCount then
      self.btnPokemonRegularItemBuyBtn:SetEnabled(true)
      self.btnPokemonRegularItemBuyBtn:SetTouchable(true)
      if self.itemData.finalPrice == 0 then
        UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_BUY_BTN_RED, true, nil, nil, self.itemData.id)
      else
        UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_BUY_BTN_RED, false, nil, nil, self.itemData.id)
      end
    else
      self.btnPokemonRegularItemBuyBtn:SetEnabled(false)
      self.btnPokemonRegularItemBuyBtn:SetTouchable(false)
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_BUY_BTN_RED, false, nil, nil, self.itemData.id)
    end
  else
    self.txtPokemonRegularItemRemainCounts:SetVisible(false)
    self.btnPokemonRegularItemBuyBtn:SetEnabled(true)
    self.btnPokemonRegularItemBuyBtn:SetTouchable(true)
    if self.itemData.finalPrice == 0 then
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_BUY_BTN_RED, true, nil, nil, self.itemData.id)
    else
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_BUY_BTN_RED, false, nil, nil, self.itemData.id)
    end
  end
end

function M:updateRefreshTime(curTime)
  local remainTime
  if self.itemData.tabId == 1 then
    remainTime = Lib.getDayEndTime(curTime) - curTime
  elseif self.itemData.tabId == 2 then
    remainTime = Lib.getWeekEndTime(curTime) + 86400 - curTime
  elseif self.itemData.tabId == 3 then
    remainTime = Lib.getMonthEndTime(curTime) - curTime
  end
  if remainTime < 0 then
    remainTime = 0
  end
  local timeDay = math.floor(remainTime / 86400)
  if 0 < timeDay then
    local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(remainTime))
    text = timeDay .. "D:" .. text
    self.txtPokemonRegularItemRemainTime:SetText(text)
  else
    local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(remainTime))
    self.txtPokemonRegularItemRemainTime:SetText(text)
  end
end

function M:getItemId()
  return self.itemData.id
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
