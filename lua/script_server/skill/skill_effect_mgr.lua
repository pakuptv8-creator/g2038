local skillEffectCfg = T(Config, "SkillEffectConfig")
local SkillConfig = T(Config, "SkillConfig")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local setting = require("common.setting")
local PokemonConfig = T(Config, "PokemonConfig")

local function showPkmSkillBuffTipWnd(player, effectInfo, objID, showId, round, pkmObjID)
  local effect_desc = string.gsub(effectInfo.effect_desc, "^%s+", "")
  if effect_desc and 0 < #effect_desc then
    local dec = effectInfo.effect_desc
    local realRound = round
    if effectInfo.round and tonumber(effectInfo.round[1]) >= 99 then
      realRound = tonumber(effectInfo.round[1])
    end
    local packet = {
      pid = "showPkmSkillBuffTipWnd",
      showId = showId,
      txtTitle = effectInfo.effect_type,
      txtContent = dec,
      pkmObjID = pkmObjID,
      entityObjID = objID,
      round = realRound,
      playerObjID = player.objID
    }
    player:sendPacket(packet)
  end
end

local function calcNextSkillEffectIndex(target)
  if not target or not target:isValid() then
    return -1
  end
  local count = 0
  local addSkillEffcts = target:getAddSkillEffects()
  for i, v in pairs(addSkillEffcts) do
    if v then
      count = count + 1
    end
  end
  if target.pokemon then
    local roundSkillEffcts = target.pokemon:getLongRoundEffectbuffList()
    for i, v in pairs(roundSkillEffcts) do
      if v then
        count = count + 1
      end
    end
  end
  return count + 1
end

local function processSkillEffect(pTarget, from, skillId, effectCfg, dealBattleState, skillFrom, skillTarget)
  if not pTarget or not pTarget:isValid() then
    if dealBattleState then
      SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectCfg.id)
    end
    return
  end
  local round = math.random(tonumber(effectCfg.round[1] or 1), tonumber(effectCfg.round[2] or 1))
  local addBuff = pTarget:addBuff(effectCfg.effectFullname, nil, from, effectCfg.id)
  local addTime = os.time()
  local sortIndex = calcNextSkillEffectIndex(pTarget)
  if effectCfg.isLongRoundEffect == 0 then
    local addSkillEffcts = pTarget:getAddSkillEffects()
    local name = string.format("buff_%d_%d", pTarget.objID, addBuff.id)
    addSkillEffcts[name] = {
      skilleffectId = effectCfg.id,
      tagetId = pTarget.objID,
      buffCfg = addBuff.cfg,
      buffId = addBuff.id,
      abnormalType = effectCfg.abnormalType,
      round = round,
      tbImmuneSkillEffect = effectCfg.immune,
      trigger = effectCfg.trigger,
      skillId = skillId,
      pkmObjID = pTarget.pokemon and pTarget.pokemon:getObjId() or 0,
      addTime = addTime,
      sortIndex = sortIndex
    }
    pTarget:setAddSkillEffects(addSkillEffcts)
  elseif effectCfg.isLongRoundEffect == 1 then
    if pTarget.pokemon then
      local roundSkillEffcts = pTarget.pokemon:getLongRoundEffectbuffList()
      local key = string.format("%s_%d", tostring(addTime), effectCfg.id)
      local pkmObjID = pTarget.pokemon:getObjId() or 0
      roundSkillEffcts[key] = {
        skilleffectId = effectCfg.id,
        buffCfg = addBuff.cfg,
        buffId = addBuff.id,
        abnormalType = effectCfg.abnormalType,
        round = round,
        trigger = effectCfg.trigger,
        addTime = addTime,
        skillId = skillId,
        pkmObjID = pkmObjID,
        sortIndex = sortIndex
      }
      pTarget.pokemon:setLongRoundEffectbuffList(roundSkillEffcts)
    end
    pTarget:longRoundEffectProp(true, effectCfg.id)
  end
  for i, player in pairs(pTarget.battleField and pTarget.battleField.playerList) do
    if player then
      local showId = 1
      if pTarget.battleField:isEnemy(pTarget, player) then
        showId = 2
      end
      showPkmSkillBuffTipWnd(player, effectCfg, pTarget.objID, showId, round, pTarget.pokemon and pTarget.pokemon:getObjId() or 0)
    end
  end
  if dealBattleState then
    SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectCfg.id)
  end
  if 0 < effectCfg.abnormalType then
    pTarget:data("main").addAbnormalEffect_ing = false
  end
