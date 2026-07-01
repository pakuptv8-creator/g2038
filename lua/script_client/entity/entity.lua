local LuaTimer = T(Lib, "LuaTimer")
local PokemonManager = require("script_client.pokemon.pokemon_manager")
local PlayableScript = require("script_client.time_line.playable_script")
local skillEffectCfg = T(Config, "SkillEffectConfig")
local GloryConfig = T(Config, "GloryConfig")
local SkillPerformConfig = T(Config, "SkillPerformConfig")
local ClientBuffId = L("ClientBuffId", 0)
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local NPCConfig = T(Config, "NPCConfig")
local Entity = _ENV.Entity

function Entity.ValueFunc:pokemonId(value)
end

function Entity.ValueFunc:curGym(value)
  Lib.logDebug("curGym = ", value)
  if 0 < value then
    Lib.emitEvent(Event.EVENT_HIDE_MINI_MAP)
  elseif value == 0 then
    Lib.emitEvent(Event.EVENT_OPEN_MINI_MAP)
  end
end

function Entity.ValueFunc:curBattlePetObjID(value)
  Lib.logDebug("curBattlePetObjID", self.objID, value)
end

function Entity.ValueFunc:battleNpcId(value)
  Lib.logDebug(self.objID, "battleNpcId", value)
  Lib.emitEvent(Event.EVENT_UPDATE_BATTLE_NPC_ID, value)
end

function Entity.ValueFunc:npcChallengeList(value)
  self.hasNpcChallengeList = true
end

function Entity.ValueFunc:playerTitleList(value)
  Lib.emitEvent(Event.EVENT_CHANGE_GLORY, value)
end

function Entity.ValueFunc:bookRecord(value)
  Lib.emitEvent(Event.EVENT_GET_PET_COLLECT, value)
end

function Entity.ValueFunc:playerTitle(value)
  Lib.emitEvent(Event.EVENT_CHANGE_PLAYER_TITLE, value)
  if 0 < value then
    local cfg = GloryConfig:getGloryById(value)
    if cfg then
      self.headIcon = string.sub(cfg.icon, 36)
    end
  else
    self.headIcon = false
  end
  self:updateShowName()
end

function Entity.EntityProp:effect(value, add, buff)
  local from = buff.from
  if from and from:isValid() then
    local curCastMainSkill = from:data("main").curCastMainSkill
    local SkillPerformCfg = SkillPerformConfig:getSkillPerformConfig(curCastMainSkill)
    if SkillPerformCfg then
      if SkillPerformCfg.startEffectOwner and SkillPerformCfg.startEffectOwner == (buff.cfg and buff.cfg.fullName) then
        if value.path then
          value.path = string.gsub(value.path, value.effect, SkillPerformCfg.startEffect)
        end
        value.effect = SkillPerformCfg.startEffect
        if buff.cfg and buff.cfg.effect then
          if buff.cfg.effect.path then
            buff.cfg.effect.path = string.gsub(buff.cfg.effect.path, buff.cfg.effect.effect, SkillPerformCfg.startEffect)
          end
          buff.cfg.effect.effect = SkillPerformCfg.startEffect
        end
      elseif SkillPerformCfg.skillEffectOwner and SkillPerformCfg.skillEffectOwner == (buff.cfg and buff.cfg.fullName) then
        if value.path then
          value.path = string.gsub(value.path, value.effect, SkillPerformCfg.skillEffect)
        end
        value.effect = SkillPerformCfg.skillEffect
        if buff.cfg and buff.cfg.effect then
          if buff.cfg.effect.path then
            buff.cfg.effect.path = string.gsub(buff.cfg.effect.path, buff.cfg.effect.effect, SkillPerformCfg.skillEffect)
          end
          buff.cfg.effect.effect = SkillPerformCfg.skillEffect
        end
      elseif SkillPerformCfg.hitEffectOwner and SkillPerformCfg.hitEffectOwner == (buff.cfg and buff.cfg.fullName) then
        if value.path then
          value.path = string.gsub(value.path, value.effect, SkillPerformCfg.hitEffect)
        end
        value.effect = SkillPerformCfg.hitEffect
        if buff.cfg and buff.cfg.effect then
          if buff.cfg.effect.path then
            buff.cfg.effect.path = string.gsub(buff.cfg.effect.path, buff.cfg.effect.effect, SkillPerformCfg.hitEffect)
          end
          buff.cfg.effect.effect = SkillPerformCfg.hitEffect
        end
      end
    end
  end
  local name = string.format("buff_%d_%d", self.objID, buff.id)
  if buff.effectId then
    local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
    if effectCfg and effectCfg.addEffect then
      effectCfg.addEffect = string.gsub(effectCfg.addEffect, "^%s+", "")
    end
    if effectCfg and effectCfg.addEffect and #effectCfg.addEffect > 0 and effectCfg.effectFullname and effectCfg.effectFullname == (buff.cfg and buff.cfg.fullName) then
      if value.path then
        value.path = string.gsub(value.path, value.effect, effectCfg.addEffect)
      end
      value.effect = effectCfg.addEffect
      if buff.cfg and buff.cfg.effect then
        if buff.cfg.effect.path then
          buff.cfg.effect.path = string.gsub(buff.cfg.effect.path, buff.cfg.effect.effect, effectCfg.addEffect)
        end
        buff.cfg.effect.effect = effectCfg.addEffect
      end
    end
  end
  if add then
    self:showEffect(value, buff.cfg, name)
  else
    self:delEffect(name, value.smoothRemove)
  end
