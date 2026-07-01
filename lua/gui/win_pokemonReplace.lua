local LuaTimer = T(Lib, "LuaTimer")
local RaceConfig = T(Config, "RaceConfig")
local recordTimerCallback
local packetPokemonShowCount = 0

function M:init()
  WinBase.init(self, "PokemonReplace.json", false)
  self:initWnd()
end

function M:initWnd()
  self.btnClose = self:child("PokemonReplace-Close")
  self.btnCancel = self:child("PokemonReplace-Cancel")
  self.btnSave = self:child("PokemonReplace-Save")
  self.llBattleList = self:child("PokemonReplace-Battle-List")
  self.llPacketList = self:child("PokemonReplace-Packet-List")
  self.llClassifyTabList = self:child("PokemonReplace-Right-Tabs-List")
  self.btnCancel:SetText(Lang:toText("gui.btn.cancel"))
  self.btnSave:SetText(Lang:toText("gui.btn.save"))
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPacketList:InitConfig(10, 10, 6)
  self.llPacketList:AddChildWindow(self.gvPacketList)
  self.battleItems = {}
  self:initClassifyTabs()
  self:initEvent()
  local width = self.llPacketList:GetPixelSize().x
  local itemWidth = (width - 50) / 6
  local adapter = UIMgr:new_adapter("pokemon_packet", itemWidth, itemWidth)
  self.gvPacketList:invoke("setAdapter", adapter)
  self.packetShowList = {
    {pokemon = nil}
  }
  adapter:setData(self.packetShowList)
  World.Timer(1, function()
    for _ = 1, 6 do
      table.insert(self.packetShowList, {pokemon = nil})
    end
    adapter:setData(self.packetShowList)
    return #self.packetShowList < World.cfg.maxBoxPetsCnt
  end)
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:clickClose()
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    self:clickCancel()
  end)
  self:subscribe(self.btnSave, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_SAVE_QUEUE then
      Me:gotoNextGuide()
    else
      self:clickSave()
    end
  end)
end

function M:onShow(timerCallback)
  self.battlePetList = Me:getValue("battlePetList")
  self.battlePetCount = #self.battlePetList
  self.packetPetList = Me:getValue("packetPetList")
  self:upDatePokemonBattleList()
  self:upDatePokemonPacketList()
  self:selectClassifyTab(1)
  UI:openWnd("pokemonReplace")
  recordTimerCallback = timerCallback
end

function M:initClassifyTabs()
  self.classifyTabs = {}
  local raceIds = RaceConfig:getAllRaceId()
  table.insert(raceIds, 1, 0)
  local width = self.llClassifyTabList:GetPixelSize().x
  local itemHeight = self.llClassifyTabList:GetPixelSize().y
  local itemWidth = (width - 10 * (#raceIds - 1)) / #raceIds
  local positionX = 0
  for index, raceId in pairs(raceIds) do
    local tab = UIMgr:new_widget("pokemon_race_tab_cell")
    tab:SetArea({0, positionX}, {0, 0}, {0, itemWidth}, {0, itemHeight})
    tab:invoke("setRaceId", raceId)
    tab:invoke("setType", "replace")
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
    positionX = positionX + itemWidth + 10
  end
end

function M:selectClassifyTab(index)
  self.classifyTabs[index]:SetChecked(true)
end

function M:changeClassifyTab(raceId)
  self.cur_raceId = raceId
  self:upDatePokemonPacketList()
end

function M:selectBattleItem(pokemon)
  if not pokemon then
    return
  end
  for index, objId in pairs(self.battlePetList) do
    if tostring(objId) == tostring(pokemon:getObjId()) then
      self.battlePetCount = self.battlePetCount - 1
      self.battlePetList[index] = nil
      break
    end
  end
  table.insert(self.packetPetList, pokemon:getObjId())
  self:upDatePokemonBattleList()
  self:upDatePokemonPacketList()
end

function M:selectPacketItem(pokemon)
  if not pokemon then
    return
  end
  if self.battlePetCount == World.cfg.maxHandPetsCnt then
    return
  end
  if tonumber(pokemon:getLevel()) > tonumber(Me:getPlayerLevel()) then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.pokemon.level.higher"
    })
    return
  end
  for index, objId in pairs(self.packetPetList) do
    if tostring(objId) == tostring(pokemon:getObjId()) then
      table.remove(self.packetPetList, index)
      break
    end
  end
  for index = 1, World.cfg.maxHandPetsCnt do
    if self.battlePetList[index] == nil then
      self.battlePetCount = self.battlePetCount + 1
      self.battlePetList[index] = pokemon:getObjId()
      break
    end
  end
  self:upDatePokemonBattleList()
  self:upDatePokemonPacketList()