end

function SkillEffectMgr:init()
  Lib.subscribeEvent(Event.EVENT_BATTLE_ROUND_CHANGE, function(tbEntityList)
    for _, entity in pairs(tbEntityList) do
      if entity and entity:isValid() and entity.pokemon then
        local addSkillEffcts = entity:getAddSkillEffects()
        local temp = Lib.copy(addSkillEffcts)
        for key, effect in pairs(temp) do
          local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
          local effectSkillType = effectCfg and effectCfg.effectSkillType or 0
          if effectSkillType < Define.EffectSkillType.fanji then
            addSkillEffcts[key].round = addSkillEffcts[key].round - 1
            if 0 >= addSkillEffcts[key].round then
              entity:removeBuffById(addSkillEffcts[key].buffId)
              addSkillEffcts[key] = nil
            end
          end
        end
        entity:setAddSkillEffects(addSkillEffcts)
        local roundSkillEffcts = entity.pokemon:getLongRoundEffectbuffList()
        local roundTemp = Lib.copy(roundSkillEffcts)
        for key, effect in pairs(roundTemp) do
          local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
          local effectSkillType = effectCfg and effectCfg.effectSkillType or 0
          if effectSkillType < Define.EffectSkillType.fanji and roundSkillEffcts[key] then
            roundSkillEffcts[key].round = roundSkillEffcts[key].round - 1
            if 0 >= roundSkillEffcts[key].round then
              entity:removeBuffById(roundSkillEffcts[key].buffId)
              roundSkillEffcts[key] = nil
              entity:longRoundEffectProp(false, effect.skilleffectId)
            end
          end
        end
        entity.pokemon:setLongRoundEffectbuffList(roundSkillEffcts)
      end
    end
  end)
end

function SkillEffectMgr:clearPokemonSkillEffect(player)
  if not player then
    return
  end
  
  local function dealAddSkillEffects(entity)
    local AddSkillEffects = entity:getAddSkillEffects() or {}
    local tbTemp = Lib.copy(AddSkillEffects)
    for key, v in pairs(tbTemp) do
      if v.abnormalType and v.abnormalType <= 0 then
        AddSkillEffects[key] = nil
      end
    end
    entity:setAddSkillEffects(AddSkillEffects)
  end
  
  local function dealRoundEffect(pokemon)
    local tbRoundBuff = pokemon:getLongRoundEffectbuffList() or {}
    local tbTemp = Lib.copy(tbRoundBuff)
    for key, v in pairs(tbTemp) do
      if v.abnormalType and v.abnormalType <= 0 then
        local entity = pokemon:getEntity()
        if entity and entity:isValid() then
          entity:longRoundEffectProp(false, tbRoundBuff[key].skilleffectId)
        end
        tbRoundBuff[key] = nil
      end
    end
    pokemon:setLongRoundEffectbuffList(tbRoundBuff)
  end
  
  local battlePetList = player:getValue("battlePetList") or {}
  local packetPetList = player:getValue("packetPetList") or {}
  for _, petId in pairs(battlePetList) do
    local pokemon = PokemonManager:getPokemon(petId)
    if pokemon then
      dealRoundEffect(pokemon)
    end
    local entity = pokemon:getEntity()
    if entity and entity:isValid() then
      dealAddSkillEffects(entity)
    end
  end
  for _, petId in pairs(packetPetList) do
    local pokemon = PokemonManager:getPokemon(petId)
    if pokemon then
      dealRoundEffect(pokemon)
    end
    local entity = pokemon:getEntity()
    if entity and entity:isValid() then
      dealAddSkillEffects(entity)
    end
  end
end

function SkillEffectMgr:onPlayerLogout(player)
  SkillEffectMgr:clearPokemonSkillEffect(player)
end

local function triggerAndSyncSkillEffect(target, buffCfg, effectId, param)
  local master = target:getMaster()
  for i, player in pairs(target.battleField and target.battleField.playerList or {master}) do
    if player then
      player:sendPacket({
        pid = "triggerSkillEffect",
        targetId = target.objID,
        buffCfg = buffCfg,
        effectId = effectId,
        round = param.round or 1
      })
    end
  end
  local value = buffCfg.triggerData and buffCfg.triggerData.effect or buffCfg.effect
  target:skillEffecttrigger(value, buffCfg, effectId, param)
