local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local LuaTimer = T(Lib, "LuaTimer")
local skillEffectCfg = T(Config, "SkillEffectConfig")
local SkillConfig = T(Config, "SkillConfig")
local BUFF_VIEW_MAX_COUNT = 6
local BuffListviewIndex = {
  Listview1 = 1,
  Listview2 = 2,
  Listview3 = 3
}

function M:init()
  widget_base.init(self, "pokemon_head_cell.json")
  self:initUI()
  self:initEvent()
  self.BuffListOpenBtn:SetVisible(false)
end

function M:initUI()
  self._allEvent = {}
  self.lytPokemonHeadCellHeadLayout = self:child("pokemon_head_cell-Head-Layout")
  self.lytPokemonHeadCellInfoLayout = self:child("pokemon_head_cell-Info-Layout")
  self.imgPokemonHeadCellHead = self:child("pokemon_head_cell-head")
  self.widget_item = UIMgr:new_widget("pokemon_packet_item_cell")
  self.widget_item:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.imgPokemonHeadCellHead:AddChildWindow(self.widget_item)
  self.txtPokemonHeadCellName = self:child("pokemon_head_cell-name")
  self.txtPokemonHeadCellHp = self:child("pokemon_head_cell-hp")
  self.txtPokemonHeadCellHp:SetText(Lang:toText("attr_hp"))
  self.txtPokemonHeadCellHpNum = self:child("pokemon_head_cell-hp_num")
  self.grdPokemonHeadCellHpProgressBar = self:child("pokemon_head_cell-hp_progressBar")
  self.imgPokemonHeadCellDbuffIcon = self:child("pokemon_head_cell-dbuff_icon")
  self.imgPokemonHeadCellMask = self:child("pokemon_head_cell-mask")
  self.imgPokemonHeadCellSelect = self:child("pokemon_head_cell-select")
  self.lytPokemonHeadCellQueueInfoList = self:child("pokemon_head_cell-queue_info_list")
  self.lytPokemonHeadCellEmptyLayout = self:child("pokemon_head_cell-Empty")
  self.txtPokemonHeadCellHpCount = self:child("pokemon_head_cell-cell_hp_count")
  self.imgPokemonHeadCellBg = self:child("pokemon_head_cell-bg")
  self.pokemonPetBallsList = self:child("pokemon_head_cell-queue_info_list")
  self.pokemonPetBuffList = self:child("pokemon_head_cell-buffList")
  self.pokemonPetBuffList:SetVisible(false)
  self.pokemonPetBuffList1 = self:child("pokemon_head_cell-buffList_1")
  self.pokemonPetBuffList2 = self:child("pokemon_head_cell-buffList_2")
  self.pokemonPetBuffList3 = self:child("pokemon_head_cell-buffList_3")
  self.BuffListOpenBtn = self:child("pokemon_head_cell-openBtn")
  self.BuffListOpenCountText = self:child("pokemon_head_cell-count")
  self.BuffListMask = self:child("pokemon_head_cell-buffListMask")
  self.pokemonPetBuffListview1 = UIMgr:new_widget("grid_view")
  self.pokemonPetBuffListview2 = UIMgr:new_widget("grid_view")
  self.pokemonPetBuffListview3 = UIMgr:new_widget("grid_view")
  self.pokemonPetBuffList1:AddChildWindow(self.pokemonPetBuffListview1)
  self.pokemonPetBuffList2:AddChildWindow(self.pokemonPetBuffListview2)
  self.pokemonPetBuffList3:AddChildWindow(self.pokemonPetBuffListview3)
  self.pokemonPetBuffListview1:SetMoveAble(false)
  self.pokemonPetBuffListview2:SetMoveAble(false)
  self.pokemonPetBuffListview3:SetMoveAble(false)
  self.pokemonPetBuffListview1:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.pokemonPetBuffListview2:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.pokemonPetBuffListview3:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.PetBalls = {}
  for i = 1, 4 do
    self.PetBalls[i] = self:child(string.format("pokemon_head_cell-pet_ball_%d", i))
  end
end

