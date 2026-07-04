local Player = _ENV.Player
local engineSceneManager = EngineSceneManager.Instance()
Lib.subscribeEvent(Event.EVENT_ON_GROUND, function(self)
  if self.divingInfo then
    local underfootObjId = self:getCollidableUnderfootInstanceId()
    local underfootObj = Instance.getByInstanceId(underfootObjId)
    local divingPart = self.divingInfo.part
    local partProp = divingPart.properties
    if partProp == nil then
      self:clearDivingInfo()
      return
    end
    if underfootObj and tonumber(partProp.id) ~= underfootObjId then
      self:clearDivingInfo()
      return
    end
  end
end)

function Player:clearDivingInfo()
  if self.divingInfo then
    self:setProp("jumpSpeed", self.divingInfo.cacheJumpSpeed)
  end
  self:sendPacket({
    pid = "finishDivingForceMove"
  })
  self.divingInfo = nil
end

local function ParseDivingJumpSpeed(s)
  local ret = {}
  local l = Lib.split(s, "#")
  if #l == 0 then
    ret[1] = 1
    return ret
  end
  for _, ss in pairs(l) do
    table.insert(ret, tonumber(ss))
  end
  return ret
end

function Player:tryDiving(type, part, params)
  if self:isRideOnState() then
    return
  end
  if not self.divingInfo then
    self.divingInfo = {
      part = part,
      count = 0,
      cacheJumpSpeed = self:prop("jumpSpeed"),
      cfg = {
        forceOffSpeed = tonumber(params[1]) or 1,
        jumpSpeed = ParseDivingJumpSpeed(params[2])
      }
    }
  end
  self:diving()
end

local function GetDir(p)
  local yaw = -(p:getRotationYaw() + 90)
  local q = Quaternion.rotateAxis(Lib.v3(0, 1, 0), yaw)
  local dir = q * Lib.v3(1, 0, 0)
  return dir
end

local function GetDivingForceMoveMotion(p)
  local offSpeed = p.divingInfo.cfg.forceOffSpeed
  local ret = Lib.v3multip(GetDir(p), offSpeed / 20)
  return ret
end

function Player:diving()
  if not self.divingInfo then
    return
  end
  local jumpSpeedDic = self.divingInfo.cfg.jumpSpeed
  local maxCount = #jumpSpeedDic
  self.divingInfo.count = math.min(self.divingInfo.count + 1, maxCount)
  local sp = jumpSpeedDic[self.divingInfo.count]
  self:setProp("jumpSpeed", sp)
  local pos = self:getPosition()
  self:jump(pos.x, pos.z)
  if maxCount <= self.divingInfo.count then
    local motion = GetDivingForceMoveMotion(self)
    self:sendPacket({
      pid = "startDivingForceMove",
      motion = motion
    })
    self.divingInfo.count = 0
  end
  self:sendPacket({
    pid = "divingFromServer"
  })
end

function Player:onControlArea3dSound(type, target, params)
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    if params[1] ~= "" then
      local pos = target:getPosition()
      local offset = Lib.v3(0, 0, 0)
      if params[2] ~= "" then
        offset = Lib.createV3ByString(params[2])
      end
      pos = pos + offset
      local time = params[3] ~= "" and tonumber(params[3])
      self:sendPacket({
        pid = "Play3dSoundByKey",
        params = {
          key = params[1],
          pos = pos,
          time = time
        }
      })
    end
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    self:sendPacket({
      pid = "StopAll3dSound"
    })
  end
end

function Player:operatePointLight(type, target, params)
end
