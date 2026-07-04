local InteractEventConfig = T(Config, "InteractEventConfig")
local GameTimes = T(Lib, "GameTimes")
local Instance = _ENV.Instance
local PartManagerShow = T(Lib, "PartManagerShow")
local PartInteractHelper = T(Lib, "PartInteractHelper")
local HouseConfig = T(Config, "HouseConfig")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local TimingSoundConfig = T(Config, "TimingSoundConfig")
local TimingSoundMgr = T(Lib, "TimingSoundMgr")
local sceneHandles = T(SceneHandler, "sceneHandles", {})

local function existConnect(instance, signalKey)
  local targetID = instance:getRuntimeID()
  local signalMap = sceneHandles[targetID]
  if not signalMap then
    return
  end
  local signal = signalMap[signalKey]
  if not signal then
    return
  end
  return true
end

local needConnects = {
  enter_scene = function(self)
    Trigger.CheckTriggers(self._cfg, "ENTER_SCENE", {part1 = self})
  end,
  on_destroy = function(self)
    Trigger.CheckTriggers(self._cfg, "ON_DESTROY", {part1 = self})
  end,
  on_exit_scene = function(self)
    Trigger.CheckTriggers(self._cfg, "ON_EXIT_SCENE", {part1 = self})
  end
}
local needConnect1 = {
  enter_scene = function(self)
    Trigger.CheckTriggers(self._cfg, "ENTER_SCENE", {part1 = self})
  end,
  ready = function(self)
    Trigger.CheckTriggers(self._cfg, "READY", {part1 = self})
  end,
  part_touch_part_begin = function(self, target)
    Trigger.CheckTriggers(self._cfg, "PART_TOUCH_PART_BEGIN", {part1 = self, part2 = target})
  end,
  part_touch_entity_begin = function(self, target)
    Trigger.CheckTriggers(self._cfg, "PART_TOUCH_ENTITY_BEGIN", {part1 = self, obj2 = target})
  end,
  part_touch_part_end = function(self, target)
    Trigger.CheckTriggers(self._cfg, "PART_TOUCH_PART_END", {part1 = self, part2 = target})
  end,
  part_touch_entity_end = function(self, target)
    Trigger.CheckTriggers(self._cfg, "PART_TOUCH_ENTITY_END", {part1 = self, obj2 = target})
  end
}
local _getByInstanceId = L("_getByInstanceId", Instance.getByInstanceId)

function Instance.getByInstanceId(id)
  if not id or id == 0 or id == "" then
    return nil
  end
  assert(tonumber(id))
  return _getByInstanceId(id)
end

function Instance:loadTriggerOnCreate(extendCfg, properties)
  if self.className == "RegionPart" or self.className == "Model" then
    return
  end
  local interactInfo = InteractEventConfig:getCfgById(properties.name) or {}
  local curPort = World.isClient and "client" or "server"
  if interactInfo.func == "operationPartRotate" or interactInfo.func == "operationPartMove" then
    properties.staticObject = "false"
    properties.individual = "true"
  end
  properties.templateInstanceId = properties.templateId
  if interactInfo.triggers and interactInfo.sync == curPort then
    if properties.useCollide == "false" then
      properties.collisionGroup = "8"
    end
    return self:loadTriggerByExtendCfg({
      triggers = interactInfo.triggers
    })
  elseif properties.useCollide == "false" then
    properties.collisionGroup = "16"
  end
end

function Instance:onCreated(params, map)
  local properties = params.properties
  if World.isClient then
    local interactInfo = InteractEventConfig:getCfgById(properties.name) or {}
    if interactInfo and interactInfo.func == "onInitTextDecalText" then
      Me:onInitTextDecalText(nil, self, interactInfo.params)
    end
  else
    TenderingLandMgr:loadingMapLandInfo(self, map)
    local lands = HouseConfig:getAllHouseLand()
    if lands[properties.name] then
      HouseManager:locationBeGenerated(self, map, Lib.copy(params))
    end
    SceneUIPartManager:loadingPartTipsUIInfo(self, map)
    if params.class == "RegionPart" then
      self.map = map
      for key, v in pairs(needConnects) do
        self:connect(key, v)
      end
    end
    if params.class == "AudioNode" then
      local timingSoundKey = TimingSoundConfig:getKeyList()
      if timingSoundKey[properties.name] then
        TimingSoundMgr:audioNodeAddControl(self)
      end
    end
    local interactInfo = InteractEventConfig:getCfgById(properties.name) or {}
    if interactInfo and interactInfo.func == "onUpdatePartShow" and interactInfo.params[2] and tonumber(interactInfo.params[2]) == 0 then
      World.Timer(20, function()
        if not self or not self:isValid() then
          return
        end
        PartManagerShow:updatePartShowState(self)
      end)
    end
    if interactInfo and interactInfo.func == "onEditPartContentShow" then
      SceneUIPartManager:loadingPartContentUIInfo(self, map, interactInfo.params)
    end
    local HalloweenPartHelper = T(Lib, "HalloweenPartHelper")
    if interactInfo and interactInfo.func == "onHalloweenExchange" and interactInfo.params[1] == "1" then
      HalloweenPartHelper:loadingHalloweenPartInfo(self, map, interactInfo.params)
    end
    if interactInfo and interactInfo.triggers then
      if interactInfo.isTimeTrigger then
        PartManagerHelper:addTimeTriggerList(self)
      end
      for i = 1, #interactInfo.triggersData do
        if tonumber(interactInfo.triggersData[i]) == Define.PART_INTERACT_TYPE.PART_SPAWN then
          local target = Instance.getByInstanceId(properties.id)
          if target and target:isValid() and PartInteractHelper[interactInfo.func] then
            local type = Define.PART_INTERACT_TYPE.PART_SPAWN
            PartInteractHelper[interactInfo.func](type, target, interactInfo.params)
          end
        end
      end
    elseif interactInfo.func == "OnSecretBlackboard" then
      local target = Instance.getByInstanceId(properties.id)
      if target and target:isValid() then
        PartManagerShow:initSecretBlackboardPart(target)
      end
    end
    World.Timer(2, function()
      if self and self:isValid() then
        if params.class == "Part" then
          self:connect("on_destroy", needConnects.on_destroy)
        end
        T(Lib, "VehicleManager"):onPartCreated(self, properties.name)
      end
    end)
  end
end

function Instance:onClientCreated()
  local interactInfo = InteractEventConfig:getCfgById(self.name) or {}
  if interactInfo.triggers and interactInfo.sync == "client" then
    for _, key in pairs(interactInfo.triggers) do
      key = key:lower()
      if not existConnect(self, key) then
        self:connect(key, needConnect1[key])
      end
    end
  end
  if self.className == "PartClient" and self.name == "house_area" then
    self:connect("on_destroy", needConnects.on_destroy)
  end
end

RETURN()
