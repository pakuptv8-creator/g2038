local skill_effect_config = T(Config, "SkillEffectConfig")
local SkillConfig = T(Config, "SkillConfig")

function EntityServer:initSkillEffectQueue()
  self.effectQueue = {}
  self.effectBuffList = {}
end

function EntityServer:pushEffectBuffQueue(effectBuff)
  table.insert(self.effectQueue, effectBuff)
end

function EntityServer:addBattleEffectBuff(effectBuff)
  self.curEffectBuffInfo = effectBuff.effectInfo
  self:addBuff(effectBuff.effectName, nil, effectBuff.from)
  self.curEffectBuffInfo = nil
end

function EntityServer:popEffectBuffQueue()
  Lib.logDebug("EntityServer:popEffectBuffQueue ")
  local curSkillBuff = self.effectQueue[#self.effectQueue]
  if curSkillBuff.callbackFunc then
    curSkillBuff.callbackFunc()
  end
  if curSkillBuff.popBuffType == 1 then
    self:addBattleEffectBuff(curSkillBuff)
    self.effectQueue[#self.effectQueue] = nil
    self:updateEffectBuffQueue(false)
  else
    local needShowEffect
    if curSkillBuff.popBuffType == 2 then
      self:addBattleEffectBuff(curSkillBuff)
      needShowEffect = curSkillBuff.effectInfo.effect_show1
    elseif curSkillBuff.popBuffType == 3 then
      self:addBattleEffectBuff(curSkillBuff)
      needShowEffect = curSkillBuff.effectInfo.effect_show2
    elseif curSkillBuff.popBuffType == 4 then
      needShowEffect = curSkillBuff.effectInfo.effect_show1
    elseif curSkillBuff.popBuffType == 5 then
      needShowEffect = curSkillBuff.effectInfo.effect_show2
    end
    if needShowEffect then
      self:addBuff(needShowEffect, 20)
      self.effectQueue[#self.effectQueue] = nil
      for _, player in pairs(self.battleField.playerList) do
        local showId = 1
        if self.battleField:isEnemy(self, player) then
          showId = 2
        end
        local packet = {
          pid = "showPkmSkillBuffTipWnd",
          showId = showId,
          txtTitle = curSkillBuff.effectInfo.effect_type,
          txtContent = curSkillBuff.effectInfo.effect_desc,
          pkmObjID = self.objID,
          playerObjID = player.objID
        }
        player:sendPkmSkillBuffTipWnd(packet)
      end
      self:updateEffectBuffQueue(false)
    else
      self.effectQueue[#self.effectQueue] = nil
      self:updateEffectBuffQueue(false)
    end
  end
end

function EntityServer:updateEffectBuffQueue(isSkillTrig)
  if #self.effectQueue <= 0 then
    self.effectQueue = {}
    if not isSkillTrig then
      self.battleField:setAllStateReady(true)
    end
  else
    self:popEffectBuffQueue()
  end
  Lib.logDebug("EntityServer:updateEffectBuffQueue ")
end

function EntityServer:addPkmBirthEffectBuff()
  if not self.isEnemy then
    local buffList = self.pokemon:getBuffList()
    for key, val in pairs(buffList) do
      val.form = self
      val.effectInfo.popBuffType = 1
      self:pushEffectBuffQueue(val)
    end
  end
  local skillList = self.pokemon:getPassiveSkillList()
  if skillList and 0 < #skillList then
    for _, skillId in pairs(skillList) do
      local skill_config = SkillConfig:getConfigById(skillId)
      if skill_config and skill_config.skill_effect and 0 < #skill_config.skill_effect then
        for _, effectId in pairs(skill_config.skill_effect) do
          local effectInfo = skill_effect_config:getConfigById(effectId)
          if effectInfo.timing == 2 then
            local effectBuff = {
              effectName = effectInfo.display,
              effectInfo = effectInfo,
              from = self,
              popBuffType = 1
            }
            self:pushEffectBuffQueue(effectBuff)
          end
        end
      end
    end
  end
  local featuresId = self.pokemon:getFeatures()
  local skill_config = SkillConfig:getConfigById(featuresId)
  if skill_config and skill_config.skill_effect and 0 < #skill_config.skill_effect then
    for _, effectId in pairs(skill_config.skill_effect) do
      local effectInfo = skill_effect_config:getConfigById(effectId)
      if effectInfo.timing == 2 then
        local effectBuff = {
          effectName = effectInfo.display,
          effectInfo = effectInfo,
          from = self,
          popBuffType = 2
        }
        self:pushEffectBuffQueue(effectBuff)
      end
    end
  end
  Lib.logDebug("EntityServer:addPkmBirthEffectBuff ")
  self:updateEffectBuffQueue(false)
end

function EntityServer:triggerRoundEndSkillEffect()
  local isHaveEndEffect = false
  local effectKey = "poisonDamage_" .. self.objID
  local callback
  if self:getTypeBuff("fullName", Define.SKILL_ABNORMAL_BUFF[2]) and self.effectBuffList[effectKey] then
    local effectInfo = self.effectBuffList[effectKey].effectInfo
    if effectInfo.dcm < 0 then
      local maxHp = self:getMaxHp()
      local curDamage = -effectInfo.dcm * maxHp
      local tempDamage = math.floor(math.max(curDamage, 1) + 0.5)
      if self.effectBuffList[effectKey] then
        do
          local this = self
          
          function callback()
            this:doDamage({
              damage = tempDamage,
              cause = "ENGINE_PROP_POISON_DAMAGE",
              isBuffDamage = true
            })
          end
          
          local effectBuff = {
            effectName = effectInfo.display,
            effectInfo = effectInfo,
            from = self,
            popBuffType = 5,
            callbackFunc = callback
          }
          self:pushEffectBuffQueue(effectBuff)
          isHaveEndEffect = true
        end
      end
    end
  end
  local effectKey = "fireDamage_" .. self.objID
  local callback
  if self:getTypeBuff("fullName", Define.SKILL_ABNORMAL_BUFF[1]) and self.effectBuffList[effectKey] then
    local effectInfo = self.effectBuffList[effectKey].effectInfo
    if effectInfo.dcm < 0 then
      local maxHp = self:getMaxHp()
      local curDamage = -effectInfo.dcm * maxHp
      local tempDamage = math.floor(math.max(curDamage, 1) + 0.5)
      if self.effectBuffList[effectKey] then
        do
          local this = self
          
          function callback()
            this:doDamage({
              damage = tempDamage,
              cause = "ENGINE_PROP_FIRE_DAMAGE",
              isBuffDamage = true
            })
          end
          
          local effectBuff = {
            effectName = effectInfo.display,
            effectInfo = effectInfo,
            from = self,
            popBuffType = 5,
            callbackFunc = callback
          }
          self:pushEffectBuffQueue(effectBuff)
          isHaveEndEffect = true
        end
      end
    end
  end
  Lib.logDebug("EntityServer:triggerRoundEndSkillEffect ", isHaveEndEffect)
  if isHaveEndEffect then
    self:updateEffectBuffQueue(false)
  else
    self.battleField:setAllStateReady(true)
  end
end

function EntityServer:calcSkillEffect(effectInfo, from)
  if self.pokemon:isSkillAbnormalBuff(effectInfo.display) then
    local isExist = false
    for key, val in pairs(Define.SKILL_ABNORMAL_BUFF) do
      if self:getTypeBuff("fullName", val) then
        isExist = true
        return
      end
    end
  end
  local isNotImmune = true
  if Define.SKILL_ABNORMAL_IMMUNE[effectInfo.display] then
    local immuneBuff = "myplugin/" .. Define.SKILL_ABNORMAL_IMMUNE[effectInfo.display]
    local effectKey = Define.SKILL_ABNORMAL_IMMUNE[effectInfo.display] .. self.objID
    if self:getTypeBuff("fullName", immuneBuff) and self.effectBuffList[effectKey] then
      local immuneDcm = math.random(1, 100)
      if immuneDcm <= self.effectBuffList[effectKey].effectInfo.dcm * 100 then
        isNotImmune = false
      end
    end
  end
  local tempPr = math.random(1, 100)
  if isNotImmune and tempPr <= effectInfo.pr * 100 then
    local effectBuff = {
      effectName = effectInfo.display,
      effectInfo = effectInfo,
      from = from,
      popBuffType = 2
    }
    self:pushEffectBuffQueue(effectBuff)
  end
end

function EntityServer:triggerPassiveSkillEffect(curTiming, enemy)
  local skillList = self.pokemon:getPassiveSkillList()
  if skillList and 0 < #skillList then
    for _, skillId in pairs(skillList) do
      local skill_config = SkillConfig:getConfigById(skillId)
      if skill_config and skill_config.skill_effect and 0 < #skill_config.skill_effect then
        for _, effectId in pairs(skill_config.skill_effect) do
          local effectInfo = skill_effect_config:getConfigById(effectId)
          if effectInfo.timing == curTiming then
            if effectInfo.target == 1 then
              self:calcSkillEffect(effectInfo, self)
            elseif effectInfo.target == 2 then
              enemy:calcSkillEffect(effectInfo, self)
            end
          end
        end
      end
    end
  end
  local featuresId = self.pokemon:getFeatures()
  local skill_config = SkillConfig:getConfigById(featuresId)
  if skill_config and skill_config.skill_effect and 0 < #skill_config.skill_effect then
    for _, effectId in pairs(skill_config.skill_effect) do
      local effectInfo = skill_effect_config:getConfigById(effectId)
      if effectInfo.timing == curTiming then
        if effectInfo.target == 1 then
          self:calcSkillEffect(effectInfo, self)
        elseif effectInfo.target == 2 then
          enemy:calcSkillEffect(effectInfo, self)
        end
      end
    end
  end
  self:updateEffectBuffQueue(true)
end

function EntityServer:triggerInitiativeSkillEffect(curTiming, enemy, effectList)
  if effectList and 0 < #effectList then
    for _, effectId in pairs(effectList) do
      local effectInfo = skill_effect_config:getConfigById(effectId)
      if effectInfo.timing == curTiming then
        if effectInfo.target == 1 then
          self:calcSkillEffect(effectInfo, self)
        elseif effectInfo.target == 2 then
          enemy:calcSkillEffect(effectInfo, self)
        end
      end
    end
  end
  self:updateEffectBuffQueue(true)
end
