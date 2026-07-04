local PetConfig = T(Config, "PetConfig")
local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function EntityServer:addNewPet(cfgId, is_Ad_free)
  local petCfg = PetConfig:getCfgById(cfgId)
  if not petCfg then
    return
  end
  local petData = {
    cfgId = cfgId,
    cfgName = petCfg.cfgName
  }
  local petId = self:addPetDataToList(petData)
  local reportData = {
    child_id = petData.cfgId or 0,
    is_Ad_free = is_Ad_free or 0
  }
  Plugins.CallTargetPluginFunc("report", "report", "g2052_child_create_new", reportData, self)
  self:removePetFromWorld(true)
  self:createPetToWorld(petId, is_Ad_free)
  self:sendPacket({
    pid = "onAddNewPet"
  })
end

function EntityServer:addPetDataToList(petData)
  local petList = self:getPetData()
  local data = {
    id = #petList + 1,
    name = petData.name,
    cfgId = petData.cfgId,
    cfgName = petData.cfgName,
    birthday = os.time(),
    upgradeTime = os.time()
  }
  self:updatePetData(data.id, data)
  return data.id
end

function EntityServer:createPetToWorld(petId, is_Ad_free)
  if not self:isValid() then
    return
  end
  local petData = self:getPetDataById(petId)
  if not petData then
    return
  end
  local pos = self:getFrontPos(-1, true, false)
  local map = self.map
  local cfgName = petData.cfgName
  local entity = EntityServer.Create({
    cfgName = cfgName,
    map = map,
    pos = pos,
    ry = self:getRotationYaw(),
    owner = self
  })
  if not entity or not entity:isValid() then
    self:updatePetData(petId, nil)
    return
  end
  local aiControl = entity:getAIControl()
  aiControl:setFollowTarget(self)
  local stateMachine = aiControl:getMachine()
  local followState = stateMachine:getState("AIStateFollowEntity")
  if followState then
    stateMachine:setState(followState)
  end
  if petData.name then
    entity:setEntityName(petData.name)
  end
  local actorName, skin = self:getPetActorAndSkinById(petId)
  if actorName then
    entity:changeActor(actorName, true)
  end
  if skin then
    entity:changeSkin(skin)
  end
  local petName = self:getValue(Define.PET_VAR_KEY.PetName)
  if petName and petName ~= "" then
    local color = "[C=FF" .. self:getValue(Define.PET_VAR_KEY.PetNameColor) .. "]"
    entity:setEntityName(color .. petName)
  end
  self:setCurCarryPetId(petId)
  self:setCurCarryPetObjId(entity.objID)
  Plugins.CallTargetPluginFunc("garbage_collector", "register", "entity", entity.objID, self.platformUserId)
  self:recordPetEnter(petId)
  self:addUsePetCountOnce()
  if not self.isFirstPet then
    local reportData = {
      child_id = petData.cfgId or 0,
      is_Ad_free = is_Ad_free or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "first_child", reportData, self)
    self.isFirstPet = true
  end
  return true
end

function EntityServer:removePetFromWorld(isCallBack)
  local objID = self:getCurCarryPetObjId()
  local entity = World.CurWorld:getEntity(objID)
  local needRemove = false
  if self.rideOnId and self.rideOnId > 0 and self.rideOnId == objID and self.rideOnInstanceId then
    self:rideOffFromPartVehicle(false)
  end
  if entity then
    local aiControl = entity:getAIControl()
    aiControl:setFollowTarget(nil)
    entity:destroy()
    needRemove = true
  end
  self:setCurCarryPetObjId(0)
  if isCallBack then
    local petId = self:getCurCarryPetId()
    if needRemove and petId ~= 0 then
      self:reportChildData(petId)
    end
    self:setCurCarryPetId(0)
  end
end

function EntityServer:cancelPetStatus(isSyncData)
end

function EntityServer:getPetDataById(id)
  local petList = self:getPetData()
  return petList[id]
end

function EntityServer:setEntityName(name)
  self.name = name or ""
  local packet = {
    pid = "SetEntityName",
    objID = self.objID,
    name = self.name
  }
  self:sendPacketToTracking(packet, true)
end

function EntityServer:getPetActorAndSkinById(id)
  local petData = self:getPetDataById(id)
  if not petData then
    return nil, nil
  end
  return PetConfig:getActorAndSkin(petData.cfgId)
end

function EntityServer:reportChildData(childId)
  if not childId then
    return
  end
  local record = self:getPetRecord()
  if not record[childId] then
    return
  end
  local petData = self:getPetDataById(childId)
  if not petData then
    return
  end
  local petCfg = PetConfig:getCfgById(petData.cfgId)
  local is_Ad_free = 0
  if not self:checkPetUnlock(petCfg) then
    is_Ad_free = 1
  end
  local reportData = {
    child_id = petData.cfgId,
    child_time = os.time() - record[childId],
    is_Ad_free = is_Ad_free or 0
  }
  Plugins.CallTargetPluginFunc("report", "report", "child_call", reportData, self)
end
