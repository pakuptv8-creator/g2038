local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local LuaTimer = T(Lib, "LuaTimer")
local subscribeEvent = require("script_client.event_cache")
local bagCellHorizontalInterval = 13
local bagCellVerticalInterval = 10
local bagCellCount = 5
local bagMinCount = 30
local skillCellVerticalInterval = 12
local showTime = 0
local totalTime = 0
local showTimeInterval = {
  [Define.BAG_TYPE.BALL] = 0,
  [Define.BAG_TYPE.CURE] = 0,
  [Define.BAG_TYPE.OTHER] = 0,
  [Define.BAG_TYPE.SKILL] = 0
}
local hurtAbilityImg = {
  [0] = "set:pokemon_pet_attribute.json image:img_0_attribute_special",
  [1] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicalattacks",
  [2] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellattacks",
  [3] = "set:pokemon_pet_attribute.json image:img_0_attribute_special"
}
local behaviorName = {
  [Define.BAG_TYPE.BALL] = "pokeball",
  [Define.BAG_TYPE.CURE] = "medicine",
  [Define.BAG_TYPE.OTHER] = "other",
  [Define.BAG_TYPE.SKILL] = "skill"
}
local notBattleBagType = {
  [1] = Define.BAG_TYPE.CURE,
  [2] = Define.BAG_TYPE.OTHER,
  [3] = Define.BAG_TYPE.BALL,
  [4] = Define.BAG_TYPE.SKILL
}
local battleBagType = {
  [1] = Define.BAG_TYPE.CURE
}
local initPetQueueCellWidth = 238
local initPetQueueCellHeight = 74
local M = _ENV.M

