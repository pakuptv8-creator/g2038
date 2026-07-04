local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["HandItem/bagWin"] = function()
  UI:openWnd("g2052Bag")
end
local GenBuffFileHelper = T(Lib, "GenBuffFileHelper")
GMItem["HandItem/GenBuffFile"] = function()
  GenBuffFileHelper:GenBuffFiles()
end

local function createPart(position, shapeType, sizeScale, propertyList)
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(Me.map.obj)
  manager:setCurScene(scene)
  local part = Instance.Create("Part")
  part:setSize(sizeScale)
  part:setShape(shapeType)
  for k, v in pairs(propertyList or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  part:setPosition(position)
  part:setRotation(Me:getRotation())
  return part
end

local function getTargetPos(position, from)
  local yaw = (360 - from:getRotationYaw() + 90) % 360
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

local xRate = 1
local yRate = 1
local zRate = 1
local pPart2
GMItem["HandItem/\231\148\159\230\136\144\231\175\174\231\144\131"] = function(self)
  local pos = Me:getPosition()
  local part2 = createPart({
    x = pos.x,
    y = pos.y + 2.2,
    z = pos.z
  }, 2, Lib.v3(0.5, 0.5, 0.5), {})
  part2:setProperty("density", 0)
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
  force:setParent(part2)
  force:setDebugGraphShow(true)
  pPart2 = part2
end
GMItem["HandItem/\230\137\148\229\135\186\231\175\174\231\144\131"] = function(self)
  if pPart2 then
    pPart2:setProperty("density", 0.1)
    pPart2:setProperty("restitution", 2.5)
    local targetPos = getTargetPos({
      x = 0,
      y = 10,
      z = 5
    }, Me)
    local velocityDir = targetPos - pPart2:getPosition()
    pPart2:setLineVelocity(Lib.v3(0.1, 0.1, 0.1))
    pPart2:applyForce(1.5 * velocityDir:normalize(), Lib.v3(0, 0, 0))
  end
end

local function GetDir(p)
  local yaw = -(p:getRotationYaw() + 90)
  local q = Quaternion.rotateAxis(Lib.v3(0, 1, 0), yaw)
  local dir = q * Lib.v3(1, 0, 0)
  return dir
end

local function GetDivingForceMoveMotion(p)
  local offSpeed = 20
  local ret = Lib.v3multip(GetDir(p), offSpeed / 20)
  return ret
end

local N = false
GMItem["HandItem/DEBUG1"] = function(self)
  N = not N
  local fovAngle = N and 10 or 75
  Me:ForceEnableFakeFirstView(N)
  Blockman.instance:setViewFovAngle(fovAngle)
end
GMItem["HandItem/DEBUG2"] = function(self)
  local skins = Me:data("skins")
  local gun = skins.gun
  print("----------gun: = " .. tostring(gun))
  Me:applySkin({gun = ""})
end
