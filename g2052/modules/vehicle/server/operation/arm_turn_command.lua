local VehicleManager = T(Lib, "VehicleManager")
local CommandBase = require("server.operation.command_base")
local ArmTurnCommand = class("ArmTurnCommand", CommandBase)

function ArmTurnCommand:ctor(car)
  ArmTurnCommand.super.ctor(self, car)
end

function ArmTurnCommand:execute(params, player)
  self.isActive = true
end

function ArmTurnCommand:undo()
  self.isActive = false
end

return ArmTurnCommand