function M:init()
  WinBase.init(self, "PokemonBag.json", false)
  self.bagItems = {}
  self.bagType = {}
  self.petObjIds = {}
  self.petQueueCell = {}
  self.skillQueuePetIcon = {}
  self.petSkillCell = {}
  self.effectiveGoals = {}
  self.sellCount = 0
  self.selectTabType = Define.BAG_TYPE.BALL
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonBagWin = self:child("PokemonBag-win")
  self.imgPokemonBagTitle = self:child("PokemonBag-title")
  self.lytPokemonBagTabList = self:child("PokemonBag-tab_list")
  self.imgPokemonBagBagBg = self:child("PokemonBag-bag_bg")
  self.lytPokemonBagBagList = self:child("PokemonBag-bag_list")
  self.btnPokemonBagClose = self:child("PokemonBag-close")
  self.imgPokemonBagDetailBg = self:child("PokemonBag-detail_bg")
  self.btnPokemonBagUse = self:child("PokemonBag-use_btn")
  self.btnPokemonBagSell = self:child("PokemonBag-sell_btn")
  self.btnPokemonBagPreview = self:child("PokemonBag-preview_btn")
  self.gvBagList = UIMgr:new_widget("grid_view")
  self.gvTabList = UIMgr:new_widget("grid_view")
  self.btnPokemonBagDetailHelp = self:child("PokemonBag-detail_help")
  self.imgPokemonBagDetailRaceIcon = self:child("PokemonBag-detail_race_icon")
  self.txtPokemonBagDetailItemName = self:child("PokemonBag-detail_item_name")
  self.txtPokemonBagDetailItemRarity = self:child("PokemonBag-detail_item_rarity")
  local ui_rarity = Lang:toText("ui_rarity")
  local textLen = self.txtPokemonBagDetailItemRarity:GetFont():GetTextExtent(ui_rarity, 1.0)
  self.txtPokemonBagDetailItemRarity:SetWidth({0, textLen})
  self.txtPokemonBagDetailItemRarity:SetText(ui_rarity)
  self.txtPokemonBagDetailItemRarityText = self:child("PokemonBag-detail_item_rarity_text")
  self.imgPokemonBagDetailIconFrame = self:child("PokemonBag-detail_icon_frame")
  self.lyPokemonBagDetailInfo = self:child("PokemonBag-detail_info")
  self.imgPokemonBagDetailIcon = self:child("PokemonBag-detail_icon")
  self.txtPokemonBagDetailItemNum = self:child("PokemonBag-detail_item_num")
  self.lyPokemonBagDetailSkillType = self:child("PokemonBag-detail_skill_type")
  self.txtPokemonBagDetailInfoTitle = self:child("PokemonBag-detail_info_title")
  self.txtPokemonBagDetailInfoTitle:SetText(Lang:toText("ui_introduction_to_props"))
  self.lyPokemonBagDetailSkillInfo = self:child("PokemonBag-detail_skill_info")
  self.lyPokemonBagDetailSkillInfo_1 = self:child("PokemonBag-skill_info_num_1")
  self.lyPokemonBagDetailSkillInfo_2 = self:child("PokemonBag-skill_info_num_2")
  self.lyPokemonBagDetailSkillInfo_3 = self:child("PokemonBag-skill_info_num_3")
  self.lyPokemonBagDetailTextList = self:child("PokemonBag-detail_text_list")
  self.lyPokemonBagDetailMask = self:child("PokemonBag-detail_mask")
  self:child("PokemonBag-mask_text"):SetText(Lang:toText("ui_empty_items"))
  self.txtPokemonBagDetailSkillTypeText = self:child("PokemonBag-detail_skill_type_text")
  self.skillInfoIcon = {}
  self.skillInfoNum = {}
  for i = 1, 3 do
    self.skillInfoIcon[i] = self:child(string.format("PokemonBag-skill_info_%d", i))
    self.skillInfoNum[i] = self:child(string.format("PokemonBag-skill_info_num_%d", i))
  end
  self.txtPokemonBagDetailText = self:child("PokemonBag-detail_text")
  self.gvDecText = UIMgr:new_widget("grid_view")
  self.txtPokemonBagTimeText = self:child("PokemonBag-time_text")
  self.lyPokemonBagPetQueueWin = self:child("PokemonBag-pet_queue_win")
  self.btnPokemonBagPetQueueClose = self:child("PokemonBag-pet_queue_close")
  self.lyPokemonBagPetQueueList = self:child("PokemonBag-pet_queue_list")
  self.gvPetQueue = UIMgr:new_widget("grid_view")
  self.lyPokemonBagPetSkillQueueWin = self:child("PokemonBag-pet_skill_queue_win")
  self.btnPokemonBagPetSkillQueueClose = self:child("PokemonBag-pet_skill_queue_close")
  self.lyPokemonBagPetSkillQueueIconList = self:child("PokemonBag-pet_skill_queue_icon_list")
  self.lyPokemonBagPetSkillList = self:child("PokemonBag-pet_skill_list")
  self.gvPetSkillQueueIcon = UIMgr:new_widget("grid_view")
  self.gvPetSkill = UIMgr:new_widget("grid_view")
  self.lyPokemonBagSellWnd = self:child("PokemonBag-sell_wnd")
  self.txtPokemonBagSellWndTitle = self:child("PokemonBag-sell_wnd_title")
  self.txtPokemonBagSellWndTitle:SetText(Lang:toText("ui_props_for_sale"))
  self.btnPokemonBagSellWndClose = self:child("PokemonBag-sell_wnd_close")
  self.imgPokemonBagSellItemIconFrame = self:child("PokemonBag-sell_item_icon_frame")
  self.imgPokemonBagSellItemIcon = self:child("PokemonBag-sell_item_icon")
  self.txtPokemonBagSellItemNum = self:child("PokemonBag-sell_item_num")
  self.txtPokemonBagSellItemName = self:child("PokemonBag-sell_item_name")
  self.txtPokemonBagSellItemPrice = self:child("PokemonBag-sell_item_price")
  self.txtPokemonBagSellItemAcquire = self:child("PokemonBag-sell_item_acquire")
  local price = Lang:toText("ui_price")
  local acquire = Lang:toText("ui_acquire")
  local priceLen = self.txtPokemonBagSellItemPrice:GetFont():GetTextExtent(price, 1.0)
  local acquireLen = self.txtPokemonBagSellItemAcquire:GetFont():GetTextExtent(acquire, 1.0)
  self.txtPokemonBagSellItemPrice:SetWidth({0, priceLen})
  self.txtPokemonBagSellItemAcquire:SetWidth({0, acquireLen})
  self.txtPokemonBagSellItemPrice:SetText(price)
  self.txtPokemonBagSellItemAcquire:SetText(acquire)
  self.txtPokemonBagSellItemPriceNum = self:child("PokemonBag-sell_item_price_num")
  self.txtPokemonBagSellItemAcquireNum = self:child("PokemonBag-sell_item_acquire_num")
  self.btnPokemonBagSellItemYes = self:child("PokemonBag-sell_item_yes")
  self.btnPokemonBagSellItemNo = self:child("PokemonBag-sell_item_no")
  self.lytNoSuitablePopup = self:child("PokemonBag-NoSuitablePokemonPopup")
  self:child("PokemonBag-NoSuitableText"):SetText(Lang:toText("gui.skill.noSuitable"))
  self.edCountEdit = UIMgr:new_widget("pokemon_count_edit")
  self.lyPokemonBagSellItemCount = self:child("PokemonBag-sell_item_count")
  self.edCountEdit:invoke("setShowWnd", self.lyPokemonBagSellItemCount, {
    x = {0, 0},
    y = {0, 0},
    w = {1, 0},
    h = {1, 0}
  })
  self.lyBattleTopTime = UIMgr:new_widget("battle_top_time")
  self.lyBattleTopTime:invoke("showInCurrentWnd", self._root, {0, 50})
  self:child("PokemonBag-help_title"):SetText(Lang:toText("ui_help"))
  self:child("PokemonBag-help_skill_property"):SetText(Lang:toText("ui_skill_property"))
  self:child("PokemonBag-help_ability_type"):SetText(Lang:toText("ui_ability_type"))
  for i = 1, 5 do
    self:child(string.format("PokemonBag-help_skill_property_text_%d", i)):SetText(Lang:toText(string.format("ui_skill_property_%d", i)))
  end
  for i = 1, 8 do
    self:child(string.format("PokemonBag-help_skill_ability_text_%d", i)):SetText(Lang:toText(string.format("ui_skill_ability_%d", i)))
  end
  self.btnPokemonBagHelpClose = self:child("PokemonBag-help_close")
  self.lyPokemonBagHelpWnd = self:child("PokemonBag-help_wnd")
  self:child("PokemonBag-sell_text"):SetText(Lang:toText("ui_sell"))
  self:child("PokemonBag-use_text"):SetText(Lang:toText("ui_ues"))
  self:child("PokemonBag-preview_text"):SetText(Lang:toText("ui_preview"))
  self:child("PokemonBag-title_text"):SetText(Lang:toText("title_bag"))
  self:initList()
  self:initCurrency()
end