end

function Entity.EntityProp:sound(value, add, buff)
  local ti = TdAudioEngine.Instance()
  if add then
    local from = buff.from
    if from and from:isValid() then
      local curCastMainSkill = from:data("main").curCastMainSkill
      local SkillPerformCfg = SkillPerformConfig:getSkillPerformConfig(curCastMainSkill)
      if SkillPerformCfg then
        if SkillPerformCfg.startEffectOwner and SkillPerformCfg.startEffectOwner == (buff.cfg and buff.cfg.fullName) then
          if value.path then
            value.path = string.gsub(value.path, value.sound, SkillPerformCfg.startSound)
          end
          value.sound = SkillPerformCfg.startSound
          if buff.cfg and buff.cfg.sound then
            if buff.cfg.sound.path then
              buff.cfg.sound.path = string.gsub(buff.cfg.sound.path, buff.cfg.sound.sound, SkillPerformCfg.startSound)
            end
            buff.cfg.sound.sound = SkillPerformCfg.startSound
          end
        elseif SkillPerformCfg.skillEffectOwner and SkillPerformCfg.skillEffectOwner == (buff.cfg and buff.cfg.fullName) then
          if value.path then
            value.path = string.gsub(value.path, value.sound, SkillPerformCfg.skillSound)
          end
          value.sound = SkillPerformCfg.skillSound
          if buff.cfg and buff.cfg.sound then
            if buff.cfg.sound.path then
              buff.cfg.sound.path = string.gsub(buff.cfg.sound.path, buff.cfg.sound.sound, SkillPerformCfg.skillSound)
            end
            buff.cfg.sound.sound = SkillPerformCfg.skillSound
          end
        elseif SkillPerformCfg.hitEffectOwner and SkillPerformCfg.hitEffectOwner == (buff.cfg and buff.cfg.fullName) then
          if value.path then
            value.path = string.gsub(value.path, value.sound, SkillPerformCfg.hitSound)
          end
          value.sound = SkillPerformCfg.hitSound
          if buff.cfg and buff.cfg.sound then
            if buff.cfg.sound.path then
              buff.cfg.sound.path = string.gsub(buff.cfg.sound.path, buff.cfg.sound.sound, SkillPerformCfg.hitSound)
            end
            buff.cfg.sound.sound = SkillPerformCfg.hitSound
          end
        end
      end
      if buff.effectId then
        local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
        if effectCfg and effectCfg.addSound then
          effectCfg.addSound = string.gsub(effectCfg.addSound, "^%s+", "")
        end
        if effectCfg and effectCfg.addSound and #effectCfg.addSound > 0 and effectCfg.effectFullname and effectCfg.effectFullname == (buff.cfg and buff.cfg.fullName) then
          if value.path then
            value.path = string.gsub(value.path, value.sound, effectCfg.addSound)
          end
          value.sound = effectCfg.addSound
          if buff.cfg and buff.cfg.sound then
            if buff.cfg.sound.path then
              buff.cfg.sound.path = string.gsub(buff.cfg.sound.path, buff.cfg.sound.sound, effectCfg.addSound)
            end
            buff.cfg.sound.sound = effectCfg.addSound
          end
        end
      end
    end
    buff.soundId = self:playSound(value, buff.cfg)
    local soundId = buff.soundId
    local volume = tonumber(value.volume)
    if volume then
      ti:setSoundsVolume(soundId, volume)
    end
    local rollOffType = Sound3DRollOffType[value.rollOffType]
    if rollOffType then
      ti:set3DRollOffMode(soundId, rollOffType)
    end
    local distance = value.distance
    if distance then
      ti:set3DMinMaxDistance(soundId, distance[1], distance[2])
    end
  else
    ti:stopSound(buff.soundId)
  end
