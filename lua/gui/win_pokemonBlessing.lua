local RaceConfig = T(Config, "RaceConfig")
local BlessItemConfig = T(Config, "BlessItemConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")

function M:init()
  WinBase.init(self, "PokemonBlessing.json", false)
  self:initUI()
  self:initEvent()
  self:subscribeEvent()
end

function M:initUI()
  self.cur_pokemon = nil
  self.cur_raceId = 0
  self.battleList = {}
  self.packetList = {}
  self.lytPokemonBlessingLeftLayout = self:child("PokemonBlessing-Left-Layout")
  self.lytPokemonBlessingPacketLayout = self:child("PokemonBlessing-Packet-Layout")
  self.lytPokemonBlessingPacketList = self:child("PokemonBlessing-Packet-List")
  self.imgPokemonBlessingPacketTop = self:child("PokemonBlessing-Packet-Top")
  self.imgPokemonBlessingPacketTopImg = self:child("PokemonBlessing-Packet-Top-Img")
  self.lytPokemonBlessingClassifyLayout = self:child("PokemonBlessing-Classify-Layout")
  self.llClassifyOpenLayout = self:child("PokemonBlessing-Classify-Open-Layout")
  self.llClassifyTabList = self:child("PokemonBlessing-Classify-Tab-List")
  self.imgPokemonBlessingClassifyBg = self:child("PokemonBlessing-Classify-Bg")
  self.cbClassifyOpenCheckBox = self:child("PokemonBlessing-Classify-CheckBox")
  self.siCurClassifyIcon = self:child("PokemonBlessing-CurClassify")
  self.stCurClassifyText = self:child("PokemonBlessing-CurClassify-Text")
  self.lytPokemonBlessingRightLayout = self:child("PokemonBlessing-Right-Layout")
  self.imgPokemonBlessingRightTop = self:child("PokemonBlessing-Right-Top")
  self.txtPokemonBlessingName = self:child("PokemonBlessing-Name")
  self.txtPokemonBlessingLevel = self:child("PokemonBlessing-Level")
  self.lytPokemonBlessingRightContent = self:child("PokemonBlessing-Right-Content")
  self.lytPokemonBlessingRightContentTop = self:child("PokemonBlessing-Right-Content-Top")
  self.lytPokemonBlessingRightContentList = self:child("PokemonBlessing-Right-Content-List")
  self.btnPokemonBlessingRightBottom = self:child("PokemonBlessing-Right-Bottom")
  self.imgPokemonBlessingTipIcon = self:child("PokemonBlessing-Tip-Icon")
  self.btnPokemonBlessingBless = self:child("PokemonBlessing-Bless")
  self.txtPokemonBlessingTipText = self:child("PokemonBlessing-Tip-Text")
  self.lytPokemonBlessingItemLayout = self:child("PokemonBlessing-Item-Layout")
  self.btnPokemonBlessingClose = self:child("PokemonBlessing-Close")
  self.lytPokemonBlessingCurrencyMoney = self:child("PokemonBlessing-Currency-Money")
  self.imgPokemonBlessingCurrencyMoneyIcon = self:child("PokemonBlessing-Currency-Money-Icon")
  self.txtPokemonBlessingCurrencyMoneyValue = self:child("PokemonBlessing-Currency-Money-Value")
  self.lytPokemonBlessingGoldDiamond = self:child("PokemonBlessing-Gold-Diamond")
  self.imgPokemonBlessingGoldDiamondIcon = self:child("PokemonBlessing-Gold-Diamond-Icon")
  self.txtPokemonBlessingGoldDiamondValue = self:child("PokemonBlessing-Gold-Diamond-Value")
  self.btnPokemonBlessingShop = self:child("PokemonBlessing-Shop")
  self.txtPokemonBlessingTitleText = self:child("PokemonBlessing-Title-Text")
  self.txtPokemonBlessingSelectItemTitle = self:child("PokemonBlessing-SelectItem-Title")
  self.txtPokemonBlessingSelectItemTipText = self:child("PokemonBlessing-SelectItem-Tip-Text")
  self.txtPokemonBlessingTitleText:SetText(Lang:toText("gui.title.bless"))
  self.txtPokemonBlessingSelectItemTitle:SetText(Lang:toText("gui.bless.select.title"))
  self.txtPokemonBlessingSelectItemTipText:SetText(Lang:toText("gui.bless.select.tip"))
  self.txtPokemonBlessingTipText:SetText(Lang:toText("gui.tip.bless"))
  self.btnPokemonBlessingBless:SetText(Lang:toText("gui.btn.bless"))
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPacketList:InitConfig(10, 10, 3)
  self.lytPokemonBlessingPacketList:AddChildWindow(self.gvPacketList)
  local width = self.lytPokemonBlessingPacketList:GetPixelSize().x
  local itemWidth = (width - 20) / 3
  local adapter = UIMgr:new_adapter("pokemon_packet", itemWidth, itemWidth)
  self.gvPacketList:invoke("setAdapter", adapter)
  self.imgPokemonBlessingItem = UIMgr:new_widget("pokemon_item_cell")
  self.imgPokemonBlessingItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPokemonBlessingItemLayout:AddChildWindow(self.imgPokemonBlessingItem)
  self:initCurrency()
  self:initDetailLayout()
  self:initClassifyTabs()
  self:initBlessLayout()
  self:selectBlessItem({})
  self:upDatePokemonBattleList()
  self:upDatePokemonPacketList()