end

local function processEffectRound(target, buffCfg, effectId, key)
  local roundSkillEffcts = target.pokemon:getLongRoundEffectbuffList()
  if roundSkillEffcts[key] then
    if roundSkillEffcts[key].trigger == Define.SkillTriggerType.onDead then
      roundSkillEffcts[key].round = 0
    else
      roundSkillEffcts[key].round = roundSkillEffcts[key].round - 1
    end
    if roundSkillEffcts[key].round <= 0 then
      target:removeBuffById(roundSkillEffcts[key].buffId)
      roundSkillEffcts[key] = nil
      target:longRoundEffectProp(false, effectId)
    end
    target.pokemon:setLongRoundEffectbuffList(roundSkillEffcts)
  end
  local addSkillEffcts = target:getAddSkillEffects()
  if addSkillEffcts[key] then
    if addSkillEffcts[key].trigger == Define.SkillTriggerType.onDead then
      addSkillEffcts[key].round = 0
    else
      addSkillEffcts[key].round = addSkillEffcts[key].round - 1
    end
    if addSkillEffcts[key].round <= 0 then
      target:removeBuffById(addSkillEffcts[key].buffId)
      addSkillEffcts[key] = nil
    end
    target:setAddSkillEffects(addSkillEffcts)
  end
end

function SkillEffectMgr:addSkillEffect(from, target, skillId, effectId, dealBattleState, skillFrom, skillTarget)
  if not target or not target:isValid() then
    if dealBattleState then
      SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectId)
    end
    return
  end
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    if dealBattleState then
      SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectId)
    end
    target:data("main").addAbnormalEffect_ing = false
    return
  end
  processSkillEffect(target, from, skillId, effectCfg, dealBattleState, skillFrom, skillTarget)
end

function SkillEffectMgr:triggerSkillDamageEffect(target, buffCfg, effectId, key, param)
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    return
  end
  if effectCfg.trigger ~= Define.SkillTriggerType.skillDamage then
    return
  end
  triggerAndSyncSkillEffect(target, buffCfg, effectId, param)
end

function SkillEffectMgr:triggerEffectSkill(target, buffCfg, effectId, key, param)
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    return
  end
  if effectCfg.trigger ~= Define.SkillTriggerType.finshSkillCast then
    return
  end
  if effectCfg.effectSkillType == Define.EffectSkillType.fanji then
    local skillId = effectCfg.effectSkill
    if 0 < skillId and param.from and param.from:isValid() then
      SkillMgr:castSkill(param.from, skillId, target, true)
    end
    triggerAndSyncSkillEffect(param.from, buffCfg, effectId, param)
  elseif effectCfg.effectSkillType == Define.EffectSkillType.lianji then
    local skillId = effectCfg.effectSkill
    if 0 < skillId and param.from and param.from:isValid() then
      SkillMgr:castSkill(param.from, skillId, target, true)
    end
    triggerAndSyncSkillEffect(param.from, buffCfg, effectId, param)
  elseif effectCfg.effectSkillType == Define.EffectSkillType.fantan then
    triggerAndSyncSkillEffect(target, buffCfg, effectId, param)
  end
end

function SkillEffectMgr:triggerCastSkillEffect(target, buffCfg, effectId, key, round)
  local param = {}
  param.result = false
  param.canCast = true
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    param.result = false
    return param
  end
  if effectCfg.trigger ~= Define.SkillTriggerType.castSkill then
    param.result = false
    return param
  end
  if effectCfg.abnormalType == Define.SkillAbnormalType.palsy then
    if effectCfg.dcm ~= 0 then
      local castDcm = math.random(1, 100)
      if castDcm <= effectCfg.dcm * 100 then
        param.result = true
        param.canCast = false
        target.battleField:setAllStateReady(true)
      end
    end
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.sleep then
    param.result = true
    param.canCast = false
    target.battleField:setAllStateReady(true)
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.chaos and effectCfg.dcm ~= 0 then
    local castDcm = math.random(1, 100)
    if castDcm <= effectCfg.dcm * 100 then
      param.result = true
      param.canCast = true
      param.skillId = effectCfg.effectSkill or nil
    end
  end
  if param.result then
    triggerAndSyncSkillEffect(target, buffCfg, effectId, {round = round})
  end
  return param
end

