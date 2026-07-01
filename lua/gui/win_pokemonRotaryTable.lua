local WinPokemonRotaryTable = M
local LuaTimer = T(Lib, "LuaTimer")
local PokemonRotaryTableConfig = T(Config, "PokemonRotaryTableConfig")
local RotaryTableTabRes = {
  [Define.RotaryTabType.goldTab] = {
    tableBgResIcon = "set:pokemon_rotary_table.json image:img_0_bottom_gold",
    bigRoundRes = "set:pokemon_rotary_table.json image:img_0_turntable1_gold",
    bigRoundRes2 = "set:pokemon_rotary_table2.json image:img_0_turntable3_gold",
    dotRoundRes1 = "set:pokemon_rotary_table2.json image:img_0_gold_light1",
    dotRoundRes2 = "set:pokemon_rotary_table2.json image:img_0_gold_light2",
    smallRoundRes = "set:pokemon_rotary_table.json image:img_0_turntable2_gold",
    catIconRes = "set:pokemon_rotary_table.json image:img_0_character_gold",
    ruleBgRes = "set:pokemon_rotary_table.json image:img_9_description_gold",
    topArrowRes = "set:pokemon_rotary_table.json image:img_0_arrow1_gold",
    midArrowRes = "set:pokemon_rotary_table.json image:img_0_arrow2_gold",
    selectTabIcon = "set:pokemon_rotary_table.json image:img_0_gold_on",
    normalTabIcon = "set:pokemon_rotary_table.json image:img_0_gold_normal",
    tabTitleSelectColor = {
      1.0,
      0.28627450980392155,
      0.13333333333333333,
      1
    },
    tabTitleNormalColor = {
      0.6941176470588235,
      0.30980392156862746,
      0.027450980392156862,
      1
    },
    ruleTitleBorderColor = tostring(0.9176470588235294) .. " " .. tostring(0.41568627450980394) .. " " .. tostring(0.2196078431372549) .. " 1",
    goTitleTxtColor = {
      1.0,
      0.28627450980392155,
      0.13333333333333333,
      1
    },
    ratioBorderColor = tostring(0.9411764705882353) .. " " .. tostring(0.29411764705882354) .. " " .. tostring(0.1568627450980392) .. " 1"
  },
  [Define.RotaryTabType.candyTab] = {
    tableBgResIcon = "set:pokemon_rotary_table.json image:img_0_bottom_candy",
    bigRoundRes = "set:pokemon_rotary_table.json image:img_0_turntable1_candy",
    bigRoundRes2 = "set:pokemon_rotary_table2.json image:img_0_turntable3_candy",
    dotRoundRes1 = "set:pokemon_rotary_table2.json image:img_0_candy_light1",
    dotRoundRes2 = "set:pokemon_rotary_table2.json image:img_0_candy_light2",
    smallRoundRes = "set:pokemon_rotary_table.json image:img_0_turntable2_candy",
    catIconRes = "set:pokemon_rotary_table.json image:img_0_character_candy",
    ruleBgRes = "set:pokemon_rotary_table.json image:img_9_description_candy",
    topArrowRes = "set:pokemon_rotary_table.json image:img_0_arrow1_candy",
    midArrowRes = "set:pokemon_rotary_table.json image:img_0_arrow2_candy",
    selectTabIcon = "set:pokemon_rotary_table.json image:img_0_candy_on",
    normalTabIcon = "set:pokemon_rotary_table.json image:img_0_candy_normal",
    tabTitleSelectColor = {
      0.984313725490196,
      0.27450980392156865,
      0.5411764705882353,
      1
    },
    tabTitleNormalColor = {
      0.25882352941176473,
      0.3058823529411765,
      0.5803921568627451,
      1
    },
    ruleTitleBorderColor = tostring(0.9411764705882353) .. " " .. tostring(0.6235294117647059) .. " " .. tostring(0.592156862745098) .. " 1",
    goTitleTxtColor = {
      0.984313725490196,
      0.27450980392156865,
      0.5411764705882353,
      1
    },
    ratioBorderColor = tostring(0.0784313725490196) .. " " .. tostring(0.4470588235294118) .. " " .. tostring(1.0) .. " 1"
  }
}

