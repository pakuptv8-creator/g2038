local BiddingPreviewManager = T(Lib, "BiddingPreviewManager")
local BiddingRankCatchManager = T(Lib, "BiddingRankCatchManager")
local root = Root.Instance():getGamePath() .. "map/"
local setting = require("common.setting")

local function resetMapInfo(scene)
  local function scanAndModify(data)
    if type(data) ~= "table" then
      return
    end
    local children = data.children
    if children then
      scanAndModify(children)
    else
      for key, v in pairs(data) do
        if type(v) == "table" and key == "properties" then
          v.needSync = nil
          v.id = tostring(Instance:allocateId())
        else
          scanAndModify(v)
        end
      end
    end
  end
  
  scanAndModify(scene)
end

function BiddingPreviewManager:downLoadMap(playerId, url, callback)
  local fileName = playerId .. "-" .. os.time() .. "-map"
  AsyncProcess.GetFileData(url, function(data)
    local scene = data.scene
    resetMapInfo(scene)
    if callback then
      callback(fileName, data)
    end
  end)
end

function BiddingPreviewManager:previewFirstBuild(viewPlayer, blockId)
  BiddingRankCatchManager:getRankList(viewPlayer.platformUserId, blockId, 1, function(rankList)
    local info = rankList[1]
    if not info then
      return
    end
    return self:previewBuild(viewPlayer, blockId, info.mapId)
  end)
end

function BiddingPreviewManager:previewBuild(viewPlayer, blockId, mapId)
  if not viewPlayer or not viewPlayer:isValid() then
    return
  end
  Lib.logDebug("blockId, targetId  ", blockId, mapId)
  local info = BiddingRankCatchManager:getPlayerBuild(blockId, mapId)
  local isLike = BiddingRankCatchManager:isLikeBuild(viewPlayer.platformUserId, blockId, mapId)
  local url = info.mapResourceUrl
  if viewPlayer.inDownLoadMap then
    return
  end
  viewPlayer.inDownLoadMap = true
  self:downLoadMap(viewPlayer.platformUserId, url, function(fileName, jsonData)
    if not viewPlayer or not viewPlayer:isValid() then
      return
    end
    viewPlayer.inDownLoadMap = false
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
      model = "Preview",
      modelData = {blockId = blockId, mapId = mapId}
    })
  end)
end