function SkillEffectMgr:triggerFinishCastSkillEffect(target, buffCfg, effectId, param)
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    return
  end
  if effectCfg.trigger ~= Define.SkillTriggerType.finshSkillCast then
    return
  end
  triggerAndSyncSkillEffect(target, buffCfg, effectId, {
    round = param.round,
    damage = param.damage,
    intger = param.intger
  })
end

function SkillEffectMgr:triggerRoundEndEffect(target, buffCfg, effectId, key, round)
  if not target or not target:isValid() then
    Lib.logError("Error:not target or not target:isValid() when triggerRoundEndEffect", effectId)
    return false
  end
  if not target.pokemon then
    Lib.logError("Error:not target.pokemon when triggerRoundEndEffect", effectId)
    return false
  end
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    Lib.logError("Error:not effectCfg when triggerRoundEndEffect", target.objID, effectId)
    return false
  end
  if effectCfg.trigger ~= Define.SkillTriggerType.roundEnd then
    return false
  end
  triggerAndSyncSkillEffect(target, buffCfg, effectId, {round = round})
  target.battleField:setAllStateReady(true)
  return true
end

function SkillEffectMgr:triggerVulnerabilityEffect(target, buffCfg, effectId, key, round)
  triggerAndSyncSkillEffect(target, buffCfg, effectId, {round = round})
  processEffectRound(target, buffCfg, effectId, key)
end

function SkillEffectMgr:triggerDeadEffect(target, buffCfg, effectId, key, round)
  local isTrigger = false
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if effectCfg and effectCfg.trigger == Define.SkillTriggerType.onDead and effectCfg.dcm > 0 then
    local castDcm = math.random(1, 100)
    if castDcm <= effectCfg.dcm * 100 then
      isTrigger = true
    end
  end
  if isTrigger then
    World.Timer(10, function()
      Lib.logInfo("_____triggerDeadEffect:", target:cfg().fullName, effectId, Lib.v2s(buffCfg))
      triggerAndSyncSkillEffect(target, buffCfg, effectId, {round = round})
    end)
  end
  return isTrigger
end

function SkillEffectMgr:calcSkillEffect(skillId, effectInfo, from, target, dealBattleState, skillFrom, skillTarget)
  if not target or not target:isValid() then
    return
  end
  if effectInfo.abnormalType > 0 then
    if target:data("main").addAbnormalEffect_ing then
      return
    end
    target:data("main").addAbnormalEffect_ing = true
    if target.pokemon and target.pokemon:isAbnormalState() then
      if dealBattleState then
        SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectInfo.id)
      end
      target:data("main").addAbnormalEffect_ing = false
      return
    end
    if target then
      local result, immuneSkillEffectId, round = target:isImmuneSkillEffect(effectInfo.id)
      if result and immuneSkillEffectId then
        local effectCfg = skillEffectCfg:getConfigById(immuneSkillEffectId)
        if effectCfg then
          local buffCfg = setting:fetch("buff", effectCfg.effectFullname)
          triggerAndSyncSkillEffect(target, buffCfg, effectCfg.id, {round = round})
          if dealBattleState then
            SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectCfg.id)
          end
        end
        target:data("main").addAbnormalEffect_ing = false
        return
      end
    end
  end
  local tempPr = math.random(1, 100)
  if tempPr <= effectInfo.pr * 100 then
    if 0 < effectInfo.timingDelay then
      World.Timer(effectInfo.timingDelay, function()
        SkillEffectMgr:addSkillEffect(from, target, skillId, effectInfo.id, dealBattleState, skillFrom, skillTarget)
      end)
    else
      SkillEffectMgr:addSkillEffect(from, target, skillId, effectInfo.id, dealBattleState, skillFrom, skillTarget)
    end
  else
    target:data("main").addAbnormalEffect_ing = false
    if dealBattleState then
      SkillEffectMgr:setCurHandleEffectState(skillFrom, skillTarget, effectInfo.id)
    end
  end
end

