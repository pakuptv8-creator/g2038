local LuaTimer = T(Lib, "LuaTimer")
local TargetManager = T(MobileEditor, "TargetManager")
local IScene = require("common.engine.engine_scene")
local IInstance = require("common.engine.engine_instance")
local util = require("common.util.util")
local CommandManager = T(MobileEditor, "CommandManager")
local GameManager = T(MobileEditor, "GameManager")
local ConfigManager = T(MobileEditor, "ConfigManager")

function TargetManager:initialize()
  Lib.logDebug("TargetManager:initialize")
  self.transformType = Define.TRANSFORM_TYPE.NONE
  self.targets = {}
  self.prevPos = {}
  self:subscribeEvents()
end

function TargetManager:finalize()
end

function TargetManager:subscribeEvents()
  Lib.subscribeEvent(Event.EVENT_CONFIRM_MULTIPLE, function()
    CommandManager:instance():endFrame()
    Lib.emitEvent(Event.EVENT_ENABLE_MULTIPLE, false)
  end)
  Lib.subscribeEvent(Event.EVENT_CANCEL_MULTIPLE, function()
    CommandManager:instance():resetFrame()
    Lib.emitEvent(Event.EVENT_ENABLE_MULTIPLE, false)
  end)
  Lib.subscribeEvent(Event.EVENT_GROUP_TARGET, function()
    if Lib.getTableSize(self.targets) > 1 then
      local CommandGroup = require("common.command.command_group")
      CommandManager:instance():register(CommandGroup:new(self.targets))
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ADD_GROUP, function(id)
    if Lib.getTableSize(self.targets) > 0 then
      local CommandAddGroup = require("common.command.command_add_group")
      CommandManager:instance():register(CommandAddGroup:new(self.targets, id))
    end
  end)
  Lib.subscribeEvent(Event.EVENT_REMOVE_GROUP, function(id)
    if Lib.getTableSize(self.targets) > 0 then
      local CommandRemoveGroup = require("common.command.command_remove_group")
      CommandManager:instance():register(CommandRemoveGroup:new(self.targets, id))
    end
  end)
  Lib.subscribeEvent(Event.EVENT_DUPLICATE_TARGET, function()
    if Lib.getTableSize(self.targets) > 0 then
      local CommandDuplicate = require("common.command.command_duplicate")
      CommandManager:instance():register(CommandDuplicate:new(self.targets))
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ADD_TARGET, function(id)
    self:addTarget(id)
  end)
  Lib.subscribeEvent(Event.EVENT_REMOVE_TARGET, function(id)
    self:removeTarget(id)
  end)
  Lib.subscribeEvent(Event.EVENT_DELETE_TARGET, function()
    local CommandDelete = require("common.command.command_delete")
    CommandManager:instance():register(CommandDelete:new(self.targets))
  end)
  Lib.subscribeEvent(Event.EVENT_MOVE_TARGET, function(id, pos)
    self:moveTarget(id, pos)
  end)
  Lib.subscribeEvent(Event.EVENT_END_MOVE, function()
    Lib.logDebug("EVENT_END_MOVE")
    IScene:end_drag_parts()
  end)
  Lib.subscribeEvent(Event.EVENT_SELECT_TARGET, function()
    self:selectTargets()
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_TARGET_STATE, function(state)
    if state == "Place" then
      self:gotoPlace()
    elseif state == "Select" then
      self:gotoSelect()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_RESET_TARGET, function()
    self.targets = {}
    self.transformType = Define.TRANSFORM_TYPE.NONE
  end)
  Lib.subscribeEvent(Event.EVENT_UNSELECT_TARGET, function()
    Lib.emitEvent(Event.EVENT_HIDE_GIZMO)
    Lib.emitEvent(Event.EVENT_SHOW_LAST_TOOL_PANEL)
    self:gotoPlace()
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_TARGET, function()
    self:selectTargets()
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_MATERIAL_TEXTURE, function(textureIndex)
    local CommandChangeTexture = require("common.command.command_change_texture")
    CommandManager:instance():register(CommandChangeTexture:new(self.targets, textureIndex))
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_MATERIAL_COLOR, function(colorIndex)
    local data = ConfigManager:instance().materialColorConfig:getConfig(colorIndex)
    if data then
      local color_temp = string.format("r:%s g:%s b:%s", data.rgba.r / 255, data.rgba.g / 255, data.rgba.b / 255)
      local CommandChangeColor = require("common.command.command_change_color")
      CommandManager:instance():register(CommandChangeColor:new(self.targets, color_temp))
    end
  end)
  Lib.subscribeEvent(Event.EVENT_START_TRANSLATE, function()
    local objects = GameManager:instance():filter(self.targets, function(node)
      return node:checkAbility(Define.ABILITY_EDITOR.AABB)
    end, true)
    for _, object in pairs(objects) do
      self.prevPos[object:getInstanceID()] = object:getPosition()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_FINISH_TRANSLATE, function()
    local CommandTranslate = require("common.command.command_translate")
    CommandManager:instance():register(CommandTranslate:new(self.targets, self.prevPos))
    self.prevPos = {}
  end)
