local CarConfig = T(Config, "CarConfig")
local CommandBase = require("server.operation.command_base")
local HonkCommand = class("HonkCommand", CommandBase)

function HonkCommand:ctor(car)
  HonkCommand.super.ctor(self, car)
  self.act = "honk"
end

function HonkCommand:execute(params, player)
  local pos = self.car:getPosition()
  local carName = self.car:getName()
  player:addBuff("myplugin/car_honk_buff", 20)
end

function HonkCommand:undo()
end

return HonkCommand
