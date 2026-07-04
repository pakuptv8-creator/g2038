local PropsConfig = T(Config, "PropsConfig")
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local Player = _ENV.Player
local curTick = 0
Lib.subscribeEvent(Event.EVENT_CLICK_SCREEN, function(pos)
  Me:onClickScreen(pos)
end)
Lib.lightSubscribeEvent("error!!!!! : Interact lib event : EVENT_CLIENT_HANDLE_TICK", Event.EVENT_CLIENT_HANDLE_TICK, function()
  curTick = curTick + 1
end)

local function createPart(cfg)
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(Me.map.obj)
  manager:setCurScene(scene)
  local part = Instance.Create("Part")
  part:setSize(cfg.properties.scale)
  part:setShape(cfg.properties.shape)
  for k, v in pairs(cfg.properties or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  return part
end

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

function Player:onClickScreen(pos)
  local inUseItem = self:getInUseProp()
  if not inUseItem then
    return
  end
  local cfg = PropsConfig:getCfgById(inUseItem.itemId)
  if not cfg or cfg.throwTrigger ~= Define.ThrowObjTrigger.click then
    return
  end
  if cfg.isThrowObj == Define.ThrowObjType.Basketball then
    if self.rideOnId and self.rideOnId > 0 then
      return
    end
    if self.lastPlayBasketballTime and curTick - self.lastPlayBasketballTime <= self:cfg().playBasketballCD then
      return
    end
    Plugins.CallTargetPluginFunc("interaction_ui", "stopDanceAction", true)
    self.lastPlayBasketballTime = curTick
    Me:sendPacket({
      pid = "tryPlayBasketball",
      objID = Me.objID,
      pos = pos
    })
  elseif cfg.isThrowObj == Define.ThrowObjType.GoldCoin then
    if self.lastWishGoldCoinTime and curTick - self.lastWishGoldCoinTime <= self:cfg().wishGoldCoinCD then
      return
    end
    Plugins.CallTargetPluginFunc("interaction_ui", "stopDanceAction", true)
    self.lastWishGoldCoinTime = curTick
    local _desktop = GUISystem.instance:GetRootWindow()
    local mid_x = _desktop:GetPixelSize().x / 2
    local mid_y = _desktop:GetPixelSize().y / 2
    local offX = pos.x - mid_x
    local offY = pos.y - mid_y
    local angle = math.atan(offY, offX) * 180 / math.pi
    local dis = math.sqrt(offX * offX + offY * offY)
    local maxDis = mid_y
    Me:sendPacket({
      pid = "ThrowWishGoldCoin",
      objID = Me.objID,
      angle = angle,
      dis = dis,
      maxDis = maxDis
    })
  end
end
