local M = _ENV.M
local SkillConfig = T(Config, "SkillConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local RaceConfig = T(Config, "RaceConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local recordTimerCallback
local showPokemonCount = 0

function M:init()
  WinBase.init(self, "PokemonWake.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.txtPokemonWakeTitleTxt = self:child("PokemonWake-TitleTxt")
  self.btnPokemonWakeCloseBtn = self:child("PokemonWake-CloseBtn")
  self.lytPokemonWakeInteractionLayout = self:child("PokemonWake-InteractionLayout")
  self.imgPokemonWakeItemLayout = self:child("PokemonWake-ItemLayout")
  self.btnPokemonWakeItem = self:child("PokemonWake-Item")
  self.txtPokemonWakeItemCount = self:child("PokemonWake-ItemCount")
  self.btnPokemonWakeUpWake = self:child("PokemonWake-UpWake")
  self.lytPokemonWakeLeftLayout = self:child("PokemonWake-LeftLayout")
  self.lytPokemonWakeDetailLayout = self:child("PokemonWake-Detail-Layout")
  self.lytWakeMain = self:child("PokemonWake-MainLayout")
  self.lytWakeSuccess = self:child("PokemonWake-WakeSuccess")
  self.successMask = self:child("PokemonWake-SuccessMask")
  self.lytPreStar = self:child("PokemonWake-PreStarUpShowLayout")
  self.lytAfterStar = self:child("PokemonWake-AfterStarUpShowLayout")
  self.actSuccessEntity = self:child("PokemonWake-SuccessEntityWindow")
  self.txtSuccessTitle = self:child("PokemonWake-SuccessTxt")
  self.preStar = UIMgr:new_widget("pokemon_star_item_cell")
  self.lytPreStar:AddChildWindow(self.preStar)
  self.afterStar = UIMgr:new_widget("pokemon_star_item_cell")
  self.lytAfterStar:AddChildWindow(self.afterStar)
  self.btnItem = self:child("PokemonWake-Item")
  self.selectPokemonItem = UIMgr:new_widget("pokemonSelectCell")
  self.selectPokemonItem:SetName("guide_pokemon_wake_select")
  self.selectPokemonItem:invoke("setData", function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_ADD_MATERIAL then
      Me:gotoNextGuide()
    else
      self.lytPokemonWakeSelect:SetVisible(true)
    end
  end, nil)
  self.selectPokemonItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.btnItem:AddChildWindow(self.selectPokemonItem)
  self.btnSuccessConfirm = self:child("PokemonWake-ConfirmBtn")
  self.txtPokemonWakeTitleTxt:SetText(Lang:toText("gui.wake.title"))
  self.btnPokemonWakeUpWake:SetText(Lang:toText("gui.wake.title"))
  self.txtSuccessTitle:SetText(Lang:toText("gui.wakeUp.success"))
  self:initPassiveDetail()
  self:initAttrDetail()
  self:initSelectLayout()
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT, self.selectPokemonItem:invoke("root"), -5, 5)
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, self.btnPokemonWakeUpWake, -5, 5)
end

function M:initAttrDetail()
  self.lytAttr = self:child("PokemonWake-AttributesLayout")
  self.attributesItem = UIMgr:new_widget("pokemonAttributes")
  self.attributesItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytAttr:AddChildWindow(self.attributesItem)
end

function M:initPassiveDetail()
  self.passiveItems = {}
  self.lytPokemonWakePassiveList = self:child("PokemonWake-Passive-List")
  self.imgPokemonWakePassiveDescIconBg = self:child("PokemonWake-Passive-Desc-Icon-Bg")
  self.stPassiveDescIcon = UIMgr:new_widget("pokemon_passive_cell")
  self.stPassiveDescIcon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.imgPokemonWakePassiveDescIconBg:AddChildWindow(self.stPassiveDescIcon)
  self.txtPokemonWakePassiveDescName = self:child("PokemonWake-Passive-Desc-Name")
  self.txtPokemonWakePassiveDescText = self:child("PokemonWake-Passive-Desc-Text")
  self.imgPokemonWakeStarArrow = self:child("PokemonWake-Star-Arrow")
  self.lytPokemonWakeStarLeft = self:child("PokemonWake-Star-Left")
  self.stPassiveStarLeft = UIMgr:new_widget("pokemon_star_item_cell")
  self.lytPokemonWakeStarLeft:AddChildWindow(self.stPassiveStarLeft)
  self.lytPokemonWakeStarRight = self:child("PokemonWake-Star-Right")
  self.stPassiveStarRight = UIMgr:new_widget("pokemon_star_item_cell")
  self.lytPokemonWakeStarRight:AddChildWindow(self.stPassiveStarRight)
  local width = self.lytPokemonWakePassiveList:GetPixelSize().x
  local itemWidth = (width - 42) / 4
  local itemHeight = itemWidth
  local positionY = 0
  local positionX = 0
  for index = 1, 8 do
    local item = UIMgr:new_widget("pokemon_passive_cell")
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lytPokemonWakePassiveList:AddChildWindow(item)
    self.passiveItems[index] = item
    positionX = positionX + itemWidth + 14
    if index % 4 == 0 then
      positionX = 0
      positionY = positionY + itemHeight + 14
    end
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectPassiveItem(item)
    end)
  end