function WinPokemonRotaryTable:init()
  WinBase.init(self, "PokemonRotaryTable.json")
  self:initUI()
  self:initEvent()
end

function WinPokemonRotaryTable:initUI()
  self.lytDraw = self:child("PokemonRotaryTable-Draw")
  self.lytContent = self:child("PokemonRotaryTable-content")
  self.lytMidContent = self:child("PokemonRotaryTable-midContent")
  self.lytTabPanel = self:child("PokemonRotaryTable-tabPanel")
  self.lytTab1 = self:child("PokemonRotaryTable-Tab1")
  self.imgNormalTab1 = self:child("PokemonRotaryTable-normalTab1")
  self.imgSelectTab1 = self:child("PokemonRotaryTable-selectTab1")
  self.imgTabIcon1 = self:child("PokemonRotaryTable-TabIcon1")
  self.txtTabTitle1 = self:child("PokemonRotaryTable-TabTitle1")
  self.lytTab2 = self:child("PokemonRotaryTable-Tab2")
  self.imgNormalTab2 = self:child("PokemonRotaryTable-normalTab2")
  self.imgSelectTab2 = self:child("PokemonRotaryTable-selectTab2")
  self.imgTabIcon2 = self:child("PokemonRotaryTable-TabIcon2")
  self.txtTabTitle2 = self:child("PokemonRotaryTable-TabTitle2")
  self.lytTablePanel = self:child("PokemonRotaryTable-table_panel")
  self.imgTableBg = self:child("PokemonRotaryTable-tableBg")
  self.lytBigRoundPanel = self:child("PokemonRotaryTable-bigRoundPanel")
  self.imgBigRoundBg = self:child("PokemonRotaryTable-bigRoundBg")
  self.imgBigRoundBg2 = self:child("PokemonRotaryTable-bigRoundBg2")
  self.imgRoundDot1 = self:child("PokemonRotaryTable-roundDot1")
  self.imgRoundDot2 = self:child("PokemonRotaryTable-roundDot2")
  self.imgRoundDot3 = self:child("PokemonRotaryTable-roundDot3")
  self.imgRoundDot4 = self:child("PokemonRotaryTable-roundDot4")
  self.imgRoundDot5 = self:child("PokemonRotaryTable-roundDot5")
  self.imgRoundDot6 = self:child("PokemonRotaryTable-roundDot6")
  self.lytSmallRoundPanel = self:child("PokemonRotaryTable-smallRoundPanel")
  self.imgSmallRoundBg = self:child("PokemonRotaryTable-smallRoundBg")
  self.lytArrowPanel = self:child("PokemonRotaryTable-arrowPanel")
  self.imgTopArrow = self:child("PokemonRotaryTable-topArrow")
  self.imgMidArrow = self:child("PokemonRotaryTable-midArrow")
  self.txtGoTxt = self:child("PokemonRotaryTable-GoTxt")
  self.imgArrowDia = self:child("PokemonRotaryTable-arrowDia")
  self.txtArrowPrice = self:child("PokemonRotaryTable-arrowPrice")
  self.lytArrowBtn = self:child("PokemonRotaryTable-arrowBtn")
  self.lytDescPanel = self:child("PokemonRotaryTable-descPanel")
  self.imgDescBg = self:child("PokemonRotaryTable-descBg")
  self.txtDescTitle = self:child("PokemonRotaryTable-descTitle")
  self.lytDescScrollow = self:child("PokemonRotaryTable-descScrollow")
  self.txtDescTxt = self:child("PokemonRotaryTable-descTxt")
  self.imgTopCat = self:child("PokemonRotaryTable-topCat")
  self.btnTakeBtn = self:child("PokemonRotaryTable-takeBtn")
  self.txtTakePrice = self:child("PokemonRotaryTable-takePrice")
  self.imgTakeIcon = self:child("PokemonRotaryTable-takeIcon")
  self.txtCountTips = self:child("PokemonRotaryTable-countTips")
  self.btnBtnClose = self:child("PokemonRotaryTable-BtnClose")
  self.btnShop = self:child("PokemonRotaryTable-Shop")
  self.lytCoverBg = self:child("PokemonRotaryTable-coverBg")
  self.lytCoverBg = self:child("PokemonRotaryTable-coverBg")
  self.imgAwardEffect = self:child("PokemonRotaryTable-awardEffect")
  self.gvDescTxt = UIMgr:new_widget("grid_view")
  self.lytDescScrollow:AddChildWindow(self.gvDescTxt)
  self.gvDescTxt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDescTxt:InitConfig(0, 5, 1)
  self.gvDescTxt:AddItem(self.txtDescTxt)
  self.txtDescTitle:SetText(Lang:toText("gui_rotary_desc_title"))
  self.txtTabTitle1:SetText(Lang:toText("gui_rotary_tab_title1"))
  self.txtTabTitle2:SetText(Lang:toText("gui_rotary_tab_title2"))
  self.txtCountTips:SetText(Lang:toText("gui_rotary_cost_count_tips"))
  self.curSelectTab = Define.RotaryTabType.goldTab
  self.rotationAngle = {
    [Define.RotaryTabType.goldTab] = {
      [1] = {
        0,
        60,
        120,
        180,
        240,
        300
      },
      [2] = {
        0,
        60,
        120,
        180,
        240,
        300
      }
    },
    [Define.RotaryTabType.candyTab] = {
      [1] = {
        0,
        60,
        120,
        180,
        240,
        300
      },
      [2] = {
        0,
        60,
        120,
        180,
        240,
        300
      }
    }
  }
  self.ratioItemList = {}
  self.goodsItemList = {}
  self:initCurrency()
  self:initRatioItem()
  self:initGoodsItem()
  self:adapterUIShow()
