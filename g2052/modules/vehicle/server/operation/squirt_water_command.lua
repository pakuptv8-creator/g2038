local CommandBase = require("server.operation.command_base")
local SquirtWaterCommand = class("SquirtWaterCommand", CommandBase)
local LuaTimer = T(Lib, "LuaTimer")

function SquirtWaterCommand:ctor(car)
  SquirtWaterCommand.super.ctor(self, car)
  self.act = "squirtWater"
end

function SquirtWaterCommand:execute(params, player)
  local count = self.car:getChildrenCount()
  local len = count - 1
  local part
  for i = 0, len do
    local child = self.car:getChildAt(i)
    local cnt = child:getChildrenCount()
    if 0 < cnt then
      local l = cnt - 1
      for j = 0, l do
        local secChild = child:getChildAt(j)
        if string.match(secChild:getName(), "carsashui") then
          secChild.visible = true
          part = secChild
        end
      end
    elseif string.match(child:getName(), "carsashui") then
      child.visible = true
      part = child
    end
  end
  if self.putOutFireTimer then
    LuaTimer:cancel(self.putOutFireTimer)
    self.putOutFireTimer = nil
  end
  if part then
    self.putOutFireTimer = LuaTimer:schedule(function()
      if not (part and part:isValid() and player) or not player:isValid() then
        LuaTimer:cancel(self.putOutFireTimer)
        self.putOutFireTimer = nil
        return
      end
      player:PutOutFire({
        obj1 = part,
        fullName = "myplugin/extinguish_fire_click"
      }, 10, 3, 10, 10)
    end, 0, 1000)
  end
  self.isActive = true
end

function SquirtWaterCommand:undo(player)
  local count = self.car:getChildrenCount()
  local len = count - 1
  for i = 0, len do
    local child = self.car:getChildAt(i)
    local cnt = child:getChildrenCount()
    if 0 < cnt then
      local l = cnt - 1
      for j = 0, l do
        local secChild = child:getChildAt(j)
        if string.match(secChild:getName(), "carsashui") then
          secChild.visible = false
        end
      end
    elseif string.match(child:getName(), "carsashui") then
      child.visible = false
    end
  end
  self.isActive = false
  if self.putOutFireTimer then
    LuaTimer:cancel(self.putOutFireTimer)
    self.putOutFireTimer = nil
  end
end

function SquirtWaterCommand:playSoundForDriver(player)
  if not player or player:isValid() then
  end
end

return SquirtWaterCommand