end

function M:upDatePokemonBattleList()
  local itemWidth = self.llBattleList:GetPixelSize().x
  local height = self.llBattleList:GetPixelSize().y
  local itemHeight = (height - 45) / 4
  local positionY = 0
  for index = 1, World.cfg.maxHandPetsCnt do
    local item = self.battleItems[index]
    local pokemon
    Me:getPokemon(self.battlePetList[index], function(_pokemon)
      pokemon = _pokemon
    end)
    if not item then
      item = UIMgr:new_widget("pokemon_head_cell")
      item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
      item:SetVerticalAlignment(0)
      self.llBattleList:AddChildWindow(item)
      self.battleItems[index] = item
      self:subscribe(item, UIEvent.EventWindowClick, function()
        self:selectBattleItem(item:invoke("getPokemon"))
      end)
      item:invoke("setType", Define.SCENE_TYPE.NOT_BATTLE)
      positionY = positionY + itemHeight + 15
    end
    item:invoke("updateInfo", pokemon)
  end
end

function M:upDatePokemonPacketList()
  for index = 1, packetPokemonShowCount do
    self.packetShowList[index] = {pokemon = nil}
  end
  packetPokemonShowCount = 0
  Me:getPokemonList(self.packetPetList, function(packetList)
    self.packetPokemonList = packetList
    for _, pokemon in pairs(packetList) do
      if self.cur_raceId == 0 or tonumber(pokemon:getRace()) == self.cur_raceId then
        packetPokemonShowCount = packetPokemonShowCount + 1
        if packetPokemonShowCount > #self.packetShowList then
          packetPokemonShowCount = packetPokemonShowCount - 1
          World.Timer(20, function()
            self:upDatePokemonPacketList()
          end)
          return
        end
        self.packetShowList[packetPokemonShowCount] = {
          pokemon = pokemon,
          clickCallBack = function()
            self:selectPacketItem(pokemon)
            if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_POKEMON then
              Me:gotoNextGuide()
            end
          end
        }
      end
    end
    local adapter = self.gvPacketList:invoke("getAdapter")
    adapter:notifyDataChange()
    adapter:setScrollOffset(0)
    adapter.view:GET_ITEM(0):SetName("guide_pokemon_battle_first_cell")
    if not Me:isGuideFinish() then
      adapter.view:GET_ITEM(0):SetName("guide_pokemon_battle_first_cell")
      if Me:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_POKEMON then
        Lib.logDebug("open guide")
        UI:getWnd("pokemonGuide"):onShow(true, Me:getCurGuideIndex())
      end
    end
  end)
end

function M:clickClose()
  if recordTimerCallback ~= nil and type(recordTimerCallback) == "function" then
    recordTimerCallback()
  end
  local oldBattleList = Me:getValue("battlePetList")
  local listChanged = false
  for index = 1, 4 do
    if self.battlePetList[index] ~= oldBattleList[index] then
      listChanged = true
      break
    end
  end
  if listChanged then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.replace.no.save"
    }, function(sure)
      if sure then
        self:clickCancel()
      end
    end)
    return
  else
    UI:closeWnd(self)
  end
end

function M:clickCancel()
  UI:closeWnd(self)
end

function M:clickSave()
  if self.battlePetCount == 0 then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.replace.cant.empty"
    })
    return
  end
  if self.battlePetCount < World.cfg.maxHandPetsCnt and 0 < #self.packetPetList and not Me.disableReplaceAuto then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.replace.auto"
    }, function(sure)
      if sure then
        while self.battlePetCount < World.cfg.maxHandPetsCnt do
          local pokemon = table.remove(self.packetPokemonList, 1)
          if not pokemon then
            break
          end
          for index = 1, World.cfg.maxHandPetsCnt do
            if self.battlePetList[index] == nil then
              self.battlePetCount = self.battlePetCount + 1
              self.battlePetList[index] = pokemon:getObjId()
              break
            end
          end
        end
        self:sendBattlePacket()
      end
    end)
    return
  end
  self:sendBattlePacket()
end

function M:sendBattlePacket()
  Me:sendPacket({
    pid = "setBattleListFromClient",
    objIds = table.concat(self.battlePetList, ":")
  }, function(result)
    if result.success then
      UI:closeWnd(self)
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_CLOSE_PACKET then
        UI:getWnd("pokemonGuide"):onShow(true, Me:getCurGuideIndex())
        Lib.emitEvent(Event.EVENT_HIDE_BLOCK_INPUT)
      end
    else
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.replace.fail"
      })
    end
  end)
end
