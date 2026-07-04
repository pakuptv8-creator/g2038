local EmergencyEffectMgr = T(Lib, "EmergencyEffectMgr")
local manager = World.CurWorld:getSceneManager()
local EFFECT_NAME = {
  [Define.EMERGENCY_TYPE.FireDisaster] = "asset/effect/g2052_house_fire.effect"
}

function EmergencyEffectMgr:init()
  self.effectRecord = {}
  for _, type in pairs(Define.EMERGENCY_TYPE) do
    self.effectRecord[type] = {}
  end
  Lib.subscribeEvent(Event.EVENT_UPDATE_HOUSE_INFO, function(allHouseInfo)
  end)
  Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    local map = World.CurMap
    if map.name ~= "map001" then
      self:resetEffectRecord()
    end
  end)
end

function EmergencyEffectMgr:createEffect(type, key, posList)
  if not EFFECT_NAME[type] then
    return
  end
  local path = EFFECT_NAME[type]
  if not self.effectRecord[type] then
    self.effectRecord[type] = {}
  end
  if not self.effectRecord[type][key] then
    self.effectRecord[type][key] = {}
  end
  for _, pos in ipairs(posList) do
    local extendName = pos.x .. "#" .. pos.y .. "#" .. pos.z
    if not self.effectRecord[type][key][extendName] then
      local scene = manager:getOrCreateScene(Player.CurPlayer.map.obj)
      local scale = {
        x = 1,
        y = 1,
        z = 1
      }
      local rotation = Lib.v3(0, 0, 0)
      local effectNode = EffectNode.Load(path)
      effectNode:start()
      effectNode:setWorldPosition(Lib.v3(pos.x, pos.y, pos.z))
      effectNode:setWorldScale(Lib.v3(scale.x, scale.y, scale.z))
      effectNode:setWorldRotation(rotation)
      scene:getRoot():addChild(effectNode)
      local soundPath = "asset/sound/house_fire.mp3"
      local soundId = TdAudioEngine.Instance():play3dSound(soundPath, pos, true, 1, 1.0, 100.0)
      TdAudioEngine.Instance():setSoundsVolume(soundId, 2)
      TdAudioEngine.Instance():set3DRollOffMode(soundId, Sound3DRollOffType.LINEAR)
      TdAudioEngine.Instance():set3DMinMaxDistance(soundId, 1, 10)
      self.effectRecord[type][key][extendName] = {
        pos = pos,
        effectNode = effectNode,
        soundId = soundId
      }
    end
  end
end

function EmergencyEffectMgr:delEffect(type, key, posList)
  if not EFFECT_NAME[type] then
    return
  end
  local path = EFFECT_NAME[type]
  if not self.effectRecord[type][key] then
    return
  end
  local record = self.effectRecord[type][key]
  if not posList then
    for extendName, tab in pairs(record) do
      local effectNode = tab.effectNode
      if effectNode and effectNode:isValid() then
        effectNode:destroy()
      end
    end
    self.effectRecord[type][key] = nil
  else
    for _, pos in ipairs(posList) do
      local extendName = pos.x .. "#" .. pos.y .. "#" .. pos.z
      if self.effectRecord[type][key][extendName] then
        local effectNode = self.effectRecord[type][key][extendName].effectNode
        if effectNode and effectNode:isValid() then
          effectNode:destroy()
        end
        local soundId = self.effectRecord[type][key][extendName].soundId
        if soundId then
          TdAudioEngine.Instance():stopSound(soundId)
        end
        self.effectRecord[type][key][extendName] = nil
      end
    end
  end
end

function EmergencyEffectMgr:delAllEffect()
  for type, record in ipairs(self.effectRecord) do
    for key, _ in pairs(record) do
      EmergencyEffectMgr:delEffect(type, key)
    end
  end
end

function EmergencyEffectMgr:resetEffectRecord()
  for type, _ in ipairs(self.effectRecord) do
    self.effectRecord[type] = {}
  end
end

EmergencyEffectMgr:init()
return EmergencyEffectMgr
