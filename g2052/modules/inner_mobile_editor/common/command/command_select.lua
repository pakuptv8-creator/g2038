local class = require("common.3rd.middleclass.middleclass")
local Command = require("common.command.command")
local CommandSelect = class("CommandSelect", Command)

function CommandSelect:initialize(targets)
  Command.initialize(self, targets)
end

function CommandSelect:execute()
end

function CommandSelect:undo()
end

function CommandSelect:redo()
end

return CommandSelect
