local PayShopConfig = T(Config, "PayShopConfig")
local SkillConfig = T(Config, "SkillConfig")
local setting = require("common.setting")
local subscribeEvent = require("script_client.event_cache")
local tabVerticalInterval = 15
local openTabSpeed = 3
local tabs = {
  [1] = Define.SHOP_TAB_TYPE.PREFERENTIAL,
  [2] = Define.SHOP_TAB_TYPE.COMMON,
  [3] = Define.SHOP_TAB_TYPE.BALL,
  [4] = Define.SHOP_TAB_TYPE.CURE,
  [6] = Define.SHOP_TAB_TYPE.SKILL
}
local showTime = 0
local totalTime = 0
local showTimeInterval = {
  [Define.SHOP_TAB_TYPE.PREFERENTIAL] = 0,
  [Define.SHOP_TAB_TYPE.COMMON] = 0,
  [Define.SHOP_TAB_TYPE.BALL] = 0,
  [Define.SHOP_TAB_TYPE.CURE] = 0,
  [Define.SHOP_TAB_TYPE.INTENSIFY] = 0,
  [Define.SHOP_TAB_TYPE.SKILL] = 0
}
local oldItemW = 214
local oldItemH = 234
local color = {
  [1] = "\226\150\162FF873E01",
  [2] = "\226\150\162FF548135",
  [3] = "\226\150\162FF12A2FF",
  [4] = "\226\150\162FF6F258E",
  [5] = "\226\150\162FFFF8402"
}