end

function WinPokemonRotaryTable:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytMidContent, 1202, 674)
end

function WinPokemonRotaryTable:initCurrency()
  self.llCurrencyMoney = self:child("PokemonRotaryTable-Currency-Money")
  self.llGoldDiamond = self:child("PokemonRotaryTable-Gold-Diamond")
  self.llCashCoupon = self:child("PokemonRotaryTable-Cash-Coupon")
  self.money_currency = UIMgr:new_widget("pokemonRotaryCurrency")
  self.money_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.money_currency:invoke("setCurrencyType", "gold_coin")
  self.llCurrencyMoney:AddChildWindow(self.money_currency)
  local diamonds_currency = UIMgr:new_widget("common_currency")
  diamonds_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  diamonds_currency:invoke("setCurrencyType", World.cfg.useFDiamonds and "fDiamonds" or "gDiamonds")
  self.llGoldDiamond:AddChildWindow(diamonds_currency)
  local cash_coupon = UIMgr:new_widget("common_currency")
  cash_coupon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  cash_coupon:invoke("setCurrencyType", "gameCashCoupon")
  self.llCashCoupon:AddChildWindow(cash_coupon)
end

function WinPokemonRotaryTable:getPosByAngleAndRadius(angle, radius)
  local yaw = angle
  local value = -1 * yaw * 3.14159 / 180
  local s = math.sin(value)
  local c = math.cos(value)
  return Lib.v3(s, c, 0) * radius
end

function WinPokemonRotaryTable:initRatioItem()
  local curAdapterRatio = UIMgr.UIShowManage:getAdapterRatio()
  self.smallItemSize = {
    width = 68 * curAdapterRatio,
    height = 35 * curAdapterRatio,
    radius = 105 * curAdapterRatio
  }
  for i = 1, 6 do
    self.ratioItemList[i] = UIMgr:new_widget("pokemonRotaryRatioItem")
    local itemPos = self:getPosByAngleAndRadius(self.rotationAngle[Define.RotaryTabType.goldTab][1][i], self.smallItemSize.radius)
    self.ratioItemList[i]:SetArea({
      0,
      itemPos.x
    }, {
      0,
      itemPos.y
    }, {
      0,
      self.smallItemSize.width
    }, {
      0,
      self.smallItemSize.height
    })
    self.lytSmallRoundPanel:AddChildWindow(self.ratioItemList[i])
  end
end

