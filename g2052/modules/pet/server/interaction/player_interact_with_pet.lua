local PetConfig = T(Config, "PetConfig")
local Player = _ENV.Player

function Player:playWithPet(ridePosIdx)
  if not ridePosIdx then
    return
  end
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  if pet.rideOnId > 0 then
    return
  end
  local cfg = pet:cfg()
  local playingPlayerAction
  if cfg then
    playingPlayerAction = cfg.playingPlayerAction
    if cfg.playRidePosIdx then
      ridePosIdx = cfg.playRidePosIdx
    end
  end
  pet:rideOn(self, nil, ridePosIdx)
  self.inPlayWithPet = true
  self:sendPacket({
    pid = "playWithPetReply",
    objID = objId_pet,
    status = 1,
    playingPlayerAction = playingPlayerAction
  })
  local reportData = {
    child_event_type = Define.PET_INTERACTION_TYPE.PlayWith
  }
  Plugins.CallTargetPluginFunc("report", "report", "child_event", reportData, self)
  pet:setEntityName("")
end

function Player:stopWithPet()
  if not self.inPlayWithPet then
    return
  end
  self.inPlayWithPet = false
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  pet:rideOn(nil)
  self:sendPacket({
    pid = "playWithPetReply",
    objID = objId_pet,
    status = 0
  })
  local petName = self:getValue(Define.PET_VAR_KEY.PetName)
  if petName and petName ~= "" then
    local color = "[C=FF" .. self:getValue(Define.PET_VAR_KEY.PetNameColor) .. "]"
    pet:setEntityName(color .. petName)
  end
end

function Player:liftUpPet(ridePosIdx)
  if not ridePosIdx then
    return
  end
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  if pet.rideOnId > 0 then
    return
  end
  pet:rideOn(self, nil, ridePosIdx)
  self:addSkill("myplugin/lift_down_pet")
  self:sendPacket({
    pid = "liftUpPetReply",
    objID = objId_pet
  })
  local reportData = {
    child_event_type = Define.PET_INTERACTION_TYPE.LiftUp
  }
  Plugins.CallTargetPluginFunc("report", "report", "child_event", reportData, self)
end