function SkillEffectMgr:addPassiveSkillEffect(curTiming, from, target)
  local pTarget = target
  local pFrom = from
  if Define.SkillEffectTiming.finshSkillCast == curTiming or Define.SkillEffectTiming.skillCast == curTiming or Define.SkillEffectTiming.enterBattle == curTiming then
    pTarget = from
    pFrom = target
  elseif Define.SkillEffectTiming.beAccuracy == curTiming or Define.SkillEffectTiming.relife == curTiming or Define.SkillEffectTiming.beHurt == curTiming or Define.SkillEffectTiming.damage == curTiming then
    pFrom = from
    pTarget = target
  end
  local wake_config = PokemonConfig:getWakeConfig(from.pokemon:getWake())
  if wake_config and wake_config.skillId then
    local skill_config = SkillConfig:getConfigById(wake_config.skillId)
    if skill_config and skill_config.skill_effect and #skill_config.skill_effect > 0 then
      for _, effectId in pairs(skill_config.skill_effect) do
        local effectInfo = skillEffectCfg:getConfigById(effectId)
        if effectInfo and effectInfo.timing == curTiming then
          SkillEffectMgr:calcSkillEffect(wake_config.skillId, effectInfo, pFrom, pTarget)
        end
      end
    end
  end
  local skillList = pTarget and pTarget.pokemon and pTarget.pokemon:getPassiveSkillList() or {}
  if skillList and 0 < #skillList then
    for _, skillId in pairs(skillList) do
      local skill_config = SkillConfig:getConfigById(skillId)
      if skill_config and skill_config.skill_effect and #skill_config.skill_effect > 0 then
        for _, effectId in pairs(skill_config.skill_effect) do
          local effectInfo = skillEffectCfg:getConfigById(effectId)
          if effectInfo then
            if effectInfo.timing == curTiming then
              if effectInfo.target == 1 then
                Lib.logInfo("__________addPassiveSkillEffect:", pTarget and pTarget:isValid() and pTarget.objID or 0, curTiming, effectId)
                SkillEffectMgr:calcSkillEffect(skillId, effectInfo, pFrom, pTarget)
              elseif effectInfo.target == 2 then
                Lib.logInfo("__________addPassiveSkillEffect:", pFrom and pFrom:isValid() and pFrom.objID or 0, curTiming, effectId)
                SkillEffectMgr:calcSkillEffect(skillId, effectInfo, pTarget, pFrom)
              end
            end
          else
            Lib.logError("Error:can not found skillEffectCfg, effectId =" .. effectId .. ",please check skill_effect.csv")
          end
        end
      end
    end
  end
  local featuresId = pTarget.pokemon and pTarget.pokemon:getFeatures() or nil
  if featuresId then
    local skill_config = SkillConfig:getConfigById(featuresId)
    if skill_config and skill_config.skill_effect and #skill_config.skill_effect > 0 then
      for _, effectId in pairs(skill_config.skill_effect) do
        local effectInfo = skillEffectCfg:getConfigById(effectId)
        if effectInfo then
          if effectInfo.timing == curTiming then
            if effectInfo.target == 1 then
              Lib.logInfo("__________addfeaturesSkillEffect:", pTarget and pTarget:isValid() and pTarget.objID or 0, curTiming, effectId)
              SkillEffectMgr:calcSkillEffect(featuresId, effectInfo, pFrom, pTarget)
            elseif effectInfo.target == 2 then
              Lib.logInfo("__________addfeaturesSkillEffect:", pFrom and pFrom:isValid() and pFrom.objID or 0, curTiming, effectId)
              SkillEffectMgr:calcSkillEffect(featuresId, effectInfo, pTarget, pFrom)
            end
          end
        else
          Lib.logError("Error:can not found skillEffectCfg, effectId =", effectId .. ",please check skill_effect.csv")
        end
      end
    end
  end
end

function SkillEffectMgr:addInitiativeSkillEffect(skillId, curTiming, from, target, effectList, dealBattleState)
  if not from or not from:isValid() then
    if dealBattleState then
      SkillEffectMgr:setCurHandleEffectState(from, target, 0)
    end
    return
  end
  local skillInfo = from.curSkillBaseInfo
  if not skillInfo or not skillInfo.isAccuracy then
    if dealBattleState then
      from.battleField:setAllStateReady(true)
    end
    return
  end
  if dealBattleState then
    from.battleField:setAllStateReady(false)
  end
  if effectList and 0 < #effectList then
    if not from:data("main").curHandleEffectList then
      from:data("main").curHandleEffectList = {}
    end
    if dealBattleState then
      for i = 1, #effectList do
        local data = {
          effectId = tonumber(effectList[i]),
          state = false
        }
        from:data("main").curHandleEffectList[tonumber(effectList[i])] = data
      end
    end
    for _, effectId in pairs(effectList) do
      local effectInfo = skillEffectCfg:getConfigById(effectId)
      if effectInfo.timing == curTiming then
        if effectInfo.target == 1 then
          Lib.logInfo("_________addInitiativeSkillEffect:", from.objID, curTiming, effectId)
          SkillEffectMgr:calcSkillEffect(skillId, effectInfo, from, from, dealBattleState, from, target)
        elseif effectInfo.target == 2 then
          Lib.logInfo("__________addInitiativeSkillEffect:", target and target:isValid() and target.objID or 0, curTiming, effectId)
          SkillEffectMgr:calcSkillEffect(skillId, effectInfo, from, target, dealBattleState, from, target)
        end
      elseif dealBattleState then
        SkillEffectMgr:setCurHandleEffectState(from, target, tonumber(effectId))
      end
    end
  elseif dealBattleState then
    from.battleField:setAllStateReady(true)
  end
