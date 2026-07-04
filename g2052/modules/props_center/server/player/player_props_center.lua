local Player = _ENV.Player
local PropsConfig = T(Config, "PropsConfig")
local setting = require("common.setting")
local PartCfg = setting:mod("part")

local function getTargetPos(position, yawOffset, from)
  local fromYaw = from:getRotationYaw() - yawOffset
  local yaw = (360 - fromYaw + 90) % 360
  local pos = Lib.tov3(Lib.copy(position))
  local new_off_x, new_off_y = pos.x, pos.z
  local arc1 = math.atan(new_off_y, -new_off_x)
  local deg1 = math.deg(arc1)
  local deg2 = yaw - (360 - deg1 + 90) % 360
  local arc2 = math.rad(deg2)
  local len = (new_off_x ^ 2 + new_off_y ^ 2) ^ 0.5
  local offx = len * math.cos(arc2)
  local offy = len * math.sin(arc2)
  pos.x = -offx
  pos.z = offy
  local targrtpos = from:getPosition() + pos
  return targrtpos
end

function Player:throwWishGoldCoin(part, dis, maxDis, angle)
  local cfg = PartCfg:get("myplugin/gold_coin")
  if part then
    part:setProperty("density", cfg.properties.density or 0.1)
    local throwAngle = math.abs(angle)
    local minAngle = self:cfg().goldCoinAngleLimit[1] or 30
    local maxAngle = self:cfg().goldCoinAngleLimit[2] or 150
    if throwAngle < minAngle then
      throwAngle = minAngle
    elseif maxAngle < throwAngle then
      throwAngle = maxAngle
    end
    local yaw = throwAngle - 90
    local targetPos = getTargetPos({
      x = 0,
      y = 7,
      z = 5
    }, yaw, self)
    local velocityDir = targetPos - part:getPosition()
    local rate = 1 < dis / maxDis and 1 or dis / maxDis
    local backForceRate = 1
    if 0 < angle then
      backForceRate = self:cfg().backForceRate or 1
    end
    local MaxForce = self:cfg().goldCoinMaxForce or 2
    local MinForce = self:cfg().goldCoinMinForce or 0.2
    local throwForce = MaxForce * rate * backForceRate
    if MinForce > throwForce then
      throwForce = MinForce
    end
    local goldTorque = self:cfg().goldTorque
    local torque = Lib.v3(goldTorque.x, goldTorque.y, goldTorque.z)
    part:applyForce(throwForce * velocityDir:normalize(), torque)
  end
end

function Player:tryTriggerItemUseEvent(inUseItem)
  if not inUseItem or not inUseItem.itemId then
    self:updateBillboardUIShow(false)
    return
  end
  local cfg = PropsConfig:getCfgById(inUseItem.itemId)
  if not cfg then
    return
  end
  if cfg.isThrowObj == Define.ThrowObjType.Billboard then
    self:updateBillboardUIShow(true)
  else
    self:updateBillboardUIShow(false)
  end
end

function Player:updateBillboardUIShow(isShow)
  local billboardState = self:getBillboardState()
  if isShow then
    if not billboardState then
      self:setBillboardState(true)
    end
  elseif billboardState then
    self:setBillboardState(false)
  end
end

function Player:doReceivePropAction(itemId, fromUserId, receiveTips)
  local from = Game.GetPlayerByUserId(fromUserId)
  if from and from:isValid() then
    self:onReceiveProp(itemId)
    if receiveTips then
      self:sendPacket({
        pid = "receivePropSucceed",
        itemId = itemId,
        fromId = from.objID,
        fromUserId = from.platformUserId
      })
    end
    from:onSendProp(itemId, self.platformUserId)
    from:sendPacket({
      pid = "givePropSucceed",
      itemId = itemId,
      targetId = self.objID,
      targetUserId = self.platformUserId
    })
  end
end