function WinPokemonRotaryTable:initGoodsItem()
  local curAdapterRatio = UIMgr.UIShowManage:getAdapterRatio()
  self.bigItemSize = {
    width = 98 * curAdapterRatio,
    height = 98 * curAdapterRatio,
    radius = 205 * curAdapterRatio
  }
  for i = 1, 6 do
    self.goodsItemList[i] = UIMgr:new_widget("pokemonRotaryGoodItem")
    local itemPos = self:getPosByAngleAndRadius(self.rotationAngle[Define.RotaryTabType.goldTab][2][i], self.bigItemSize.radius)
    self.goodsItemList[i]:SetArea({
      0,
      itemPos.x
    }, {
      0,
      itemPos.y
    }, {
      0,
      self.bigItemSize.width
    }, {
      0,
      self.bigItemSize.height
    })
    self.lytBigRoundPanel:AddChildWindow(self.goodsItemList[i])
  end
end

function WinPokemonRotaryTable:initEvent()
  self:subscribe(self.lytTab1, UIEvent.EventWindowClick, function()
    self.curSelectTab = Define.RotaryTabType.goldTab
    self:updateTabViewShow()
    Me:gameBehaviorReport("CandyWheel_btn", 1)
  end)
  self:subscribe(self.lytTab2, UIEvent.EventWindowClick, function()
    self.curSelectTab = Define.RotaryTabType.candyTab
    self:updateTabViewShow()
    Me:gameBehaviorReport("CoinWheel_btn", 1)
  end)
  self:subscribe(self.lytArrowBtn, UIEvent.EventWindowClick, function()
    self:clickTakeRotaryTable()
    if self.curSelectTab == Define.RotaryTabType.goldTab then
      Me:gameBehaviorReport("CoinWheel_go_click", 1)
    else
      Me:gameBehaviorReport("CandyWheel_go_click", 1)
    end
  end)
  self:subscribe(self.btnTakeBtn, UIEvent.EventButtonClick, function()
    self:clickTakeRotaryTable()
    if self.curSelectTab == Define.RotaryTabType.goldTab then
      Me:gameBehaviorReport("CoinWheel_play_click", 1)
    else
      Me:gameBehaviorReport("CandyWheel_play_click", 1)
    end
  end)
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnShop, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("ui", "shop")
    UI:getWnd("pokemon_Shop"):onShow(true)
  end)
end

function WinPokemonRotaryTable:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PUSH_ROTARY_RESULT, function(resultState, resultID)
    if resultState then
      self:startRotateTimer(resultID)
    else
      self:updateCoverBgShow(false)
    end
  end)
end

function WinPokemonRotaryTable:initView(showTab)
  self.curSelectTab = showTab or Define.RotaryTabType.goldTab
  self.rotationAngle = {
    [Define.RotaryTabType.goldTab] = {
      [1] = {
        0,
        60,
        120,
        180,
        240,
        300
      },
      [2] = {
        0,
        60,
        120,
        180,
        240,
        300
      }
    },
    [Define.RotaryTabType.candyTab] = {
      [1] = {
        0,
        60,
        120,
        180,
        240,
        300
      },
      [2] = {
        0,
        60,
        120,
        180,
        240,
        300
      }
    }
  }
  self:updateTabViewShow()
  self:updateCoverBgShow(false)
  self.money_currency:invoke("changeCurrency")
end

