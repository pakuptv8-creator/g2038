local CommandBase = require("server.operation.command_base")
local HeadlightCommand = class("HeadlightCommand", CommandBase)

function HeadlightCommand:ctor(car)
  HeadlightCommand.super.ctor(self, car)
  self.act = "headlight"
end

function HeadlightCommand:execute()
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    if string.match(child:getName(), "headlight") then
      child.visible = true
    end
  end
  self.isActive = true
end

function HeadlightCommand:undo()
  local count = self.car:getChildrenCount()
  for i = 0, count - 1 do
    local child = self.car:getChildAt(i)
    if string.match(child:getName(), "headlight") then
      child.visible = false
    end
  end
  self.isActive = false
end

return HeadlightCommand