function Player:feedPet()
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  if self.createInstForPet then
    return
  end
  if pet.feedRunTimer then
    return
  end
  local petId = self:getCurCarryPetId()
  local petData = self:getPetDataById(petId)
  if not petData then
    return
  end
  local cfgId = petData.cfgId
  local cfg = PetConfig:getCfgById(cfgId)
  if not cfg then
    return
  end
  pet:stopAI()
  local myPos = self:getPosition()
  local targetPos = Lib.v3(myPos.x + cfg.feedOffset.x, myPos.y + cfg.feedOffset.y, myPos.z + cfg.feedOffset.z)
  local initPos = pet:getPosition()
  local forwardDir = targetPos - initPos
  local totalDistance = forwardDir:len()
  local totalTime = totalDistance / cfg.foodSpeed
  local passTime = 0
  local normalize = forwardDir / totalTime
  local happyAction = cfg.happyAction
  local actionName
  if 0 < #happyAction then
    actionName = happyAction[math.random(1, #happyAction)]
  end
  local happyTime = 40
  local eatTime = 40
  if actionName then
    EntityServer.playAction({
      entity = pet,
      actionName = actionName,
      actionTime = happyTime
    })
  else
    happyTime = 0
  end
  pet.isFeedRunAction = false
  pet.isFeedEatAction = false
  pet.feedRunTimer = World.Timer(1, function()
    if not (pet and pet:isValid() and self) or not self:isValid() then
      if self.createInstForPet and self.createInstForPet:isValid() then
        self.createInstForPet:destroy()
      end
      self.createInstForPet = nil
      return false
    end
    passTime = passTime + 1
    if passTime > happyTime and passTime <= happyTime + totalTime then
      local newPos = initPos + (passTime - happyTime) * normalize
      pet:setAITargetPos(newPos, true)
      if not pet.isFeedRunAction then
        EntityServer.playAction({
          entity = pet,
          actionName = "run",
          actionTime = -1
        })
        pet.isFeedRunAction = true
      end
    elseif passTime > happyTime + totalTime and passTime <= happyTime + totalTime + eatTime then
      if not pet.isFeedEatAction then
        pet.isFeedEatAction = true
        pet:setAITargetPos(nil)
        local pos_food = pet:getFrontPos(cfg.foodFrontDis, true, false)
        local inst = self:addItemPartToWorld(cfg.feedFood, self, pos_food, true)
        if inst then
          self.createInstForPet = inst
          EntityServer.playAction({
            entity = pet,
            actionName = "eat",
            actionTime = -1
          })
          self:sendPacket({
            pid = "petFoodCreated",
            objID = objId_pet,
            inFeed = true
          })
        end
      end
    elseif passTime > happyTime + totalTime + eatTime then
      if pet and pet:isValid() then
        EntityServer.playAction({
          entity = pet,
          actionName = "idle",
          actionTime = -1
        })
      end
      if self.createInstForPet and self.createInstForPet:isValid() then
        self.createInstForPet:destroy()
      end
      self.createInstForPet = nil
      pet:startAI()
      self:sendPacket({
        pid = "petFoodCreated",
        objID = objId_pet,
        inFeed = false
      })
      local reportData = {
        child_event_type = Define.PET_INTERACTION_TYPE.Feed
      }
      Plugins.CallTargetPluginFunc("report", "report", "child_event", reportData, self)
      pet.feedRunTimer = nil
      return false
    end
    return true
  end)
end

function Player:teasePet()
end

function Player:ridePet()
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  
  local function rideFailReply()
    self:sendPacket({
      pid = "ridePetReply",
      objID = objId_pet,
      errorCode = 1
    })
  end
  
  if self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
    rideFailReply()
    return
  end
  if self.rideOnInstanceId then
    rideFailReply()
    return
  end
  local passengers = pet:data("passengers") or {}
  if next(passengers) ~= nil then
    return
  end
  local oldPartId = self:getInteractionPartID()
  if oldPartId ~= "" then
    rideFailReply()
    return
  end
  local ridePosCfg = pet:cfg().ridePos
  if not ridePosCfg or not ridePosCfg[1] then
    return
  end
  pet:stopAI()
  self:rideOn(pet, nil, 1)
  self:sendPacket({
    pid = "ridePetReply",
    objID = objId_pet,
    errorCode = 0
  })
  local reportData = {
    child_event_type = Define.PET_INTERACTION_TYPE.Ride
  }
  Plugins.CallTargetPluginFunc("report", "report", "child_event", reportData, self)
  local inUseCar = self:getInUseCar()
  if inUseCar then
    self:onOperationCar({
      id = inUseCar.id
    })
  end
  pet:setEntityName("")
end

function Player:rideOffPet()
  if self.rideOnId <= 0 then
    return
  end
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  if self.rideOnId ~= pet.objID then
    return
  end
  self:rideOffFromPartVehicle(false)
  self:rideOn(nil)
  pet:startAI()
  local petName = self:getValue(Define.PET_VAR_KEY.PetName)
  if petName and petName ~= "" then
    local color = "[C=FF" .. self:getValue(Define.PET_VAR_KEY.PetNameColor) .. "]"
    pet:setEntityName(color .. petName)
  end
  return true
end

function Player:removeRidingPet()
  local isSuc = self:rideOffPet()
  if isSuc then
    self:removePetFromWorld(true)
  end
end

function Player:petSpeedUp()
  if self.rideOnId <= 0 then
    return
  end
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if not pet or not pet:isValid() then
    return
  end
  if self.rideOnId ~= pet.objID then
    return
  end
  local petId = self:getCurCarryPetId()
  local petData = self:getPetDataById(petId)
  if not petData then
    return
  end
  local cfgId = petData.cfgId
  local cfg = PetConfig:getCfgById(cfgId)
  if not cfg then
    return
  end
  if not cfg.speedUpBuff or cfg.speedUpBuff == "" or os.time() - (self.lastPetSpeedUpStamp or 0) < cfg.speedUpCD then
    return
  end
  pet:addBuff(cfg.speedUpBuff, cfg.speedUpTime * 20)
  self.lastPetSpeedUpStamp = os.time()
  return true
end

function Player:cancelPlayerPetInteractions()
  Player:stopWithPet()
  local objId_pet = self:getCurCarryPetObjId()
  local pet = World.CurWorld:getObject(objId_pet)
  if pet and pet:isValid() and pet.rideOnId > 0 then
    pet:rideOn(nil)
  end
end
