local BaseStatus = require("client.player_status.base_status")
local StepDownStatus = class("StepDownStatus", BaseStatus)
local SkateControl = T(Lib, "SkateControl")
local SkateAnimMgr = T(Lib, "SkateAnimMgr")

function StepDownStatus:onEnter()
  Lib.logWarning("StepDownStatus onEnter")
  SkateControl:setCurMoveSpeed(0)
  Me:cancelSkate()
  Lib.emitEvent(Event.EVENT_SKATE_STATUS_EXIT, self.statusName)
  self:playSound("g2060_stepdown")
end

function StepDownStatus:onExit()
  Lib.logWarning("StepDownStatus onExit")
  for i, event in pairs(self.eventList) do
    event()
  end
  self.eventList = {}
end

return StepDownStatus
