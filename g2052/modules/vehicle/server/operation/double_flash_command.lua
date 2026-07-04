local CommandBase = require("server.operation.command_base")
local DoubleFlashCommand = class("DoubleFlashCommand", CommandBase)

function DoubleFlashCommand:ctor(car)
  DoubleFlashCommand.super.ctor(self, car)
  self.act = "doubleFlash"
end

function DoubleFlashCommand:execute(params, player)
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    if string.match(child:getName(), "flashinglight") then
      child.visible = true
    end
  end
  player:addBuff("myplugin/car_double_flash_buff")
  self.isActive = true
end

function DoubleFlashCommand:undo(player)
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    if string.match(child:getName(), "flashinglight") then
      child.visible = false
    end
  end
  player:removeTypeBuff("fullName", "myplugin/car_double_flash_buff")
  self.isActive = false
end

function DoubleFlashCommand:playSoundForDriver(player)
  if player and player:isValid() then
    player:addBuff("myplugin/car_double_flash_buff")
  end
end

return DoubleFlashCommand
