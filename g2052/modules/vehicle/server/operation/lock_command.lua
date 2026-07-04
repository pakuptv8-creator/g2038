local VehicleManager = T(Lib, "VehicleManager")
local CommandBase = require("server.operation.command_base")
local LockCommand = class("LockCommand", CommandBase)

function LockCommand:ctor(car)
  LockCommand.super.ctor(self, car)
end

function LockCommand:execute(params, player)
  VehicleManager:clearRide(self.car, {
    player:getInstanceID()
  })
  self.isActive = true
end

function LockCommand:undo()
  self.isActive = false
end

return LockCommand
