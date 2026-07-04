local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local AnimType = {
  Idle = 1,
  Run = 2,
  Box = 3,
  Jump = 4,
  Fall = 5,
  Step = 6,
  Squat = 7,
  Stop = 8,
  JumpDown = 9,
  Turn = 10
}
local random = math.random
local RandomIdle = {
  "g2052_boy_stand_idle1",
  "g2052_boy_stand_idle2"
}

function SkateAnimMgr:init(skateCfg, skateEntity)
  self.skateCfg = skateCfg
  self.skateEntity = skateEntity
  self.curAnimCbTimerDict = {}
  self.entityPlayAnimData = {}
  self.interruptFuncDict = {
    [AnimType.JumpDown] = self.JumpDownInterruptFunc
  }
end

function SkateAnimMgr:playIdle(isForce)
  self:playSkateAnim("g2052_skateboard_idle", "g2052_skate_jump_squat", 1, AnimType.Idle, isForce)
end

function SkateAnimMgr:playRandomIdle(cb)
  local randomIdx = random(1, #RandomIdle)
  self:playSkateAnim(RandomIdle[randomIdx], nil, 1, AnimType.Idle, false, cb)
end

function SkateAnimMgr:playKick()
  self:playSkateAnim("g2052_boy_kick", "g2052_skate_jump_squat", 2, AnimType.Run)
end

function SkateAnimMgr:playBreak1()
  self:playSkateAnim("g2052_boy_break_1", "g2052_skate_break_1", 5, AnimType.Stop)
end

function SkateAnimMgr:playBreak2()
  self:playSkateAnim("g2052_boy_break_2", "g2052_skate_break_2", 5, AnimType.Stop)
end

function SkateAnimMgr:playTurnRight()
  self:playSkateAnim("g2052_boy_turnright", "g2052_skate_jump_squat", 3, AnimType.Turn)
end

function SkateAnimMgr:playTurnLeft()
  self:playSkateAnim("g2052_boy_turnleft", "g2052_skate_jump_squat", 3, AnimType.Turn)
end

function SkateAnimMgr:playJump(forcePg)
  local index, animDataKey
  if forcePg ~= 0 then
    local val = forcePg * 10
    index = math.ceil(val / 2)
    animDataKey = "jumpAnim" .. index
  else
    animDataKey = "jumpAnim1"
  end
  self:playSkateAnim(self.skateCfg[animDataKey].player, self.skateCfg[animDataKey].skate, 6, AnimType.Jump)
end

function SkateAnimMgr:playFly()
  self:playSkateAnim(self.skateCfg.flyingAnim.player, self.skateCfg.flyingAnim.skate, 8, AnimType.Jump)
end

function SkateAnimMgr:playJumpSquat()
  local curAnimData = self.entityPlayAnimData[Me.objID]
  if curAnimData and curAnimData.animType ~= AnimType.Fall then
    self:playSkateAnim("g2052_boy_jump_squat", "g2052_skate_jump_squat", 1, AnimType.Squat, true)
  end
end

function SkateAnimMgr:playJumpDown()
  self:playSkateAnim("g2052_boy_jumpdown", "g2052_skate_jumpdown", 5, AnimType.JumpDown)
end

function SkateAnimMgr:playFallGround(cb)
  self:playSkateAnim("g2052_boy_fall", "g2052_skate_fall", 9, AnimType.Fall, false, cb)
end

function SkateAnimMgr:playBoxSlip()
  self:playSkateAnim(self.skateCfg.glideAnim.player, self.skateCfg.glideAnim.skate, 6, AnimType.Box)
end

function SkateAnimMgr:playBoxSlipEnd()
  self:playSkateAnim(self.skateCfg.glideOverAnim.player, self.skateCfg.glideOverAnim.skate, 6, AnimType.Box)
end

function SkateAnimMgr:playStepDown(cb)
  self:playSkateAnim("g2052_boy_stepdown", "g2052_skate_stepdown", 10, AnimType.Step, false, cb)
end

function SkateAnimMgr:playStepOn(cb)
  self:playSkateAnim("g2052_boy_stepon", "g2052_skate_stepon", 10, AnimType.Step, false, cb)
end

function SkateAnimMgr:jumpDownInterruptFunc(animType)
  if animType == AnimType.Box or animType == AnimType.Fall or animType == AnimType.Special or animType == AnimType.Stop then
    return true
  end
  return false
end

function SkateAnimMgr:getCurAnimName(objID)
  objID = objID or Me.objID
  local playAnimData = self.entityPlayAnimData[objID] or {}
  return playAnimData.animName
end

function SkateAnimMgr:playSkateAnim(playerAnim, skateAnim, animLevel, AnimType, isForce, cb)
  local success = self:playAnim(Me, playerAnim, animLevel, AnimType, isForce, cb)
  if success then
    if skateAnim then
      self.skateEntity:updateUpperAction(skateAnim, -1)
    end
    Me:sendPacket({
      pid = "broadcastSkateAnim",
      playerAnim = playerAnim,
      skateAnim = skateAnim
    })
  end
end

function SkateAnimMgr:playAnim(entity, animName, animLevel, animType, isForce, cb)
  animLevel = animLevel or 1
  local curWorldTick = World.CurWorld:getTickCount()
  local playAnimData = self.entityPlayAnimData[entity.objID]
  if not playAnimData then
    playAnimData = {}
    self.entityPlayAnimData[entity.objID] = playAnimData
  end
  if not (self.skateEntity and self.skateEntity:isValid()) or not self.skateEntity.objID then
    return
  end
  if playAnimData.animName then
    if playAnimData.animName == animName then
      return false
    elseif not isForce and curWorldTick < playAnimData.animEndTick then
      local func = self.interruptFuncDict[playAnimData.animType]
      if func then
        if not func(self, animType) then
          return
        end
      elseif animLevel < playAnimData.animLevel then
        return
      end
    end
  end
  playAnimData.animName = animName
  local time = entity:getUpperActionTicks(animName) or -1
  entity:addPlayerSkateAction(self.skateEntity.objID, animName, -1)
  if cb then
    local timer = self.curAnimCbTimerDict[entity.objID]
    if timer then
      timer()
    end
    self.curAnimCbTimerDict[entity.objID] = World.Timer(time, function()
      cb()
      self.curAnimCbTimerDict[entity.objID] = nil
    end)
  end
  playAnimData.animEndTick = curWorldTick + time
  playAnimData.animLevel = animLevel
  playAnimData.animType = animType
  return true
end

function SkateAnimMgr:resetPlayAnimData()
  self.entityPlayAnimData[Me.objID] = {}
end

function SkateAnimMgr:unInit()
  for i, timer in pairs(self.curAnimCbTimerDict) do
    timer()
  end
  self.curAnimCbTimerDict = {}
  self.entityPlayAnimData = {}
  self.skateCfg = nil
  self.skateEntity = nil
end

return SkateAnimMgr
