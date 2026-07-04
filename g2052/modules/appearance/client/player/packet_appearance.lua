local handles = T(Player, "PackageHandlers")

function handles:dyeing(packet)
  print("execute dyeing-------------------")
  local objId = packet.objID
  local player = World.CurWorld:getEntity(objId)
  if player and player:isValid() then
    local masterSlaveName = packet.masterSlaveName
    local color = packet.color
    player:setOverlayColor(masterSlaveName, {
      color[1],
      color[2],
      color[3],
      color[4]
    })
    player:setUseOverlayColorReplaceMode(masterSlaveName, true)
    if player == Me then
      UI:getWnd("dyeingColorSelect"):undoLocked()
      Me.disableJumpToLeavePart = nil
    end
  end
end

function handles:cancelDyeing(packet)
  print("execute cancelDyeing-------------------")
  local objId = packet.objID
  local player = World.CurWorld:getEntity(objId)
  if player and player:isValid() then
    local masterSlaveNames = packet.masterSlaveNames
    for _, masterSlaveName in ipairs(masterSlaveNames) do
      player:setOverlayColor(masterSlaveName, {
        1,
        1,
        1,
        1
      })
      player:setUseOverlayColorReplaceMode(masterSlaveName, false)
    end
  end
end

function handles:syncStatusToClient(packet)
  local data = packet.data
  if not data then
    return
  end
  for _, v in ipairs(data) do
    local objID = v.objID
    local player = World.CurWorld:getEntity(objID)
    if player and player:isValid() then
      local masterSlaveName = v.masterSlaveName
      local color = v.color
      player:setOverlayColor(masterSlaveName, {
        color[1],
        color[2],
        color[3],
        color[4]
      })
      player:setUseOverlayColorReplaceMode(masterSlaveName, true)
    end
  end
end
