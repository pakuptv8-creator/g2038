local engineLoadCurMap = WorldClient.loadCurMap

function WorldClient:loadCurMap(data, pos, mapChunkData)
  engineLoadCurMap(self, data, pos, mapChunkData)
  local map = World.CurMap
  Blockman.instance:setPersonView(World.cfg.cameraCfg.defaultView or 3)
  Me:initBattleCameraView(map.cfg.cameraCfg)
end