end

function M:initCurrency()
  self.llCurrencyMoney = self:child("PokemonBlessing-Currency-Money")
  self.llGoldDiamond = self:child("PokemonBlessing-Gold-Diamond")
  self.llCashCoupon = self:child("PokemonBlessing-Cash-Coupon")
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

function M:initBlessLayout()
  self.txtPokemonBlessingSelectItemLayout = self:child("PokemonBlessing-SelectItem-Layout")
  self.txtPokemonBlessingSelectItemClose = self:child("PokemonBlessing-SelectItem-Close")
  self.txtPokemonBlessingSelectItemYes = self:child("PokemonBlessing-SelectItem-Yes")
  self.txtPokemonBlessingSelectItemList = self:child("PokemonBlessing-SelectItem-List")
  self.gvBlessList = UIMgr:new_widget("grid_view")
  self.gvBlessList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBlessList:InitConfig(10, 10, 6)
  self.txtPokemonBlessingSelectItemList:AddChildWindow(self.gvBlessList)
  local width = self.txtPokemonBlessingSelectItemList:GetPixelSize().x
  local itemWidth = (width - 50) / 6
  local adapter = UIMgr:new_adapter("pokemon_bag", itemWidth, itemWidth)
  self.gvBlessList:invoke("setAdapter", adapter)
  local showList = BlessItemConfig:getAllConfig()
  table.sort(showList, function(a, b)
    if a.bless_type ~= b.bless_type then
      return a.bless_type < b.bless_type
    end
    return a.bless_level > b.bless_level
  end)
  for index, config in pairs(showList) do
    local itemData = {
      item = {
        _cfg = config,
        stack_count = function()
          return Me:getTrayItemCountByFullName(config.fullName)
        end
      },
      clickCallBack = function()
        for clickIndex, itemData in pairs(showList) do
          itemData.select = clickIndex == index
        end
        self.txtPokemonBlessingSelectItemTipText:SetText(Lang:toText(config.desc))
        adapter:notifyDataChange()
      end,
      select = false
    }
    showList[index] = itemData
  end
  self.blessItemList = showList
  adapter:setData(showList)
end

