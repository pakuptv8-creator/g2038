local GoldExchangeHotContent = World.cfg.goldExchangeHotContent

function M:init()
  WinBase.init(self, "PokemonGoldExchange.json", false)
  self:initUI()
end

function M:initUI()
  self.curSelectTab = 2
  self.tsTitle = self:child("PokemonGoldExchange-title_text")
  self.tsTitle:SetText(Lang:toText("gui_gold_exchange"))
  self.tabPanel = self:child("PokemonGoldExchange-tab-panel")
  self.tabBtn1 = self:child("PokemonGoldExchange-tabBtn1")
  self.tabBtnHot1 = self:child("PokemonGoldExchange-tab-hot1")
  self.tabBtnHot2 = self:child("PokemonGoldExchange-tab-hot2")
  self.tabBtn2 = self:child("PokemonGoldExchange-tabBtn2")
  self.tabBtnNor1 = self:child("PokemonGoldExchange-tab-normal1")
  self.tabBtnNor2 = self:child("PokemonGoldExchange-tab-normal2")
  self.normalPanel = self:child("PokemonGoldExchange-bg")
  self.hotPanel = self:child("CandyWorldHotExchange-bg")
  self.tsCubeNum = self:child("PokemonGoldExchange-cube_num")
  self.tsGoldNum = self:child("PokemonGoldExchange-gold_num")
  self.tsPbNum = self:child("PokemonGoldExchange-progress_text")
  self.btnClose = self:child("PokemonGoldExchange-close_btn")
  self.btnSub = self:child("PokemonGoldExchange-sub_btn")
  self.btnAdd = self:child("PokemonGoldExchange-add_btn")
  self.btnMax = self:child("PokemonGoldExchange-max_btn")
  self.btnConfirm = self:child("PokemonGoldExchange-confirm_btn")
  self.btnCancel = self:child("PokemonGoldExchange-cancel_btn")
  self.sdQuantity = self:child("PokemonGoldExchange-slider")
  self.curHotBuyCount = 1
  self.txtHotBuyState = self:child("CandyWorldHotExchange-buy-counts")
  self.txtHotExchangeNum = self:child("CandyWorldHotExchange-change-txt")
  self.btnHotSub = self:child("CandyWorldHotExchange-sub_btn")
  self.txtHotExchangeCount = self:child("CandyWorldHotExchange-change_counts")
  self.btnHotAdd = self:child("CandyWorldHotExchange-add_btn")
  self.btnHotMax = self:child("CandyWorldHotExchange-max_btn")
  self.btnHotBuy = self:child("CandyWorldHotExchange-buy_btn")
  self.buyHotDisPanel = self:child("PokemonGoldExchange-dis-hot-buy")
  self.txtHotFirstPrice = self:child("PokemonGoldExchange-hot_first_price")
  self.txtHotNowPrice = self:child("PokemonGoldExchange-hot_now_price")
  self.buyHotNorPanel = self:child("PokemonGoldExchange-normal-hot-buy")
  self.txtBuyHotPrice = self:child("PokemonGoldExchange-hot_buy_price")
  self:initEvent()
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("pokemon_gold_exchange")
  end)
  self:subscribe(self.btnSub, UIEvent.EventButtonClick, function()
    self:setExchangeInfoByGrade(self.grade - 1)
  end)
  self:subscribe(self.btnAdd, UIEvent.EventButtonClick, function()
    self:setExchangeInfoByGrade(self.grade + 1)
  end)
  self:subscribe(self.btnMax, UIEvent.EventButtonClick, function()
    local Contents = World.cfg.goldCoinExchangeContent
    self:setExchangeInfoByGrade(#Contents)
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    if self:checkItemMoney(self.cube) then
      local textContent = string.format(Lang:toText("gui_exchange_tips"), self.cube, self.gold)
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", textContent, function(ret)
        if not ret then
          return
        end
        local packet = {
          pid = "GetGoldByExchanging",
          grade = self.grade
        }
        Me:sendPacket(packet)
        UI:closeWnd("pokemon_gold_exchange")
        Me:playSoundByKey("exchange_gold")
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
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    UI:closeWnd("pokemon_gold_exchange")
  end)
  self:subscribe(self.sdQuantity, UIEvent.EventWindowTouchUp, function()
    local progress = self.sdQuantity:GetProgress()
    self:setExchangeInfo(progress)
  end)
  self:subscribe(self.sdQuantity, UIEvent.EventWindowTouchMove, function()
    local progress = self.sdQuantity:GetProgress()
    self:setExchangeInfo(progress)
  end)
  self:subscribe(self.sdQuantity, UIEvent.EventMotionRelease, function()
    self:adjustQuantitySlider()
  end)
  self:subscribe(self.tabBtn1, UIEvent.EventWindowClick, function()
    self.curSelectTab = 1
    self:updatePanelShow()
  end)
  self:subscribe(self.tabBtn2, UIEvent.EventWindowClick, function()
    self.curSelectTab = 2
    self:updatePanelShow()
  end)
  self:subscribe(self.btnHotSub, UIEvent.EventButtonClick, function()
    self:updateHotPanelShow(self.curHotBuyCount - 1)
  end)
  self:subscribe(self.btnHotAdd, UIEvent.EventButtonClick, function()
    self:updateHotPanelShow(self.curHotBuyCount + 1)
  end)
  self:subscribe(self.btnHotMax, UIEvent.EventButtonClick, function()
    self:updateHotPanelShow(GoldExchangeHotContent.limitCount)
  end)
  self:subscribe(self.btnHotBuy, UIEvent.EventButtonClick, function()
    local cubeCost = self.curHotBuyCount * GoldExchangeHotContent.onceCube
    local gainGold = self.curHotBuyCount * GoldExchangeHotContent.onceGold
    if self:checkItemMoney(cubeCost) then
      local textContent = string.format(Lang:toText("gui_exchange_tips"), cubeCost, gainGold)
      UI:openWnd("commonDialog"):initView({
        content = textContent,
        contentCenter = true,
        txtTitle = Lang:toText("gui_tip"),
        hideClose = true,
        leftCb = function()
        end,
        rightCb = function()
          local packet = {
            pid = "GetGoldHotExchanging",
            count = self.curHotBuyCount
          }
          Me:sendPacket(packet)
          UI:closeWnd("pokemon_gold_exchange")
        end
      })
    end
  end)
end

function M:updatePanelShow()
  if self.curSelectTab == 2 then
    self.normalPanel:SetVisible(true)
    self.hotPanel:SetVisible(false)
    self.tabBtnNor1:SetVisible(false)
    self.tabBtnNor2:SetVisible(true)
    self.tabBtnHot1:SetVisible(true)
    self.tabBtnHot2:SetVisible(false)
    self:setExchangeInfoByGrade(1)
  else
    self.normalPanel:SetVisible(false)
    self.hotPanel:SetVisible(true)
    self.tabBtnNor2:SetVisible(false)
    self.tabBtnNor1:SetVisible(true)
    self.tabBtnHot2:SetVisible(true)
    self.tabBtnHot1:SetVisible(false)
    self:updateHotPanelShow(1)
  end
end

function M:initTabPanelShow()
  self.curSelectTab = 2
  self.tabPanel:SetVisible(false)
  self:updatePanelShow()
end

function M:updateHotPanelShow(count)
  local stateStr = string.format(Lang:toText("gui_gold_exchange_limit"), self.goldHotExchangeCount, GoldExchangeHotContent.limitCount)
  self.txtHotBuyState:SetText(stateStr)
  if self.goldHotExchangeCount + count > GoldExchangeHotContent.limitCount then
    self.curHotBuyCount = GoldExchangeHotContent.limitCount - self.goldHotExchangeCount
  else
    self.curHotBuyCount = count
  end
  if self.curHotBuyCount <= 0 then
    self.curHotBuyCount = 1
  end
  local gainCount = math.floor(GoldExchangeHotContent.onceGold * self.curHotBuyCount)
  self.txtHotExchangeNum:SetText("x" .. gainCount)
  self.txtHotExchangeCount:SetText(self.curHotBuyCount)
  if GoldExchangeHotContent.onceOriginalCube == GoldExchangeHotContent.onceCube then
    self.buyHotDisPanel:SetVisible(false)
    self.buyHotNorPanel:SetVisible(true)
    self.txtBuyHotPrice:SetText(self.curHotBuyCount * GoldExchangeHotContent.onceCube)
  else
    self.buyHotDisPanel:SetVisible(true)
    self.buyHotNorPanel:SetVisible(false)
    self.txtHotFirstPrice:SetText(self.curHotBuyCount * GoldExchangeHotContent.onceOriginalCube)
    self.txtHotNowPrice:SetText(self.curHotBuyCount * GoldExchangeHotContent.onceCube)
  end
  if self.goldHotExchangeCount >= GoldExchangeHotContent.limitCount then
    self.btnHotBuy:SetTouchable(false)
    self.btnHotBuy:SetEnabled(false)
  else
    self.btnHotBuy:SetTouchable(true)
    self.btnHotBuy:SetEnabled(true)
  end
end

function M:setExchangeInfo(progress)
  local Contents = World.cfg.goldCoinExchangeContent
  local ratio = math.floor(progress * (#Contents - 1) + 0.5)
  local nowProgress = ratio / (#Contents - 1)
  if self.progress ~= nowProgress then
    self.progress = nowProgress
    self.grade = ratio + 1
    local amount = Contents[self.grade]
    self.cube = amount.cube
    self.gold = amount.gold
    self.tsCubeNum:SetText(amount.cube)
    self.tsGoldNum:SetText(amount.gold)
    self.tsPbNum:SetText(amount.cube .. "/" .. Contents[#Contents].cube)
  end
end

function M:adjustQuantitySlider()
  self.sdQuantity:SetProgress(self.progress)
end

function M:setExchangeInfoByGrade(grade)
  local Contents = World.cfg.goldCoinExchangeContent
  if 0 < grade and grade <= #Contents then
    self.grade = grade
    self.progress = (grade - 1) / (#Contents - 1)
    local amount = Contents[grade]
    self.cube = amount.cube
    self.gold = amount.gold
    self.tsCubeNum:SetText(amount.cube)
    self.tsGoldNum:SetText(amount.gold)
    self.tsPbNum:SetText(amount.cube .. "/" .. Contents[#Contents].cube)
    self:adjustQuantitySlider()
  end
end

function M:checkItemMoney(cubeCost)
  if not World.cfg.useFDiamonds then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if cubeCost <= asset then
        return true
      else
      end
    end
  else
    if cubeCost <= Coin:countByCoinName(Me, Coin:coinNameByCoinId(4)) then
      return true
    else
    end
  end
  return false
end

function M:onOpen()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
  self:initTabPanelShow()
end

function M:onClose()
end

return M