function M:init()
  WinBase.init(self, "pokemon_Shop.json", false)
  self:initData()
  self:initUI()
  self:initList()
  self:initCurrency()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonShopNormalPanel = self:child("pokemon_Shop-normal_panel")
  self.lytPokemonShopStorePanel = self:child("pokemon_Shop-store_panel")
  self.imgPokemonShopStoreBg = self:child("pokemon_Shop-store_bg")
  self.lytPokemonShopInfoPanel = self:child("pokemon_Shop-info_panel")
  self.imgPokemonShopModelBg = self:child("pokemon_Shop-model_bg")
  self.lytPokemonShopModelPanel = self:child("pokemon_Shop-model_panel")
  self.txtPokemonShopModelTitle = self:child("pokemon_Shop-model_title")
  self.imgPokemonShopModelGoodsBg = self:child("pokemon_Shop-model-goods-bg")
  self.imgPokemonShopModelGoodsIcon = self:child("pokemon_Shop-model-goods-icon")
  self.imgPokemonShopModelDescBg = self:child("pokemon_Shop-model-descBg")
  self.lytPokemonShopModelDescList = self:child("pokemon_Shop-model_desc_list")
  self.gvDecText = UIMgr:new_widget("grid_view")
  self.txtPokemonShopModelDesc = self:child("pokemon_Shop-model_desc")
  self.lytPokemonShopBuyPanel = self:child("pokemon_Shop-buy_panel")
  self.btnPokemonShopBtnBuyPreview = self:child("pokemon_Shop-btn_buy_preview")
  self.lytPokemonShopTotalPrice = self:child("pokemon_Shop-total_price")
  self.gvDecTotalPrice = UIMgr:new_widget("grid_view")
  self.txtPokemonShopTotalName = self:child("pokemon_Shop-total-name")
  local total = Lang:toText("ui_total_price")
  local textLen = self.txtPokemonShopTotalName:GetFont():GetTextExtent(total, 1.0)
  self.txtPokemonShopTotalName:SetWidth({0, textLen})
  self.txtPokemonShopTotalName:SetText(Lang:toText("ui_total_price"))
  self.imgPokemonShopTotalDia = self:child("pokemon_Shop-total_dia")
  self.txtPokemonShopTotalTxt = self:child("pokemon_Shop-total_txt")
  self.txtPokemonShopRemaining = self:child("pokemon_Shop-remaining")
  self.decNode = {}
  table.insert(self.decNode, self.txtPokemonShopTotalName)
  table.insert(self.decNode, self.imgPokemonShopTotalDia)
  table.insert(self.decNode, self.txtPokemonShopTotalTxt)
  table.insert(self.decNode, self.txtPokemonShopRemaining)
  self.lytPokemonShopLeftPanel = self:child("pokemon_Shop-left_panel")
  self.imgPokemonShopLeftBg = self:child("pokemon_Shop-left-Bg")
  self.imgPokemonShopLeftTopBg = self:child("pokemon_Shop-left-top-bg")
  self.imgPokemonShopLeftDianBg = self:child("pokemon_Shop-left-dian-bg")
  self.lytPokemonShopGoodsContent = self:child("pokemon_Shop-goods_content")
  self.gvShopItemList = UIMgr:new_widget("grid_view")
  self.lytPokemonShopSmallTabList = self:child("pokemon_Shop-small_tabList")
  self.imgPokemonShopTitleBg = self:child("pokemon_Shop_titleBg")
  self:child("pokemon_Shop-title-name"):SetText(Lang:toText("ui_shop"))
  self.lytPokemonShopBigTabList = self:child("pokemon_Shop-big_tabList")
  self.gvTabList = UIMgr:new_widget("grid_view")
  self.btnPokemonShopBtnBack = self:child("pokemon_Shop-btn_back")
  self.txtPokemonShopModelName = self:child("pokemon_Shop-model_name")
  self:child("pokemon_Shop-owned"):SetText(Lang:toText("ui_owned") .. ": ")
  self.txtPokemonShopOwnedNum = self:child("pokemon_Shop-owned_num")
  self:child("pokemon_Shop-confirm_wnd_title"):SetText(Lang:toText("ui_confirm_purchase"))
  self.imgPokemonShopConfirmWndItemFrame = self:child("pokemon_Shop-confirm_wnd_item_frame")
  self.imgPokemonShopConfirmWndItemIcon = self:child("pokemon_Shop-confirm_wnd_item_icon")
  self.imgPokemonShopConfirmWndCurrencyIcon = self:child("pokemon_Shop-confirm_wnd_currency_icon")
  self.imgPokemonShopConfirmWndGetItemIcon = self:child("pokemon_Shop-confirm_wnd_get_item_icon")
  self.txtPokemonShopConfirmWndCurrencyNum = self:child("pokemon_Shop-confirm_wnd_currency_num")
  self.txtPokemonShopConfirmWndGetItemNum = self:child("pokemon_Shop-confirm_wnd_get_item_num")
  self.btnPokemonShopConfirmWndClose = self:child("pokemon_Shop-confirm_wnd_close")
  self.lytPokemonShopConfirmWnd = self:child("pokemon_Shop-confirm_wnd")
  self.btnPokemonShopConfirmWndYes = self:child("pokemon_Shop-confirm_wnd_yes")
  self.btnPokemonShopConfirmWndNo = self:child("pokemon_Shop-confirm_wnd_no")
  self.textPokemonShopModelQuality = self:child("pokemon_Shop-model_quality")
  self.textPokemonShopModelInclusion = self:child("pokemon_Shop-model_inclusion")
  self.lytPokemonShopModelMask = self:child("pokemon_Shop-model_mask")
  self:child("pokemon_Shop-model_mask_text"):SetText(Lang:toText("ui_unselected_commodity"))
  self.edCountEdit = UIMgr:new_widget("pokemon_count_edit")
  self.lyPokemonShopBuyCountEditWnd = self:child("pokemon_Shop-buy_count_edit_wnd")
  self.edCountEdit:invoke("setShowWnd", self.lyPokemonShopBuyCountEditWnd, {
    x = {0, 0},
    y = {0, 0},
    w = {1, 0},
    h = {1, 0}
  })
  self.llPokemonShopBuyInfo = self:child("pokemon_Shop-buy_info")
  self.btnPokemonShopInfoPanelClose = self:child("pokemon_Shop-info_panel_closed")
  self.btnPokemonShopBuyNo = self:child("pokemon_Shop-buy_no")
  self.btnPokemonShopBuyYes = self:child("pokemon_Shop-buy_yes")
  self.llPokemonShopBuyFailTip = self:child("pokemon_Shop-buy_fail_tip")
  self:child("pokemon_Shop-buy_fail_title"):SetText(Lang:toText("ui_buy_fail"))
  self.txtPokemonShopBuyFailDec = self:child("pokemon_Shop-buy_fail_dec")
  self.btnPokemonShopBuyFailNo = self:child("pokemon_Shop-buy_fail_no")
  self.btnPokemonShopBuyFailYes = self:child("pokemon_Shop-buy_fail_yes")
  self.llPokemonShopBuySuccessTip = self:child("pokemon_Shop-buy_success_tip")
  self:child("pokemon_Shop-buy_success_title"):SetText(Lang:toText("ui_buy_finish"))
  self:child("pokemon_Shop-buy_success_click"):SetText(Lang:toText("ui_click_blank_close"))
  self.llPokemonShopBuySuccessMask = self:child("pokemon_Shop-buy_success_mask")
  self.llPokemonShopBuyItemsList = self:child("pokemon_Shop-buy_items_list")
  self.gvBuyItems = UIMgr:new_widget("grid_view")
end

function M:initData()
  self.tabCells = {}
  self.buyInfo = {}
  self.tabRedDotStatus = {}
  self.tabId = 1
  self.subTabId = 1
  self.index = 1
  self.canOpenSTab = {}
  self.sTabHeight = {}
  self.subTabCells = {}
  self.gvSubTabLists = {}
  self.shopData = PayShopConfig:getNeatenAfterSettings()
  self:neatenItemData()
