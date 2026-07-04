local PlayerPhotographHelper = T(Lib, "PlayerPhotographHelper")

function PlayerPhotographHelper:init()
  self.photographList = {}
end

function PlayerPhotographHelper:updatePlayerPhotographInfo(player, part, params)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  local pos = part:getPosition()
  local posOffset = Lib.createV3ByString(params[2])
  local finalPos = Lib.v3(pos.x + posOffset.x, pos.y + posOffset.y, pos.z + posOffset.z)
  local size = Lib.splitString(params[1], "#", true)
  local defaultSkin = player:getOriginalSkin() or {}
  local extraShapeInfo = player:getShapeInfo()
  if next(extraShapeInfo) ~= nil then
    local changeSkinData = player:parseNewSkinData()
    for i, v in pairs(changeSkinData) do
      defaultSkin[i] = v
    end
  end
  self.photographList[partID] = {
    userId = player.platformUserId,
    nameContent = player.name,
    nameColor = player:getNameColor(),
    sex = player:data("main").sex or 2,
    actorScale = tonumber(params[5]) or 1,
    skinData = defaultSkin,
    mapName = player.map.name,
    position = finalPos,
    rotate = Lib.createV3ByString(params[3]),
    width = size[1],
    height = size[2],
    viewDistance = tonumber(params[4]),
    partID = partID
  }
  self:clientUpdatePhotograph(partID)
end

function PlayerPhotographHelper:clientUpdatePhotograph(partID, player)
  local packet = {
    pid = "SCPlayerPhotographShow"
  }
  if partID then
    local part = Instance.getByInstanceId(partID)
    if not part or not part:isValid() then
      return
    end
    packet.partID = partID
    packet.curPhotographInfo = self.photographList[partID]
  else
    packet.allPhotographInfo = self.photographList
  end
  if player then
    player:sendPacket(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

function PlayerPhotographHelper:removePartInteractState(part)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  if self.photographList[partID] then
    self.photographList[partID] = nil
    self:clientUpdatePhotograph(partID)
  end
end

function PlayerPhotographHelper:loginSyncPhotographInfo(player)
  self:clientUpdatePhotograph(nil, player)
end
