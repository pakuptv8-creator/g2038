local Player = _ENV.Player

function Player:syncPetData(data)
  self:sendPacket({
    pid = "syncPetData",
    data = data
  })
end

function Player:updatePetData(id, data)
  local petList = self:getPetData()
  petList[id] = data
  self:setPetData(id, data)
  self:syncSinglePetData(id, data)
  return true
end

function Player:syncSinglePetData(id, data)
  self:sendPacket({
    pid = "syncSinglePetData",
    id = id,
    data = data
  })
end
