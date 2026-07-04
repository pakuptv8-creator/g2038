local PartSingleHelper = T(Lib, "PartSingleHelper")

function PartSingleHelper:init()
  self.singlePartList = {}
end

function PartSingleHelper:checkPartIsCanInteraction(part, fromEntity, params, isBreak)
  local entityPos = fromEntity:getPosition()
  local maxLen = 5
  if maxLen < (Lib.v3(entityPos.x, entityPos.y, entityPos.z) - part:getPosition()):len() then
    return false
  end
  local partID = part:getInstanceID()
  if isBreak then
    return self.singlePartList[partID]
  else
    return not self.singlePartList[partID]
  end
end

function PartSingleHelper:updatePartEntityInfo(part, sitIdx, objID, isBreak)
  local partID = part:getInstanceID()
  local entity = World.CurWorld:getObject(objID)
  if entity and entity:isValid() then
    local oldSinglePartId = entity:getSingleInteractPartID()
    if not isBreak then
      if oldSinglePartId ~= "" then
        self:cleanSinglePartInfo(oldSinglePartId)
      end
      if oldSinglePartId ~= partID then
        self.singlePartList[partID] = objID
        entity:setSingleInteractPartID(partID)
        WorldServer.BroadcastPacket({
          pid = "SCPushSingleInteractState",
          partID = partID,
          objID = objID
        })
      end
    elseif oldSinglePartId ~= "" and oldSinglePartId == partID then
      self:cleanSinglePartInfo(oldSinglePartId)
    end
  end
end

function PartSingleHelper:cleanSinglePartInfo(partID)
  if self.singlePartList[partID] then
    WorldServer.BroadcastPacket({
      pid = "SCPushSingleInteractState",
      partID = partID
    })
    local entity = World.CurWorld:getEntity(self.singlePartList[partID])
    if entity and entity:isValid() then
      entity:setSingleInteractPartID("")
    end
    self.singlePartList[partID] = nil
  end
end

function PartSingleHelper:loginSyncSingleInteractState(player)
  local packet = {
    pid = "SyncSingleInteractState",
    dataList = self.singlePartList
  }
  player:sendPacket(packet)
end
