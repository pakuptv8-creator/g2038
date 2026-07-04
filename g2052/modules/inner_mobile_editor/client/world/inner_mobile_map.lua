local engine_loadCurMap = WorldClient.loadCurMap

function WorldClient:loadCurMap(data, pos, mapChunkData)
  if data.name == "map_empty" then
    if Me.targetMap then
      data.name = Me.targetMap
    else
      local ModeManager = T(MobileEditor, "ModeManager")
      data.name = ModeManager:instance():getBlockId()
    end
  end
  engine_loadCurMap(self, data, pos, mapChunkData)
end