end

function Entity.ValueFunc:inBattle(value)
  if self.isMainPlayer then
    self.disableControl = value
    if value then
      Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
      Lib.emitEvent(Event.EVENT_HIDE_MINI_MAP)
      UI:getWnd("pokemonGuide"):onShow(false)
      UI:getWnd("battle_pre_animation"):onShow(false)
      UI:closeWnd("pokemonBag")
      Lib.emitEvent(Event.EVENT_STOP_TICK_MINI_MAP)
      self.battleHideFunc = UI:hideOpenedWnd({"chatMain", "chatBar"})
      UI:getWnd("chatMain"):root():SetAlwaysOnTop(true)
      UI:getWnd("chatBar"):setLevelOffset(-1)
      UI:getWnd("chatBar"):setForceOnTop(true)
      Lib.emitEvent(Event.EVENT_SET_CHAT_ALIGNMENT, "LT", {
        0,
        5,
        0,
        80
      })
      Lib.emitEvent(Event.EVENT_SET_CHAT_BAR_POS, {10, 20})
      Me:playPreHideBlackAnimation()
    else
      CGame.Instance():SetMaxFps(World.cfg.maxFps)
      Me:updateUpperAction("", 0)
      UI:closeWnd("battle_main")
      Lib.emitEvent(Event.EVENT_START_TICK_MINI_MAP)
      if self.battleHideFunc then
        self.battleHideFunc()
      end
      UI:getWnd("chatMain"):root():SetAlwaysOnTop(false)
      UI:getWnd("chatBar"):setLevelOffset(1)
      UI:getWnd("chatBar"):setForceOnTop(false)
      Lib.emitEvent(Event.EVENT_SET_CHAT_ALIGNMENT, "BC")
      Lib.emitEvent(Event.EVENT_SET_CHAT_BAR_POS)
      UI:getWnd("pokemonGiftBag"):pushGiftPackage()
      Lib.emitEvent(Event.EVENT_OPEN_MINI_MAP)
      if not Me:isGuideFinish() and (Me:getCurGuideIndex() == Define.GUIDE_INDEX.GOTO_FIRST_NPC or Me:getCurGuideIndex() == Define.GUIDE_INDEX.GOTO_GYM_1_BOSS or Me:getCurGuideIndex() == Define.GUIDE_INDEX.GOTO_GYM_2_BOSS or Me:getCurGuideIndex() == Define.GUIDE_INDEX.GOTO_GYM_3_BOSS or Me:getCurGuideIndex() == Define.GUIDE_INDEX.GOTO_GYM_4_BOSS or Me:getCurGuideIndex() == Define.GUIDE_INDEX.GOTO_GYM_5_BOSS) then
        local npcId = Me:isInNpcBattle()
        Lib.logDebug("guideLogic npcId = ", npcId)
        local guide_data = PokemonGuideConfig:getGuideData(Me:getCurGuideIndex())
        if npcId and guide_data and tostring(guide_data.npc_id) == tostring(npcId) then
          local count = self:getNpcChallenge(npcId)
          Lib.logInfo("guideLogic battle end count = ", count)
          if count and count <= 0 then
            Me:gotoNextGuide()
          else
            UI:getWnd("pokemonGuide"):onShow(true, Me:getCurGuideIndex())
          end
        else
          UI:getWnd("pokemonGuide"):onShow(true, Me:getCurGuideIndex())
        end
      end
    end
  end
