local BiddingRankCatchManager = T(Lib, "BiddingRankCatchManager")
local BiddingPreviewManager = T(Lib, "BiddingPreviewManager")
local handles = T(Player, "PackageHandlers")

function handles:initBiddingRankList(packet)
  local player = self
  BiddingRankCatchManager:requestInitRankData(self.platformUserId, packet.blockId, function(data)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncBiddingRankList",
        data = data,
        maxNum = BiddingRankCatchManager:getRankMaxNum(packet.blockId),
        blockId = packet.blockId,
        page = 1
      })
    end
  end)
end

function handles:loadBiddingRankList(packet)
  local player = self
  BiddingRankCatchManager:getRankList(self.platformUserId, packet.blockId, packet.page, function(data)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncBiddingRankList",
        data = data,
        maxNum = BiddingRankCatchManager:getRankMaxNum(packet.blockId),
        blockId = packet.blockId,
        page = packet.page
      })
    end
  end)
end

function handles:GetRecommendLandList(packet)
  local player = self
  AsyncProcess.getRecommendLandList(self.platformUserId, packet.blockId, function(data)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncRecommendLandData",
        data = data,
        blockId = packet.blockId
      })
    end
  end)
end

function handles:previewBiddingAuditMap(packet)
  local blockId = packet.blockId
  local mapId = packet.mapId
  local mapResourceUrl = packet.mapResourceUrl
  local viewPlayer = self
  BiddingPreviewManager:downLoadMap(viewPlayer.platformUserId, mapResourceUrl, function(fileName, jsonData)
    if not viewPlayer or not viewPlayer:isValid() then
      return
    end
    local mapName = fileName
    local mapCfg = jsonData
    local emptyMap = Lib.copy(mapCfg)
    emptyMap.scene = {}
    viewPlayer:sendPacket({
      pid = "syncPreviewMapData",
      mapCfg = emptyMap,
      mapName = mapName
    })
    Plugins.CallTargetPluginFunc("engine_overwrite", "addMapCfg", mapName, mapCfg)
    local map = World.CurWorld:createDynamicMap(mapName, true)
    local pos = viewPlayer:getPosition()
    viewPlayer.normalPos = Lib.v3(pos.x, pos.y, pos.z)
    viewPlayer:setMapPos(map, map.cfg.initPos)
    viewPlayer:resetInitGravity()
    Plugins.CallTargetPluginFunc("engine_overwrite", "removeMapCfg", mapName)
    viewPlayer:sendPacket({
      pid = "syncChangePlayModel",
      model = "PreviewAudit",
      modelData = {blockId = blockId, mapId = mapId}
    })
  end)
end

function handles:previewBiddingMap(packet)
  local blockId = packet.blockId
  local mapId = packet.mapId
  Plugins.CallTargetPluginFunc("interaction_ui", "cleanPlayerAllInteraction", self)
  self:removePetFromWorld(true)
  BiddingPreviewManager:previewBuild(self, blockId, mapId)
  local VehicleManager = T(Lib, "VehicleManager")
  VehicleManager:removeSummonedVehicle(self.platformUserId)
end

function handles:previewFirstBiddingMap(packet)
  local blockId = packet.blockId
  Plugins.CallTargetPluginFunc("interaction_ui", "cleanPlayerAllInteraction", self)
  self:removePetFromWorld(true)
  BiddingPreviewManager:previewFirstBuild(self, blockId)
  local VehicleManager = T(Lib, "VehicleManager")
  VehicleManager:removeSummonedVehicle(self.platformUserId)
end

function handles:leavePreviewModel(packet)
  local pos = self.normalPos or World.cfg.initPos
  self:setMapPos(World.cfg.defaultMap or "map001", pos)
  self:sendPacket({
    pid = "syncChangePlayModel",
    model = "Normal"
  })
  local VehicleManager = T(Lib, "VehicleManager")
  VehicleManager:removeSummonedVehicle(self.platformUserId)
end

function handles:likeBiddingBuild(packet)
  Lib.logDebug("likeBiddingBuild === ", packet)
  local blockId = packet.blockId
  local mapId = packet.mapId
  local pageNum = packet.pageNum
  local player = self
  
  local function syncRankList()
    if player and player:isValid() then
      BiddingRankCatchManager:getRankList(self.platformUserId, blockId, pageNum, function(resultData)
        player:sendPacket({
          pid = "syncBiddingRankList",
          data = resultData,
          maxNum = BiddingRankCatchManager:getRankMaxNum(blockId),
          blockId = blockId,
          page = pageNum
        })
      end)
    end
  end
  
  local function syncRankInfo(info)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncBiddingRankInfo",
        data = info,
        blockId = blockId,
        mapId = mapId
      })
    end
  end
  
  BiddingRankCatchManager:upPlayerBuild(self, blockId, mapId, packet.reportFrom, function(info)
    if packet.reportFrom == "recommend" then
      player:sendPacket({
        pid = "syncMyRecommendRankList",
        data = info,
        blockId = blockId,
        mapId = mapId
      })
    elseif pageNum then
      syncRankList()
    else
      syncRankInfo(info)
    end
  end)
end

function handles:findBiddingRankPlayer(packet)
  local findId = tonumber(packet.findId)
  local blockId = packet.blockId
  local player = self
  BiddingRankCatchManager:findPlayer(self.platformUserId, blockId, findId, function(message, rankList)
    if message then
      player:sendPacket({
        pid = "syncBiddingFindRankList",
        data = rankList,
        blockId = packet.blockId
      })
    else
    end
  end)
end

function handles:getMyBiddingRankPlayer(packet)
  local userId = self.platformUserId
  local blockId = packet.blockId
  local player = self
  BiddingRankCatchManager:findPlayer(self.platformUserId, blockId, userId, function(message, rankList)
    if message then
      player:sendPacket({
        pid = "syncMyBiddingRankList",
        data = rankList,
        blockId = packet.blockId
      })
    else
    end
  end)
end

function handles:getBiddingRankInfo(packet)
  return BiddingRankCatchManager:getClientRankInfo(self.platformUserId, packet.blockId, packet.mapId)
end

function handles:requestAuditRankList(packet)
  local player = self
  AsyncProcess.requestAuditRankList(packet.blockId, packet.currPage, packet.pageSize, {
    auditStatus = packet.status,
    findId = packet.findId
  }, function(data)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncAuditRankData",
        data = data,
        blockId = packet.blockId,
        pageNum = packet.currPage
      })
    end
  end, function(data)
  end)
end

function handles:auditBiddingMap(packet)
  local player = self
  if player.isAuditBiddingMapIng then
    return
  end
  player.isAuditBiddingMapIng = true
  AsyncProcess.auditMap(player.platformUserId, packet.auditType, packet.mapId, function(code, data)
    if player and player:isValid() then
      if data and data.auditType ~= nil then
        player:sendPacket({
          pid = "syncAuditBiddingMap",
          isSuccess = true,
          auditType = data.auditType
        })
      end
      player.isAuditBiddingMapIng = nil
    end
  end, function()
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncAuditBiddingMap",
        isSuccess = false
      })
      player.isAuditBiddingMapIng = nil
    end
  end)
end

function handles:requestAuditBiddingInfo(packet)
  local player = self
  AsyncProcess.requestAuditRankList(packet.blockId, 1, 4, {
    mapId = packet.mapId
  }, function(data)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncAuditMapData",
        data = data,
        blockId = packet.blockId,
        mapId = packet.mapId
      })
    end
  end, function(data)
    Lib.logDebug("requestAuditRankList fail ", data)
  end)
end
