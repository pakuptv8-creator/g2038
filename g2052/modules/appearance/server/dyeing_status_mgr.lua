local DyeingStatusMgr = T(Lib, "DyeingStatusMgr")

function DyeingStatusMgr:init()
  self._status = {}
end

function DyeingStatusMgr:setStatus(userId, partName, color)
  print("DyeingStatusMgr:setStatus--------------------")
  if not self._status[userId] then
    self._status[userId] = {}
  end
  self._status[userId][partName] = color
end

function DyeingStatusMgr:delStatus(player, partName)
  if not player or not player:isValid() then
    return
  end
  local userId = player.platformUserId
  if not self._status[userId] then
    return
  end
  if not self._status[userId][partName] then
    return
  end
  local curSkin = player:data("skin")
  local slaveNames = {}
  local skin = curSkin[partName]
  if type(skin) ~= "table" then
    slaveNames[1] = partName .. "." .. skin
    local packet = {
      pid = "cancelDyeing",
      objID = player.objID,
      masterSlaveNames = slaveNames
    }
    player:sendPacketToTracking(packet, true)
  end
  self._status[userId][partName] = nil
end

function DyeingStatusMgr:resetStatus(player)
  print("DyeingStatusMgr:resetStatus--------------------")
  if not player or not player:isValid() then
    return
  end
  if not self._status[player.platformUserId] or next(self._status[player.platformUserId]) == nil then
    return
  end
  local curSkin = player:data("skin")
  local slaveNames = {}
  for partName, _ in pairs(self._status[player.platformUserId]) do
    local skin = curSkin[partName]
    if type(skin) ~= "table" then
      slaveNames[#slaveNames + 1] = partName .. "." .. skin
    end
  end
  local packet = {
    pid = "cancelDyeing",
    objID = player.objID,
    masterSlaveNames = slaveNames
  }
  player:sendPacketToTracking(packet, true)
  self._status[player.platformUserId] = nil
end

function DyeingStatusMgr:clearStatus(player)
  if not player or not player:isValid() then
    return
  end
  if not self._status[player.platformUserId] then
    return
  end
  self._status[player.platformUserId] = nil
end

function DyeingStatusMgr:getStatus(platformUserId)
  return self._status[platformUserId]
end

DyeingStatusMgr:init()
return DyeingStatusMgr