end

function Entity.ValueFunc:battlePetList(value)
  Lib.emitEvent(Event.EVENT_CHANGE_BATTLE_PET, value)
end

function Entity.ValueFunc:packetPetList(value)
  Lib.emitEvent(Event.EVENT_CHANGE_PACKET_PET, value)
end

function Entity.ValueFunc:curBattlePetName(value)
  Lib.setPlayableScriptParam("curBattlePetName", value)
end

function Entity.ValueFunc:shopBuyInfo(value)
  Lib.emitEvent(Event.EVENT_UPDATE_SHOP_BUY_INFO, value)
end

function Entity.ValueFunc:triggerGiftInfo(value)
  Lib.emitEvent(Event.EVENT_UPDATE_TRIGGER_GIFT_INFO, value)
end

function Entity.ValueFunc:sprayEndTime(value)
  Lib.emitEvent(Event.EVENT_UPDATE_SPRAY_TIME, value)
end

function Entity.ValueFunc:regularBuyInfo(value)
  Lib.emitEvent(Event.EVENT_UPDATE_REGULAR_BUY_INFO, value)
end

function Entity.ValueFunc:luckyEggInfo(value)
end

function Entity.ValueFunc:curBattlePetList(value)
  Lib.logDebug("curBattlePetList", Lib.v2s(value))
  Lib.emitEvent(Event.EVENT_UPDATE_BATTLE_PET_LIST, value)
end

function Entity.ValueFunc:curEnemyPetList(value)
  Lib.logDebug("curEnemyPetList", Lib.v2s(value))
  Lib.emitEvent(Event.EVENT_UPDATE_ENEMY_PET_LIST, value)
end

function Entity.ValueFunc:curBattlePetBallId(value)
  Lib.setPlayableScriptParam("BallID", value)
end

function Entity.ValueFunc:capturePetList(value)
  Lib.emitEvent(Event.EVENT_UPDATE_CAPTURE_POKEMON_LIST, value)
end

function Entity.ValueFunc:playerLevel(value)
  if self.objID == Me.objID then
    local unlockMod = PlayerExpConfig:getUnlockModByLv(value)
    World.LightTimer("Entity.ValueFunc:playerLevel", 20, Lib.emitEvent, Event.EVENT_PLAYER_LEVEL_UP, value, unlockMod)
  end
  self:updateShowName()
end

function Entity.ValueFunc:playerExp(value)
  Lib.emitEvent(Event.EVENT_PLAYER_EXP_ADD, value)
end

function Entity.ValueFunc:gymFinishList(value)
  Lib.emitEvent(Event.EVENT_GYM_FINISH_CHANGE, value)
end

function Entity.ValueFunc:swapPokemonObjId(value)
  Lib.emitEvent(Event.EVENT_PLAYER_SWAP_POKEMON_CHANGE, value, self.objID)
end

function Entity.ValueFunc:swapSure(value)
  Lib.emitEvent(Event.EVENT_PLAYER_SWAP_SURE, value, self.objID)
end

function Entity.ValueFunc:soundTimes(value)
  if not self:getSoundMoonCardEnable() then
    Lib.emitEvent(Event.EVENT_SOUND_TIME_CHANGE)
  end
end

function Entity.ValueFunc:soundMoonCard(value)
  Lib.emitEvent(Event.EVENT_SOUND_MOON_CHANGE)
end

function Entity.ValueFunc:freeSoundTimes(value)
  if not self:getSoundMoonCardEnable() then
    Lib.emitEvent(Event.EVENT_FREE_SOUND_TIME_CHANGE)
  end
end