end

function SkillEffectMgr:setCurHandleEffectState(from, target, effectId)
  if not from or not from:isValid() then
    return
  end
  
  local function tyrTriggerSkillCastEffect(from, tbSkillCastEffect)
    local skillId = from.curSkillBaseInfo and from.curSkillBaseInfo.id or nil
    if skillId then
      if from:data("main").skillDamage and from:data("main").skillDamage[tonumber(skillId)] then
        local damage = from:data("main").skillDamage and from:data("main").skillDamage[tonumber(skillId)] or 0
        SkillEffectMgr:processTriggerSkillCastEffect(from, tbSkillCastEffect, damage)
      else
        from.battleField:setAllStateReady(true)
      end
    else
      from.battleField:setAllStateReady(true)
    end
  end
  
  local tbSkillCastEffect = SkillEffectMgr:getTriggerSkillCastEffect(from, target)
  local curHandleEffectList = from:data("main").curHandleEffectList or {}
  if not curHandleEffectList[effectId] then
    if 0 < #tbSkillCastEffect then
      tyrTriggerSkillCastEffect(from, tbSkillCastEffect)
    else
      from.battleField:setAllStateReady(true)
    end
    return
  end
  curHandleEffectList[effectId].state = true
  from:data("main").curHandleEffectList = curHandleEffectList
  local isAllReady = true
  for effectId, effectInfo in pairs(from:data("main").curHandleEffectList or {}) do
    if not effectInfo.state then
      isAllReady = false
    end
  end
  if isAllReady then
    from:data("main").curHandleEffectList = nil
    if 0 < #tbSkillCastEffect then
      tyrTriggerSkillCastEffect(from, tbSkillCastEffect)
    else
      from.battleField:setAllStateReady(true)
    end
  end
end

local function getSkillTime(skillId)
  local skillTime = 2
  if 0 < skillId then
    local skillcfg = SkillConfig:getConfigById(skillId)
    if skillcfg then
      local setttintCfg = setting:fetch("skill", skillcfg.setting_full_name)
      if setttintCfg then
        skillTime = setttintCfg.skillTime
      end
    end
  end
  return skillTime
end

local function getSkillEffectTriggerData(from, target, pTarget, effectSkillType)
  local data = {}
  data.dcm = 0
  data.intger = 0
  data.effect = {}
  data.effectCfg = {}
  data.effectCfgList = {}
  data.effectOwnerId = pTarget and pTarget.objID or 0
  local addSkillEffcts = pTarget and pTarget:getAddSkillEffects() or {}
  for key, effect in pairs(addSkillEffcts) do
    local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
    local skillTime = getSkillTime(effectCfg.effectSkill)
    if effectCfg.effectSkillType == effectSkillType then
      local fromId = from and from.objID or 0
      local targetId = target and target.objID or 0
      if effectCfg.effectSkillType == Define.EffectSkillType.fantan or effectCfg.effectSkillType == Define.EffectSkillType.fanji then
        fromId = target and target.objID or 0
        targetId = from and from.objID or 0
      end
      data.dcm = data.dcm + effectCfg.dcm
      data.intger = data.intger + effectCfg.intger
      data.fromId = fromId
      data.targetId = targetId
      data.effectSkillType = effectCfg.effectSkillType
      if effectSkillType == Define.EffectSkillType.lianji then
        if 0 < effectCfg.effectSkill then
          data.effect = effect
          data.effectCfg = effectCfg
        end
      else
        data.effect = effect
        data.effectCfg = effectCfg
      end
      data.skillTime = skillTime
      data.round = effect.round
      data.effectCfgList[key] = effect
    end
  end
  if not data.effectSkillType then
    return nil
  end
  return data