function M:clearAllBuffListvGridView()
  self.pokemonPetBuffListview1:RemoveAllItems()
  self.pokemonPetBuffListview2:RemoveAllItems()
  self.pokemonPetBuffListview3:RemoveAllItems()
  self.pokemonPetBuffListview1:InitConfig(5, 0, BUFF_VIEW_MAX_COUNT)
  self.pokemonPetBuffListview2:InitConfig(5, 0, BUFF_VIEW_MAX_COUNT)
  self.pokemonPetBuffListview3:InitConfig(5, 0, BUFF_VIEW_MAX_COUNT)
end

function M:updateOpenBuffListState(isShow, isMyPet, count)
  if isShow then
    if count > BUFF_VIEW_MAX_COUNT then
      self.BuffListOpenBtn:SetVisible(true)
      self.BuffListOpenBtn:SetVerticalAlignment(isMyPet and 2 or 0)
      self.BuffListOpenCountText:SetText("+" .. count - 5)
      if isMyPet then
        self.pokemonPetBuffListview2:SetVisible(false)
        self.pokemonPetBuffListview3:SetVisible(false)
        self.pokemonPetBuffList2:SetVisible(false)
        self.pokemonPetBuffList3:SetVisible(false)
      else
        self.pokemonPetBuffListview1:SetVisible(false)
        self.pokemonPetBuffListview2:SetVisible(false)
        self.pokemonPetBuffList1:SetVisible(false)
        self.pokemonPetBuffList2:SetVisible(false)
      end
      self.BuffListMask:SetVisible(false)
    end
  else
    self.BuffListOpenBtn:SetVisible(false)
    if count > BUFF_VIEW_MAX_COUNT then
      self.pokemonPetBuffListview2:SetVisible(true)
      self.pokemonPetBuffListview3:SetVisible(true)
      self.pokemonPetBuffList2:SetVisible(true)
      self.pokemonPetBuffList3:SetVisible(true)
      self.BuffListMask:SetVisible(false)
    elseif isMyPet then
      self.pokemonPetBuffListview2:SetVisible(false)
      self.pokemonPetBuffListview3:SetVisible(false)
      self.pokemonPetBuffList2:SetVisible(false)
      self.pokemonPetBuffList3:SetVisible(false)
    else
      self.pokemonPetBuffListview1:SetVisible(false)
      self.pokemonPetBuffListview2:SetVisible(false)
      self.pokemonPetBuffList1:SetVisible(false)
      self.pokemonPetBuffList2:SetVisible(false)
    end
  end
end

function M:createSkilleffectCell(index, info, effect)
  local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
  local skill_config = SkillConfig:getConfigById(effect.skillId)
  local cell = UIMgr:new_widget("skilleffectCell")
  info.icon = effectCfg.icon or "set:skillbuff.json image:icon_debuff_spell_def"
  info.round = effect.round
  info.skillName = skill_config and skill_config.name
  info.effectDec = effectCfg.effectTipDec
  info.effectName = effectCfg.iconEffectName or nil
  cell:invoke("updateInfo", info)
  if index == BuffListviewIndex.Listview1 then
    self.pokemonPetBuffListview1:AddItem(cell)
  elseif index == BuffListviewIndex.Listview2 then
    self.pokemonPetBuffListview2:AddItem(cell)
  else
    self.pokemonPetBuffListview3:AddItem(cell)
  end
end

local function sortSkillBuffList(tbList)
  table.sort(tbList, function(a, b)
    return a.sortIndex < b.sortIndex
  end)
  return tbList
end

