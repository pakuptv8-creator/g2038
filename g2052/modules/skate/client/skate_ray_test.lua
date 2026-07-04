local SkateRayTest = T(Lib, "SkateRayTest")
local SkateMapObject = T(Lib, "SkateMapObject")
local PartType = Define.PartType
local AutoRotateType = {Left = 1, Right = 2}

function SkateRayTest:init()
  local SkateMgr = T(Lib, "SkateMgr")
  self.skateEntity = SkateMgr:getSkateEntity()
  self.downVct = Vector3.new(0, -1, 0)
  self.upVct = Vector3.new(0, 1, 0)
  self.forwardVct = Vector3.new(0, 0, 1)
  self.xVct = Vector3.new(1, 0, 0)
  self.rayOffset = Vector3.new(0, 1, 0)
  self.eyeHeight = self.skateEntity:prop("eyeHeight")
  self.lockRotateDirFrame = 30
  self.curRotateDirFrame = 0
  self.curAutoRotateType = nil
  self.checkFootPitchPartId = nil
end

function SkateRayTest:checkFootCollision()
  local world = World.CurMap:getPhysicsWorld()
  local curPos = self.skateEntity:getPosition()
  local point = curPos + self.rayOffset
  local collisionResult, objectType
  local result = world:raycast(point, self.downVct, 2, 1)
  local pitch
  if result and result.normalOnHitObject then
    local oType = self:getHitObjectType(result.target)
    if oType == PartType.Jump or oType == PartType.Box then
      objectType = oType
      collisionResult = result
      pitch = self:calcPitch(result)
    else
      pitch = 0
    end
  else
    pitch = 0
  end
  local data = {
    objectType = objectType,
    result = collisionResult,
    pitch = pitch
  }
  return data
end

function SkateRayTest:calcPitch(collisionResult)
  local pitch = 0
  local normal = collisionResult.normalOnHitObject
  local rotate = collisionResult.target:getRotation()
  local q = Quaternion.fromEulerAngle(rotate.x, rotate.y, rotate.z)
  local scale = collisionResult.target:getScale()
  local dir = self.xVct
  if scale.x < scale.z then
    dir = self.forwardVct
  end
  local wdir = q * dir
  local dot = Lib.v3Dot(wdir, Lib.v3(wdir.x, 0, wdir.z):normalize())
  if 0 < dot then
    dot = math.min(dot, 1)
  else
    dot = math.max(dot, -1)
  end
  pitch = math.acos(dot) * 180 / math.pi
  local frontPos = self.skateEntity:getFrontPos(1, true)
  local slopeAngle = Vector3.angle(normal, frontPos - self.skateEntity:getPosition()) * 180 / math.pi
  if 90 < slopeAngle then
    pitch = -pitch
  end
  return pitch
end

function SkateRayTest:checkHeadCollision()
  local world = World.CurMap:getPhysicsWorld()
  local curPos = self.skateEntity:getPosition()
  curPos.y = curPos.y + self.eyeHeight
  local radius = 0.3
  local points = {
    Lib.v3(curPos.x + radius, curPos.y, curPos.z),
    Lib.v3(curPos.x - radius, curPos.y, curPos.z),
    Lib.v3(curPos.x, curPos.y, curPos.z + radius),
    Lib.v3(curPos.x, curPos.y, curPos.z - radius),
    Lib.v3(curPos.x, curPos.y, curPos.z)
  }
  for i, pos in pairs(points) do
    local result = world:raycast(pos, self.upVct, 0.1, 1)
    if result and result.normalOnHitObject then
      return true
    end
  end
end

function SkateRayTest:autoRotateForwardDir()
  local world = World.CurMap:getPhysicsWorld()
  local curPos = self.skateEntity:getPosition()
  local frontPos = self.skateEntity:getFrontPos(0.5, true)
  local frontDir = frontPos - curPos
  curPos.y = curPos.y + self.eyeHeight
  local result = world:raycast(curPos, frontDir, 1, 1)
  if result and result.normalOnHitObject and not result.target.isPlayer then
    local slopeAngle = Vector3.angle(result.normalOnHitObject, frontDir) * 180 / math.pi
    if 90 < slopeAngle then
      local curYaw = self.skateEntity:getRotationYaw()
      if self.curRotateDirFrame > self.lockRotateDirFrame then
        local cross = frontDir:cross(result.normalOnHitObject)
        if cross.y > 0 then
          self.curAutoRotateType = AutoRotateType.Left
          self.curRotateDirFrame = 1
        else
          self.curAutoRotateType = AutoRotateType.Right
          self.curRotateDirFrame = 1
        end
      else
        self.curRotateDirFrame = self.curRotateDirFrame + 1
      end
      if self.curAutoRotateType == AutoRotateType.Left then
        self.skateEntity:setRotationYaw(curYaw - 10)
      else
        self.skateEntity:setRotationYaw(curYaw + 10)
      end
    else
      self.curAutoRotateType = nil
    end
  else
    self.curAutoRotateType = nil
  end
end

function SkateRayTest:checkForwardHit()
  local curPos = self.skateEntity:getPosition()
  local frontPos = self.skateEntity:getFrontPos(1, true)
  local dir = (frontPos - curPos):normalize()
  curPos.y = curPos.y + 1
  local world = World.CurMap:getPhysicsWorld()
  local result = world:raycast(curPos, dir, 1, 1)
  if result and result.normalOnHitObject and result.target then
    return result.target.useCollide
  end
  return false
end

function SkateRayTest:checkRightHit()
  local world = World.CurMap:getPhysicsWorld()
  local curPos = self.skateEntity:getPosition()
  local frontPos = self.skateEntity:getFrontPos(1, true)
  local dir = frontPos - curPos
  local q = Quaternion.fromEulerAngle(0, 90, 0)
  dir = q * dir
  local result = world:raycast(curPos, dir, 0.5, 1)
  if result and result.normalOnHitObject then
    return true
  end
  return false
end

function SkateRayTest:checkLeftHit()
  local world = World.CurMap:getPhysicsWorld()
  local curPos = self.skateEntity:getPosition()
  local frontPos = self.skateEntity:getFrontPos(1, true)
  local dir = frontPos - curPos
  local q = Quaternion.fromEulerAngle(0, -90, 0)
  dir = q * dir
  local result = world:raycast(curPos, dir, 0.5, 1)
  if result and result.normalOnHitObject then
    return true
  end
  return false
end

function SkateRayTest:getHitObjectType(target)
  local targetName = target.name
  local objectType = SkateMapObject:getObjectType(targetName)
  if not objectType then
    local str = Lib.split(targetName, "_")
    objectType = SkateMapObject:recordPart(targetName, str[1])
  end
  return objectType
end

function SkateRayTest:unInit()
end