end

function M:initSelectLayout()
  self.lytPokemonWakeSelect = self:child("PokemonWake-Select")
  self.txtSelectLytTitle = self:child("PokemonWake-selectLytTitle")
  self.txtSelectLytTitle:SetText(Lang:toText("gui.wake.select"))
  self.btnSelectLytBtn = self:child("PokemonWake-SelectLytBtn")
  self.lytPetsSelectLyt = self:child("PokemonWake-petsSelectLyt")
  self.lytPetsShowList = self:child("PokemonWake-petsShowList")
  self.btnYesBtn = self:child("PokemonWake-yesBtn")
  self.btnNoBtn = self:child("PokemonWake-noBtn")
  self.gvPetsSelectList = UIMgr:new_widget("grid_view")
  self.gvPetsSelectList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPetsSelectList:SetAutoColumnCount(false)
  self.gvPetsSelectList:SetItemAlignment(1)
  self.lytPetsSelectLyt:AddChildWindow(self.gvPetsSelectList)
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 12}, {1, 0}, {1, -24})
  self.gvPacketList:InitConfig(26, 8, 4)
  self.gvPetsSelectList:SetAutoColumnCount(false)
  self.gvPetsSelectList:SetItemAlignment(1)
  self.lytPetsShowList:AddChildWindow(self.gvPacketList)
  local adapter = UIMgr:new_adapter("pokemon_packet", 80, 80)
  self.gvPacketList:invoke("setAdapter", adapter)
end

function M:showWakeSelect()
  self.lytPokemonWakeSelect:SetVisible(true)
end

function M:hideWakeSelect()
  self.lytPokemonWakeSelect:SetVisible(false)
end

function M:selectPassiveItem(selectItem)
  local skillId = selectItem:invoke("getSkillId")
  if skillId == 0 then
    return
  end
  for _, item in pairs(self.passiveItems) do
    item:invoke("onChecked", false)
    if selectItem == item then
      item:invoke("onChecked", true)
      local skill_config = SkillConfig:getConfigById(skillId) or {}
      self.txtPokemonWakePassiveDescName:SetText(Lang:toText(skill_config.name or "SkillName"))
      self.txtPokemonWakePassiveDescText:SetText(Lang:toText(skill_config.describe or "DescText"))
      self.stPassiveDescIcon:invoke("updateInfo", skillId, false)
    end
  end
end

function M:initEvent()
  self:subscribe(self.btnPokemonWakeCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnSuccessConfirm, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_WND then
      Me:gotoNextGuide()
    else
      self:confirmWakeUp()
    end
  end)
  self:subscribe(self.btnPokemonWakeItem, UIEvent.EventButtonClick, function()
  end)
  self:subscribe(self.btnPokemonWakeUpWake, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CONFIRM_WAKE then
      Me:gotoNextGuide()
    else
      self:checkWakeUp()
    end
  end)
  self:subscribe(self.btnItem, UIEvent.EventButtonClick, function()
  end)
  self:subscribe(self.btnSelectLytBtn, UIEvent.EventButtonClick, function()
    self.lytPokemonWakeSelect:SetVisible(false)
    self:refreshSelectList()
    self:refreshPokemonList()
  end)
  self:subscribe(self.btnYesBtn, UIEvent.EventButtonClick, function()
    Me:getPokemonList(self.selectList, function(pokemonList)
      Lib.logDebug("btnYesBtn")
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CONFIRM_MATERIAL then
        Me:gotoNextGuide()
      end
      local wake_config = PokemonConfig:getWakeConfig(self.cur_pokemon:getWake())
      local costNum = wake_config.wakeUpCost
      local firstSelectPokemon
      for _, pokemon in pairs(pokemonList) do
        firstSelectPokemon = firstSelectPokemon or pokemon
        if pokemon:isHighQuality() then
          Me:showSpecialChatDialog({
            titleText = "gui.tip.title",
            msgText = "gui.release.high.quality",
            popupKey = "wakeUpHighQuality"
          }, function(sure)
            if sure then
              UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, self.packetMode == "battle" and costNum == #self.selectList)
              self.lytPokemonWakeSelect:SetVisible(false)
              local cfg = PokemonConfig:getConfigById(firstSelectPokemon:getCfgId())
              self.selectPokemonItem:invoke("setLimitHeadIcon", cfg.icon, true)
            end
          end)
          return
        end
      end
      self.lytPokemonWakeSelect:SetVisible(false)
      self.selectPokemonItem:invoke("setPokemon", firstSelectPokemon)
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, self.cur_pokemon:getCanWakeRedPointShow() and self.packetMode == "battle" and costNum == #self.selectList)
    end)
  end)
  self:subscribe(self.btnNoBtn, UIEvent.EventButtonClick, function()
    self.lytPokemonWakeSelect:SetVisible(false)
    self:refreshSelectList()
    self:refreshPokemonList()
  end)