function M:updatePetBuffList(pokemon)
  if self.scene_type ~= Define.SCENE_TYPE.BATTLE then
    return
  end
  if not pokemon then
    Lib.logError("error:updatePetBuffList, not pokemon")
    return
  end
  local entityId = pokemon:getEntityObjId()
  local entity = World.CurWorld:getObject(entityId)
  if not entity or not entity:isValid() then
    Lib.logError("error:updatePetBuffList, not entity or not entity:isValid()")
    return
  end
  local isMyPet = false
  local masterId = pokemon:getMasterId()
  if Me.platformUserId == masterId or Me:getCampId() == entity:getCampId() then
    isMyPet = true
  end
  local tbBuff = {}
  local tbRoundBuff = pokemon:getLongRoundEffectbuffList() or {}
  local addSkillEffcts = entity:getAddSkillEffects() or {}
  for key, v in pairs(tbRoundBuff) do
    if v then
      table.insert(tbBuff, v)
    end
  end
  for key, effect in pairs(addSkillEffcts) do
    if effect then
      table.insert(tbBuff, effect)
    end
  end
  tbBuff = sortSkillBuffList(tbBuff)
  local count = 0
  local isShowOpenBtn = false
  self.isMyPet = isMyPet
  self:clearAllBuffListvGridView()
  for index, effect in pairs(tbBuff) do
    local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
    effectCfg.icon = string.gsub(effectCfg.icon, "^%s+", "")
    if effectCfg and 0 < #effectCfg.icon then
      local info = {}
      info.skilleffectId = effect.skilleffectId
      if effectCfg.round and tonumber(effectCfg.round[1]) >= 99 then
        info.isLong = true
      else
        info.isLong = false
      end
      count = count + 1
      if count <= BUFF_VIEW_MAX_COUNT then
        self:createSkilleffectCell(isMyPet and BuffListviewIndex.Listview1 or BuffListviewIndex.Listview3, info, effect)
      elseif count > BUFF_VIEW_MAX_COUNT and count <= 2 * BUFF_VIEW_MAX_COUNT then
        isShowOpenBtn = true
        self:createSkilleffectCell(BuffListviewIndex.Listview2, info, effect)
      elseif count > 3 * BUFF_VIEW_MAX_COUNT then
        isShowOpenBtn = true
        self:createSkilleffectCell(isMyPet and BuffListviewIndex.Listview3 or BuffListviewIndex.Listview1, info, effect)
      end
    end
  end
  self.myPetCount = count
  self:updateOpenBuffListState(isShowOpenBtn, isMyPet, count)
end

function M:refreshMainUISize()
  local rootHeight = self:root():GetPixelSize().y
  self.lytPokemonHeadCellHeadLayout:SetArea({0, 0}, {0, 0}, {0, rootHeight}, {0, rootHeight})
  self.lytPokemonHeadCellInfoLayout:SetArea({0, 0}, {0, 0}, {
    1,
    -rootHeight
  }, {0, rootHeight})
end

function M:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_BATTLE_ENEMY_RUN_AWAY", Event.EVENT_BATTLE_ENEMY_RUN_AWAY, function(objId)
    if self.pokemon then
      if tostring(objId) == tostring(self.pokemon:getObjId()) then
        self.pokemon = nil
        self:updateInfo(self.pokemon)
      end
      self:updatePetBallsInfo()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if self.pokemon then
      if tostring(objId) == tostring(self.pokemon:getObjId()) then
        self:updateInfo(self.pokemon)
        self:updatePetBuffList(self.pokemon)
      end
      self:updatePetBallsInfo()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_ADD_EFFECT_DATA_CHANGE, function(objId)
    if self.pokemon and tostring(objId) == tostring(self.pokemon:getObjId()) then
      self:updatePetBuffList(self.pokemon)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_ADD_SKILL_EFFECT, function(objId)
    if self.pokemon and tostring(objId) == tostring(self.pokemon:getObjId()) then
      self:updatePetBuffList(self.pokemon)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_TOUCH_SCREEN, function(sender)
    if self.isOpenBuffList then
      if self.closeBuffListTimer then
        self.closeBuffListTimer()
        self.closeBuffListTimer = nil
      end
      if sender then
        if sender:getId() == self.pokemonPetBuffList:getId() or sender:getId() == self.pokemonPetBuffListview1:getId() or sender:getId() == self.pokemonPetBuffListview2:getId() or sender:getId() == self.pokemonPetBuffListview3:getId() or sender:getId() == self.pokemonPetBuffListview1:getContainerWindow():getId() or sender:getId() == self.pokemonPetBuffListview2:getContainerWindow():getId() or sender:getId() == self.pokemonPetBuffListview3:getContainerWindow():getId() or sender:GetName() == "skilleffectCell" or sender:GetName() == "skilleffectCell-item" or sender:GetName() == "skilleffectCell-effect" or sender:GetName() == "skilleffectCell-round" then
          return
        elseif self.pokemon then
          self:updateOpenBuffListState(true, self.isMyPet, self.myPetCount)
        end
      elseif self.pokemon then
        self:updateOpenBuffListState(true, self.isMyPet, self.myPetCount)
      end
      self.closeBuffListTimer = World.Timer(120, function()
        if self.isOpenBuffList then
          self:updateOpenBuffListState(true, self.isMyPet, self.myPetCount)
          self.isOpenBuffList = false
        end
      end)
    end
  end)
  self._allEvent[#self._allEvent + 1] = World.Timer(1, function()
    if self._root:IsVisible() then
      self:onTick()
    end
    return true
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasRestraint event : EventButtonClick", self.BuffListOpenBtn, UIEvent.EventButtonClick, function()
    self.isOpenBuffList = true
    self:updateOpenBuffListState(false, self.isMyPet, self.myPetCount)
    if self.closeBuffListTimer then
      self.closeBuffListTimer()
      self.closeBuffListTimer = nil
    end
    self.closeBuffListTimer = World.Timer(120, function()
      if self.isOpenBuffList then
        self:updateOpenBuffListState(true, self.isMyPet, self.myPetCount)
        self.isOpenBuffList = false
      end
    end)
  end)
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
  self._allEvent = {}
