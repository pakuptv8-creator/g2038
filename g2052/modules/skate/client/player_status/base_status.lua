local SkateControlType = Define.SkateControlType
local BaseStatus = class("BaseStatus")
local SoundManager = T(Lib, "SoundManager")

function BaseStatus:ctor(statusName, skateCfg)
  self.statusName = statusName
  self.skateCfg = skateCfg
  local SkateMgr = T(Lib, "SkateMgr")
  self.skateEntity = SkateMgr:getSkateEntity()
  self.eventList = {}
  self.dragVct = Vector2.new(0, 0)
end

function BaseStatus:onEnter()
end

function BaseStatus:onUpdate()
end

function BaseStatus:onExit()
end

function BaseStatus:playSound(key)
end

function BaseStatus:stopSound()
end

function BaseStatus:isSameStatus(statusName)
  return self.statusName == statusName
end

function BaseStatus:dctor()
  for _, event in pairs(self.eventList) do
    event()
  end
  self.eventList = {}
end

function BaseStatus:getControlType(poleForward, poleStrafe, forward, left)
  local controlType = SkateControlType.Idle
  if poleForward ~= 0 or poleStrafe ~= 0 then
    self.dragVct.x = poleStrafe
    self.dragVct.y = poleForward
    local angle = math.atan(self.dragVct.y, -self.dragVct.x) * 180 / math.pi
    if angle <= -60 and -120 <= angle then
      controlType = SkateControlType.Stop
    elseif 60 <= angle and angle <= 120 then
      controlType = SkateControlType.ForwardAcc
    elseif 120 < angle and angle < 180 or angle < -120 and -180 <= angle then
      controlType = SkateControlType.TurnLeft
    elseif angle < 60 and 0 < angle or angle <= 0 and -60 <= angle then
      controlType = SkateControlType.TurnRight
    end
  elseif 0 < left then
    controlType = SkateControlType.TurnLeft
  elseif left < 0 then
    controlType = SkateControlType.TurnRight
  elseif 0 < forward then
    controlType = SkateControlType.ForwardAcc
  elseif forward < 0 then
    controlType = SkateControlType.Stop
  end
  return controlType
end

return BaseStatus