function M:initList()
  self.lyPokemonBagDetailTextList:AddChildWindow(self.gvDecText)
  self.gvDecText:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDecText:InitConfig(0, 0, 1)
  self.gvDecText:AddItem(self.txtPokemonBagDetailText)
  self.lytPokemonBagTabList:AddChildWindow(self.gvTabList)
  self.gvTabList:SetAutoColumnCount(false)
  self.gvTabList:SetMoveAble(false)
  self.gvTabList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvTabList:InitConfig(0, 15, 1)
  self.lyPokemonBagPetSkillQueueIconList:AddChildWindow(self.gvPetSkillQueueIcon)
  self.gvPetSkillQueueIcon:SetMoveAble(false)
  self.gvPetSkillQueueIcon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPetSkillQueueIcon:InitConfig(0, 15, 1)
  self.lyPokemonBagPetSkillList:AddChildWindow(self.gvPetSkill)
  self.gvPetSkill:SetAutoColumnCount(false)
  self.gvPetSkill:SetMoveAble(false)
  self.gvPetSkill:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPetSkill:InitConfig(0, skillCellVerticalInterval, 1)
  self.lytPokemonBagBagList:AddChildWindow(self.gvBagList)
  self.gvBagList:SetAutoColumnCount(false)
  self.gvBagList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBagList:InitConfig(bagCellHorizontalInterval, bagCellVerticalInterval, bagCellCount)
  local width = self.lytPokemonBagBagList:GetPixelSize().x
  local itemWidth = (width - bagCellHorizontalInterval * (bagCellCount - 1)) / bagCellCount
  self.bagAdapter = UIMgr:new_adapter("pokemon_bag", itemWidth, itemWidth)
  self.gvBagList:invoke("setAdapter", self.bagAdapter)
  self.lyPokemonBagPetQueueList:AddChildWindow(self.gvPetQueue)
  self.gvPetQueue:SetMoveAble(false)
  self.gvPetQueue:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.petQueueCellWidth = self.gvPetQueue:GetPixelSize().x - 10
  self.petQueueCellHeight = self.petQueueCellWidth / initPetQueueCellWidth * initPetQueueCellHeight
  local petQueueVerticalInterval = (self.gvPetQueue:GetPixelSize().y - self.petQueueCellHeight * 4) / 4
  self.gvPetQueue:InitConfig(0, petQueueVerticalInterval, 1)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagClose event : EventButtonClick", self.btnPokemonBagClose, UIEvent.EventButtonClick, function()
    self:onHide(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagPetQueueClose event : EventButtonClick", self.btnPokemonBagPetQueueClose, UIEvent.EventButtonClick, function()
    self.lyPokemonBagPetQueueWin:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagPetSkillQueueClose event : EventButtonClick", self.btnPokemonBagPetSkillQueueClose, UIEvent.EventButtonClick, function()
    self.lyPokemonBagPetSkillQueueWin:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagUse event : EventButtonClick", self.btnPokemonBagUse, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("ui_backpack", behaviorName[self.selectTabType] .. "_use")
    self:onBeginUsed()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_Shop btnPokemonBagPreview event : EventButtonClick", self.btnPokemonBagPreview, UIEvent.EventButtonClick, function()
    UI:getWnd("skillPokemonUsePreview"):onShow(self.selectSkillId)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagSell event : EventButtonClick", self.btnPokemonBagSell, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("ui_backpack", behaviorName[self.selectTabType] .. "_sell")
    self:onBeginSell()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagSellWndClose event : EventButtonClick", self.btnPokemonBagSellWndClose, UIEvent.EventButtonClick, function()
    self.lyPokemonBagSellWnd:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagSellItemNo event : EventButtonClick", self.btnPokemonBagSellItemNo, UIEvent.EventButtonClick, function()
    self.lyPokemonBagSellWnd:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagHelpClose event : EventButtonClick", self.btnPokemonBagHelpClose, UIEvent.EventButtonClick, function()
    self.lyPokemonBagHelpWnd:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagDetailHelp event : EventButtonClick", self.btnPokemonBagDetailHelp, UIEvent.EventButtonClick, function()
    self.lyPokemonBagHelpWnd:SetVisible(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBag btnPokemonBagSellItemYes event : EventButtonClick", self.btnPokemonBagSellItemYes, UIEvent.EventButtonClick, function()
    self:confirmSellItem()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_REFRESH_PLAYER_BAG", Event.EVENT_REFRESH_PLAYER_BAG, function()
    if not UI:isOpen(self) then
      return
    end
    self:updateBagData()
    if self.selectTabType and self.selectItemId then
      self:onCheckedTab(self.selectTabType, self.selectItemId)
    end
    self:onBeginSell(true)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_CHANGE_BATTLE_PET", Event.EVENT_CHANGE_BATTLE_PET, function()
    if not UI:isOpen(self) then
      return
    end
    self:updatePetQueueList()
  end)
  subscribeEvent(Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    for _, cell in pairs(self.skillQueuePetIcon) do
      local pokemon = cell:invoke("getPokemon")
      if pokemon and pokemon:getObjId() == objId then
        self:updatePetSkillQueueList(pokemon)
      end
    end
  end)
  subscribeEvent(Event.EVENT_UPDATE_SPRAY_TIME, function(time)
    self.sprayEndTime = time
    self:startSprayCountDown()
  end)
end

function M:subscribeEvent()
end

function M:initCurrency()
  self.llCurrencyMoney = self:child("PokemonBag-Currency-Money")
  self.llGoldDiamond = self:child("PokemonBag-Gold-Diamond")
  self.llCashCoupon = self:child("PokemonBag-Cash-Coupon")
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

function M:initView(sceneType)
  if sceneType == Define.SCENE_TYPE.BATTLE then
    self.bagType = battleBagType
    self.imgPokemonBagTitle:SetVisible(false)
    self.lyBattleTopTime:SetVisible(true)
    self.sceneType = Define.SCENE_TYPE.BATTLE
  else
    self.bagType = notBattleBagType
    self.imgPokemonBagTitle:SetVisible(true)
    self.lyBattleTopTime:SetVisible(false)
    self.sceneType = Define.SCENE_TYPE.NOT_BATTLE
  end
  self.tabCells = {}
  self:updateBagData()
  self:updateBagTabList()
  self:updatePetQueueList()
end

function M:neatenBagData(itemsArr)
  self.bagItems = {}
  for tabType, items in pairs(itemsArr) do
    self.bagItems[tabType] = {}
    local sortAnArray = {}
    for _, item in pairs(items) do
      table.insert(sortAnArray, item)
    end
    table.sort(sortAnArray, function(a, b)
      if a._cfg.skillBookType and b._cfg.skillBookType then
        if a._cfg.skillBookType > b._cfg.skillBookType then
          return true
        elseif a._cfg.skillBookType == b._cfg.skillBookType then
          if a._cfg.rarity > b._cfg.rarity then
            return true
          elseif a._cfg.rarity == b._cfg.rarity then
            return a._cfg.itemId < b._cfg.itemId
          else
            return false
          end
        else
          return false
        end
      else
        return a._cfg.itemId < b._cfg.itemId
      end
      return a._cfg.itemId < b._cfg.itemId
    end)
    for _, item in pairs(sortAnArray) do
      local data = {item = item, select = false}
      table.insert(self.bagItems[tabType], data)
    end
    local addItem = {item = "add", select = false}
    table.insert(self.bagItems[tabType], 1, addItem)
    local maxCellCount = 30
    if #self.bagItems[tabType] > bagMinCount then
      if #self.bagItems[tabType] % 5 ~= 0 then
        maxCellCount = #self.bagItems[tabType] + (5 - #self.bagItems[tabType] % 5)
      else
        maxCellCount = #self.bagItems[tabType]
      end
    end
    for i = 1, maxCellCount do
      if not self.bagItems[tabType][i] then
        local blankItem = {
          select = false,
          itemId = i,
          tabType = tabType
        }
        table.insert(self.bagItems[tabType], blankItem)
      else
        self.bagItems[tabType][i].itemId = i
        self.bagItems[tabType][i].tabType = tabType
      end
      self.bagItems[tabType][i].clickCallBack = function()
        local unlockMod = UI:getWnd("pokemonMain").unlockMod
        unlockMod = unlockMod or PlayerExpConfig:getUnlockModByLv(Me:getPlayerLevel())
        if 1 < i then
          self:onCheckedTab(tabType, i)
        elseif i == 1 and unlockMod and unlockMod[Define.MODULE_TYPE.MAIN_SHOP] then
          UI:getWnd("pokemon_Shop"):onShow(true)
        end
      end
    end
  end
end

function M:updateBagData()
  local itemsArr = Me:getBagItems()
  self:neatenBagData(itemsArr)
end

function M:updateBagItemView(tabType)
  if self.selectTabType ~= tabType then
    self.bagAdapter:setScrollOffset(0)
  end
  self.bagAdapter:setData(self.bagItems[tabType])
end

function M:onCheckedBagItem(tabType, itemId)
  for index, item in pairs(self.bagItems[tabType]) do
    if item.itemId == itemId then
      self.bagItems[tabType][index].select = true
      self:updateItemInfoView(self.bagItems[tabType][index])
    else
      self.bagItems[tabType][index].select = false
    end
  end
  self:updateBagItemView(tabType)
end

function M:updateBagTabList()
  self.gvTabList:RemoveAllItems()
  for _, _type in ipairs(self.bagType) do
    local tabCell = UIMgr:new_widget("pokemon_bag_tab_cell")
    tabCell:invoke("updateInfo", _type)
    self:lightSubscribe("error!!!!! script_client win_pokemonBag bagCell-_type=" .. _type .. " event : EventWindowClick", tabCell, UIEvent.EventWindowClick, function()
      Me:playSoundByKey("tab_click")
      self:manuallySwitchTabs()
      Me:gameBehaviorReport("ui_backpack", behaviorName[_type])
      self:onCheckedTab(_type, 2)
    end)
    self.gvTabList:AddItem(tabCell)
    self.tabCells[_type] = tabCell
  end
end

function M:updatePetQueueList()
  Me:getBattlePokemon(function(pokemonList)
    self.petObjIds = {}
    for index, pokemon in ipairs(pokemonList) do
      if not self.petQueueCell[index] then
        local item = UIMgr:new_widget("pokemon_head_cell")
        item:SetVerticalAlignment(0)
        item:SetWidth({
          0,
          self.petQueueCellWidth
        })
        item:SetHeight({
          0,
          self.petQueueCellHeight
        })
        item:invoke("setType", Define.SCENE_TYPE.NOT_BATTLE)
        item:invoke("updateInfo", pokemon)
        self.gvPetQueue:AddItem(item)
        self.petQueueCell[index] = item
      else
        self.petQueueCell[index]:invoke("updateInfo", pokemon)
      end
      self.petObjIds[index] = pokemon:getObjId()
    end
    for i, cell in pairs(self.petQueueCell) do
      if not pokemonList[i] then
        self.gvPetQueue:RemoveItem(cell)
        self.petQueueCell[i] = nil
      end
    end
    self:updatePetSkillQueueIconList(pokemonList)
  end)
end

function M:updatePetSkillQueueIconList(pokemonList)
  for i = 1, 4 do
    if not self.skillQueuePetIcon[i] then
      local cell = UIMgr:new_widget("pokemon_packet_item_cell")
      cell:SetWidth({0, 64})
      cell:SetHeight({0, 64})
      self.gvPetSkillQueueIcon:AddItem(cell)
      cell:invoke("updateInfo", pokemonList[i])
      self.skillQueuePetIcon[i] = cell
    else
      self.skillQueuePetIcon[i]:invoke("updateInfo", pokemonList[i])
    end
  end
end

function M:onCheckedQueueIcon(index)
  for i, cell in pairs(self.skillQueuePetIcon) do
    if index == i then
      cell:invoke("onChecked", true)
    else
      cell:invoke("onChecked", false)
    end
  end
end

function M:updatePetSkillQueueList(pokemon, effectiveGoals)
  if effectiveGoals then
    self.effectiveGoals = effectiveGoals
  end
  local skills = pokemon:getSkillList()
  for i = 1, 4 do
    if not self.petSkillCell[i] then
      local cell = UIMgr:new_widget("pokemon_skill_cell")
      cell:invoke("updateInfo", skills[i])
      cell:invoke("associatedWithThePet", pokemon)
      self.gvPetSkill:AddItem(cell)
      cell:invoke("showMask", not self.effectiveGoals[i])
      self:lightSubscribe("error!!!!! script_client win_pokemonBag skillQueueListCell-num=" .. i .. " event : EventWindowClick", cell, UIEvent.EventWindowClick, function()
        if not self.effectiveGoals[i] then
          return
        end
        local skill = cell:invoke("getSkill")
        if not skill then
          return
        end
        local pet = cell:invoke("getRelatedPet")
        local objId
        if pet then
          objId = pet:getObjId()
        end
        if not objId then
          return
        end
        self:onPetTargetUseItem(Define.ITEM_TYPE.CURE, objId, skill.skillId)
      end)
      self.petSkillCell[i] = cell
    else
      self.petSkillCell[i]:invoke("updateInfo", skills[i])
      self.petSkillCell[i]:invoke("associatedWithThePet", pokemon)
      self.petSkillCell[i]:invoke("showMask", not self.effectiveGoals[i])
    end
  end
end

function M:onCheckedTab(_type, itemId)
  for i, cell in pairs(self.tabCells) do
    if _type == i then
      cell:invoke("onChecked", true)
      self:onCheckedBagItem(_type, itemId)
      self.selectTabType = _type
      self.selectItemId = itemId
    else
      cell:invoke("onChecked", false)
    end
  end
end

function M:onBeginUsed()
  if not self.selectItem then
    return
  end
  local cfg = self.selectItem._cfg
  if cfg then
    if cfg.useTarget == Define.USE_TARGET.PLAYER then
      if cfg.itemType == Define.ITEM_TYPE.SPRAY then
        if self.sprayInUse then
          UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_spray_in_use", function(ret)
            if not ret then
              return
            end
            self:onPlayerUseItem(cfg.itemType)
          end)
        else
          self:onPlayerUseItem(cfg.itemType)
        end
      elseif cfg.itemType == Define.ITEM_TYPE.EggTicket then
        UI:getWnd("pokemonLuckyEgg"):onShow(true, cfg.ticketType)
        self:onHide(true)
      end
    elseif cfg.useTarget == Define.USE_TARGET.PET then
      if cfg.itemType == Define.ITEM_TYPE.CURE then
        self:onBeginUsedCure(cfg)
      elseif cfg.itemType == Define.ITEM_TYPE.EXP then
        self:onBeginUsedExp()
      elseif cfg.itemType == Define.ITEM_TYPE.SKILL then
        self:onBeginUsedSkill()
      elseif cfg.itemType == Define.ITEM_TYPE.WASH then
        self:onBeginUsedWash()
      elseif cfg.itemType == Define.ITEM_TYPE.Bless then
        if Me:isInPreBattleOrBattle() then
          return
        end
        UI:openWnd("pokemonBlessing")
        self:onHide(true)
      end
    end
  end
