local ConfigManager = T(MobileEditor, "ConfigManager")
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local util = require("common.util.util")
local IScene = require("common.engine.engine_scene")
local BM = Blockman.Instance()
local EditState = {}

function EditState:enteredState()
end

function EditState:exitedState()
  Lib.emitEvent(Event.EVENT_LOCK_FLY_MODE)
  self.floor = nil
  self.birth = nil
end

function EditState:touchBegin(x, y)
  if not self.floor then
    return
  end
  self.touchBeginPos = Lib.v2(x, y)
  local result = IScene:raycast(Lib.v2(x, y), util:getRayLength(), -1, {
    self.floor:getId()
  })
  if result then
    local root = util:getRoot(result.target, self.root)
    if not root then
      Lib.logError("Edit EVENT_TOUCH_BEGIN getRoot is nil")
      return
    end
    self.touchBeginId = root:getInstanceID()
    local node = self:getNode(root:getInstanceID())
    if node and node:getCurrentState() == "Select" then
      Lib.emitEvent(Event.EVENT_START_TRANSLATE)
    end
  else
    self.pressTime = Lib.getTime()
    self.touchBeginId = nil
    self.isTouchBegin = true
    Lib.emitEvent(Event.EVENT_START_SELECTION, self.touchBeginPos)
  end
end

function EditState:touchMove(curX, curY, prevX, prevY)
  if not self.floor then
    return
  end
  if self.isTouchMove == false then
    self.isTouchMove = true
  end
  if self.touchBeginId then
    local GizmoManager = T(MobileEditor, "GizmoManager")
    if GizmoManager:instance():isShow() then
      return
    end
    local TargetManager = T(MobileEditor, "TargetManager")
    if TargetManager:instance():containTarget(self.touchBeginId) then
      Lib.emitEvent(Event.EVENT_MOVE_TARGET, self.touchBeginId, Lib.v2(curX, curY))
    else
      self:panCamera(curX, curY, prevX, prevY)
    end
  else
    self:panCamera(curX, curY, prevX, prevY)
  end
end

function EditState:touchEnd(x, y)
  if not self.floor then
    return
  end
  local result = IScene:raycast(Lib.v2(x, y), util:getRayLength(), -1, {
    self.floor:getId()
  })
  if result then
    local root = util:getRoot(result.target, self.root)
    if not root then
      Lib.logError("Edit EVENT_TOUCH_END getRoot is nil")
      return
    end
    self.touchEndId = root:getInstanceID()
    if self.touchBeginId and self.touchBeginId == self.touchEndId then
      local node = self:getNode(root:getInstanceID())
      if node then
        if node:getCurrentState() == "Place" then
          local TargetManager = T(MobileEditor, "TargetManager")
          if not TargetManager:instance():containTarget(root:getInstanceID()) then
            if self.isTouchMove == false then
              Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
              Lib.emitEvent(Event.EVENT_RESET_TARGET)
              Lib.emitEvent(Event.EVENT_ADD_TARGET, root:getInstanceID())
              Lib.emitEvent(Event.EVENT_SELECT_TARGET)
            end
          else
            Lib.emitEvent(Event.EVENT_FINISH_TRANSLATE)
            Lib.emitEvent(Event.EVENT_SELECT_TARGET)
          end
        elseif node:getCurrentState() == "Select" then
          if self.isTouchMove == false then
            Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
            Lib.emitEvent(Event.EVENT_RESET_TARGET)
          else
            Lib.emitEvent(Event.EVENT_FINISH_TRANSLATE)
            Lib.emitEvent(Event.EVENT_SELECT_TARGET)
          end
        end
      end
    end
  elseif self.touchBeginId then
    if self.isTouchMove == true then
      local TargetManager = T(MobileEditor, "TargetManager")
      if TargetManager:instance():containTarget(self.touchBeginId) then
        Lib.emitEvent(Event.EVENT_FINISH_TRANSLATE)
        Lib.emitEvent(Event.EVENT_SELECT_TARGET)
      else
        Lib.emitEvent(Event.EVENT_SET_CAMERA, BM:getViewerPos(), BM:getViewerYaw(), BM:getViewerPitch(), 0)
      end
    end
  elseif self.isTouchMove == false then
    Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
    Lib.emitEvent(Event.EVENT_RESET_TARGET)
    self.clickCount = self.clickCount + 1
    if self.clickCount == 1 then
      self.clickTime = Lib.getTime()
    end
    local curTime = Lib.getTime()
    local diff = curTime - self.clickTime
    if self.clickCount > 1 and diff < self.clickDelay * 1000 then
      self.clickCount = 0
      self.clickTime = 0
      local targetResult = BM:getScreenIntersectPlane(self.touchBeginPos, Lib.v3(0, 1, 0), Lib.v3(0, 31, 0))
      Lib.emitEvent(Event.EVENT_SET_FOCUS, targetResult.intersect)
    elseif self.clickCount > 2 or 1500.0 <= diff then
      self.clickCount = 0
    end
  else
    Lib.emitEvent(Event.EVENT_SET_CAMERA, BM:getViewerPos(), BM:getViewerYaw(), BM:getViewerPitch(), 0)
  end
  self.touchBeginPos = nil
  self.touchBeginId = nil
  self.touchEndId = nil
  self.isTouchMove = false
  self.isTouchBegin = false
  self.pressTime = 0
end

return EditState
