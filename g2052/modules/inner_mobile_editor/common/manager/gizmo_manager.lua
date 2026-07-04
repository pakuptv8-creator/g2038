local GizmoManager = T(MobileEditor, "GizmoManager")
local IScene = require("common.engine.engine_scene")
local IInstance = require("common.engine.engine_instance")
local PartTransformHelper = require("common.helper.part_transform_helper")
local util = require("common.util.util")
local GameManager = T(MobileEditor, "GameManager")
local CommandManager = T(MobileEditor, "CommandManager")
local last

function GizmoManager:initialize()
  self.transformType = Define.TRANSFORM_TYPE.NONE
  self.mode = Define.SPACE_MODE.LOCAL
  self.targets = {}
  self.objects = nil
  self.prevPos = {}
  self.prevAxis = nil
  self.prevDegree = 0
  self.prevOffset = Lib.v3()
  self.prevStretch = nil
  self:subscribeEvents()
end

function GizmoManager:finalize()
  self.transformType = Define.TRANSFORM_TYPE.NONE
  self.mode = Define.SPACE_MODE.LOCAL
  self.targets = {}
  self.objects = nil
  self.prevPos = {}
  self.prevAxis = nil
  self.prevDegree = 0
  self.prevOffset = Lib.v3()
  self.prevStretch = nil
  if self.node then
    self.node:destroy()
    self.node = nil
  end
end