end

function M:onBeginSell(isUpdate)
  if not self.lyPokemonBagSellWnd:IsVisible() and isUpdate then
    return
  end
  if not self.selectItem then
    self.lyPokemonBagSellWnd:SetVisible(false)
    return
  end
  local cfg = self.selectItem._cfg
  if not cfg then
    return
  end
  local count = self.selectItem:stack_count()
  self.edCountEdit:invoke("setMaximum", count)
  self.txtPokemonBagSellItemNum:SetText(self.selectItem:stack_count())
  if isUpdate then
    return
  end
  self.edCountEdit:invoke("setCallback", function(_count)
    if _count then
      self.txtPokemonBagSellItemAcquireNum:SetText(cfg.sellingPrice * _count)
      self.sellCount = _count
    end
  end)
  self.lyPokemonBagSellWnd:SetVisible(true)
  self.txtPokemonBagSellItemPriceNum:SetText(cfg.sellingPrice)
  self.imgPokemonBagSellItemIconFrame:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
  self.imgPokemonBagSellItemIcon:SetImage(cfg.icon)
  self.txtPokemonBagSellItemName:SetText(Lang:toText(cfg.itemName))
end

function M:confirmSellItem()
  if not self.selectItem then
    return
  end
  local cfg = self.selectItem._cfg
  if not cfg or not cfg.sellingPrice then
    return
  end
  if self.sellCount <= 0 then
    return
  end
  local showSellWnd = true
  if self.selectItem:stack_count() == self.sellCount then
    showSellWnd = false
  end
  if self.onSellItem then
    return
  end
  self.onSellItem = true
  Me:sendPacket({
    pid = "OnSellItem",
    params = {
      fullName = self.selectItem:full_name(),
      slot = self.selectItem._slot,
      count = self.sellCount
    }
  }, function(ret)
    self.onSellItem = false
    if ret then
      Me:playSoundByKey("sell_success")
      self.lyPokemonBagSellWnd:SetVisible(showSellWnd)
      UI:getWnd("battle_dialog"):showDialogText({
        text = Lang:toText("ui_sell_finish"),
        maskEquateYes = true,
        yesCb = function()
        end
      })
    end
  end)
