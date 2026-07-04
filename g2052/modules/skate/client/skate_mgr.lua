local SkateMgr = T(Lib, "SkateMgr")
local SkateRayTest = T(Lib, "SkateRayTest")
local SkateControl = T(Lib, "SkateControl")
local SkateConfig = T(Config, "SkateConfig")
local StatusController = T(Lib, "StatusController")
local SkateAnimMgr = T(Lib, "SkateAnimMgr")

function SkateMgr:enterSkateMode(skateObjID, isMoving)
  local skateInfo = Me:getInUseCar()
  if not skateInfo then
    return
  end
  local skateCfg = SkateConfig:getCfgById(skateInfo.id)
  if not skateCfg then
    return
  end
  local skateEntity = World.CurWorld:getEntity(skateObjID)
  if skateEntity then
    Lib.logDebug("enterSkateMode ")
    self.skateEntity = skateEntity
    SkateControl:init(skateCfg)
    SkateAnimMgr:init(skateCfg, skateEntity)
    SkateRayTest:init(skateEntity)
    StatusController:init(skateCfg)
    StatusController:setStatus(Define.SkateStatus.Idle)
    self.inSkateMode = true
    if Blockman.instance:isKeyPressing("key.jump") then
      Blockman.instance:setKeyPressing("key.jump", false)
      Lib.emitEvent(Event.SET_JUMP_CHARGE, true)
    end
  end
end

function SkateMgr:getSkateEntity()
  return self.skateEntity
end

function SkateMgr:leaveSkateMode()
  Lib.logWarning("leaveSkateMode  ")
  self.inSkateMode = false
  StatusController:unInit()
  SkateControl:unInit()
  SkateRayTest:unInit()
  SkateAnimMgr:unInit()
  self.skateEntity = nil
end

function SkateMgr:isSkateMode()
  return self.inSkateMode
end

function SkateMgr:isSkateOnGround()
  if self.skateEntity and self.skateEntity:isValid() and self.skateEntity.onGround then
    return true
  end
end

function SkateMgr:isCanLeaveSkateMode()
  if self.skateEntity then
    if not self.skateEntity.onGround then
      return false
    elseif StatusController:isStatus(Define.SkateStatus.StepOn) or StatusController:isStatus(Define.SkateStatus.StepDown) or StatusController:isStatus(Define.SkateStatus.Jump) or StatusController:isStatus(Define.SkateStatus.Charge) then
      return false
    end
    return true
  else
    return true
  end
end

return SkateMgr