function Entity.ValueFunc:isVip(value)
  if self.isMainPlayer then
    Lib.emitEvent(Event.EVENT_UPDATE_UI_DATA, "enlargeLootPackage")
    Lib.emitEvent(Event.EVENT_UPDATE_UI_DATA, "update_vip_btn", value)
  end
end

local EntityClient = _ENV.EntityClient

function EntityClient:setMiniMapIcon()
  local icon, width
  local cfg = World.CurMap.cfg.miniMap
  if cfg then
    if Me.objID == self.objID then
      icon = cfg.mainPlayerIcon
      width = 20
    else
      icon = cfg.otherPlayerIcon
      width = 10
    end
    Lib.emitEvent(Event.EVENT_MAP_SETICON, self.objID, icon, nil, {
      x = 0,
      y = 0,
      z = 0
    }, 315, self.objID, true, width)
  end
end

function EntityClient:setCurSkillBaseInfo(skillCfg)
  self.curSkillBaseInfo = skillCfg
end

function EntityClient:resetCurSkillBaseInfo()
  self.curSkillBaseInfo = nil
end

function Entity.ValueFunc:crashThreeSel(value)
  if type(value) == "table" and next(value) ~= nil or type(value) == "number" and value ~= 0 then
    UI:getWnd("pokemon_three_select_one"):onShow(value)
  end
end

function Entity.ValueFunc:inNpc(value)
  if self.isMainPlayer and value == 0 then
    Me.disableControl = false
  end
end

function Entity.ValueFunc:curGuideIndex(value)
  Lib.logDebug("curGuideIndex value = ", value)
  if not Me:isWatch() and Me:getIsLogin() == true and value ~= 0 then
    Lib.logDebug("curGuideIndex EVENT_FORCE_GUIDE value = ", value)
    Lib.emitEvent(Event.EVENT_FORCE_GUIDE, value)
  end
end

local function processTriggerSound(self, value, buffCfg, effectCfg)
  if not effectCfg then
    return
  end
  if effectCfg.triggerSound then
    effectCfg.triggerSound = string.gsub(effectCfg.triggerSound, "^%s+", "")
  end
  if effectCfg.triggerSound and #effectCfg.triggerSound > 0 then
    if value.path then
      value.path = string.gsub(value.path, value.sound, effectCfg.triggerSound)
    end
    value.sound = effectCfg.triggerSound
    if buffCfg and buffCfg.sound then
      if buffCfg.sound.path then
        buffCfg.sound.path = string.gsub(buffCfg.sound.path, buffCfg.sound.sound, effectCfg.triggerSound)
      end
      buffCfg.sound.sound = effectCfg.triggerSound
    end
  end
  local ti = TdAudioEngine.Instance()
  local soundId = self:playSound(value, buffCfg)
  local volume = tonumber(value.volume)
  if volume then
    ti:setSoundsVolume(soundId, volume)
  end
  local rollOffType = Sound3DRollOffType[value.rollOffType]
  if rollOffType then
    ti:set3DRollOffMode(soundId, rollOffType)
  end
  local distance = value.distance
  if distance then
    ti:set3DMinMaxDistance(soundId, distance[1], distance[2])
  end
end

local function processTriggerEffect(self, value, buffCfg, effectCfg)
  if effectCfg.triggerEffect then
    effectCfg.triggerEffect = string.gsub(effectCfg.triggerEffect, "^%s+", "")
  end
  if effectCfg.triggerEffect and #effectCfg.triggerEffect > 0 then
    if value.path then
      value.path = string.gsub(value.path, value.effect, effectCfg.triggerEffect)
    end
    value.effect = effectCfg.triggerEffect
    if buffCfg and buffCfg.effect then
      if buffCfg.effect.path then
        buffCfg.effect.path = string.gsub(buffCfg.effect.path, buffCfg.effect.effect, effectCfg.triggerEffect)
      end
      buffCfg.effect.effect = effectCfg.triggerEffect
    end
  end
  self:showEffect(value, buffCfg)
end