end

function M:getItemCureType(cfg)
  local canHp = false
  local canLife = false
  local canDBuff = false
  local canPp = false
  for _, _type in pairs(cfg.cureType or {}) do
    if _type == Define.CURE_TYPE.HP then
      canHp = true
    elseif _type == Define.CURE_TYPE.LIFE then
      canLife = true
    elseif _type == Define.CURE_TYPE.DBUFF then
      canDBuff = cfg.deBuffFullName
    elseif _type == Define.CURE_TYPE.PP then
      canPp = true
    end
  end
  return canHp, canLife, canDBuff, canPp
end

function M:detectIfPokemonCanUseCure(pokemon, canHp, canLife, canDBuff, canPp)
  if not pokemon then
    return
  end
  local canUseCure = false
  local curHp = pokemon:getCurHp()
  local maxHp = pokemon:isFought() and pokemon:getBattleMaxHp() or pokemon:getMaxHp()
  local effectiveGoals = {}
  if canHp and 0 < curHp and curHp < maxHp then
    canUseCure = true
  end
  if canLife and curHp <= 0 then
    canUseCure = true
  end
  if canDBuff then
    local buffList = pokemon:getLongRoundEffectbuffList()
    if canDBuff == 0 then
      for _, cfg in pairs(buffList) do
        if 0 < cfg.abnormalType then
          canUseCure = true
          break
        end
      end
    else
      for _, cfg in pairs(buffList) do
        if cfg.abnormalType == canDBuff then
          canUseCure = true
          break
        end
      end
    end
  end
  if canPp then
    local skillList = pokemon:getSkillList()
    for i, skill in pairs(skillList) do
      local skillConfig = SkillConfig:getConfigById(skill.skillId)
      local maxTimes = skill.maxTimes or skillConfig.max_number
      if skill.curTimes ~= maxTimes then
        effectiveGoals[i] = true
        canUseCure = true
      else
        effectiveGoals[i] = false
      end
    end
  end
  return canUseCure, effectiveGoals