function WinPokemonRotaryTable:updateTabViewShow()
  self:stopRotateTimer()
  self.imgTableBg:SetImage(RotaryTableTabRes[self.curSelectTab].tableBgResIcon)
  self.imgBigRoundBg:SetImage(RotaryTableTabRes[self.curSelectTab].bigRoundRes)
  self.imgBigRoundBg2:SetImage(RotaryTableTabRes[self.curSelectTab].bigRoundRes2)
  self.imgRoundDot1:SetImage(RotaryTableTabRes[self.curSelectTab].dotRoundRes1)
  self.imgRoundDot2:SetImage(RotaryTableTabRes[self.curSelectTab].dotRoundRes2)
  self.imgRoundDot3:SetImage(RotaryTableTabRes[self.curSelectTab].dotRoundRes2)
  self.imgRoundDot4:SetImage(RotaryTableTabRes[self.curSelectTab].dotRoundRes1)
  self.imgRoundDot5:SetImage(RotaryTableTabRes[self.curSelectTab].dotRoundRes2)
  self.imgRoundDot6:SetImage(RotaryTableTabRes[self.curSelectTab].dotRoundRes2)
  self.imgSmallRoundBg:SetImage(RotaryTableTabRes[self.curSelectTab].smallRoundRes)
  self.imgTopCat:SetImage(RotaryTableTabRes[self.curSelectTab].catIconRes)
  self.imgDescBg:SetImage(RotaryTableTabRes[self.curSelectTab].ruleBgRes)
  self.imgTopArrow:SetImage(RotaryTableTabRes[self.curSelectTab].topArrowRes)
  self.imgMidArrow:SetImage(RotaryTableTabRes[self.curSelectTab].midArrowRes)
  self.txtGoTxt:SetTextColor(RotaryTableTabRes[self.curSelectTab].goTitleTxtColor)
  self.txtArrowPrice:SetTextColor(RotaryTableTabRes[self.curSelectTab].goTitleTxtColor)
  self.txtDescTitle:SetProperty("TextBorderColor", RotaryTableTabRes[self.curSelectTab].ruleTitleBorderColor)
  for _, tabKey in pairs(Define.RotaryTabType) do
    if tabKey == self.curSelectTab then
      self["imgNormalTab" .. tabKey]:SetVisible(false)
      self["imgSelectTab" .. tabKey]:SetVisible(true)
      self["imgTabIcon" .. tabKey]:SetImage(RotaryTableTabRes[tabKey].selectTabIcon)
      self["txtTabTitle" .. tabKey]:SetTextColor(RotaryTableTabRes[tabKey].tabTitleSelectColor)
    else
      self["imgNormalTab" .. tabKey]:SetVisible(true)
      self["imgSelectTab" .. tabKey]:SetVisible(false)
      self["imgTabIcon" .. tabKey]:SetImage(RotaryTableTabRes[tabKey].normalTabIcon)
      self["txtTabTitle" .. tabKey]:SetTextColor(RotaryTableTabRes[tabKey].tabTitleNormalColor)
    end
  end
  self.txtDescTxt:SetText(Lang:toText("gui_rotary_desc_content" .. self.curSelectTab))
  self:updateTabAwardContent()
  self.imgAwardEffect:SetVisible(false)
end

function WinPokemonRotaryTable:updateTabAwardContent()
  self.goodAwardData = PokemonRotaryTableConfig:getAwardByRotaryType(self.curSelectTab)
  self.ratioAwardData = PokemonRotaryTableConfig:getRatioByRotaryType(self.curSelectTab)
  self.priceData = self.goodAwardData[1]
  local currencyIcon = "set:pokemonMain.json image:icon_coin"
  if self.priceData.currencyType == 0 or self.priceData.currencyType == 4 then
    currencyIcon = "set:pokemonMain.json image:icon_dimond"
  end
  self.imgTakeIcon:SetImage(currencyIcon)
  self.txtTakePrice:SetText(self.priceData.price_num)
  self.imgArrowDia:SetImage(currencyIcon)
  self.txtArrowPrice:SetText(self.priceData.price_num)
  for i = 1, 6 do
    if self.goodAwardData[i] then
      self.goodsItemList[i]:invoke("initItemInfo", self.goodAwardData[i])
      self.goodsItemList[i]:invoke("updateGoodBgShow", self.curSelectTab)
    end
    if self.ratioAwardData[i] then
      self.ratioItemList[i]:invoke("updateItemInfo", self.ratioAwardData[i].ratio_num)
      self.ratioItemList[i]:invoke("updateItemBorderColor", RotaryTableTabRes[self.curSelectTab].ratioBorderColor)
    end
  end
  self:updateRoundPosWithAngle(1)
  self:updateRoundPosWithAngle(2)
  self:updateGoodAwardEffectShow(false)
end

