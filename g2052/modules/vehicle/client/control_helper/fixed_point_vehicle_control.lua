local FixedPointVehicleControl = T(Lib, "FixedPointVehicleControl")
local bm = Blockman.Instance()

local function axisValue(forward, back)
  local value = 0.0
  if bm:isKeyPressing(forward) then
    value = value + 1
  end
  if bm:isKeyPressing(back) then
    value = value - 1
  end
  return value
end

function FixedPointVehicleControl:init(target, cfg)
  self.car = nil
  if self.controlTick then
    self.controlTick()
    self.controlTick = nil
  end
  if target and target:isValid() then
    self.car = target
  end
  if self.car then
    self.initRotation = self.car:getRotation()
    self.params = cfg.params or {}
    self.controlTick = World.Timer(1, function()
      return self:updateCarRotate()
    end)
  end
end

local function verifyAxisKey(axisKey)
  local v = "z"
  if axisKey == "x" or axisKey == "y" then
    v = axisKey
  end
  return v
end

function FixedPointVehicleControl:updateCarRotate()
  if self.car and self.car:isValid() then
    local offset = Blockman.instance.gameSettings.poleStrafe + axisValue("key.left", "key.right") + axisValue("key.top.left", "key.top.right")
    local curRotation = self.car:getRotation()
    local axisKey = verifyAxisKey(self.params[6])
    local velocity = tonumber(self.params[4]) or 1
    local targetRotation = Lib.v3(curRotation.x, curRotation.y, curRotation.z)
    if offset ~= 0 then
      offset = offset * velocity
      local initAngle = self.initRotation[axisKey]
      local totalOffset = curRotation[axisKey] - offset - initAngle
      local maxAngle = tonumber(self.params[3]) or 30
      if maxAngle < math.abs(totalOffset) then
        totalOffset = totalOffset / math.abs(totalOffset) * maxAngle
      end
      targetRotation[axisKey] = totalOffset
      self.car:setRotation(targetRotation)
    elseif self.initRotation ~= curRotation then
      local offsetPos = self.initRotation - curRotation
      if math.abs(offsetPos[axisKey]) < math.abs(velocity) then
        self.car:setRotation(self.initRotation)
      else
        local totalOffset = offsetPos[axisKey] / math.abs(offsetPos[axisKey]) * velocity
        targetRotation[axisKey] = targetRotation[axisKey] + totalOffset
        self.car:setRotation(targetRotation)
      end
    end
    return true
  end
  return false
end

function FixedPointVehicleControl:stop()
  if self.controlTick then
    self.controlTick()
    self.controlTick = nil
  end
  if self.car and self.car:isValid() then
    self.car:setRotation(self.initRotation)
  end
  self.car = nil
  self.initRotation = nil
  self.params = nil
end

return FixedPointVehicleControl
