local StatusChecker = T(Lib, "StatusChecker")
local handles = T(Player, "PackageHandlers")

function handles:syncPetData(packet)
  local data = packet.data
  self:setValue(Define.PET_VAR_KEY.PetData, data, true)
end

function handles:onAddNewPet(packet)
end

function handles:syncSinglePetData(packet)
  local id = packet.id
  local data = packet.data
  local oldData = self:getPetData()
  self:setPetData(id, data)
end

function handles:playWithPetReply(packet)
  local objID_pet = packet.objID
  local status = packet.status
  local playingPlayerAction = packet.playingPlayerAction
  if not objID_pet then
    return
  end
  if status == 1 then
    StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.Interact, {interactKey = "playWith"})
  else
    StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.None)
  end
  if playingPlayerAction then
    self:setActions(playingPlayerAction)
  end
end

function handles:liftUpPetReply(packet)
  local objID_pet = packet.objID
  if not objID_pet then
    return
  end
  StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.Interact, {interactKey = "liftUp"})
end

function handles:petFoodCreated(packet)
  local objID_pet = packet.objID
  local inFeed = packet.inFeed
  if not objID_pet then
    return
  end
  local pet = World.CurWorld:getObject(objID_pet)
  if not pet or not pet:isValid() then
    return
  end
  if inFeed then
    StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.Interact, {interactKey = "feed"})
  else
    StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.None)
  end
end

function handles:ridePetReply(packet)
  local objID_pet = packet.objID
  if not objID_pet then
    return
  end
  local errorCode = packet.errorCode
  if errorCode == 0 then
    StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.Interact, {interactKey = "rideOn"})
  else
    StatusChecker:statusRemoveConditionCheck(objID_pet, Define.PET_STATUS_REMOVE_CONDITION.None)
  end
end
