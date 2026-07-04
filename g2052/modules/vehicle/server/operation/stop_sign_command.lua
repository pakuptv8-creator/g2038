local VehicleManager = T(Lib, "VehicleManager")
local CommandBase = require("server.operation.command_base")
local StopSignCommand = class("StopSignCommand", CommandBase)

function StopSignCommand:ctor(car)
  StopSignCommand.super.ctor(self, car)
end

function StopSignCommand:execute(params, player)
  self.isActive = true
end

function StopSignCommand:undo()
  self.isActive = false
end

return StopSignCommand
