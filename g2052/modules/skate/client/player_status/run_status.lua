local BaseStatus = require("client.player_status.base_status")
local RunStatus = class("RunStatus", BaseStatus)
local SkateControl = T(Lib, "SkateControl")
local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local SkateControlType = Define.SkateControlType
local skateSetting = World.cfg.skateSetting
local SkateStatus = Define.SkateStatus
local control = Blockman.Instance():control()

function RunStatus:ctor(statusName, skateCfg)
  BaseStatus.ctor(self, statusName, skateCfg)
  self.curSpeedVal = 0
  self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
  self.turnMaxAngleSpeed = skateSetting.turnMaxAngleSpeed
  self.moveAccVal = self.skateCfg.moveAcc
  self.stopAccVal = self.skateCfg.stopAcc
  self.maxSpeed = self.skateCfg.maxSpeed
  self.control = Blockman.Instance():control()
  self.curTurnType = nil
  self.dt = 0
  self.autoKickInterval = 80
end

function RunStatus:onEnter()
  Lib.logWarning("RunStatus onEnter")
  if not SkateControl.isCharge then
    SkateAnimMgr:playIdle()
  end
  self.turnAngleSpeed = SkateControl:getCurTurnAngleSpeed()
  self.curSpeedVal = SkateControl:getCurMoveSpeed()
  self:playSound("g2060_idle")
  self:startAutoKickAnim()
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SKATE_ON_GROUND_STATUS_CHANGE, function(isOnGround)
    if not self.isBreak then
      if isOnGround then
        self:playSound("g2060_idle")
      else
        self:stopSound()
      end
    end
  end)
end

function RunStatus:onUpdate(poleForward, poleStrafe, vAxisValue, hAxisValue)
  local forward = vAxisValue + poleForward
  local left = hAxisValue + poleStrafe
  self.curSpeedVal = SkateControl:getCurMoveSpeed()
  local controlType = self:getControlType(poleForward, poleStrafe, forward, left)
  if controlType == SkateControlType.Idle then
    if not self.isBreak then
      self.isBreak = true
      self:playSound("g2060_stop")
    end
    self.curSpeedVal = math.max(self.curSpeedVal - self.stopAccVal, 0)
    if self.curSpeedVal <= 0 and self.autoKickTimer then
      self.autoKickTimer()
      self.autoKickTimer = nil
    else
    end
  else
    local isCancelTurnOpt = false
    if self.curTurnType ~= controlType and (self.curTurnType == SkateControlType.TurnLeft or self.curTurnType == SkateControlType.TurnRight) then
      isCancelTurnOpt = true
    end
    if self.isBreak then
      self.isBreak = false
      self:playSound("g2060_idle")
    end
    if self.curSpeedVal > self.maxSpeed then
      self.curSpeedVal = math.max(self.curSpeedVal - self.stopAccVal, self.maxSpeed)
    end
    if controlType ~= SkateControlType.Idle then
      if controlType == SkateControlType.TurnRight then
        if self.curTurnType ~= controlType then
          self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
        end
        if SkateControl.isCharge or self.statusName == SkateStatus.Run then
        end
      elseif controlType == SkateControlType.TurnLeft then
        if self.curTurnType ~= controlType then
          self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
        end
        if SkateControl.isCharge or self.statusName == SkateStatus.Run then
        end
      end
      if self.curSpeedVal == 0 then
        SkateAnimMgr:playKick()
      end
      if self.curSpeedVal < self.maxSpeed then
        self.curSpeedVal = self.maxSpeed
        if self.curSpeedVal > self.maxSpeed then
          self.curSpeedVal = self.maxSpeed
        end
      end
      self.turnAngleSpeed = math.min(self.turnAngleSpeed + skateSetting.turnAngleOneFrameAddVal, self.turnMaxAngleSpeed)
    else
      self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
    end
    if self.statusName == SkateStatus.Run and not SkateControl.isCharge then
      if isCancelTurnOpt then
        SkateAnimMgr:playIdle(true)
      elseif controlType == SkateControlType.Idle then
        SkateAnimMgr:playIdle()
      end
    end
  end
  if not SkateControl:isTouchMoveChangeDir() then
    if self.curSpeedVal == 0 or controlType ~= SkateControlType.TurnRight and controlType ~= SkateControlType.TurnLeft then
      left = 0
    end
    if left ~= 0 then
      local angleOffset = -(left / math.abs(left)) * self.turnAngleSpeed
      local targetYaw = self.skateEntity:getRotationYaw() + angleOffset
      self.skateEntity:setRotationYaw(targetYaw, false)
    else
      self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
    end
  else
    self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
  end
  self.curTurnType = controlType
  SkateControl:setCurTurnAngleSpeed(self.turnAngleSpeed)
  SkateControl:setCurMoveSpeed(self.curSpeedVal)
end

function RunStatus:startAutoKickAnim()
  if not self.autoKickTimer and self.statusName == SkateStatus.Run then
    self.autoKickTimer = World.Timer(self.autoKickInterval, function()
      SkateAnimMgr:playKick()
      return true
    end)
  end
end

function RunStatus:onExit()
  self.isBreak = false
  Lib.logWarning("RunStatus onExit")
  self:stopSound()
  self.curTurnType = nil
  for _, event in pairs(self.eventList) do
    event()
  end
  self.eventList = {}
  if self.autoKickTimer then
    self.autoKickTimer()
    self.autoKickTimer = nil
  end
end

function RunStatus:dctor()
  BaseStatus.dctor(self)
  self:stopSound()
  if self.autoKickTimer then
    self.autoKickTimer()
    self.autoKickTimer = nil
  end
end

return RunStatus