end

function M:onTick()
  if not self.pokemon then
    return
  end
  local nowCurHp = tonumber(self.txtPokemonHeadCellHpCount:GetText())
  if self.curHp == nowCurHp then
    return
  end
  local nowMaxHp = math.ceil(self.pokemon:isFought() and self.pokemon:getBattleMaxHp() or self.pokemon:getMaxHp())
  local progress = nowCurHp / nowMaxHp
  self.grdPokemonHeadCellHpProgressBar:SetProgress(progress)
  if 0.9 < progress then
    self.grdPokemonHeadCellHpProgressBar:SetProgressImage("set:pokemon_battle.json image:info_hp_green")
  elseif 0.3 < progress then
    self.grdPokemonHeadCellHpProgressBar:SetProgressImage("set:pokemon_battle.json image:info_hp_yellow")
  else
    self.grdPokemonHeadCellHpProgressBar:SetProgressImage("set:pokemon_battle.json image:info_hp_red")
  end
  if self.scene_type == Define.SCENE_TYPE.BATTLE and progress == 0 then
    self:showPetInformation(false)
  end
end

function M:updatePetBallsInfo()
  if self.scene_type ~= Define.SCENE_TYPE.BATTLE then
    return
  end
  
  local function fn(pokemonList)
    for i, ball in pairs(self.PetBalls) do
      if pokemonList[i] then
        local curHp = pokemonList[i]:getCurHp()
        if 0 < curHp then
          ball:SetImage("set:pokemon_battle.json image:info_state_normal")
        else
          ball:SetImage("set:pokemon_battle.json image:info_state_dead")
        end
      else
        ball:SetImage("set:pokemon_battle.json image:info_state_empty")
      end
    end
  end
  
  if self.masterId == Me.platformUserId then
    Me:getBattlePokemon(function(pokemonList)
      fn(pokemonList)
    end)
  else
    if not self.queue then
      return
    end
    Me:getPokemonList(self.queue, function(pokemonList)
      fn(pokemonList)
    end)
  end
end

function M:setPvpQueue(enemyQueue)
  self.queue = enemyQueue
  self:updatePetBallsInfo()
end

function M:getPokemon()
  return self.pokemon
end

function M:setType(scene_type)
  self.scene_type = scene_type
end

function M:showQueueInfo(isShow)
  self.lytPokemonHeadCellQueueInfoList:SetVisible(isShow)
end

function M:updatePveEnemyQueueInfo(initCount, count)
  for i, ball in pairs(self.PetBalls) do
    if i <= initCount then
      if not count then
        ball:SetImage("set:pokemon_battle.json image:info_state_normal")
      elseif i > initCount - count then
        ball:SetImage("set:pokemon_battle.json image:info_state_normal")
      else
        ball:SetImage("set:pokemon_battle.json image:info_state_dead")
      end
    else
      ball:SetImage("set:pokemon_battle.json image:info_state_empty")
    end
  end