function WinPokemonRotaryTable:updateRoundPosWithAngle(roundKey)
  if roundKey == 1 then
    for i = 1, 6 do
      local itemPos = self:getPosByAngleAndRadius(self.rotationAngle[self.curSelectTab][1][i], self.smallItemSize.radius)
      self.ratioItemList[i]:SetXPosition({
        0,
        itemPos.x
      })
      self.ratioItemList[i]:SetYPosition({
        0,
        itemPos.y
      })
    end
  elseif roundKey == 2 then
    self.imgBigRoundBg2:SetProperty("Rotate", self.rotationAngle[self.curSelectTab][2][1])
    for i = 1, 6 do
      local itemPos = self:getPosByAngleAndRadius(self.rotationAngle[self.curSelectTab][2][i], self.bigItemSize.radius)
      self.goodsItemList[i]:SetXPosition({
        0,
        itemPos.x
      })
      self.goodsItemList[i]:SetYPosition({
        0,
        itemPos.y
      })
    end
  end
end

function WinPokemonRotaryTable:updateRotateAngle(roundKey, changeNum)
  for i = 1, 6 do
    self.rotationAngle[self.curSelectTab][roundKey][i] = changeNum % 360 + (i - 1) * 60
  end
  self:updateRoundPosWithAngle(roundKey)
end

function WinPokemonRotaryTable:getTargetRotateAngle(roundKey, targetPos, initAngle)
  local bottomPos = {
    [1] = 4,
    [2] = 5,
    [3] = 6,
    [4] = 1,
    [5] = 2,
    [6] = 3
  }
  local resultPos = bottomPos[targetPos]
  local targetAngle
  if roundKey == 1 then
    targetAngle = -(resultPos - 1) * 60
  else
    targetAngle = 60 * (7 - resultPos)
  end
  local changeAngle = 0
  while true do
    changeAngle = changeAngle + 60
    local curAngle
    if roundKey == 1 then
      curAngle = initAngle - changeAngle
    else
      curAngle = initAngle + changeAngle
    end
    if curAngle % 360 == targetAngle % 360 then
      return changeAngle
    end
  end
end

function WinPokemonRotaryTable:startRotateTimer(resultID)
  self:stopRotateTimer()
  self.imgAwardEffect:SetVisible(false)
  if self.takeSoundSit then
    Me:stopSound(self.takeSoundSit)
  end
  self.takeSoundSit = Me:playSoundByKey("ui_rotary_table_speed")
  self:updateGoodAwardEffectShow(false)
  local rotaryTableAnimation = World.cfg.rotaryTableAnimation
  self.curChangeAngle = {0, 0}
  local refersTime = rotaryTableAnimation.rotaryTableRefreshTime
  local firstChangeAngle = {
    self.rotationAngle[self.curSelectTab][1][1],
    self.rotationAngle[self.curSelectTab][2][1]
  }
  local resultData = PokemonRotaryTableConfig:getCfgById(resultID)
  local needRatioAngle = self:getTargetRotateAngle(1, resultData.ratio_pos, firstChangeAngle[1])
  local needAwardAngle = self:getTargetRotateAngle(2, resultData.award_pos, firstChangeAngle[2])
  local needChangeAngle = {
    360 * rotaryTableAnimation.rotaryTableSlowNum + needRatioAngle,
    360 * rotaryTableAnimation.rotaryTableSlowNum + needAwardAngle
  }
  local totalT = rotaryTableAnimation.rotaryTableSpeedDownTime / refersTime
  local totalG1 = needChangeAngle[1] * 2 / totalT / totalT
  local totalG2 = needChangeAngle[2] * 2 / totalT / totalT
  local totalV1 = totalG1 * totalT
  local totalV2 = totalG2 * totalT
  self.totalPassTime = 0
  local speedUpIsEnd = false
  local slowDownIsEnd = false
  self.rotateDownTimer = LuaTimer:scheduleTimer(function()
    self.totalPassTime = self.totalPassTime + refersTime
    if not speedUpIsEnd then
      local curT = self.totalPassTime / refersTime
      local speedUpTotalT = rotaryTableAnimation.rotaryTableSpeedUpTime / refersTime
      local onceAngle = 0
      if speedUpTotalT ~= 0 then
        onceAngle = 360 * rotaryTableAnimation.rotaryTableFastNum / speedUpTotalT
      end
      self.curChangeAngle[1] = self.curChangeAngle[1] + onceAngle
      self.curChangeAngle[2] = self.curChangeAngle[2] + onceAngle
      self:updateRotateAngle(1, firstChangeAngle[1] - self.curChangeAngle[1])
      self:updateRotateAngle(2, firstChangeAngle[2] + self.curChangeAngle[2])
      if curT >= speedUpTotalT then
        speedUpIsEnd = true
        self.curChangeAngle = {0, 0}
        self.totalPassTime = 0
      end
    elseif speedUpIsEnd and not slowDownIsEnd then
      local curT = self.totalPassTime / refersTime
      self.curChangeAngle[1] = totalV1 * curT - totalG1 * curT * curT / 2
      self.curChangeAngle[2] = totalV2 * curT - totalG2 * curT * curT / 2
      self:updateRotateAngle(1, firstChangeAngle[1] - self.curChangeAngle[1])
      self:updateRotateAngle(2, firstChangeAngle[2] + self.curChangeAngle[2])
      if curT >= totalT then
        slowDownIsEnd = true
        self:showAwardEffect()
        self:updateGoodAwardEffectShow(true, resultData.award_pos)
        self.totalPassTime = 0
      end
    elseif speedUpIsEnd and slowDownIsEnd and self.totalPassTime >= 600 then
      self:updateCoverBgShow(false)
      self:stopRotateTimer()
      self.money_currency:invoke("changeCurrency")
      UI:getWnd("pokemonRotaryResult"):onShow(true, self.curSelectTab, resultID)
      self.totalPassTime = 0
    end
  end, refersTime, -1)