end

function SkillEffectMgr:getTriggerSkillCastEffect(from, target)
  local tbSkillCastEffect = {}
  local fromLianji = getSkillEffectTriggerData(from, target, from, Define.EffectSkillType.lianji)
  local fromFantan = getSkillEffectTriggerData(from, target, from, Define.EffectSkillType.fantan)
  local targetFanji = getSkillEffectTriggerData(from, target, target, Define.EffectSkillType.fanji)
  if fromLianji then
    table.insert(tbSkillCastEffect, fromLianji)
  end
  if fromFantan then
    table.insert(tbSkillCastEffect, fromFantan)
  end
  if targetFanji then
    table.insert(tbSkillCastEffect, targetFanji)
  end
  table.sort(tbSkillCastEffect, function(a, b)
    if a.effectSkillType and b.effectSkillType then
      return a.effectSkillType > b.effectSkillType
    end
  end)
  return tbSkillCastEffect
end

function SkillEffectMgr:processTriggerSkillCastEffect(from, tbSkillCastEffect, damage)
  if 0 < #tbSkillCastEffect then
    local function doTriggerSkillCast(skillfrom, effectData, realDamage)
      local isTrigger = false
      
      skillfrom.battleField:setAllStateReady(false)
      if effectData and effectData.effect and effectData.effectCfg then
        local pEffect = effectData.effect
        local pTarget = World.CurWorld:getObject(effectData.targetId)
        local pFrom = World.CurWorld:getObject(effectData.fromId)
        if pTarget and pTarget:isValid() and pFrom and pFrom:isValid() then
          local tempdcm = math.random(1, 100)
          Lib.logWarning("________________lianji/fanji/fantan dailv:", tempdcm, effectData.dcm, pEffect.skilleffectId, effectData.effectSkillType, effectData.intger)
          if tempdcm <= effectData.dcm * 100 then
            isTrigger = true
            SkillEffectMgr:triggerEffectSkill(pTarget, pEffect.buffCfg, pEffect.skilleffectId, pEffect.key, {
              damage = realDamage,
              from = pFrom,
              intger = effectData.intger,
              round = effectData.round
            })
          else
            Lib.logInfo("___trigger fail:", pEffect.skilleffectId)
          end
        else
          if pFrom and pFrom:isValid() then
            Lib.logError("Error:not pTarget or not pTarget:isValid() when processTriggerSkillCastEffect", pFrom.name, pFrom.objID, pEffect and pEffect.skilleffectId)
            pFrom.battleField:setAllStateReady(true)
          end
          if pTarget and pTarget:isValid() then
            Lib.logError("Error:not pFrom or not pFrom:isValid() when processTriggerSkillCastEffect", pEffect and pEffect.skilleffectId)
            pTarget.battleField:setAllStateReady(true)
          end
        end
        for key, effectCfg in pairs(effectData.effectCfgList) do
          local entity = World.CurWorld:getObject(effectData.effectOwnerId)
          if entity and entity:isValid() then
            processEffectRound(entity, effectCfg.buffCfg, effectCfg.skilleffectId, key)
          else
            Lib.logError("error:not entity or not entity:isValid() when remove skill effect,skilleffectId =", effectCfg.skilleffectId)
          end
        end
      end
      local skillTime = tbSkillCastEffect[#tbSkillCastEffect].skillTime
      tbSkillCastEffect[#tbSkillCastEffect] = nil
      if isTrigger then
        World.Timer(skillTime, function()
          if skillfrom and skillfrom:isValid() then
            if 0 < #tbSkillCastEffect then
              doTriggerSkillCast(skillfrom, tbSkillCastEffect[#tbSkillCastEffect], realDamage)
            elseif from and from:isValid() then
              if not from:data("main").isEffectTriggerState then
                skillfrom.battleField:setAllStateReady(true)
              end
            else
              skillfrom.battleField:setAllStateReady(true)
            end
          end
        end)
      elseif 0 < #tbSkillCastEffect then
        doTriggerSkillCast(skillfrom, tbSkillCastEffect[#tbSkillCastEffect], realDamage)
      elseif not from:data("main").isEffectTriggerState then
        skillfrom.battleField:setAllStateReady(true)
      end
    end
    
    doTriggerSkillCast(from, tbSkillCastEffect[#tbSkillCastEffect], damage)
  else
    from.battleField:setAllStateReady(true)
  end
end

return SkillEffectMgr
