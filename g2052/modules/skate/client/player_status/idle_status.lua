local BaseStatus = require("client.player_status.base_status")
local IdleStatus = class("IdleStatus", BaseStatus)
local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local skateSetting = World.cfg.skateSetting

function IdleStatus:onEnter()
  Lib.logWarning("IdleStatus onEnter")
  self.randomIdleInterval = skateSetting.randomIdleInterval
  self.curTick = 0
  self.isPlayRandomIdle = false
end

function IdleStatus:onUpdate()
  self.curTick = self.curTick + 1
  if self.curTick >= self.randomIdleInterval then
    if not self.isPlayRandomIdle then
      self.isPlayRandomIdle = true
      SkateAnimMgr:playRandomIdle(function()
        self.curTick = 0
        self.isPlayRandomIdle = false
      end)
    end
  else
    SkateAnimMgr:playIdle()
  end
end

function IdleStatus:onExit()
  Lib.logWarning("IdleStatus onExit")
  for i, event in pairs(self.eventList) do
    event()
  end
  self.eventList = {}
  self.curTick = 0
  self.isPlayRandomIdle = false
end

return IdleStatus