end

function M:onBeginUsedCure(cfg)
  local canHp, canLife, canDBuff, canPp = self:getItemCureType(cfg)
  if cfg.group then
    local canUse = false
    for _, cell in pairs(self.petQueueCell) do
      local pokemon = cell:invoke("getPokemon")
      canUse = self:detectIfPokemonCanUseCure(pokemon, canHp, canLife, canDBuff, canPp)
      if canUse then
        break
      end
    end
    if canUse then
      self:onPetTargetUseItem(cfg.itemType)
    else
      UI:getWnd("battle_dialog"):showDialogText({
        text = Lang:toText("ui_incorrect_target"),
        yesCb = function()
        end
      })
    end
  elseif canPp then
    for i, item in pairs(self.skillQueuePetIcon) do
      local pokemon = item:invoke("getPokemon")
      local _, effectiveGoals = self:detectIfPokemonCanUseCure(pokemon, canHp, canLife, canDBuff, canPp)
      self:unsubscribe(item)
      self:lightSubscribe("error!!!!! script_client win_pokemonBag skillQueuePetIconCell-num=" .. i .. " event : EventWindowClick", item, UIEvent.EventWindowClick, function()
        if not pokemon then
          return
        end
        self:onCheckedQueueIcon(i)
        self:updatePetSkillQueueList(pokemon, effectiveGoals)
      end)
      if i == 1 then
        if not pokemon then
          return
        end
        self:onCheckedQueueIcon(i)
        self:updatePetSkillQueueList(pokemon, effectiveGoals)
      end
    end
    self.lyPokemonBagPetSkillQueueWin:SetVisible(true)
  else
    for i, cell in pairs(self.petQueueCell) do
      local pokemon = cell:invoke("getPokemon")
      local canUse = self:detectIfPokemonCanUseCure(pokemon, canHp, canLife, canDBuff, canPp)
      cell:invoke("onShowMask", not canUse)
      self:unsubscribe(cell)
      self:lightSubscribe("error!!!!! script_client win_pokemonBag petQueueCell-num=" .. i .. " event : EventWindowClick", cell, UIEvent.EventWindowClick, function()
        if not canUse then
          return
        end
        self:onPetTargetUseItem(cfg.itemType, self.petObjIds[i])
      end)
    end
    self.lyPokemonBagPetQueueWin:SetVisible(true)
  end
end

function M:onBeginUsedExp()
  UI:getWnd("pokemonPacket"):onShow("packet", 1)
end

function M:onBeginUsedSkill()
  if #Me:getSkillSuitablePokemon(SkillConfig:getConfigById(self.selectSkillId)) == 0 then
    self:subscribe(self.lytNoSuitablePopup, UIEvent.EventWindowClick, function()
      self:cancelPopup()
    end)
    self.lytNoSuitablePopup:SetVisible(true)
    self.popupTimer = LuaTimer:scheduleTimer(function()
      self:cancelPopup()
    end, 2000)
    return
  end
  UI:getWnd("pokemonLearnSkill"):onShow(self.selectItem)
