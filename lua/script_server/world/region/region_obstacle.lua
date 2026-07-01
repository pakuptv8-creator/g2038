local NPCConfig = T(Config, "NPCConfig")
local NPCDialogueListConfig = T(Config, "NPCDialogueListConfig")

function RegionObstacle:init(region)
end

function RegionObstacle:onEntityEnter(entity, cfg, region)
  local objID = -1
  local map = World.CurWorld:getMap(cfg.mapName)
  for npc_obj, npc_id in pairs(map.npcEntities) do
    if npc_id == cfg.id then
      objID = npc_obj
      break
    end
  end
  local npcEntity = World.CurWorld:getEntity(objID)
  if npcEntity and npcEntity:isValid() then
    npcEntity:interact_with_npc(entity, cfg, region)
  end
end

function RegionObstacle:onEntityLeave(entity, cfg, region)
  Lib.logDebug("RegionObstacle onEntityLeave")
end

return RegionObstacle
