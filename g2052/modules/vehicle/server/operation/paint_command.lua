local CommandBase = require("server.operation.command_base")
local PaintCommand = class("PaintCommand", CommandBase)

function PaintCommand:ctor(car)
  PaintCommand.super.ctor(self, car)
end

function PaintCommand:execute()
end

function PaintCommand:undo()
end

return PaintCommand
