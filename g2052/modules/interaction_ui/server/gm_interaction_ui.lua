local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\228\186\164\228\186\146/yaw-self"] = function(self)
  self:setRotationYaw(150)
end
GMItem["\228\186\164\228\186\146/yaw_car"] = function(self)
  if self.rideOnId > 0 then
    local target = World.CurWorld:getEntity(self.rideOnId)
    target:setRotationYaw(20)
  else
    self:setRotationYaw(150)
  end
end
GMItem["\228\186\164\228\186\146/pos-self"] = function(self)
  local nowPos = self:getPosition()
  self:setPos({
    x = nowPos.x + 2,
    y = nowPos.y,
    z = nowPos.z
  }, 20, nil, true)
end
GMItem["\228\186\164\228\186\146/pos-car"] = function(self)
  if self.rideOnId > 0 then
    local target = World.CurWorld:getEntity(self.rideOnId)
    local nowPos = target:getPosition()
    target:setPos({
      x = nowPos.x + 2,
      y = nowPos.y,
      z = nowPos.z
    }, -90, nil, true)
  else
    local nowPos = self:getPosition()
    self:setPos({
      x = nowPos.x + 2,
      y = nowPos.y,
      z = nowPos.z
    }, -90, nil, true)
  end
end
GMItem["\228\186\164\228\186\146/pos-car2"] = function(self)
  if self.rideOnId > 0 then
    local target = World.CurWorld:getEntity(self.rideOnId)
    local nowPos = target:getPosition()
    target:setPos({
      x = 86.17,
      y = 25.84,
      z = -118.9
    }, -90, nil, true)
  else
    local nowPos = self:getPosition()
    self:setPos({
      x = 86.17,
      y = 25.84,
      z = -118.9
    }, -90, nil, true)
  end
end
