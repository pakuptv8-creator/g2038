local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
local LuaTimer = T(Lib, "LuaTimer")
local subscribeEvent = require("script_client.event_cache")

function M:init()
  WinBase.init(self, "PokemonGiftBag.json", false)
  self.giftType = Define.TRIGGER_GIFT_TYPE.GROW
  self.giftData = {}
  self.giftCells = {}
  self.giftItemCells = {}
  self.showByGiftId = nil
  self.curGiftTime = 0
  self.curIndex = 0
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonGiftBagWnd = self:child("PokemonGiftBag-wnd")
  self.lytPokemonGiftBagGiftItemsList = self:child("PokemonGiftBag-gift_items_list")
  self.btnPokemonGiftBagBuy = self:child("PokemonGiftBag-buy")
  self.imgPokemonGiftBagCurrencyIcon = self:child("PokemonGiftBag-currency_icon")
  self.txtPokemonGiftBagCurrencyNum = self:child("PokemonGiftBag-currency_num")
  self:child("PokemonGiftBag-original_price"):SetText(Lang:toText("ui_original_price"))
  self.imgPokemonGiftBagOriginalPriceIcon = self:child("PokemonGiftBag-original_price_icon")
  self.txtPokemonGiftBagOriginalPriceNum = self:child("PokemonGiftBag-original_price_num")
  self.lytPokemonGiftBagLedgement = self:child("PokemonGiftBag-ledgement")
  self.btnPokemonGiftBagClose = self:child("PokemonGiftBag-close")
  self.btnPokemonGiftBagLeft = self:child("PokemonGiftBag-left")
  self.btnPokemonGiftBagRight = self:child("PokemonGiftBag-right")
  self.lytPokemonGiftBagGiftList = self:child("PokemonGiftBag-gift_list")
  self.lytPokemonGiftBagGiftInfo = {}
  self.imgPokemonGiftBagPokemonIcon = {}
  self.txtPokemonGiftBagPercentText = {}
  self.txtPokemonGiftBagTitleText = {}
  self.txtPokemonGiftBagRemainingTimeNum = {}
  for i = 1, 2 do
    self.lytPokemonGiftBagGiftInfo[i] = self:child(string.format("PokemonGiftBag-gift_info_%d", i))
    self.imgPokemonGiftBagPokemonIcon[i] = self:child(string.format("PokemonGiftBag-pokemon_icon_%d", i))
    self.txtPokemonGiftBagTitleText[i] = self:child(string.format("PokemonGiftBag-title_text_%d", i))
    self.txtPokemonGiftBagPercentText[i] = self:child(string.format("PokemonGiftBag-percent_text_%d", i))
    self:child(string.format("PokemonGiftBag-remaining_time_%d", i)):SetText(Lang:toText("ui_remaining_time"))
    self.txtPokemonGiftBagRemainingTimeNum[i] = self:child(string.format("PokemonGiftBag-remaining_time_num_%d", i))
  end
  self.gvGiftItem = UIMgr:new_widget("grid_view")
  self.gvGift = UIMgr:new_widget("grid_view")
  self:initList()
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonGiftBag btnPokemonGiftBagBuy event : EventButtonClick", self.btnPokemonGiftBagBuy, UIEvent.EventButtonClick, function()
    if not self.curGiftId or self.onBuy then
      return
    end
    local gift = TriggerGiftConfig:getGiftById(self.curGiftId)
    local realPrice = math.ceil(gift.original * gift.discount)
    if self:checkItemMoney(realPrice) then
      Me:sendPacket({
        pid = "OnBuyTriggerGift",
        giftId = self.curGiftId
      })
      self.onBuy = true
    else
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_lack_money", function(ret)
        if not ret then
          return
        end
        Interface.onRecharge(1)
      end)
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonGiftBag btnPokemonGiftBagClose event : EventButtonClick", self.btnPokemonGiftBagClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonGiftBag btnPokemonGiftBagLeft event : EventButtonClick", self.btnPokemonGiftBagLeft, UIEvent.EventButtonClick, function()
    self:onCheckedGift(self.curIndex - 1)
    self:startGiftBtnTimer()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonGiftBag btnPokemonGiftBagRight event : EventButtonClick", self.btnPokemonGiftBagRight, UIEvent.EventButtonClick, function()
    self:onCheckedGift(self.curIndex + 1)
    self:startGiftBtnTimer()
  end)
  subscribeEvent(Event.EVENT_UPDATE_TRIGGER_GIFT_INFO, function(value)
    self:updateGiftData(value)
    UI:getWnd("pokemonMain"):updateGiftBtnTime(self.giftData)
    if UI:isOpen(self) and self.curGiftId then
      self:onShowByGiftId(self.curGiftId)
      return
    end
    Me.giftBagUIIsInit = true
    Me:checkLoginGiftBagUIIsInit()
  end)