end

function M:subscribeEvent()
end

function M:checkWakeUp()
  local needCount = self.gvPetsSelectList:GetChildCount()
  if needCount > #self.selectList then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.wake.not.enough"
    })
    return
  end
  Me:sendPacket({
    pid = "pokemonCanWakeUp",
    objId = self.cur_pokemon:getObjId(),
    costIds = self.selectList
  }, function(code)
    if code == 0 then
      self:showWakeSuccessPreview()
      Me:playSoundByKey("wake_success")
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_WND then
        UI:getWnd("pokemonGuide"):onShow(false)
        Lib.emitEvent(Event.EVENT_HIDE_BLOCK_INPUT)
      end
    elseif code == 1 then
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.wake.not.enough"
      })
    elseif code == 2 then
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.wake.cost.error"
      })
    end
  end)
end

function M:confirmWakeUp()
  Me:sendPacket({
    pid = "pokemonWakeUp",
    objId = self.cur_pokemon:getObjId(),
    costIds = self.selectList
  }, function()
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, false)
    Lib.emitEvent(Event.EVENT_CLICK_WAKE_CONFIRM)
    self:onHide()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_PACKET then
      UI:getWnd("pokemonGuide"):onShow(true, Me:getCurGuideIndex())
      Lib.emitEvent(Event.EVENT_HIDE_BLOCK_INPUT)
    end
  end)
end

function M:selectPokemon(pokemon)
  self.cur_pokemon = pokemon
  self.stPassiveStarLeft:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake())
  self.stPassiveStarRight:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake() + 1)
  local passiveRule = pokemon:getCfg().passiveRule
  for index, item in pairs(self.passiveItems) do
    local passiveTable = passiveRule[index] or {}
    local skillId = tonumber(passiveTable[1] or 0)
    local unlockWake = tonumber(passiveTable[2] or 0)
    local readyToUnlock = unlockWake - pokemon:getWake() == 1
    item:invoke("updateInfo", skillId, unlockWake > pokemon:getWake(), readyToUnlock)
  end
  self:selectPassiveItem(self.passiveItems[1])
  self.attributesItem:invoke("updateUIByType", self.cur_pokemon, "wake")
  local wake_config = PokemonConfig:getWakeConfig(pokemon:getWake())
  local costNum = wake_config.wakeUpCost
  local pokemon_config_list = PokemonConfig:getEvolutionList(pokemon:getCfgId())
  self.selectPokemonItem:invoke("setLimitHeadIcon", pokemon_config_list[1].icon)
  self:updateGridView(costNum, pokemon_config_list[1].icon)
end

function M:updateGridView(count, limitIcon)
  self.gvPetsSelectList:RemoveAllItems()
  self.gvPetsSelectList:InitConfig(31, 0, count)
  for _ = 1, count do
    local item = UIMgr:new_widget("pokemonSelectCell")
    item:SetHorizontalAlignment(0)
    item:invoke("setLimitHeadIcon", limitIcon)
    item:SetArea({0, 0}, {0, 0}, {0, 82}, {0, 82})
    self.gvPetsSelectList:AddItem(item)
  end
end

function M:showWakeSuccessPreview()
  self:showWnd(true)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(self.cur_pokemon:getCfgFullName())
  local pokemon_config = PokemonConfig:getConfigById(self.cur_pokemon:getCfgId())
  self.actSuccessEntity:SetActor1(entity_cfg.actorName, "idle")
  self.actSuccessEntity:SetActorScale(pokemon_config.uiScale)
  if getmetatable(self.actSuccessEntity).SetActorOffset then
    self.actSuccessEntity:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  self.actSuccessEntity:SetYPosition({
    pokemon_config.uiOffsetY,
    0
  })
  self.actSuccessEntity:SetRotateY(-15)
  self.actSuccessEntity:SetRotateX(10)
  self.preStar:invoke("updateUI", self.cur_pokemon:getStarLevel(), self.cur_pokemon:getWake(), 1)
  self.afterStar:invoke("updateUI", self.cur_pokemon:getStarLevel(), self.cur_pokemon:getWake() + 1, 1)
