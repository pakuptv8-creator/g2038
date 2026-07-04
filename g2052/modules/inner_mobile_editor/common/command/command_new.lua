local class = require("common.3rd.middleclass.middleclass")
local Command = require("common.command.command")
local CommandNew = class("CommandNew", Command)
local GameManager = T(MobileEditor, "GameManager")
local util = require("common.util.util")

function CommandNew:initialize(targets, config, snapPos, normal, modCfgId)
  Command.initialize(self, targets)
  self.config = Lib.copy(config)
  self.snapPos = snapPos
  self.normal = normal
  self.modCfgId = modCfgId
  self.createId = nil
end

function CommandNew:execute()
  Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
  Lib.emitEvent(Event.EVENT_RESET_TARGET)
  local node = GameManager:instance():createNode(self.config)
  if node then
    self.createId = node:getId()
    self.pos = util:getPlacePos(self.snapPos, self.normal, node:getSize())
    node:setPosition(self.pos)
    node:setModCfgId(self.modCfgId)
    Lib.emitEvent(Event.EVENT_ADD_TARGET, node:getId())
    if GameManager:instance():getCurrentState() ~= "Create" then
      Lib.emitEvent(Event.EVENT_SELECT_TARGET)
    end
  end
  return node
end

function CommandNew:update(params)
  if params then
    if params.pos then
      self.pos = params.pos
    end
    if params.cfg then
      self.config = params.cfg
    end
  end
end

function CommandNew:undo()
  Lib.logDebug("CommandNew:undo self.createId = ", self.createId)
  Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
  Lib.emitEvent(Event.EVENT_RESET_TARGET)
  Lib.emitEvent(Event.EVENT_DELETE_NODE, self.createId)
end

function CommandNew:redo()
  Lib.logDebug("CommandNew:redo")
  Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
  Lib.emitEvent(Event.EVENT_RESET_TARGET)
  self.config.properties.id = self.createId
  local node = GameManager:instance():createNode(self.config)
  if node then
    node:setPosition(self.pos)
    node:setModCfgId(self.modCfgId)
    Lib.emitEvent(Event.EVENT_ADD_TARGET, self.createId)
    if GameManager:instance():getCurrentState() ~= "Create" then
      Lib.emitEvent(Event.EVENT_SELECT_TARGET)
    end
  end
  return node
end

return CommandNew