end

function M:subscribeEvent()
end

function M:initList()
  self.lytPokemonGiftBagGiftList:AddChildWindow(self.gvGift)
  self.gvGift:SethScorllMoveAble(true)
  self.gvGift:SetvScorllMoveAble(false)
  self.gvGift:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvGift:InitConfig(0, 0, 1)
  self.lytPokemonGiftBagGiftItemsList:AddChildWindow(self.gvGiftItem)
  self.gvGiftItem:SetMoveAble(false)
  self.gvGiftItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvGiftItem:InitConfig(6, 0, 4)
  self:updateGiftData()
end

function M:initView(index)
  index = index or 1
  self:updateGiftList()
  self:onCheckedGift(index)
end

function M:pushGiftPackage()
  if self.showByGiftId then
    self:onShowByGiftId(self.showByGiftId)
    self.showByGiftId = nil
  end
end

function M:checkItemMoney(totalPrice)
  if not World.cfg.useFDiamonds then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if totalPrice <= asset then
        return true
      end
    end
  elseif totalPrice <= Coin:countByCoinName(Me, Coin:coinNameByCoinId(4)) then
    return true
  end
  return false
end

function M:updateGiftViewInfo(index)
  for i = 1, 2 do
    self.lytPokemonGiftBagGiftInfo[i]:SetVisible(i == self.giftType)
  end
  local data = self.giftData[self.giftType]
  self.curGiftTime = 0
  if not data or not data[index] then
    return
  end
  local gift = TriggerGiftConfig:getGiftById(data[index].id)
  if not gift then
    return
  end
  self.txtPokemonGiftBagPercentText[self.giftType]:SetText(math.floor((1 - gift.discount) * 100) .. "%" .. "OFF")
  self.txtPokemonGiftBagOriginalPriceNum:SetText(gift.original)
  self:updateGiftItemList(gift.id)
  self.curGiftTime = data[index].time
  if Me:getGainFirstOrangePet() == 1 and gift.triggerType == Define.GIFT_TRIGGER_CONDITION.ORANGE_PET then
    Me:setGainFirstOrangePet(2)
  end
  local time = data[index].time - os.time()
  if time <= 0 then
    self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText("00:00:00")
    return
  end
  self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText(Lib.getFormatTime(time))
  self.finalPrice = math.ceil(gift.original * gift.discount)
  self.txtPokemonGiftBagCurrencyNum:SetText(self.finalPrice)
  local color = {
    "\226\150\162FFFFFB88",
    "\226\150\162FF81FFF2"
  }
  self.txtPokemonGiftBagTitleText[self.giftType]:SetText(color[self.giftType] .. Lang:toText(gift.title) .. "\226\150\162FFFFFFFD" .. Lang:toText("ui_package"))
end

function M:updateGiftItemList(giftId)
  local giftItemInfo = TriggerGiftConfig:getGiftItemsInfoById(giftId)
  for _, cell in pairs(self.giftItemCells) do
    cell:invoke("onCellShow", false)
  end
  for index, info in pairs(giftItemInfo or {}) do
    if not self.giftItemCells[index] then
      local cell = UIMgr:new_widget("pokemon_gift_item_cell")
      cell:invoke("updateInfo", info)
      self:lightSubscribe("error!!!!! script_client win_pokemonGiftBag updateGiftItemList-cell-index=" .. index .. " event : EventWindowClick", cell, UIEvent.EventWindowClick, function()
      end)
      self.gvGiftItem:AddItem(cell)
      self.giftItemCells[index] = cell
    else
      self.giftItemCells[index]:invoke("updateInfo", info)
    end
  end
end

function M:updateGiftData(data)
  self.giftData = {}
  for id, time in pairs(data or {}) do
    local gift = TriggerGiftConfig:getGiftById(id)
    if gift then
      local giftType = gift.type
      if self.giftData[giftType] and type(self.giftData[giftType]) == "table" then
        table.insert(self.giftData[giftType], {id = id, time = time})
      else
        self.giftData[giftType] = {}
        table.insert(self.giftData[giftType], {id = id, time = time})
      end
    end
  end
  for _, _data in pairs(self.giftData or {}) do
    table.sort(_data, function(a, b)
      return a.time < b.time
    end)
  end
  self:updateGiftList()