end

function WinPokemonRotaryTable:stopRotateTimer()
  if self.rotateDownTimer then
    LuaTimer:cancel(self.rotateDownTimer)
    self.rotateDownTimer = nil
  end
end

function WinPokemonRotaryTable:showAwardEffect()
  self.imgAwardEffect:SetVisible(true)
  if self.curSelectTab == Define.RotaryTabType.goldTab then
    self.imgAwardEffect:UnprepareEffect()
    self.imgAwardEffect:SetEffectName("g2038_zhuanpan_5.effect")
  else
    self.imgAwardEffect:UnprepareEffect()
    self.imgAwardEffect:SetEffectName("g2038_zhuanpan_6.effect")
  end
end

function WinPokemonRotaryTable:updateGoodAwardEffectShow(isShow, award_pos)
  for i = 1, 6 do
    if self.goodAwardData[i] then
      if isShow then
        self.goodsItemList[i]:invoke("updateSelectState", award_pos == i)
      else
        self.goodsItemList[i]:invoke("updateSelectState", isShow)
      end
    end
  end
end

function WinPokemonRotaryTable:updateCoverBgShow(show)
  self.lytCoverBg:SetVisible(show)
end

function M:clickTakeRotaryTable()
  if not self.priceData then
    return
  end
  if self.lytCoverBg:IsVisible() then
    return
  end
  if Me:isInPreBattleOrBattle() then
    return
  end
  local priceData = self.priceData
  if self:checkItemMoney(priceData) then
    local packet = {
      pid = "takeRotaryTableAward",
      tabType = self.curSelectTab
    }
    Me:sendPacket(packet)
    self:updateCoverBgShow(true)
    Me:playSoundByKey("ui_rotary_table_btn")
  elseif priceData.currencyType == 3 then
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
end

function WinPokemonRotaryTable:checkItemMoney(priceData)
  if priceData.isPay then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if asset >= priceData.price_num then
        return true
      else
      end
    end
  else
    if Coin:countByCoinName(Me, Coin:coinNameByCoinId(priceData.currencyType)) >= priceData.price_num then
      return true
    else
    end
  end
  return false
end

function WinPokemonRotaryTable:onHide()
  UI:closeWnd("pokemonRotaryTable")
end

function WinPokemonRotaryTable:onShow(isShow, showTab)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonRotaryTable", showTab)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPokemonRotaryTable:onOpen(showTab)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(showTab)
end

function WinPokemonRotaryTable:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:stopRotateTimer()
  if self.takeSoundSit then
    Me:stopSound(self.takeSoundSit)
  end
end

return WinPokemonRotaryTable