end

function M:initView()
end

function M:onShow(pokemon, timerCallback, packetMode)
  recordTimerCallback = timerCallback
  self.packetMode = packetMode
  UI:openWnd("pokemonWake", pokemon)
end

function M:onHide()
  UI:closeWnd("pokemonWake")
end

function M:refreshSelectList()
  self.selectList = {}
  self.unSelectList = Me:getValue("battlePetList")
  self.battlePetObjIds = Me:getValue("battlePetList")
  local packetPetList = Me:getValue("packetPetList")
  packetPetList = Me:filterLockPokemonToEnd(packetPetList)
  for _, objId in pairs(packetPetList) do
    table.insert(self.unSelectList, objId)
  end
end

function M:onOpen(pokemon)
  self._allEvent = {}
  self.selectPokemonItem:invoke("setPokemon", nil)
  self:subscribeEvent()
  self:initView()
  self:selectPokemon(pokemon)
  self:refreshSelectList()
  self:refreshPokemonList()
  self:showWnd(false)
  if not pokemon:getCanWakeRedPointShow() or self.packetMode ~= "battle" then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, false)
  elseif pokemon:getCanWakeRedPointShow() and self.packetMode == "battle" and UIRedDotMgr:getRedShowStateByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM) then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, false)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT, true)
  end
end

function M:showWnd(success)
  self.lytWakeMain:SetVisible(not success)
  self.lytWakeSuccess:SetVisible(success)
  self.successMask:SetVisible(success)
end

function M:refreshPokemonList()
  Me:getPokemonList(self.selectList, function(pokemonList)
    local itemCount = self.gvPetsSelectList:GetItemCount()
    for index = 1, itemCount do
      local item = self.gvPetsSelectList:GetItem(index - 1)
      local pokemon = pokemonList[index]
      item:invoke("onDataChanged", {
        pokemon = pokemon,
        clickCallBack = function()
          if pokemon then
            self:unSelectPokemonObjId(pokemon:getObjId())
          end
        end
      })
    end
    self.txtPokemonWakeItemCount:SetText(#pokemonList .. "/" .. itemCount)
  end)
  Me:getPokemonList(self.unSelectList, function(packetList)
    local adapter = self.gvPacketList:invoke("getAdapter")
    local showList = {}
    for _, pokemon in pairs(packetList) do
      if PokemonConfig:isSamePokemon(pokemon:getCfgId(), self.cur_pokemon:getCfgId()) and pokemon ~= self.cur_pokemon then
        local isSelect = false
        for _, objId in pairs(self.selectList) do
          if pokemon:getObjId() == objId then
            isSelect = true
            break
          end
        end
        table.insert(showList, {
          pokemon = pokemon,
          checkInTeam = true,
          checkLocked = true,
          isChecked = isSelect,
          clickCallBack = function()
            if pokemon:isLocked() then
              return
            end
            self:checkPokemonObjId(pokemon:getObjId())
            if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_SELECT_MATERIAL then
              Me:gotoNextGuide()
            end
          end
        })
      end
    end
    for index = 1, World.cfg.maxBoxPetsCnt do
      showList[index] = showList[index] or {pokemon = nil}
    end
    self.packetShowList = showList
    adapter:setData(showList)
    adapter:setScrollOffset(0)
    local guide_node = adapter.view:GET_ITEM(0)
    if guide_node then
      guide_node:SetName("guide_pokemon_wake_first_cell")
    end
  end)
end

function M:checkPokemonObjId(checkObjId)
  for _, objId in pairs(self.selectList) do
    if objId == checkObjId then
      self:unSelectPokemonObjId(checkObjId)
      return
    end
  end
  for _, objId in pairs(self.battlePetObjIds) do
    if objId == checkObjId then
      return
    end
  end
  self:selectPokemonObjId(checkObjId)
end

function M:selectPokemonObjId(selectObjId)
  local itemCount = self.gvPetsSelectList:GetItemCount()
  if itemCount <= #self.selectList then
    return
  end
  table.insert(self.selectList, selectObjId)
  self:refreshPokemonList()
end

function M:unSelectPokemonObjId(unSelectObjId)
  for index, objId in pairs(self.selectList) do
    if objId == unSelectObjId then
      table.remove(self.selectList, index)
      break
    end
  end
  self:refreshPokemonList()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if recordTimerCallback ~= nil and type(recordTimerCallback) == "function" then
    recordTimerCallback()
  end
end

return M
