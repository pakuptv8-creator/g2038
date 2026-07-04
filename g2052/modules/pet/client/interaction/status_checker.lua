local IDLE_WAIT_TIME = 2
local PetStatusConfig = T(Config, "PetStatusConfig")
local StatusChecker = T(Lib, "StatusChecker")

function StatusChecker:init()
  self._petSelf = {}
  self._petStatus = {}
  self._isIdle = nil
  Lib.subscribeEvent(Event.EVENT_ENTITY_MOVE_STATUS_CHANGE, function(objID, newState, oldState)
    if not self._petSelf[objID] then
      return
    end
    local pet = World.CurWorld:getObject(objID)
    if not pet or not pet:isValid() then
      return
    end
    if Define.EntityMoveStatus[newState] ~= "IDLE" then
      if self._isIdle ~= 0 then
        self._isIdle = 0
      end
      self._petStatus[objID].idleStartTime = nil
      self:clearIdleWaitTimer()
      self:statusRemoveConditionCheck(objID, Define.PET_STATUS_REMOVE_CONDITION.Move)
    else
      if self._isIdle ~= 1 and not self._idleWaitTimer then
        self._idleWaitTimer = World.Timer(IDLE_WAIT_TIME, function()
          self._isIdle = 1
        end)
      end
      if not self._petStatus[objID].idleStartTime then
        self._petStatus[objID].idleStartTime = os.time()
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_PET_CARRY_OBJ_ID_CHANGE, function(objID)
    if objID == 0 then
      self._petSelf = {}
      self._petStatus = {}
      self:clearIdleWaitTimer()
      self:clearStatusTimer()
      self:clearSatisfyTimer()
    else
      self:addObserver(objID)
    end
  end)
end

function StatusChecker:addObserver(objID)
  self._petSelf[objID] = os.time()
  self._petStatus[objID] = {
    idleStartTime = os.time(),
    curStatus = Define.PET_STATUS.None
  }
  self:clearStatusTimer()
  self._statusTimer = World.Timer(20, function()
    if self._petStatus[objID] then
      local idleStartTime = self._petStatus[objID].idleStartTime
      local now = os.time()
      if idleStartTime and now - idleStartTime >= World.cfg.petFromIdleToPerformanceTime and self._petStatus[objID].curStatus == Define.PET_STATUS.None and not self:isLiftByOwner(objID) and not self:isRideByOwner(objID) then
        local statusCfg = PetStatusConfig:randomOneStatusCfg()
        assert(statusCfg, "no pet status cfg, check func")
        self._petStatus[objID].curStatus = statusCfg.id
        self:doStatusPerformance(objID, statusCfg)
      end
      return true
    end
  end)
end

function StatusChecker:isLiftByOwner(objID)
  local pet = World.CurWorld:getObject(objID)
  if pet and pet:isValid() and pet.rideOnId > 0 and pet.rideOnId == Me.objID then
    return true
  end
  return false
end

function StatusChecker:isRideByOwner(objID)
  local pet = World.CurWorld:getObject(objID)
  if pet and pet:isValid() and Me.rideOnId > 0 and Me.rideOnId == pet.objID then
    return true
  end
  return false
end

function StatusChecker:removeObserver(objID)
  self._petSelf[objID] = nil
  self._petStatus[objID] = nil
  self:clearStatusTimer()
end

function StatusChecker:clearStatusTimer()
  if self._statusTimer then
    self._statusTimer()
    self._statusTimer = nil
  end
end

function StatusChecker:clearSatisfyTimer()
  if self._satisfyTimer then
    self._satisfyTimer()
    self._satisfyTimer = nil
  end
end

function StatusChecker:clearIdleWaitTimer()
  if self._idleWaitTimer then
    self._idleWaitTimer()
    self._idleWaitTimer = nil
  end
end

function StatusChecker:doStatusPerformance(objID, statusCfg)
  local pet = World.CurWorld:getObject(objID)
  if not pet or not pet:isValid() then
    return
  end
  local cfg = pet:cfg()
  if cfg and cfg.rejectStateChange then
    return
  end
  local addBuff = statusCfg.performanceBuff
  if addBuff ~= "" then
    Me:sendPacket({
      pid = "petAddPerformanceBuff",
      objID = objID,
      statusId = statusCfg.id
    })
  end
end

function StatusChecker:statusRemoveConditionCheck(objID, action, params)
  params = params or {}
  local curStatus = self._petStatus[objID].curStatus
  if action == Define.PET_STATUS_REMOVE_CONDITION.None then
    local pet = World.CurWorld:getObject(objID)
    if pet and pet:isValid() and pet.isShowInteractionUi then
      Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_CHECKIN, objID, true)
    end
  end
  if curStatus == Define.PET_STATUS.None then
    return
  end
  local lastStatus = curStatus
  local statusCfg = PetStatusConfig:getCfgById(curStatus)
  if not statusCfg then
    return
  end
  local statusRemoveCond = statusCfg.statusRemoveCond
  local canRemove = false
  for _, v in ipairs(statusRemoveCond) do
    if v == action then
      canRemove = true
      break
    end
  end
  if canRemove then
    self._petStatus[objID].curStatus = Define.PET_STATUS.None
    if self._petStatus[objID].idleStartTime then
      self._petStatus[objID].idleStartTime = nil
    end
    local pet = World.CurWorld:getObject(objID)
    if pet and pet:isValid() then
      local moveStatus = pet:getMoveStatus()
      if moveStatus == 2 then
        self._petStatus[objID].idleStartTime = os.time()
      end
    end
    Me:sendPacket({
      pid = "petRemovePerformanceBuff",
      objID = objID,
      statusId = lastStatus
    })
    print("pet remove performance status, last status is: ", lastStatus)
    local interactSatisfyBuff = statusCfg.interactSatisfyBuff
    local interactSatisfyKey = statusCfg.interactSatisfyKey
    local interactSatisfyBuffDelay = statusCfg.interactSatisfyBuffDelay
    local interactSatisfyBuffDuration = statusCfg.interactSatisfyBuffDuration or 20
    if interactSatisfyBuff ~= "" and params.interactKey and params.interactKey == interactSatisfyKey then
      self._satisfyTimer = World.Timer(interactSatisfyBuffDelay, function()
        Me:sendPacket({
          pid = "petAddSatisfyBuff",
          objID = objID,
          statusId = lastStatus
        })
        print("pet add Satisfy status, status is: ", lastStatus)
      end)
    else
    end
  else
  end
end

StatusChecker:init()
return StatusChecker
