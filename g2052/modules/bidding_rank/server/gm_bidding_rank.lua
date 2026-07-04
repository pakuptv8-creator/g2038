local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local BiddingPreviewManager = T(Lib, "BiddingPreviewManager")
GMItem["ME/\232\191\155\229\133\165\233\148\153\232\175\175\229\156\176\229\155\190"] = function(self)
  local url = "http://static.sandboxol.com/sandbox/avatar/map/1649670865504112.json"
  BiddingPreviewManager:downLoadMap(self.platformUserId, url, function(fileName, jsonData)
    if not self or not self:isValid() then
      return
    end
    local mapName = fileName
    local mapCfg = jsonData
    self:sendPacket({
      pid = "syncPreviewMapData",
      mapCfg = mapCfg,
      mapName = mapName
    })
    Plugins.CallTargetPluginFunc("engine_overwrite", "addMapCfg", mapName, mapCfg)
    local map = World.CurWorld:createDynamicMap(mapName, true)
    local pos = self:getPosition()
    self.normalPos = Lib.v3(pos.x, pos.y, pos.z)
    self:setMapPos(map, map.cfg.initPos)
    self:resetInitGravity()
    Plugins.CallTargetPluginFunc("engine_overwrite", "removeMapCfg", mapName)
    self:sendPacket({
      pid = "syncChangePlayModel",
      model = "Preview",
      modelData = {blockId = "zhaobiao", mapId = 9527}
    })
  end)
end
