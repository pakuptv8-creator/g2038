local class = require("common.3rd.middleclass.middleclass")
local Command = require("common.command.command")
local CommandRotate = class("CommandRotate", Command)
local IScene = require("common.engine.engine_scene")
local GameManager = T(MobileEditor, "GameManager")

function CommandRotate:initialize(targets, prevAxis, prevDegree)
  Command.initialize(self, targets)
  self.prevAxis = prevAxis
  self.prevDegree = prevDegree
  self.objects = GameManager:instance():filter(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.AABB)
  end, true)
end

function CommandRotate:execute()
end

function CommandRotate:undo()
  self.objects = GameManager:instance():filter(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.AABB)
  end, true)
  IScene:rotate_parts(self.objects, self.prevAxis, -self.prevDegree)
  Lib.emitEvent(Event.EVENT_ROTATE_GIZMO)
end

function CommandRotate:redo()
  self.objects = GameManager:instance():filter(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.AABB)
  end, true)
  IScene:rotate_parts(self.objects, self.prevAxis, self.prevDegree)
  Lib.emitEvent(Event.EVENT_ROTATE_GIZMO)
end

return CommandRotate
