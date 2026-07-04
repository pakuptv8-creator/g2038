local RunStatus = require("client.player_status.run_status")
local StepOnStatus = class("StepOnStatus", RunStatus)
local StatusController = T(Lib, "StatusController")
local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local SkateControl = T(Lib, "SkateControl")
local skateSetting = World.cfg.skateSetting

function StepOnStatus:onEnter(data)
  Lib.logWarning("StepOnStatus onEnter")
  World.Timer(1, function()
    StatusController:setLockStatus(nil)
  end)
  self:playSound("g2060_stepon")
  self.turnAngleSpeed = SkateControl:getCurTurnAngleSpeed()
  if data.rideOnMoveStatue then
    SkateControl:setCurMoveSpeed(self.skateCfg.stepOnSpeed)
  end
end

function StepOnStatus:onExit()
  self:stopSound()
  StatusController:setLockStatus(nil)
  Lib.logWarning("StepOnStatus onExit")
  for i, event in pairs(self.eventList) do
    event()
  end
  self.eventList = {}
end

return StepOnStatus