end

function M:initList()
  self.lytPokemonShopModelDescList:AddChildWindow(self.gvDecText)
  self.gvDecText:SetAutoColumnCount(false)
  self.gvDecText:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDecText:InitConfig(0, 5, 1)
  self.gvDecText:AddItem(self.txtPokemonShopModelDesc)
  self.lytPokemonShopTotalPrice:AddChildWindow(self.gvDecTotalPrice)
  self.gvDecTotalPrice:SetMoveAble(false)
  self.gvDecTotalPrice:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDecTotalPrice:InitConfig(20, 0, 3)
  for _, node in ipairs(self.decNode) do
    self.gvDecTotalPrice:AddItem(node)
  end
  self.lytPokemonShopBigTabList:AddChildWindow(self.gvTabList)
  self.gvTabList:SetMoveAble(false)
  self.gvTabList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvTabList:InitConfig(0, tabVerticalInterval, 1)
  self:initTabList()
  self.llPokemonShopBuyItemsList:AddChildWindow(self.gvBuyItems)
  self.gvBuyItems:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBuyItems:InitConfig(5, 0, 1)
  self.gvBuyItems:SethScorllMoveAble(true)
  self.gvBuyItems:SetvScorllMoveAble(false)
  self.lytPokemonShopGoodsContent:AddChildWindow(self.gvShopItemList)
  self.gvShopItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvShopItemList:InitConfig(0, 0, 4)
  local width = self.lytPokemonShopGoodsContent:GetPixelSize().x
  local itemWidth = width / 4
  local itemHeight = itemWidth * (oldItemH / oldItemW)
  self.shopAdapter = UIMgr:new_adapter("pokemon_shop", itemWidth, itemHeight)
  self.gvShopItemList:invoke("setAdapter", self.shopAdapter)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopBtnBuyPreview event : EventButtonClick", self.btnPokemonShopBtnBuyPreview, UIEvent.EventButtonClick, function()
    UI:getWnd("skillPokemonUsePreview"):onShow(self.selectSkillId)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopBtnBack event : EventButtonClick", self.btnPokemonShopBtnBack, UIEvent.EventButtonClick, function()
    self:onHide(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopConfirmWndClose event : EventButtonClick", self.btnPokemonShopConfirmWndClose, UIEvent.EventButtonClick, function()
    self.lytPokemonShopConfirmWnd:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopBuyYes event : EventButtonClick", self.btnPokemonShopBuyYes, UIEvent.EventButtonClick, function()
    self:onBuyItem()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopConfirmWndNo event : EventButtonClick", self.btnPokemonShopConfirmWndNo, UIEvent.EventButtonClick, function()
    self.lytPokemonShopConfirmWnd:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopInfoPanelClose event : EventButtonClick", self.btnPokemonShopInfoPanelClose, UIEvent.EventButtonClick, function()
    self.llPokemonShopBuyInfo:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop gvShopItemList event : EventWindowTouchUp", self.gvShopItemList, UIEvent.EventWindowTouchUp, function()
    self:resetItemSelected()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop _root event : EventWindowTouchUp", self._root, UIEvent.EventWindowTouchUp, function()
    self:resetItemSelected()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop gvTabList event : EventWindowTouchUp", self.gvTabList, UIEvent.EventWindowTouchUp, function()
    self:resetItemSelected()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopBuyNo event : EventButtonClick", self.btnPokemonShopBuyNo, UIEvent.EventButtonClick, function()
    self.llPokemonShopBuyInfo:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopBuyFailNo event : EventButtonClick", self.btnPokemonShopBuyFailNo, UIEvent.EventButtonClick, function()
    self.llPokemonShopBuyFailTip:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonShopBuyFailYes event : EventButtonClick", self.btnPokemonShopBuyFailYes, UIEvent.EventButtonClick, function()
    self.buyFailYes()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop llPokemonShopBuySuccessMask event : EventWindowClick", self.llPokemonShopBuySuccessMask, UIEvent.EventWindowClick, function()
    self.llPokemonShopBuySuccessTip:SetVisible(false)
  end)
  subscribeEvent(Event.EVENT_UPDATE_SHOP_BUY_INFO, function(value)
    for _, _buyInfo in pairs(value or {}) do
      self.buyInfo = _buyInfo
    end
    self.shopData = PayShopConfig:getNeatenAfterSettingsByBuyInfo(self.buyInfo)
    if not self.shopData then
      return
    end
    self:neatenItemData()
    self:selectCellByDetail(self.tabId, self.subTabId, self.index)
  end)
  subscribeEvent(Event.EVENT_PLAYER_LEVEL_UP, function(value)
    self.shopData = PayShopConfig:getNeatenAfterSettingsByBuyInfo(self.buyInfo)
    if not self.shopData then
      return
    end
    self:neatenItemData()
    self:selectCellByDetail(self.tabId, self.subTabId, self.index)
  end)