function GizmoManager:subscribeEvents()
  Lib.subscribeEvent(Event.EVENT_UPDATE_SPACE, function(mode)
    self.mode = mode
    if self.transformType ~= Define.TRANSFORM_TYPE.NONE then
      local GameManager = T(MobileEditor, "GameManager")
      local center = GameManager:instance():getCenter(self.targets)
      self:switch(center)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SHOW_GIZMO, function(targets)
    self.targets = targets
    local GameManager = T(MobileEditor, "GameManager")
    local enableTranslate = false
    local translateObjects = GameManager:instance():all(self.targets, function(node)
      return node:checkAbility(Define.ABILITY_EDITOR.TRANSLATE)
    end)
    if Lib.getTableSize(translateObjects) > 0 then
      enableTranslate = true
    end
    local enableRotate = false
    local rotateObjects = GameManager:instance():all(self.targets, function(node)
      return node:checkAbility(Define.ABILITY_EDITOR.ROTATE)
    end)
    if Lib.getTableSize(rotateObjects) > 0 then
      enableRotate = true
    end
    local enableScale = false
    local scaleObjects = GameManager:instance():all(self.targets, function(node)
      return node:checkAbility(Define.ABILITY_EDITOR.SCALE)
    end)
    if Lib.getTableSize(scaleObjects) > 0 then
      enableScale = true
    end
    if self.transformType ~= Define.TRANSFORM_TYPE.NONE then
      if self.transformType == Define.TRANSFORM_TYPE.TRANSLATE and enableTranslate == true or self.transformType == Define.TRANSFORM_TYPE.ROTATE and enableRotate == true or self.transformType == Define.TRANSFORM_TYPE.SCALE and enableScale == true then
        local center = GameManager:instance():getCenter(self.targets)
        self:switch(center)
      elseif self.node then
        self.node:destroy()
        self.node = nil
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SWITCH_GIZMO, function(type)
    self.transformType = type
    if self.transformType == Define.TRANSFORM_TYPE.NONE then
      if self.node then
        self.node:destroy()
        self.node = nil
      end
    else
      local GameManager = T(MobileEditor, "GameManager")
      local center = GameManager:instance():getCenter(self.targets)
      self:switch(center)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_HIDE_GIZMO, function()
    if self.node then
      self.node:destroy()
      self.node = nil
    end
    self.targets = {}
  end)
  Lib.subscribeEvent(Event.EVENT_MOVE_GIZMO, function()
    if self.node then
      local GameManager = T(MobileEditor, "GameManager")
      local center = GameManager:instance():getCenter(self.targets)
      self.node:setPosition(center)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ROTATE_GIZMO, function()
    if self.node then
      local target = self.targets[#self.targets]
      local GameManager = T(MobileEditor, "GameManager")
      local node = GameManager:instance():getNode(target)
      if node then
        local rotation = node:getRotation()
        if rotation then
          self.node:setRotationXYZ(rotation)
        end
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SCALE_GIZMO, function()
    if self.node then
      local GameManager = T(MobileEditor, "GameManager")
      local center = GameManager:instance():getCenter(self.targets)
      self.node:setPosition(center)
    end
  end)
end

function GizmoManager:switch(pos)
  if not pos then
    return
  end
  last = nil
  local manager = World.CurWorld:getSceneManager()
  if self.node then
    self.node:destroy()
    self.node = nil
  end
  self.mode = Define.SPACE_MODE.LOCAL
  if self.transformType == Define.TRANSFORM_TYPE.TRANSLATE then
    self.node = GizmoTransformMove.createWithParameter(6, 0.1, 0.5, 1.5, 0.25, 0.5, false, false)
    self.node:setMoveInterval(0.01)
    self.mode = Define.SPACE_MODE.WORLD
  elseif self.transformType == Define.TRANSFORM_TYPE.ROTATE then
    self.node = GizmoTransformRotate.createWithParameter(26, 196)
    self.node:setDegreeInterval(1)
    self.node:setShowAxis(0)
  elseif self.transformType == Define.TRANSFORM_TYPE.SCALE then
    self.node = GizmoTransformScale.createWithParameter(6, 0.1, 0.5, 1.5, 0.2, false)
    self.node:setScaleInterval(0.01)
  end
  if self.mode == Define.SPACE_MODE.LOCAL then
    local target = self.targets[#self.targets]
    local GameManager = T(MobileEditor, "GameManager")
    local node = GameManager:instance():getNode(target)
    if node then
      local rotation = node:getRotation()
      if rotation then
        self.node:setRotationXYZ(rotation)
      end
    end
  end
  self.node:setHighLightColor(Lib.v3(0.9490196078431372, 0.9490196078431372, 0.9490196078431372))
  self.node:setAxisColor(0, Lib.v3(0.9921568627450981, 0.5137254901960784, 0.596078431372549))
  self.node:setAxisColor(1, Lib.v3(0.5882352941176471, 0.984313725490196, 0.6470588235294118))
  self.node:setAxisColor(2, Lib.v3(0.5176470588235295, 0.7725490196078432, 0.9921568627450981))
  self.node:setPosition(pos)
  manager:setGizmo(self.node)
end

function GizmoManager:isShow()
  return self.node ~= nil
end

local function getDiff(type, ...)
  if type == Define.TRANSFORM_TYPE.TRANSLATE then
    local offset = (...)
    last = last or {
      x = 0,
      y = 0,
      z = 0
    }
    local diff = {
      x = offset.x - last.x,
      y = offset.y - last.y,
      z = offset.z - last.z
    }
    return diff, offset
  elseif type == Define.TRANSFORM_TYPE.SCALE then
    local offset = (...)
    last = last or {
      x = 0,
      y = 0,
      z = 0
    }
    local diff = {
      x = offset.x - last.x,
      y = offset.y - last.y,
      z = offset.z - last.z
    }
    return diff, offset
  elseif type == Define.TRANSFORM_TYPE.ROTATE then
    local degrees = (...)
    last = last or 0.0
    local diff = degrees - last
    return diff, degrees
  end
end

function GizmoManager:handleEventBegin()
  self.touchEventing = true
  last = nil
  self.prevPos = {}
  self.prevAxis = nil
  self.prevDegree = 0
  self.prevOffset = Lib.v3()
  self.prevStretch = nil
  self.objects = nil
  local GameManager = T(MobileEditor, "GameManager")
  self.objects = GameManager:instance():filter(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.AABB)
  end, true)
  if self.transformType == Define.TRANSFORM_TYPE.TRANSLATE then
    for _, object in pairs(self.objects) do
      self.prevPos[object:getInstanceID()] = object:getPosition()
    end
  elseif self.transformType == Define.TRANSFORM_TYPE.SCALE then
  elseif self.transformType == Define.TRANSFORM_TYPE.ROTATE then
  end
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

local function inArea(p, center, floorBound)
  p = p + center
  if p.x >= floorBound.min.x and p.y >= floorBound.min.y and p.z >= floorBound.min.z and p.x <= floorBound.max.x and p.y <= floorBound.max.y and p.z <= floorBound.max.z then
    return true
  end
  return false
end

local function testRotateBound(axis, center, bounds, floorBound, degree)
  local rotate = Quaternion.rotateAxis(axis, degree)
  local vec = {
    Vector3.fromTable({
      x = bounds.min.x,
      y = bounds.min.y,
      z = bounds.min.z
    }) - center,
    Vector3.fromTable({
      x = bounds.min.x,
      y = bounds.min.y,
      z = bounds.max.z
    }) - center,
    Vector3.fromTable({
      x = bounds.max.x,
      y = bounds.min.y,
      z = bounds.max.z
    }) - center,
    Vector3.fromTable({
      x = bounds.max.x,
      y = bounds.min.y,
      z = bounds.min.z
    }) - center,
    Vector3.fromTable({
      x = bounds.max.x,
      y = bounds.max.y,
      z = bounds.max.z
    }) - center,
    Vector3.fromTable({
      x = bounds.max.x,
      y = bounds.max.y,
      z = bounds.min.z
    }) - center,
    Vector3.fromTable({
      x = bounds.min.x,
      y = bounds.max.y,
      z = bounds.min.z
    }) - center,
    Vector3.fromTable({
      x = bounds.min.x,
      y = bounds.max.y,
      z = bounds.max.z
    }) - center
  }
  for _, p in pairs(vec) do
    if not inArea(rotate * p, center, floorBound) then
      return false
    end
  end
  return true
end

function GizmoManager:handleEventMove(...)
  if not self.touchEventing then
    return
  end
  local GameManager = T(MobileEditor, "GameManager")
  local floorBound = GameManager:instance():getFloorBound()
  local nodes = GameManager:instance():getNodes(self.targets)
  local bounds = util:getBound(nodes)
  local center = GameManager:instance():getCenter(self.targets)
  if self.transformType == Define.TRANSFORM_TYPE.TRANSLATE then
    local offset = (...)
    local diff, cur = getDiff(Define.TRANSFORM_TYPE.TRANSLATE, offset)
    if testMoveBound(bounds, diff, floorBound) then
      IScene:move_parts(self.objects, diff)
      last = cur
    end
    Lib.emitEvent(Event.EVENT_MOVE_GIZMO)
  elseif self.transformType == Define.TRANSFORM_TYPE.ROTATE then
    local axis_t, degree = ...
    local diff, cur = getDiff(Define.TRANSFORM_TYPE.ROTATE, degree)
    local axis = {
      x = axis_t == 1 and 1 or 0,
      y = axis_t == 2 and 1 or 0,
      z = axis_t == 3 and 1 or 0
    }
    if self.mode == Define.SPACE_MODE.LOCAL then
      local rotate = Quaternion.fromEulerAngleVector(self.node:getRotationXYZ())
      local v3 = Vector3.fromTable(axis)
      axis = rotate * v3
    end
    if testRotateBound(axis, center, bounds, floorBound, degree) then
      self.prevAxis = axis
      self.prevDegree = self.prevDegree + diff
      IScene:rotate_parts(self.objects, self.prevAxis, diff)
      last = cur
    end
    Lib.emitEvent(Event.EVENT_ROTATE_GIZMO)
  elseif self.transformType == Define.TRANSFORM_TYPE.SCALE then
    local axis, scale, stretch = ...
    local diff, cur = getDiff(self.transformType, scale)
    local rotate = Quaternion.fromEulerAngleVector(self.node:getRotationXYZ())
    local extra = {
      bounds = bounds,
      center = center,
      floorBound = floorBound,
      rotate = rotate,
      func = function(canScale)
        if canScale then
          self.prevAxis = axis
          self.prevOffset = Lib.v3(self.prevOffset.x + diff.x, self.prevOffset.y + diff.y, self.prevOffset.z + diff.z)
          self.prevStretch = stretch
        end
        last = cur
        Lib.emitEvent(Event.EVENT_SCALE_GIZMO)
      end
    }
    PartTransformHelper.getScale(self.objects, axis, diff, stretch == 1, extra)
  end
end

function GizmoManager:handleEventEnd()
  if not self.touchEventing then
    return
  end
  if self.transformType == Define.TRANSFORM_TYPE.TRANSLATE then
    local CommandTranslate = require("common.command.command_translate")
    local CommandManager = T(MobileEditor, "CommandManager")
    CommandManager:instance():register(CommandTranslate:new(self.targets, self.prevPos))
  elseif self.transformType == Define.TRANSFORM_TYPE.ROTATE then
    local CommandRotate = require("common.command.command_rotate")
    local CommandManager = T(MobileEditor, "CommandManager")
    CommandManager:instance():register(CommandRotate:new(self.targets, self.prevAxis, self.prevDegree))
  elseif self.transformType == Define.TRANSFORM_TYPE.SCALE then
    local CommandScale = require("common.command.command_scale")
    local CommandManager = T(MobileEditor, "CommandManager")
    CommandManager:instance():register(CommandScale:new(self.targets, self.prevAxis, self.prevOffset, self.prevStretch))
  end
  self.touchEventing = false
end

return GizmoManager