end

function M:cancelPopup()
  self.lytNoSuitablePopup:SetVisible(false)
  self:unsubscribe(self.lytNoSuitablePopup, UIEvent.EventWindowClick)
  if self.popupTimer then
    LuaTimer:cancel(self.popupTimer)
    self.popupTimer = nil
  end
end

function M:onBeginUsedWash()
  UI:getWnd("pokemonPacket"):onShow("packet", 3)
end

function M:onPlayerUseItem(itemType)
  Me:sendPacket({
    pid = "OnUseItem",
    type = itemType,
    params = {
      fullName = self.selectItem:full_name(),
      slot = self.selectItem._slot
    }
  }, function()
  end)
end

function M:onPetTargetUseItem(itemType, target, skillId)
  Me:sendPacket({
    pid = "OnPetTargetUseItem",
    type = itemType,
    params = {
      fullName = self.selectItem:full_name(),
      slot = self.selectItem._slot,
      sceneType = self.sceneType,
      skillId = skillId,
      target = target
    }
  }, function(ret)
    if ret then
      local wnd = UI:getWnd("battle_dialog")
      wnd:showDialogText({
        text = Lang:toText("ui_use_finish"),
        maskEquateYes = true,
        yesCb = function()
          self.lyPokemonBagPetQueueWin:SetVisible(false)
          self.lyPokemonBagPetSkillQueueWin:SetVisible(false)
          if self.sceneType == Define.SCENE_TYPE.BATTLE and Me:battleAction(Define.BATTLE_ACTION.ITEM) then
            self:onHide()
          end
        end
      })
      if itemType == Define.ITEM_TYPE.CURE then
        Me:playSoundByKey("use_cure_item")
      end
    end
  end)
  if self.sceneType == Define.SCENE_TYPE.BATTLE then
    UI:getWnd("battle_main"):showControlWin(false)
    local ourQueue = UI:getWnd("battle_main").ourQueue
    for _, pet in pairs(ourQueue or {}) do
      if not target or pet:getObjId() == target then
        self:onHide()
        break
      end
    end
    UI:getWnd("battle_main").canCommand = false
  end
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
      [Define.BAG_TYPE.BALL] = 0,
      [Define.BAG_TYPE.CURE] = 0,
      [Define.BAG_TYPE.OTHER] = 0,
      [Define.BAG_TYPE.SKILL] = 0
    }
  else
    showTimeInterval[self.selectTabType] = showTimeInterval[self.selectTabType] + os.time() - showTime
    showTime = os.time()
  end
end

function M:updateItemInfoView(itemInfo)
  self.selectItem = itemInfo.item
  self.lyPokemonBagDetailSkillType:SetVisible(false)
  self.lyPokemonBagDetailSkillInfo:SetVisible(false)
  self.imgPokemonBagDetailRaceIcon:SetVisible(false)
  self.txtPokemonBagTimeText:SetVisible(false)
  self.btnPokemonBagDetailHelp:SetVisible(false)
  self.txtPokemonBagDetailInfoTitle:SetYPosition({0, 0})
  self.lyPokemonBagDetailMask:SetVisible(true)
  self.gvDecText:SetScrollOffset(0)
  if not itemInfo.item then
    return
  end
  local cfg = self.selectItem:cfg()
  self.selectSkillId = nil
  self.btnPokemonBagPreview:SetVisible(cfg.itemType == Define.BAG_TYPE.SKILL)
  if cfg then
    self.lyPokemonBagDetailMask:SetVisible(false)
    self.txtPokemonBagDetailItemName:SetText(Lang:toText(cfg.itemName))
    self.txtPokemonBagDetailItemRarityText:SetText(Lang:toText(string.format("ui_item_rarity_%d", cfg.rarity)))
    self.imgPokemonBagDetailIconFrame:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
    self.imgPokemonBagDetailIcon:SetImage(cfg.icon)
    self.txtPokemonBagDetailText:SetText(Lang:toText(cfg.desc))
    self.txtPokemonBagDetailItemNum:SetText(self.selectItem:stack_count())
    self.btnPokemonBagUse:SetXPosition({0, 80})
    self.btnPokemonBagSell:SetXPosition({0, -80})
    local h = self.lyPokemonBagDetailInfo:GetPixelSize().y - self.txtPokemonBagDetailInfoTitle:GetPixelSize().y
    if self.sceneType == Define.SCENE_TYPE.BATTLE then
      self.btnPokemonBagUse:SetVisible(cfg.battleUse)
      self.btnPokemonBagSell:SetVisible(false)
      if cfg.battleUse then
        self.btnPokemonBagUse:SetXPosition({0, 0})
      end
    else
      self.btnPokemonBagUse:SetVisible(cfg.canUse)
      local canSell = cfg.sellingPrice and cfg.sellingPrice ~= 0
      self.btnPokemonBagSell:SetVisible(canSell)
      if cfg.canUse and not canSell then
        self.btnPokemonBagUse:SetXPosition({0, 0})
      elseif not cfg.canUse and canSell then
        self.btnPokemonBagSell:SetXPosition({0, 0})
      end
    end
    if cfg.itemType == Define.BAG_TYPE.SKILL then
      local skillId = cfg.skillId
      self.selectSkillId = skillId
      local skill_config = SkillConfig:getConfigById(skillId) or {}
      self.txtPokemonBagDetailText:SetText(Lang:toText(skill_config.describe or "DescText"))
      if skill_config.type == 1 then
        h = h - self.lyPokemonBagDetailSkillType:GetPixelSize().y - self.lyPokemonBagDetailSkillInfo:GetPixelSize().y
        self.txtPokemonBagDetailSkillTypeText:SetText(Lang:toText("gui.skill.initiative"))
      else
        h = h - self.lyPokemonBagDetailSkillType:GetPixelSize().y
        self.txtPokemonBagDetailSkillTypeText:SetText(Lang:toText("gui.skill.passive"))
      end
      self.imgPokemonBagDetailRaceIcon:SetVisible(true)
      self.imgPokemonBagDetailRaceIcon:SetImage(RaceConfig:getClassifyIcon(skill_config.race))
      self.skillInfoIcon[1]:SetImage(hurtAbilityImg[skill_config.hurt_type])
      local hurt = (not skill_config.hurt or skill_config.hurt == 0) and "--" or skill_config.hurt
      self.lyPokemonBagDetailSkillInfo_1:SetText(hurt)
      self.lyPokemonBagDetailSkillInfo_2:SetText(skill_config.skill_speed or "0")
      self.lyPokemonBagDetailSkillInfo_3:SetText(skill_config.accuracy or "0")
      self.lyPokemonBagDetailSkillInfo:SetVisible(true)
      self.lyPokemonBagDetailSkillType:SetVisible(true)
      self.btnPokemonBagDetailHelp:SetVisible(true)
      self.txtPokemonBagDetailInfoTitle:SetYPosition({0, 23})
    end
    self.lyPokemonBagDetailTextList:SetHeight({0, h})
    if cfg.itemType == Define.ITEM_TYPE.SPRAY and self.sprayEndTime and self.sprayEndTime > os.time() then
      self.txtPokemonBagTimeText:SetVisible(true)
      self.checkSpray = true
    else
      self.checkSpray = false
    end
  end
