local class = require("common.3rd.middleclass.middleclass")
local Command = require("common.command.command")
local CommandChangeColor = class("CommandChangeColor", Command)
local GameManager = T(MobileEditor, "GameManager")
local IInstance = require("common.engine.engine_instance")
local ConfigManager = T(MobileEditor, "ConfigManager")
local util = require("common.util.util")

function CommandChangeColor:initialize(targets, curColor)
  Command.initialize(self, targets)
  self.curColor = curColor
  self.prevColors = {}
  for i = 1, #self.targets do
    local id = self.targets[i]
    local node = GameManager:instance():getNode(id)
    if node then
      self.prevColors = node:getMaterialColor()
    end
  end
end

function CommandChangeColor:execute()
  for i = 1, #self.targets do
    local node = GameManager:instance():getNode(self.targets[i])
    if node then
      node:setMaterialColor(self.curColor)
    end
  end
end

function CommandChangeColor:undo()
  for id, color in pairs(self.prevColors) do
    local object = Instance.getByInstanceId(id)
    if object then
      IInstance:set(object, "materialColor", color)
      object.attributes.color = color
    end
  end
end

function CommandChangeColor:redo()
  for i = 1, #self.targets do
    local id = self.targets[i]
    local node = GameManager:instance():getNode(id)
    if node then
      node:setMaterialColor(self.curColor)
    end
  end
end

return CommandChangeColor