end

function M:subscribeEvent()
end

function M:initCurrency()
  self.llCurrencyMoney = self:child("pokemon_Shop-Currency-Money")
  self.llGoldDiamond = self:child("pokemon_Shop-Gold-Diamond")
  self.llCashCoupon = self:child("pokemon_Shop-Cash-Coupon")
  local money_currency = UIMgr:new_widget("common_currency")
  money_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  money_currency:invoke("setCurrencyType", "gold_coin")
  self.llCurrencyMoney:AddChildWindow(money_currency)
  local diamonds_currency = UIMgr:new_widget("common_currency")
  diamonds_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  diamonds_currency:invoke("setCurrencyType", World.cfg.useFDiamonds and "fDiamonds" or "gDiamonds")
  self.llGoldDiamond:AddChildWindow(diamonds_currency)
  local cash_coupon = UIMgr:new_widget("common_currency")
  cash_coupon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  cash_coupon:invoke("setCurrencyType", "gameCashCoupon")
  self.llCashCoupon:AddChildWindow(cash_coupon)
end

function M:updateDecTotalPrice()
  self.gvDecTotalPrice:InitConfig(5, 0, #self.decNode)
  self.gvDecTotalPrice:RemoveAllItems()
end

function M:resetItemSelected()
  if self.curData then
    self.shopAdapter:setData(self.curData)
  end
end

function M:showConfirmWnd()
  if self.selectItem and self.buyCount and self.buyCount ~= 0 and self.totalPrices then
    self.imgPokemonShopConfirmWndItemFrame:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", self.selectItem.rarity))
    self.imgPokemonShopConfirmWndItemIcon:SetImage(self.selectItem.icon)
    local currencyIcon = "set:pokemonMain.json image:icon_coin"
    if self.selectItem.currencyType == 0 or self.selectItem.currencyType == 4 then
      currencyIcon = "set:pokemonMain.json image:icon_dimond"
    end
    self.imgPokemonShopConfirmWndCurrencyIcon:SetImage(currencyIcon)
    self.imgPokemonShopConfirmWndGetItemIcon:SetImage(self.selectItem.icon)
    self.txtPokemonShopConfirmWndCurrencyNum:SetText(self.totalPrices)
    self.txtPokemonShopConfirmWndGetItemNum:SetText("x " .. self.buyCount)
    self.lytPokemonShopConfirmWnd:SetVisible(true)
  end
end

function M:neatenItemData()
  self.tabRedDotStatus = {}
  for tabId, _ in pairs(self.shopData or {}) do
    for subTabId, data in pairs(self.shopData[tabId]) do
      table.sort(data, function(a, b)
        return a.sort_id < b.sort_id
      end)
      self:setTabRedDotStatus(data, tabId, subTabId)
      self:fillItemCell(data, tabId, subTabId)
    end
  end
end

function M:initTabList()
  for i, tabId in pairs(tabs) do
    local tabCell = UIMgr:new_widget("pokemon_Shop_Tab")
    tabCell:invoke("initTabByType", tabId)
    local tabData = self.shopData[tabId]
    if not tabData or #tabData <= 1 then
      tabCell:invoke("onShopUnfold", false)
    else
      tabCell:invoke("onShopUnfold", true)
    end
    tabCell:SetWidth({1, -4})
    tabCell:SetHeight({0, 72})
    local view = tabCell:invoke("getSTabInfoList")
    local node = tabCell:invoke("getClickTriggerCorrelationNode")
    self.gvSubTabLists[tabId] = view
    if not Me:isGuideFinish() and i == 1 then
      Lib.logDebug("openshop set first tab name")
      tabCell:SetName("guide_shop_tab")
    end
    self.canOpenSTab[tabId] = true
    self:lightSubscribe("error!!!!! script_client win_pokemon_Shop initTabList-cell-index=" .. i .. " event : EventWindowClick", node, UIEvent.EventWindowClick, function()
      Me:gameBehaviorReport("ui_shop", Define.SHOP_BEHAVIOR_NAME[tabId] .. "_1")
      self:manuallySwitchTabs()
      self:selectCellByDetail(tabId, 1, 1)
      self:openSTabList(tabId)
    end)
    self.gvTabList:AddItem(tabCell)
    self.tabCells[tabId] = tabCell
    self:initSubTabList(tabId)
  end
end

function M:openSTabList(tabId)
  local isOpen = self.canOpenSTab[tabId]
  if self.openSTabTimer then
    self.openSTabTimer()
  end
  local animParam = self:getCellAnimParam(tabId)
  self.openSTabTimer = World.Timer(1, function()
    local isGoOn = self:updateCellHeight(tabId, animParam, isOpen)
    if not isGoOn then
      World.Timer(1, function()
        local isMovie = self.gvTabList:GetMinScrollOffset() < 0
        self.gvTabList:SetMoveAble(isMovie)
        if not isMovie then
          self.gvTabList:SetScrollOffset(0)
        end
        if isOpen and self.gvSubTabLists[tabId] then
          self.gvSubTabLists[tabId]:SetVisible(true)
        end
      end)
    end
    return isGoOn
  end)
  self:updateOpenSTabInfo(tabId)
end

function M:updateOpenSTabInfo(tabId)
  for _tabId, isOpen in pairs(self.canOpenSTab or {}) do
    local tabData = self.shopData[_tabId]
    local cell = self.tabCells[_tabId]
    if tabId == _tabId then
      self.canOpenSTab[_tabId] = not isOpen
    else
      self.canOpenSTab[_tabId] = true
    end
    if tabData and 1 < #tabData then
      cell:invoke("updateUnfold", not self.canOpenSTab[_tabId])
    end
  end
end

function M:getCellAnimParam(tabId)
  local animParam = {}
  for _tabId, cell in pairs(self.tabCells or {}) do
    local oldH = cell:invoke("getSTabList"):GetHeight()[2]
    if _tabId == tabId then
      animParam[_tabId] = {
        maxH = self.sTabHeight[_tabId],
        value = self.sTabHeight[_tabId] / openTabSpeed
      }
    else
      animParam[_tabId] = {
        maxH = oldH,
        value = oldH / openTabSpeed
      }
    end
    if self.gvSubTabLists[_tabId] then
      self.gvSubTabLists[_tabId]:SetVisible(false)
    end
  end
  return animParam
end

function M:updateCellHeight(tabId, animParam, isOpen)
  local isGoOn = true
  for _tabId, cell in pairs(self.tabCells or {}) do
    if animParam[_tabId].value > 0 then
      local list = cell:invoke("getSTabList")
      local oldH = list:GetHeight()[2]
      local open = isOpen
      if _tabId ~= tabId then
        open = false
      end
      if open then
        list:SetHeight({
          0,
          oldH + animParam[_tabId].value
        })
      else
        list:SetHeight({
          0,
          oldH - animParam[_tabId].value
        })
      end
      local curH = list:GetHeight()[2]
      cell:invoke("setSTabListHeight", curH)
      if curH >= animParam[_tabId].maxH then
        cell:invoke("setSTabListHeight", animParam[_tabId].maxH)
        isGoOn = false
      end
      if curH <= 0 then
        cell:invoke("setSTabListHeight", 0)
        isGoOn = false
      end
    end
  end
  return isGoOn
end

function M:getCellAnimParam(tabId)
  local animParam = {}
  for _tabId, cell in pairs(self.tabCells or {}) do
    local oldH = cell:invoke("getSTabList"):GetHeight()[2]
    if _tabId == tabId then
      animParam[_tabId] = {
        maxH = self.sTabHeight[_tabId],
        value = self.sTabHeight[_tabId] / openTabSpeed
      }
    else
      animParam[_tabId] = {
        maxH = oldH,
        value = oldH / openTabSpeed
      }
    end
    if self.gvSubTabLists[_tabId] then
      self.gvSubTabLists[_tabId]:SetVisible(false)
    end
  end
  return animParam
end

function M:updateCellHeight(tabId, animParam, isOpen)
  local isGoOn = true
  for _tabId, cell in pairs(self.tabCells or {}) do
    if animParam[_tabId].value > 0 then
      local list = cell:invoke("getSTabList")
      local oldH = list:GetHeight()[2]
      local open = isOpen
      if _tabId ~= tabId then
        open = false
      end
      if open then
        list:SetHeight({
          0,
          oldH + animParam[_tabId].value
        })
      else
        list:SetHeight({
          0,
          oldH - animParam[_tabId].value
        })
      end
      local curH = list:GetHeight()[2]
      cell:invoke("setSTabListHeight", curH)
      if curH >= animParam[_tabId].maxH then
        cell:invoke("setSTabListHeight", animParam[_tabId].maxH)
        isGoOn = false
      end
      if curH <= 0 then
        cell:invoke("setSTabListHeight", 0)
        isGoOn = false
      end
    end
  end
  return isGoOn
end

function M:initSubTabList(tabId)
  local tabData = self.shopData[tabId]
  self.subTabCells[tabId] = {}
  self.sTabHeight[tabId] = 0
  if not tabData or #tabData <= 1 then
    return
  end
  local cellHeight = 0
  local index = 0
  for i, _ in pairs(tabData or {}) do
    local subTabCell = UIMgr:new_widget("pokemon_Shop_STab")
    subTabCell:SetWidth({1, -10})
    subTabCell:SetYPosition({
      0,
      (cellHeight + 11) * index
    })
    cellHeight = subTabCell:GetHeight()[2]
    subTabCell:invoke("initTabByType", tabId, i)
    self:lightSubscribe("error!!!!! script_client win_pokemon_Shop initTabList-cell-index=" .. i .. " event : EventWindowClick", subTabCell, UIEvent.EventWindowClick, function()
      Me:gameBehaviorReport("ui_shop", Define.SHOP_BEHAVIOR_NAME[tabId] .. "_" .. i)
      self:selectCellByDetail(tabId, i, 1)
    end)
    self.gvSubTabLists[tabId]:AddChildWindow(subTabCell)
    self.subTabCells[tabId][i] = subTabCell
    index = index + 1
  end
  self.sTabHeight[tabId] = index * (cellHeight + 11)
end

function M:fillItemCell(data, tabId, subTabId)
  for i, cell in pairs(data) do
    function cell.clickCallBack()
      self:selectCellByDetail(tabId, subTabId, i, true)
    end
  end
  return data
end

function M:setTabRedDotStatus(data, tabId, subTabId)
  if not self.tabRedDotStatus[tabId] then
    self.tabRedDotStatus[tabId] = {}
  end
  for i, value in pairs(data) do
    if value.showRedDot == 1 then
      self.tabRedDotStatus[tabId][subTabId] = true
      if value.curBuyCount and value.curBuyCount >= value.buyCount then
        self.tabRedDotStatus[tabId][subTabId] = false
      end
    end
  end
end

function M:onCheckItemClick(tabId, subTabId, index)
  local items
  if self.shopData[tabId] then
    for i = 1, subTabId do
      if not self.shopData[tabId][i] then
        self.shopData[tabId][i] = self:fillItemCell({}, tabId, i)
      end
    end
    items = self.shopData[tabId][subTabId]
  else
    self.shopData[tabId] = {}
    for i = 1, subTabId do
      if not self.shopData[tabId][i] then
        self.shopData[tabId][i] = self:fillItemCell({}, tabId, i)
      end
    end
  end
  if items ~= nil and 0 < #items then
    local skillCfg = SkillConfig:getConfigByName(items[index].name or "") or {}
    self.selectSkillId = skillCfg.id
    Lib.logDebug("self.selectSkillId", self.selectSkillId)
  end
  self:updateItemView(tabId, subTabId)
end

function M:updateItemView(tabId, subTabId)
  if self.tabId ~= tabId or self.subTabId ~= subTabId then
    self.shopAdapter:setScrollOffset(0)
  end
  self.shopAdapter:setData(self.shopData[tabId][subTabId])
  self.curData = self.shopData[tabId][subTabId]
  if not Me:isGuideFinish() and self.tabId == 1 and self.subTabId == 1 then
    local node = self.shopAdapter.view:GET_ITEM(0)
    Lib.logDebug("guide_shop_cell node = ", node)
    if node then
      node:SetName("guide_shop_cell")
    end
  end
end

function M:onCheckTabClick(tabId)
  for _, cell in pairs(self.tabCells) do
    cell:invoke("onCheckClick", tabId)
  end
end

function M:onCheckSubTabClick(tabId, subTabId)
  for _, cell in pairs(self.subTabCells[tabId]) do
    cell:invoke("onCheckClick", tabId, subTabId)
  end
end

function M:selectCellByDetail(tabId, subTabId, index, needLookInfo)
  self:onCheckItemClick(tabId, subTabId, index)
  self:onCheckTabClick(tabId)
  self:onCheckSubTabClick(tabId, subTabId)
  if needLookInfo then
    self:updateItemInfoView(tabId, subTabId, index)
  end
  self:updateRedDotStatus(tabId)
  self.tabId = tabId
  self.subTabId = subTabId
  self.index = index
end

function M:updateRedDotStatus(id)
  for _, tab in pairs(self.tabCells) do
    tab:invoke("onShowRedDotIcon", false)
  end
  for _, stab in pairs(self.subTabCells[id]) do
    stab:invoke("onShowRedDotIcon", false)
  end
  for tabId, data in pairs(self.tabRedDotStatus) do
    for subTabId, status in pairs(data or {}) do
      self.tabCells[tabId]:invoke("onShowRedDotIcon", status)
      if self.subTabCells[id][subTabId] and tabId == id then
        self.subTabCells[id][subTabId]:invoke("onShowRedDotIcon", status)
      end
    end
  end
end

function M:updateItemInfoView(tabId, subTabId, index)
  local item = self.shopData[tabId][subTabId][index]
  self.selectItem = nil
  self.lytPokemonShopModelMask:SetVisible(true)
  self.gvDecText:SetScrollOffset(0)
  self.llPokemonShopBuyInfo:SetVisible(false)
  self.txtPokemonShopRemaining:SetText("")
  self.txtPokemonShopRemaining:SetWidth({0, 0})
  if not item.id then
    return
  end
  self.selectItem = item
  self.lytPokemonShopModelMask:SetVisible(false)
  local inclusion = ""
  local curFullName = ""
  for fullName, count in pairs(item.items) do
    local cfg = setting:fetch("item", fullName)
    if not cfg then
      return
    end
    inclusion = inclusion .. " " .. Lang:toText(cfg.itemName) .. "x" .. count
    curFullName = fullName
  end
  self.txtPokemonShopOwnedNum:SetText(Me:getTrayItemCountByFullName(curFullName))
  self.llPokemonShopBuyInfo:SetVisible(true)
  self.btnPokemonShopBtnBuyPreview:SetVisible(tabs[tabId] == Define.SHOP_TAB_TYPE.SKILL)
  self.txtPokemonShopModelTitle:SetText(Lang:toText("ui_props_buy"))
  self.txtPokemonShopModelName:SetText(color[item.rarity] .. Lang:toText(item.name))
  self.imgPokemonShopModelGoodsBg:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", item.rarity))
  self.imgPokemonShopModelGoodsIcon:SetImage(item.icon)
  self.txtPokemonShopModelDesc:SetText(Lang:toText(item.desc))
  local price = math.ceil(item.originalPrice * item.discount)
  local maxBuyCount = World.cfg.maxBuyCount or 99
  if 0 < item.buyCount then
    local curBuyCount = item.curBuyCount or 0
    maxBuyCount = item.buyCount - curBuyCount
    local remaining = string.format(Lang:toText("ui_remaining_buy"), maxBuyCount)
    local RemainingTextLen = self.txtPokemonShopRemaining:GetFont():GetTextExtent(remaining, 1.0)
    self.txtPokemonShopRemaining:SetWidth({0, 80})
    self.txtPokemonShopRemaining:SetText(remaining)
    self.gvDecTotalPrice:InitConfig(20, 0, 4)
  else
    self.gvDecTotalPrice:InitConfig(20, 0, 3)
  end
  if item.discount ~= 1 then
  else
  end
  local textLen = self.txtPokemonShopTotalTxt:GetFont():GetTextExtent(price == 0 and Lang:toText("ui_free_charge") or price, 1.0)
  self.txtPokemonShopTotalTxt:SetWidth({0, textLen})
  self.edCountEdit:invoke("setMaximum", maxBuyCount)
  self.edCountEdit:invoke("setCallback", function(_count)
    if _count then
      self.txtPokemonShopTotalTxt:SetText(price == 0 and Lang:toText("ui_free_charge") or price * _count)
      self.buyCount = _count
      self.totalPrices = price * _count
    end
  end)
  local currencyIcon = "set:pokemonMain.json image:icon_coin"
  if item.currencyType == 0 or item.currencyType == 4 then
    currencyIcon = "set:pokemonMain.json image:icon_dimond"
  end
  self.imgPokemonShopTotalDia:SetImage(currencyIcon)
  Me:gameBehaviorReport("shop_click_" .. Define.SHOP_BEHAVIOR_NAME[self.tabId] .. "_" .. self.subTabId, self.selectItem.id)
end

function M:onBuyItem()
  if self.isOnBuy then
    return
  end
  if self.selectItem and self.buyCount and self.buyCount ~= 0 and self.totalPrices then
    if self:checkItemMoney(self.selectItem) then
      local packet = {
        pid = "SyncShopOperation",
        params = {
          shopType = Define.SHOP_TYPE.ITEM,
          itemId = self.selectItem.id,
          count = self.buyCount
        }
      }
      Me:sendPacket(packet)
      self.isOnBuy = true
      self.llPokemonShopBuyInfo:SetVisible(false)
    else
      local result = Define.BuyingTips.no_gDiamonds
      if self.selectItem.currencyType == 3 then
        result = Define.BuyingTips.no_gold
      end
      self:showBuyFailTip(result, function()
        self.llPokemonShopBuyFailTip:SetVisible(false)
        if result == Define.BuyingTips.no_gDiamonds then
          Interface.onRecharge(1)
        elseif result == Define.BuyingTips.no_gold then
          UI:openWnd("pokemon_gold_exchange")
        end
      end)
    end
  else
    Lib.logDebug("not call buy item")
  end
end

function M:itemShopBuyResult(params)
  if params.result == Define.BuyingTips.buy_finish then
    local item = PayShopConfig:getItemByItemId(params.itemId)
    self:showBuySuccessTip(item, params.count)
  else
    self:showBuyFailTip(params.result, function()
      self.llPokemonShopBuyFailTip:SetVisible(false)
      if params.result == Define.BuyingTips.no_gDiamonds then
        Interface.onRecharge(1)
      elseif params.result == Define.BuyingTips.no_gold then
        UI:openWnd("pokemon_gold_exchange")
      elseif params.result == Define.BuyingTips.not_get and not Me:isInBattle() then
        UI:getWnd("pokemonBag"):onShow(true, Define.SCENE_TYPE.NOT_BATTLE)
      end
    end)
  end
  self.isOnBuy = false
end

function M:showBuySuccessTip(item, count)
  self.gvBuyItems:RemoveAllItems()
  local i = 0
  for fullName, _count in pairs(item.items) do
    local cell = UIMgr:new_widget("pokemon_buy_item_cell")
    cell:invoke("updateInfo", fullName, _count * count)
    self.gvBuyItems:AddItem(cell)
    i = i + 1
  end
  self.gvBuyItems:InitConfig(5, 0, i)
  self.llPokemonShopBuySuccessTip:SetVisible(true)
end

function M:showBuyFailTip(result, callback)
  self.llPokemonShopBuyFailTip:SetVisible(true)
  self.txtPokemonShopBuyFailDec:SetText(Lang:toText(string.format("ui_item_shop_buy_fail_%d", result)))
  self.buyFailYes = callback
end

function M:checkItemMoney(item)
  if item.isPay then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if asset >= self.totalPrices then
        return true
      else
      end
    end
  else
    if Coin:countByCoinName(Me, Coin:coinNameByCoinId(item.currencyType)) >= self.totalPrices then
      return true
    else
    end
  end
  return false
end

function M:getTimeIntervalSection(dTime)
  if dTime <= 10 then
    return "0_10"
  elseif 10 < dTime and dTime <= 30 then
    return "11_30"
  elseif 30 < dTime and dTime <= 60 then
    return "31_60"
  elseif 60 < dTime and dTime <= 120 then
    return "61_120"
  elseif 120 < dTime then
    return "120up"
  end
end

function M:manuallySwitchTabs()
  if showTime == 0 then
    showTime = os.time()
    showTimeInterval = {
      [Define.SHOP_TAB_TYPE.PREFERENTIAL] = 0,
      [Define.SHOP_TAB_TYPE.COMMON] = 0,
      [Define.SHOP_TAB_TYPE.BALL] = 0,
      [Define.SHOP_TAB_TYPE.CURE] = 0,
      [Define.SHOP_TAB_TYPE.INTENSIFY] = 0,
      [Define.SHOP_TAB_TYPE.SKILL] = 0
    }
  else
    showTimeInterval[self.tabId] = showTimeInterval[self.tabId] + os.time() - showTime
    showTime = os.time()
  end
end

function M:initView()
end

function M:onHide(needSend)
  if needSend then
    self:manuallySwitchTabs()
    for tabType, dTime in pairs(showTimeInterval) do
      if dTime ~= 0 then
        Me:gameBehaviorReport("ui_shop_time", Define.SHOP_BEHAVIOR_NAME[tabType] .. "_" .. self:getTimeIntervalSection(dTime))
      end
    end
    Me:gameBehaviorReport("ui_shop_time", "total_" .. self:getTimeIntervalSection(os.time() - totalTime))
  end
  UI:closeWnd("pokemon_Shop")
end

function M:onShow(selectTab)
  if selectTab then
    if not UI:isOpen(self) then
      self.preSelectTab = type(selectTab) == "number" and selectTab or nil
      UI:openWnd("pokemon_Shop")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  Me:playSoundByKey("open_shop")
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  showTime = 0
  totalTime = os.time()
  if self.preSelectTab then
    Me:gameBehaviorReport("ui_shop", Define.SHOP_BEHAVIOR_NAME[Define.SHOP_TAB_TYPE.SKILL] .. "_1")
    self:manuallySwitchTabs()
    self:selectCellByDetail(Define.SHOP_TAB_TYPE.SKILL, 1, 1)
    self.canOpenSTab[Define.SHOP_TAB_TYPE.SKILL] = true
    self:openSTabList(Define.SHOP_TAB_TYPE.SKILL)
    return
  end
  self:manuallySwitchTabs()
  self:autoSelectCell()
end

function M:autoSelectCell()
  for _, tabId in pairs(tabs) do
    if self.shopData[tabId] then
      for i, data in pairs(self.shopData[tabId] or {}) do
        if data and data[1] and data[1].id then
          Me:gameBehaviorReport("ui_shop", Define.SHOP_BEHAVIOR_NAME[tabId] .. "_" .. i)
          self:selectCellByDetail(tabId, i, 1)
          self.canOpenSTab[tabId] = true
          self:openSTabList(tabId)
          return
        end
      end
    end
  end
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