end

function TargetManager:addTarget(id)
  table.insert(self.targets, id)
end

function TargetManager:removeTarget(id)
  for i = #self.targets, 1, -1 do
    if self.targets[i] == id then
      table.remove(self.targets, i)
    end
  end
end

function TargetManager:gotoSelect()
  for i = 1, #self.targets do
    local node = GameManager:instance():getNode(self.targets[i])
    if node then
      if node:getCurrentState() == "Place" then
        node:gotoState("Select")
      end
    else
      Lib.logDebug("gotoSelect node is nil id = ", self.targets[i])
    end
  end
end

function TargetManager:gotoPlace()
  for i = 1, #self.targets do
    local node = GameManager:instance():getNode(self.targets[i])
    if node and node:getCurrentState() == "Select" then
      node:gotoState("Place")
    end
  end
end

function TargetManager:selectTargets()
  if Lib.getTableSize(self.targets) <= 0 then
    return
  end
  self:gotoSelect()
  Lib.emitEvent(Event.EVENT_SHOW_GIZMO, self.targets)
  Lib.emitEvent(Event.EVENT_SHOW_TOOL_PANEL, "object", self.targets)
end

local function testMoveBound(bounds, diff, floorBound)
  local newBound = {
    min = {
      x = bounds.min.x + diff.x,
      y = bounds.min.y + diff.y,
      z = bounds.min.z + diff.z
    },
    max = {
      x = bounds.max.x + diff.x,
      y = bounds.max.y + diff.y,
      z = bounds.max.z + diff.z
    }
  }
  if newBound.min.x >= floorBound.min.x and newBound.min.y >= floorBound.min.y and newBound.min.z >= floorBound.min.z and newBound.max.x <= floorBound.max.x and newBound.max.y <= floorBound.max.y and newBound.max.z <= floorBound.max.z then
    return true
  end
  return false
end

function TargetManager:moveTarget(id, pos)
  local objects = GameManager:instance():filter(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.AABB)
  end, true)
  if Lib.getTableSize(objects) > 0 then
    local ignoreInstanceIds = {}
    for i = 1, #objects do
      table.insert(ignoreInstanceIds, objects[i]:getInstanceID())
    end
    local result = IScene:raycast(pos, util:getRayLength(), -1, ignoreInstanceIds)
    if result then
      local targetObject
      if id then
        for i = 1, #objects do
          if id == objects[i]:getInstanceID() then
            targetObject = objects[i]
            break
          end
        end
      else
        targetObject = objects[1]
      end
      if targetObject then
        local size = IInstance:size(targetObject)
        local snap
        if targetObject:isA("Part") or targetObject:isA("PartOperation") then
          snap = Define.MOD_INTERVAL.GEOMETRY
        elseif targetObject:isA("MeshPart") or targetObject:isA("Model") then
          snap = Define.MOD_INTERVAL.PROP
        end
        local snapPos = util:snap(result.collidePos, snap)
        local placePos = util:getPlacePos(snapPos, Lib.v3(util:round(result.normalOnHitObject.x), util:round(result.normalOnHitObject.y), util:round(result.normalOnHitObject.z)), size)
        local diff = {
          x = placePos.x - targetObject:getPosition().x,
          y = placePos.y - targetObject:getPosition().y,
          z = placePos.z - targetObject:getPosition().z
        }
        local floorBound = GameManager:instance():getFloorBound()
        local nodes = GameManager:instance():getNodes(self.targets)
        local bounds = util:getBound(nodes)
        if testMoveBound(bounds, diff, floorBound) then
          IScene:move_parts(objects, diff)
        end
      else
        Lib.logError("targetObject is nil")
      end
    end
  end
end

function TargetManager:getTargets()
  return self.targets
end

function TargetManager:containTarget(id)
  for i = 1, #self.targets do
    if self.targets[i] == id then
      return true
    end
  end
  return false
end

return TargetManager