end

function M:endSprayCountDown()
  if self.sprayTimer then
    LuaTimer:cancel(self.sprayTimer)
    self.sprayTimer = nil
  end
end

function M:startSprayCountDown()
  self:endSprayCountDown()
  local timeRemaining = self.sprayEndTime - os.time()
  local mainWnd = UI:getWnd("pokemonMain")
  if timeRemaining <= 0 then
    self.sprayInUse = false
    mainWnd.imgPokemonMainSprayCountdownIcon:SetVisible(false)
    return
  end
  self.sprayInUse = true
  self.txtPokemonBagTimeText:SetText(Lang:toText("ui_remaining_time") .. ":" .. Lib.getFormatTime(timeRemaining))
  mainWnd.txtPokemonMainSprayCountdownNum:SetText(Lib.getFormatTime(timeRemaining))
  self.txtPokemonBagTimeText:SetVisible(self.sprayInUse and self.checkSpray)
  mainWnd.imgPokemonMainSprayCountdownIcon:SetVisible(self.sprayInUse)
  self.sprayTimer = LuaTimer:scheduleTimer(function()
    timeRemaining = self.sprayEndTime - os.time()
    self.sprayInUse = true
    if timeRemaining <= 0 then
      self:endSprayCountDown()
      self.sprayInUse = false
    end
    self.txtPokemonBagTimeText:SetText(Lang:toText("ui_remaining_time") .. ":" .. Lib.getFormatTime(timeRemaining))
    mainWnd.txtPokemonMainSprayCountdownNum:SetText(Lib.getFormatTime(timeRemaining))
    self.txtPokemonBagTimeText:SetVisible(self.sprayInUse and self.checkSpray)
    mainWnd.imgPokemonMainSprayCountdownIcon:SetVisible(self.sprayInUse)
  end, 1000, -1)
end

function M:onHide(needSend)
  if needSend then
    self:manuallySwitchTabs()
    for tabType, dTime in pairs(showTimeInterval) do
      if dTime ~= 0 then
        Me:gameBehaviorReport("ui_backpack_time", behaviorName[tabType] .. "_" .. self:getTimeIntervalSection(dTime))
      end
    end
    Me:gameBehaviorReport("ui_backpack_time", "total_" .. self:getTimeIntervalSection(os.time() - totalTime))
  end
  UI:closeWnd("pokemonBag")
end

function M:onShow(isShow, sceneType)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonBag", sceneType)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(sceneType)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(sceneType)
  showTime = 0
  totalTime = os.time()
  self:manuallySwitchTabs()
  Me:gameBehaviorReport("ui_backpack", "pokeball")
  self:onCheckedTab(self.bagType[1], 2)
  Me:integrateTypeTray(Define.TRAY_TYPE.BAG, function()
    Me:pagingItemsByBagType()
  end)
  self.lytNoSuitablePopup:SetVisible(false)
  self:ChatWndAdapt(false)
end

function M:onClose()
  self:cancelPopup()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self.lyPokemonBagPetQueueWin:SetVisible(false)
  self.lyPokemonBagPetSkillQueueWin:SetVisible(false)
  self.lyPokemonBagHelpWnd:SetVisible(false)
  self.sellCount = 0
  self:ChatWndAdapt(true)
end

function M:ChatWndAdapt(isShow)
  if not Me:isInBattle() then
    return
  end
  UI:getWnd("chatBar"):ShowBar(isShow)
  if not isShow then
    if UI:getWnd("chatMain").isShow then
      self.needRecoverChatWnd = true
      Lib.emitEvent(Event.EVENT_OPEN_CHATBTN, false)
    end
  elseif self.needRecoverChatWnd then
    self.needRecoverChatWnd = false
    Lib.emitEvent(Event.EVENT_OPEN_CHATBTN, true)
  end
end

return M
