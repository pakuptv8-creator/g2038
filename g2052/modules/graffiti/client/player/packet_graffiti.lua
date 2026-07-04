local handles = T(Player, "PackageHandlers")
local graffitiSetting = World.cfg.graffitiSetting
local GraffitiMgr = T(Lib, "GraffitiMgr")

function handles:SCPlayDoodleEffect(packet)
  if Me.map.name ~= packet.mapName then
    return
  end
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity and entity:isValid() then
    local InteractionHelper = T(Lib, "InteractionHelper")
    local actionKey = "graffiti_" .. packet.doodleId
    local actionData = {
      priority = Define.ActionMapPriority.graffitiPriority,
      actionName = graffitiSetting.actionName,
      actionTime = -1,
      actionType = "graffitiAction"
    }
    InteractionHelper:updateEntityActionData(packet.objID, actionKey, true, actionData)
    World.Timer(graffitiSetting.actionTime, function()
      if packet.objID == Me.objID and Me and Me:isValid() then
        Me.disableControl = false
      end
      InteractionHelper:updateEntityActionData(packet.objID, actionKey, false)
    end)
    World.Timer(graffitiSetting.SprayWaitTime, function()
      GraffitiMgr:createDoodleEffect(packet)
      if packet.objID == Me.objID and Me and Me:isValid() then
        Me:playSoundByKey(graffitiSetting.soundKey, graffitiSetting.soundTime)
      end
    end)
  end
end