function M:initClassifyTabs()
  self.classifyTabs = {}
  local raceIds = RaceConfig:getAllRaceId()
  table.insert(raceIds, 1, 0)
  local itemWidth = self.llClassifyTabList:GetPixelSize().x
  local height = self.llClassifyTabList:GetPixelSize().y
  local itemHeight = (height - 10 * (#raceIds - 1)) / #raceIds
  local positionY = 0
  for index, raceId in pairs(raceIds) do
    local tab = UIMgr:new_widget("pokemon_race_tab_cell")
    tab:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    tab:invoke("setRaceId", raceId)
    self.llClassifyTabList:AddChildWindow(tab)
    self.classifyTabs[index] = tab
    self:subscribe(tab, UIEvent.EventCheckStateChanged, function()
      if tab:GetChecked() then
        for _, tabCheckBox in pairs(self.classifyTabs) do
          if tabCheckBox:GetChecked() and tabCheckBox ~= tab then
            tabCheckBox:SetChecked(false)
            tabCheckBox:SetTouchable(true)
          end
        end
        tab:SetTouchable(false)
        self:changeClassifyTab(raceId)
      end
    end)
    positionY = positionY + itemHeight + 10
  end
  self:selectClassifyTab(1)
end

function M:initDetailLayout()
  local titleItem = UIMgr:new_widget("pokemon_bless_cell")
  titleItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  titleItem:invoke("onDataChanged", {
    text1 = Lang:toText("gui.bless.current.attribute"),
    text2 = Lang:toText("gui.bless.total.bless"),
    text3 = Lang:toText("gui.bless.current.bless"),
    text4 = Lang:toText("gui.bless.used.times"),
    icon = "",
    show_delete = false
  })
  self.lytPokemonBlessingRightContentTop:AddChildWindow(titleItem)
  self.attrItems = {}
  local itemWidth = self.lytPokemonBlessingRightContentList:GetPixelSize().x
  local height = self.lytPokemonBlessingRightContentList:GetPixelSize().y
  local itemHeight = height / 6
  local positionY = 0
  for index = 1, 6 do
    local item = UIMgr:new_widget("pokemon_bless_cell")
    UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, item:invoke("root"), -40, 5, index)
    item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lytPokemonBlessingRightContentList:AddChildWindow(item)
    self.attrItems[index] = item
    positionY = positionY + itemHeight
  end
end

function M:initEvent()
  self:subscribe(self.btnPokemonBlessingBless, UIEvent.EventButtonClick, function()
    self:sendBlessPacket()
  end)
  self:subscribe(self.btnPokemonBlessingClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnPokemonBlessingShop, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemon_Shop"):onShow(true)
  end)
  self:subscribe(self.txtPokemonBlessingSelectItemYes, UIEvent.EventButtonClick, function()
    for _, itemData in pairs(self.blessItemList) do
      if itemData.select then
        self:selectBlessItem(itemData.item)
        break
      end
    end
    self.txtPokemonBlessingSelectItemLayout:SetVisible(false)
  end)
  self:subscribe(self.txtPokemonBlessingSelectItemClose, UIEvent.EventButtonClick, function()
    self.txtPokemonBlessingSelectItemLayout:SetVisible(false)
  end)
  self:subscribe(self.cbClassifyOpenCheckBox, UIEvent.EventCheckStateChanged, function()
    local checked = self.cbClassifyOpenCheckBox:GetChecked()
    self.llClassifyOpenLayout:SetVisible(checked)
  end)
end

function M:subscribeEvent()
  Lib.subscribeEvent(Event.EVENT_CHANGE_BATTLE_PET, function(value)
    self:upDatePokemonBattleList(value)
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_PACKET_PET, function(value)
    self:upDatePokemonPacketList(value)
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_ITEM_MODIFY, function()
    local adapter = self.gvBlessList:invoke("getAdapter")
    if adapter then
      adapter:notifyDataChange()
    end
    self:selectBlessItem(self.select_item)
  end)
  Lib.subscribeEvent(Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if not UI:isOpen(self) then
      return
    end
    if self.cur_pokemon and tostring(objId) == tostring(self.cur_pokemon:getObjId()) then
      self:selectPokemon(self.cur_pokemon)
    end
  end)
end

function M:changeClassifyTab(raceId)
  self.cur_raceId = raceId
  self.cbClassifyOpenCheckBox:SetChecked(false)
  self.stCurClassifyText:SetText(Lang:toText(RaceConfig:getName(raceId)))
  self.siCurClassifyIcon:SetImage(RaceConfig:getClassifyIcon(raceId))
  self:refreshPokemonPacketUI()
end

function M:selectBlessItem(item)
  local costFullName = "add"
  local countText = Lang:toText("gui.bless.add.props")
  self.select_item = nil
  if item and item._cfg and item._cfg.fullName then
    self.select_item = item
    costFullName = item._cfg.fullName
    countText = item:stack_count() .. "/1"
  end
  self.imgPokemonBlessingItem:invoke("initViewDataWithoutAdapter", costFullName, countText, function()
    self.txtPokemonBlessingSelectItemLayout:SetVisible(true)
  end)
  self.imgPokemonBlessingItem:invoke("setType")
end

function M:selectClassifyTab(index)
  self.classifyTabs[index]:SetChecked(true)
end

function M:selectPacketItem(pokemon)
  if not pokemon then
    return
  end
  self:selectPokemon(pokemon)
  local adapter = self.gvPacketList:invoke("getAdapter")
  for _, showItem in pairs(self.packetShowList) do
    showItem.isChecked = showItem.pokemon == pokemon
  end
  adapter:notifyDataChange()
end

function M:selectPokemon(pokemon)
  self.cur_pokemon = pokemon
  local showName = Lang:toText(pokemon:getName())
  self.txtPokemonBlessingName:SetText(showName)
  local textLen = self.txtPokemonBlessingName:GetFont():GetTextExtent(showName, 1.0)
  self.txtPokemonBlessingName:SetWidth({0, textLen})
  self.txtPokemonBlessingLevel:SetText("Lv." .. tostring(pokemon:getLevel()))
  local color = RaceConfig:getColorBg(pokemon:getRace())
  self._root:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
  local hpItem = self.attrItems[Define.POKEMON_ATTR_TYPE.Hp]
  hpItem:invoke("setPokemon", pokemon, Define.POKEMON_ATTR_TYPE.Hp)
  local speedItem = self.attrItems[Define.POKEMON_ATTR_TYPE.Speed]
  speedItem:invoke("setPokemon", pokemon, Define.POKEMON_ATTR_TYPE.Speed)
  local pAtkItem = self.attrItems[Define.POKEMON_ATTR_TYPE.PAtk]
  pAtkItem:invoke("setPokemon", pokemon, Define.POKEMON_ATTR_TYPE.PAtk)
  local pDefItem = self.attrItems[Define.POKEMON_ATTR_TYPE.PDef]
  pDefItem:invoke("setPokemon", pokemon, Define.POKEMON_ATTR_TYPE.PDef)
  local sAtkItem = self.attrItems[Define.POKEMON_ATTR_TYPE.SAtk]
  sAtkItem:invoke("setPokemon", pokemon, Define.POKEMON_ATTR_TYPE.SAtk)
  local sDefItem = self.attrItems[Define.POKEMON_ATTR_TYPE.SDef]
  sDefItem:invoke("setPokemon", pokemon, Define.POKEMON_ATTR_TYPE.SDef)
  if Me:isInTeam(pokemon:getObjId()) and pokemon:getCanBlessRedPointShow() then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, self:checkCanShowRedPoint(pokemon, Define.POKEMON_ATTR_TYPE.Hp), nil, nil, 1)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, self:checkCanShowRedPoint(pokemon, Define.POKEMON_ATTR_TYPE.Speed), nil, nil, 2)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, self:checkCanShowRedPoint(pokemon, Define.POKEMON_ATTR_TYPE.PAtk), nil, nil, 3)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, self:checkCanShowRedPoint(pokemon, Define.POKEMON_ATTR_TYPE.PDef), nil, nil, 4)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, self:checkCanShowRedPoint(pokemon, Define.POKEMON_ATTR_TYPE.SAtk), nil, nil, 5)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, self:checkCanShowRedPoint(pokemon, Define.POKEMON_ATTR_TYPE.SDef), nil, nil, 6)
  else
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, 1)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, 2)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, 3)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, 4)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, 5)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, 6)
  end