end

function M:setPetBallsListPos(isMyPet)
  if isMyPet then
    self.pokemonPetBallsList:SetHorizontalAlignment(0)
    self.pokemonPetBallsList:SetVerticalAlignment(2)
    self.pokemonPetBallsList:SetYPosition({0, 30})
  else
    self.pokemonPetBallsList:SetHorizontalAlignment(2)
    self.pokemonPetBallsList:SetVerticalAlignment(0)
    self.pokemonPetBallsList:SetYPosition({0, -30})
  end
end

function M:setPetBuffListPos(isMyPet)
  if isMyPet then
    self.pokemonPetBuffList:SetVerticalAlignment(0)
    self.pokemonPetBuffList:SetYPosition({0, -117})
  else
    self.pokemonPetBuffList:SetVerticalAlignment(2)
    self.pokemonPetBuffList:SetYPosition({0, 117})
  end
end

function M:updateInfo(pokemon)
  if self.scene_type ~= Define.SCENE_TYPE.BATTLE then
    self.pokemonPetBuffList:SetVisible(false)
  else
    self.pokemonPetBuffList:SetVisible(true)
  end
  local isJump = false
  if self.textTimer then
    LuaTimer:cancel(self.textTimer)
    self.textTimer = nil
  end
  if self.pokemon and pokemon and self.pokemon:getObjId() == pokemon:getObjId() then
    isJump = true
  end
  if pokemon and pokemon:getCaptured() then
    pokemon = nil
  end
  self.pokemon = pokemon
  self.lytPokemonHeadCellEmptyLayout:SetVisible(pokemon == nil)
  if not pokemon then
    self.queue = {}
    if self.scene_type == Define.SCENE_TYPE.BATTLE then
      self._root:SetVisible(false)
    end
    return
  end
  self._root:SetVisible(true)
  self:showPetInformation(true)
  local maxHP = math.ceil(pokemon:getMaxHp())
  self.masterId = pokemon:getMasterId()
  local hp = pokemon:getCurHp()
  if pokemon:isFought() then
    maxHP = math.ceil(pokemon:getBattleMaxHp())
  end
  self:refreshMainUISize()
  self.widget_item:invoke("onDataChanged", {pokemon = pokemon})
  self.txtPokemonHeadCellName:SetText(pokemon:getName())
  local curHP = math.ceil(hp)
  self.txtPokemonHeadCellHpCount:SetText(curHP)
  if curHP < maxHP / 3 and 0 < curHP then
    if Me.platformUserId == self.pokemon:getMasterId() and not self.dontplay then
      self.dontplay = true
      Me:playSoundByKey("hp_low")
    end
  else
    self.dontplay = false
  end
  self.txtPokemonHeadCellHpNum:SetText("/" .. maxHP)
  local textLen = self.txtPokemonHeadCellHpNum:GetFont():GetTextExtent("/" .. maxHP, 1.0)
  self.txtPokemonHeadCellHpNum:SetWidth({0, textLen})
  self.imgPokemonHeadCellDbuffIcon:SetImage(pokemon:getDebuffIcon())
  self.imgPokemonHeadCellDbuffIcon:SetWidth({
    0,
    self.imgPokemonHeadCellDbuffIcon:GetPixelSize().y
  })
  self:onShowMask(self.scene_type ~= Define.SCENE_TYPE.BATTLE and pokemon:isDead())
  self:updatePetBallsInfo()
end

function M:showPetInformation(isShow)
  self.lytPokemonHeadCellHeadLayout:SetVisible(isShow)
  self.lytPokemonHeadCellInfoLayout:SetVisible(isShow)
  self.imgPokemonHeadCellBg:SetVisible(isShow)
end

function M:onChecked(isChecked)
  self.imgPokemonHeadCellSelect:SetVisible(isChecked)
end

function M:onShowMask(isMask)
  self.imgPokemonHeadCellMask:SetVisible(isMask)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
