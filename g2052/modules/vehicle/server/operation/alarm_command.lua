local CommandBase = require("server.operation.command_base")
local AlarmCommand = class("AlarmCommand", CommandBase)

function AlarmCommand:ctor(car)
  AlarmCommand.super.ctor(self, car)
  self.act = "alarm"
end

function AlarmCommand:execute(params, player)
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    local name = child:getName()
    if name == "effect_jingbaodeng" then
      child.visible = true
    elseif name == "jingbaoyinxiao" then
      local count = child:getChildrenCount()
      for i = 0, count - 1 do
        local sub = child:getChildAt(i)
        if sub:getTypeName() == "AudioNode" then
          sub:playAudio()
        end
      end
    end
  end
  self.isActive = true
end

function AlarmCommand:undo(player)
  print("close alarm")
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    local name = child:getName()
    if name == "effect_jingbaodeng" then
      child.visible = false
    elseif name == "jingbaoyinxiao" then
      local count = child:getChildrenCount()
      for i = 0, count - 1 do
        local sub = child:getChildAt(i)
        if sub:getTypeName() == "AudioNode" then
          sub:stopAudio()
        end
      end
    end
  end
  self.isActive = false
end

function AlarmCommand:playSoundForDriver(player)
end

return AlarmCommand
