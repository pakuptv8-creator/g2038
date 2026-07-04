local setting = require("common.setting")
local PartCfg = setting:mod("part")
local PropsConfig = T(Config, "PropsConfig")

local function createPart(cfg, entity)
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(entity and entity.map and entity.map.obj or Me.map.obj)
  manager:setCurScene(scene)
  local part = Instance.Create(cfg.class)
  part:setSize(cfg.properties.scale)
  for k, v in pairs(cfg.properties or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  return part
end

local function getTargetPos(position, yawOffset, from)
  if not from or not from:isValid() then
    return Lib.v3(0, 0, 0)
  end
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

function Entity:doPlayBasketball(pos, itemId)
  local _desktop = GUISystem.instance:GetRootWindow()
  local mid_x = _desktop:GetPixelSize().x / 2
  local mid_y = _desktop:GetPixelSize().y / 2
  local offX = pos.x - mid_x
  local offY = pos.y - mid_y
  local angle1 = math.atan(offY, offX) * 180 / math.pi
  local dis = math.sqrt(offX * offX + offY * offY)
  local maxDis = mid_y
  if self.curBasketBallCount and self.curBasketBallCount >= (self:cfg().maxBasketBallCount or 2) then
    return
  end
  if not self.curBasketBallCount then
    self.curBasketBallCount = 0
  end
  if self:cfg().throwBasketBallAction then
    self:playClientAction(self:cfg().throwBasketBallAction, self:cfg().throwBasketBallActionTime, false)
  end
  World.Timer(10, function()
    if self and self:isValid() then
      self:playBasketball(dis, maxDis, angle1, itemId)
    end
  end)
  local actionTime = (self:getUpperActionTicks(self:cfg().throwBasketBallAction) or self:cfg().throwBasketBallActionTime) - 1
  if 0 < actionTime then
    World.Timer(actionTime, function()
      if self and self:isValid() then
        local InteractionHelper = T(Lib, "InteractionHelper")
        InteractionHelper:updateEntityActionShow(self.objID)
      end
    end)
  end
end

function Entity:playBasketball(dis, maxDis, angle, itemId)
  local propCfg = PropsConfig:getCfgById(itemId)
  if not propCfg or propCfg.isThrowObj ~= Define.ThrowObjType.Basketball then
    return
  end
  local cfg = PartCfg:get(propCfg.throwCfgName)
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local part = Instance.newInstance(cfg, self.map)
  if part then
    part:setParent(scene:getRoot())
    part:setUseCollide(false)
    local partPos = self:getFrontPos(1, true, false) + {
      x = 0,
      y = 2,
      z = 0
    }
    part:setPosition(partPos)
    self.curBasketBallCount = self.curBasketBallCount + 1
    World.Timer(2, function()
      if not self or not self:isValid() then
        return
      end
      part:setUseCollide(true)
      local throwAngle = math.abs(angle)
      local minAngle = self:cfg().basketBallAngleLimit[1] or 30
      local maxAngle = self:cfg().basketBallAngleLimit[2] or 150
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
      local MaxForce = self:cfg().basketBallMaxForce or 2
      local MinForce = self:cfg().basketBallMinForce or 0.2
      local throwForce = MaxForce * rate * backForceRate
      if MinForce > throwForce then
        throwForce = MinForce
      end
      local force = Instance.Create("Force")
      force:setProperty("relativeForce", {
        x = 0,
        y = 1,
        z = 5
      })
      force:setProperty("force", {
        x = 0,
        y = 1,
        z = 5
      })
      force:setProperty("useRelativeForce", "true")
      force:setParent(part)
      part:applyForce(throwForce * velocityDir:normalize(), Lib.v3(0, 0, 0))
    end)
    World.Timer(self:cfg().basketBallLifeTime or 100, function()
      if part and part:isValid() then
        part:destroy()
        self.curBasketBallCount = self.curBasketBallCount - 1
        if self.curBasketBallCount < 0 then
          self.curBasketBallCount = 0
        end
      end
    end)
  end
end
