local SkateStatus = Define.SkateStatus
local StatusController = T(Lib, "StatusController")
local StatusClass = {
  [SkateStatus.Idle] = require("client.player_status.idle_status"),
  [SkateStatus.Run] = require("client.player_status.run_status"),
  [SkateStatus.Jump] = require("client.player_status.jump_status"),
  [SkateStatus.StepDown] = require("client.player_status.step_down_status"),
  [SkateStatus.StepOn] = require("client.player_status.step_on_status"),
  [SkateStatus.Charge] = require("client.player_status.charge_status")
}

function StatusController:init(skateCfg)
  self.statusDict = {}
  self.curStatus = nil
  self.curLockStatus = nil
  for statusName, status in pairs(StatusClass) do
    local cls = status.new(statusName, skateCfg)
    self.statusDict[statusName] = cls
  end
end

function StatusController:tick(poleForward, poleStrafe, vAxisValue, hAxisValue)
  if self.curStatus then
    self.curStatus:onUpdate(poleForward, poleStrafe, vAxisValue, hAxisValue)
  end
end

function StatusController:setStatus(statusName, data, lockStatus)
  if not self.statusDict then
    return
  end
  if self.curStatus then
    if self.curStatus:isSameStatus(statusName) or self.curLockStatus and self.curLockStatus ~= statusName then
      return
    end
    self.curStatus:onExit()
    Lib.emitEvent(Event.EVENT_SKATE_STATUS_EXIT, self.curStatus.statusName)
    self.curStatus = nil
  end
  local status = self.statusDict[statusName]
  if status then
    if lockStatus then
      self:setLockStatus(statusName)
    end
    status:onEnter(data)
    self.curStatus = status
    Lib.emitEvent(Event.EVENT_SKATE_STATUS_ENTER, statusName)
    print("set current status : ", statusName)
  end
end

function StatusController:setLockStatus(status)
  self.curLockStatus = status
end

function StatusController:getCurStatus()
  return self.curStatus
end

function StatusController:isLockStatus()
  return self.curLockStatus
end

function StatusController:isStatus(statusName)
  if self.curStatus and self.curStatus.statusName == statusName then
    return true
  end
end

function StatusController:unInit()
  for _, status in pairs(self.statusDict) do
    status:dctor()
  end
  self.statusDict = {}
  self.curStatus = nil
  self.curLockStatus = nil
end
