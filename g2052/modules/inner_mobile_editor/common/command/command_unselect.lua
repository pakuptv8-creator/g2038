local class = require("common.3rd.middleclass.middleclass")
local Command = require("common.command.command")
local CommandUnSelect = class("CommandUnSelect", Command)

function CommandUnSelect:initialize(targets)
  Command.initialize(self, targets)
end

function CommandUnSelect:execute()
end

function CommandUnSelect:undo()
end

function CommandUnSelect:redo()
end

return CommandUnSelect
