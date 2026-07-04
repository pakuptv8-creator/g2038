local SkillBase = Skill.GetType("Base")
local CGInterface = CGame.instance:getShellInterface()
SkillBase.startAction = "attack2"
SkillBase.sustainAction = "aim2"
SkillBase.castAction = "attack2"
SkillBase.castActionTime = -1
SkillBase.isResetBaseAction = true
SkillBase.cycleTimer = {}
SkillBase.castEffectName = {}
local consume = {}

local function doConsume(from, consumeItem, check)
  local ret = true
  if type(consumeItem) == "table" then
    for _, i in pairs(consumeItem) do
      ret = consume:consumeItem(from, i)
      if not ret then
        return false
      end
    end
  else
    ret = consume:consumeItem(from, consumeItem)
  end
  return ret
end

local function playAction(from, action, time, isResetBaseAction)
  if not from or not from:isValid() then
    return
  end
  if from:data("reload").reloadTimer and action ~= "idle" and action ~= "" then
    return
  end
  if from.isEntity and action and action ~= "" then
    from:updateUpperAction(action, time, isResetBaseAction)
  end
end

local function playEffect(from, cfg, effect)
  if not from or not from:isValid() then
    return
  end
  if effect and from.isEntity then
    local isEffectArr = false
    if not cfg.castEffectName[from.objID] then
      cfg.castEffectName[from.objID] = {}
    end
    for _, eff in ipairs(effect) do
      local name = from:showEffect(eff, cfg)
      table.insert(cfg.castEffectName[from.objID], name)
      isEffectArr = true
    end
    if not isEffectArr then
      local name = from:showEffect(effect, cfg)
      table.insert(cfg.castEffectName[from.objID], name)
    end
  end
end

local function stopPlayEffect(from, cfg, effect)
  if not cfg.castEffectName[from.objID] then
    return
  end
  for k, name in ipairs(cfg.castEffectName[from.objID]) do
    from:delEffect(name)
  end
  cfg.castEffectName[from.objID] = {}
end

local function playSound(from, self, cfg, sound)
  if not from or not from:isValid() then
    return
  end
  if sound then
    from:data("soundId")[self.fullName] = from:playSound(sound, cfg)
  end
end

local function stopSound(from, self)
  if from then
    local soundId = from:data("soundId")[self.fullName]
    if soundId then
      from:stopSound(soundId)
    end
  end
end

local function playFirstViewUIEffect(from, value, add)
  if not from or not from:isValid() then
    return
  end
  if from.isMainPlayer and value then
    Lib.emitEvent(Event.PLAYE_UI_EFFECT, value, add, value.time or 20)
  end
end

local function vibratorOnTime(from, vibratorTime)
  if not from or not from:isValid() then
    return
  end
  if not vibratorTime or type(vibratorTime) ~= "number" then
    return
  end
  CGInterface:vibratorOnTime(vibratorTime)
end

function SkillBase:stop(packet, from)
  local cycleTimer = self.cycleTimer[from.objID]
  if cycleTimer then
    cycleTimer()
    self.cycleTimer[from.objID] = nil
  end
  local InteractionHelper = T(Lib, "InteractionHelper")
  if not InteractionHelper:isHaveEntityAction(from.objID) then
    playAction(from, self.stopAction or "idle", 0)
  end
  playEffect(from, self, self.stopEffect)
  playSound(from, self, self:getSoundCfg(packet, "stopSound", from))
  stopSound(from, self)
  vibratorOnTime(from, self.stopVibratorTime)
  playFirstViewUIEffect(from, self.preCastUIEffect, false)
  playFirstViewUIEffect(from, self.startUIEffect, false)
  playFirstViewUIEffect(from, self.sustainUIEffect, false)
  playFirstViewUIEffect(from, self.stopUIEffect, false)
end
