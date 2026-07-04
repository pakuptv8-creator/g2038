local CommandBase = require("server.operation.command_base")
local FirstAidCommand = class("FirstAidCommand", CommandBase)

function FirstAidCommand:ctor(car)
  FirstAidCommand.super.ctor(self, car)
  self.act = "firstAid"
end

function FirstAidCommand:execute(params, player)
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    if string.match(child:getName(), "effect_jingbaodeng") then
      child.visible = true
    end
  end
  player:addBuff("myplugin/car_first_aid_buff")
  self.isActive = true
end

function FirstAidCommand:undo(player)
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    if string.match(child:getName(), "effect_jingbaodeng") then
      child.visible = false
    end
  end
  player:removeTypeBuff("fullName", "myplugin/car_first_aid_buff")
  self.isActive = false
end

function FirstAidCommand:playSoundForDriver(player)
  if player and player:isValid() then
    player:addBuff("myplugin/car_first_aid_buff")
  end
end

return FirstAidCommand