end

function M:updateGiftList()
  local data = self.giftData[self.giftType]
  if data and type(data) == "table" then
    self.gvGift:InitConfig(0, 0, #data)
    for i, cell in pairs(self.giftCells or {}) do
      if i > #data then
        self.gvGift:RemoveItem(cell)
        self.giftCells[i] = nil
      end
    end
    for index, value in pairs(data or {}) do
      local style = 2
      if index == 1 and index ~= #data then
        style = 1
      elseif index == #data then
        if index == 1 then
          style = 4
        else
          style = 3
        end
      end
      if not self.giftCells[index] then
        local cell = UIMgr:new_widget("pokemon_gift_cell")
        cell:invoke("updateInfo", value, style, self.giftType)
        self:lightSubscribe("error!!!!! script_client win_pokemonGiftBag updateGiftList-cell-index=" .. index .. " event : EventWindowClick", cell, UIEvent.EventWindowClick, function()
          local curIndex = self.curIndex
          self:onCheckedGift(index)
          if curIndex ~= index then
            self:startGiftBtnTimer()
          end
        end)
        self.gvGift:AddItem(cell)
        self.giftCells[index] = cell
      else
        self.giftCells[index]:invoke("updateInfo", value, style, self.giftType)
      end
    end
  end
end

function M:onHide()
  UI:closeWnd("pokemonGiftBag")
end

function M:onCheckedGift(index)
  if self.giftCells and type(self.giftCells) == "table" and index <= #self.giftCells then
    local giftId
    for i, cell in pairs(self.giftCells) do
      if i == index then
        cell:invoke("onChecked", true)
        giftId = cell:invoke("getGiftId")
      else
        cell:invoke("onChecked", false)
      end
    end
    self:updateGiftViewInfo(index)
    self.curIndex = index
    self.curGiftId = giftId
    self.btnPokemonGiftBagRight:SetVisible(true)
    self.btnPokemonGiftBagLeft:SetVisible(true)
    if index == #self.giftCells then
      self.btnPokemonGiftBagRight:SetVisible(false)
    end
    if index == 1 then
      self.btnPokemonGiftBagLeft:SetVisible(false)
    end
  end
end

function M:startGiftBtnTimer()
  if self.giftBtnTimer then
    LuaTimer:cancel(self.giftBtnTimer)
    self.giftBtnTimer = nil
    self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText("00:00:00")
  end
  if self.curGiftTime == 0 then
    self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText("00:00:00")
    return
  end
  local time = self.curGiftTime - os.time()
  self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText(Lib.getFormatTime(time))
  self.giftBtnTimer = LuaTimer:scheduleTimer(function()
    time = time - 1
    self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText(Lib.getFormatTime(time))
    if time <= 0 then
      LuaTimer:cancel(self.giftBtnTimer)
      self.giftBtnTimer = nil
      self.txtPokemonGiftBagRemainingTimeNum[self.giftType]:SetText("00:00:00")
    end
  end, 1000, -1)
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonGiftBag")
    end
  else
    self:onHide()
  end
end

function M:onShowByGiftId(giftId)
  local index
  for giftType, data in pairs(self.giftData or {}) do
    for i, value in pairs(data or {}) do
      if value.id == giftId then
        index = i
        self.giftType = giftType
        break
      end
    end
    if index then
      break
    end
  end
  if index then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonGiftBag", self.giftType, index)
    else
      self:initView(index)
      self:startGiftBtnTimer()
    end
  else
    self:onHide()
  end
end

function M:onOpen(giftType, index)
  self._allEvent = {}
  self.giftType = giftType
  self:subscribeEvent()
  if giftType and not index then
    local behaviorKey = "GrowthGift_open"
    if giftType == Define.TRIGGER_GIFT_TYPE.TIME then
      behaviorKey = "LimitedGift_open"
    end
    Me:gameBehaviorReport(behaviorKey)
  end
  self:initView(index)
  self:startGiftBtnTimer()
  if Me:isInBattle() then
    self:root():SetLevel(20)
    self:root():SetAlwaysOnTop(true)
  else
    self:root():SetLevel(50)
    self:root():SetAlwaysOnTop(false)
  end
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.giftBtnTimer then
    LuaTimer:cancel(self.giftBtnTimer)
    self.giftBtnTimer = nil
  end
  self.curGiftId = nil
end

return M