function Entity:skillEffecttrigger(value, buffCfg, skilleffectId, dealEffect)
  local effectCfg = skillEffectCfg:getConfigById(skilleffectId)
  if not effectCfg then
    return
  end
  if effectCfg.effectFullname and effectCfg.effectFullname == (buffCfg and buffCfg.fullName) then
    if dealEffect then
      processTriggerEffect(self, value, buffCfg, effectCfg)
    else
      processTriggerSound(self, value, buffCfg, effectCfg)
    end
  end
end

function Entity.ValueFunc:activePoint(value)
  Lib.logDebug("entity valueFunc activePoint = ", value)
  Lib.emitEvent(Event.EVENT_ACTIVE_POINT_CHANGE, value)
end

function Entity.ValueFunc:curActiveIndex(value)
  Lib.logDebug("entity valueFunc curActiveIndex = ", value)
  Lib.emitEvent(Event.EVENT_ACTIVE_INDEX_CHANGE, value)
end

function Entity.ValueFunc:dailyTaskList(value)
  Lib.logDebug("entity valueFunc dailyTaskList = ", Lib.v2s(value))
end

function Entity.ValueFunc:dailyTaskStatusList(value)
  Lib.logDebug("entity valueFunc dailyTaskStatusList = ", Lib.v2s(value, 2))
  Lib.emitEvent(Event.EVENT_DAILY_TASK_STATUS_CHANGE, value)
end

function Entity.ValueFunc:rechargeSum(value)
  Lib.emitEvent(Event.EVENT_PLAYER_RECHARGE_SUM)
end

function Entity.ValueFunc:rechargeAwardStatus(value)
  UIMgr:registerWindowCallBack("pokemonMain", function()
    Lib.emitEvent(Event.EVENT_PLAYER_RECHARGE_STATUS, value)
  end)
end

function Entity.ValueFunc:followPetPrivilege(value)
  if value then
    Lib.emitEvent(Event.EVENT_FOLLOW_PET_PRIVILEGE_BTN_CHANGE)
  end
end

function EntityClient:updateShowName()
  local headText = self:data("headText")
  local name = self.name
  local cfg = self._cfg
  if cfg.nameBorder or World.cfg.nameBorder then
    name = "[B=1]Lv." .. self:getPlayerLevel() .. "          " .. self.name
  end
  if self.isPlayer then
    local _name = name
    if self.headIcon then
      _name = "[P=plugin/myplugin/image/" .. self.headIcon .. ".png]" .. "\n" .. name
    end
    self:setShowName1(_name, cfg.headFont or World.cfg.headFont or "HT24", World.cfg.headFontHeight or 0)
  else
    if cfg.interactionUI and cfg.interactionUI.id then
      local cnt = Me:getNpcChallenge(cfg.interactionUI.id)
      if cnt and cnt == 0 then
        name = "[P=plugin/myplugin/image/pass.png]" .. "\n" .. name
      end
    end
    self:setShowName1(name, cfg.headFont or World.cfg.headFont or "HT24", World.cfg.headFontHeight or 0)
  end
end

function EntityClient:addClientBuff(name, id, time, from, effectId)
  if not id then
    id = ClientBuffId - 1
    ClientBuffId = id
  end
  local buff = {
    cfg = Entity.BuffCfg(name),
    id = id,
    owner = self,
    time = time,
    effectId = effectId or 0
  }
  self:data("buff")[id] = buff
  self:calcBuff(buff, true, from)
  if self.isMainPlayer then
    Lib.emitEvent(Event.DRAW_BUFFICON, buff)
    Lib.emitEvent(Event.FETCH_ENTITY_INFO, true)
  end
  return buff
end

function EntityClient:createRandomAction()
  if self.randomActionTimer then
    self.randomActionTimer()
  end
  if not self:cfg().randomIdleAction then
    return
  end
  local time = 0
  if not Me:isInBattle() then
    local list = self:cfg().randomIdleAction.randomList
    if #list == 0 then
      return
    end
    local index = math.random(1, #list)
    time = self:updateUpperAction(list[index].action, list[index].time)
  end
  if time < 0 then
    time = 0
  end
  self.randomActionTimer = self:lightTimer("random_action", time + self:cfg().randomIdleAction.cdTime, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity then
      entity:createRandomAction()
    end
  end, self.objID)
end