end

function M:checkCanShowRedPoint(pokemon, type)
  for level = 1, 3 do
    local blessItemCfg = BlessItemConfig:getConfigByTypeAndLevel(type, level)
    if Me:getTrayItemCountByFullName(blessItemCfg.fullName) > 0 and pokemon:getBlessTimes(blessItemCfg.bless_type) < pokemon:getBlessLimit(blessItemCfg.bless_type) then
      return true
    end
  end
end

function M:upDatePokemonBattleList(objIds)
  objIds = objIds or Me:getValue("battlePetList")
  Me:getPokemonList(objIds, function(battleList)
    self.battleList = battleList
    if UI:isOpen(self) and self.type == "battle" then
      self:refreshPokemonBattleUI()
    end
  end)
end

function M:upDatePokemonPacketList(objIds)
  objIds = objIds or Me:getValue("packetPetList")
  Me:getPokemonList(objIds, function(packetList)
    self.packetList = packetList
    for _, tab in pairs(self.classifyTabs) do
      local raceId = tab:invoke("getRaceId")
      local pokemonList = self:getPokemonListByRaceId(raceId)
      tab:invoke("setEnabled", 0 < #pokemonList)
    end
    if UI:isOpen(self) and self.type == "packet" then
      self:refreshPokemonPacketUI()
    end
  end)
end

function M:refreshPokemonPacketUI()
  local adapter = self.gvPacketList:invoke("getAdapter")
  local raceId = self.cur_raceId
  local showPokemonList = self:getPokemonListByRaceId(raceId)
  if #showPokemonList == 0 then
    return
  end
  local showList = {}
  for _, pokemon in pairs(showPokemonList) do
    table.insert(showList, {
      pokemon = pokemon,
      clickCallBack = function()
        self:selectPacketItem(pokemon)
      end,
      checkInTeam = true,
      isChecked = false,
      checkCanBless = true
    })
  end
  for index = 1, World.cfg.maxBoxPetsCnt do
    if not showList[index] then
      showList[index] = {pokemon = nil, isChecked = false}
    end
  end
  self.packetShowList = showList
  adapter:setData(showList)
  adapter:setScrollOffset(0)
  self:selectPacketItem(adapter.view:GET_ITEM(0):invoke("getPokemon"))
end

function M:getPokemonListByRaceId(raceId)
  local showList = {}
  for _, pokemon in pairs(self.battleList) do
    if raceId == 0 or tonumber(pokemon:getRace()) == raceId then
      table.insert(showList, pokemon)
    end
  end
  for _, pokemon in pairs(self.packetList) do
    if raceId == 0 or tonumber(pokemon:getRace()) == raceId then
      table.insert(showList, pokemon)
    end
  end
  return showList
end

function M:sendBlessPacket()
  if not self.select_item then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.bless.not.select"
    })
    return
  end
  local hasNum = self.select_item:stack_count()
  if hasNum == 0 then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.not.enough"
    })
    return
  end
  local use_fullName = self.select_item._cfg.fullName
  local bless_config = BlessItemConfig:getConfigByFullName(use_fullName)
  local bless_pokemon = self.cur_pokemon
  if bless_pokemon:getBlessTimes(bless_config.bless_type) >= bless_pokemon:getBlessLimit(bless_config.bless_type) then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.bless.attr.full"
    })
    return
  end
  Me:sendPacket({
    pid = "pokemonBless",
    objId = self.cur_pokemon:getObjId(),
    fullName = use_fullName
  }, function()
    self:checkBattlePokemonRedPoint()
  end)
end

function M:checkBattlePokemonRedPoint()
  Me:getBattlePokemon(function(battlePokemonList)
    for index, pokemon in pairs(battlePokemonList) do
      local haveBlessItem = false
      for type = 1, 6 do
        if self:checkCanShowRedPoint(pokemon, type) then
          haveBlessItem = true
          break
        end
      end
      pokemon:setCanBlessRedPointShow(haveBlessItem)
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_PET_RED, haveBlessItem, nil, nil, index)
    end
  end)
end

function M:removeBattlePokemonRedPoint()
  Me:getBattlePokemon(function(battlePokemonList)
    for index, pokemon in pairs(battlePokemonList) do
      pokemon:setCanBlessRedPointShow(false)
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_PET_RED, false, nil, nil, index)
    end
  end)
end

function M:initView()
  self:refreshPokemonPacketUI()
  self.btnPokemonBlessingShop:SetVisible(UI:getWnd("pokemonMain").btnPokemonMainShop:IsVisible())
end

function M:onOpen()
  self:initView()
end

function M:onClose()
  for index = 1, 6 do
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_ATTRIBUTE_RED, false, nil, nil, index)
  end
  self:removeBattlePokemonRedPoint()
end

return M
