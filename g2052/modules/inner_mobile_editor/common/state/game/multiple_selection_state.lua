local util = require("common.util.util")
local IScene = require("common.engine.engine_scene")
local TargetManager = T(MobileEditor, "TargetManager")
local CommandManager = T(MobileEditor, "CommandManager")
local IInstance = require("common.engine.engine_instance")
local BM = Blockman.Instance()
local MultipleSelectionState = {}

function MultipleSelectionState:enteredState()
  local targets = TargetManager:instance():getTargets()
  if #targets <= 0 then
    return
  end
  for i = 1, #targets do
    local node = self:getNode(targets[i])
    if node then
      node:set("materialColor", "r:0.0 g:1.0 b:0.0 a:1.0")
    end
  end
  CommandManager:instance():startFrame()
end

function MultipleSelectionState:exitedState()
  local targets = TargetManager:instance():getTargets()
  if #targets <= 0 then
    return
  end
  for i = 1, #targets do
    local node = self:getNode(targets[i])
    if node then
      node:resetMaterialColor()
    end
  end
end

function MultipleSelectionState:touchBegin(x, y)
  self.touchBeginPos = Lib.v2(x, y)
  local result = IScene:raycast(Lib.v2(x, y), util:getRayLength(), -1, {
    self.floor:getId()
  })
  if result then
    self.touchBeginId = result.target:getInstanceID()
  else
    self.pressTime = Lib.getTime()
    self.touchBeginId = nil
    self.isTouchBegin = true
    Lib.emitEvent(Event.EVENT_START_SELECTION, Lib.v2(x, y))
  end
end

function MultipleSelectionState:touchMove(curX, curY, prevX, prevY)
  if self.isTouchMove == false then
    self.isTouchMove = true
  end
  self:panCamera(curX, curY, prevX, prevY)
end

function MultipleSelectionState:touchEnd(x, y)
  local result = IScene:raycast(Lib.v2(x, y), util:getRayLength(), -1, {
    self.floor:getId()
  })
  if result then
    self.touchEndId = result.target:getInstanceID()
    if self.isTouchMove == false and self.touchBeginId and self.touchBeginId == self.touchEndId then
      local parent = util:getRoot(result.target, self.root)
      if TargetManager:instance():containTarget(parent:getInstanceID()) then
        if parent == result.target then
        else
          Lib.emitEvent(Event.EVENT_REMOVE_GROUP, result.target:getInstanceID())
        end
      else
        local targets = TargetManager:instance():getTargets()
        if Lib.getTableSize(targets) == 0 then
          Lib.emitEvent(Event.EVENT_ADD_TARGET, parent:getInstanceID())
          Lib.emitEvent(Event.EVENT_UPDATE_TARGET)
        elseif IInstance:get(parent, "name") ~= "birth" then
          Lib.emitEvent(Event.EVENT_ADD_GROUP, parent:getInstanceID())
        end
      end
    end
  end
  Lib.emitEvent(Event.EVENT_SET_CAMERA, BM:getViewerPos(), BM:getViewerYaw(), BM:getViewerPitch(), 0)
  self.touchBeginPos = nil
  self.touchBeginId = nil
  self.touchEndId = nil
  self.isTouchMove = false
  self.isTouchBegin = false
  self.pressTime = 0
end

return MultipleSelectionState
