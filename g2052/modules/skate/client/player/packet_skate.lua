local handles = T(Player, "PackageHandlers")
local InteractionHelper = T(Lib, "InteractionHelper")

function handles:playSkateAnimNotice(packet)
  if packet.playerAnim then
    local playerObjId = packet.playerObjId
    local playerEntity = World.CurWorld:getEntity(playerObjId)
    if not playerEntity or playerEntity:isValid() then
    end
    local actionKey = "skateAction_" .. packet.skateObjId
    local actionData = {
      priority = Define.ActionMapPriority.skatePriority,
      actionName = packet.playerAnim,
      actionTime = -1,
      actionType = "skatePlayer"
    }
    InteractionHelper:updateEntityActionData(playerObjId, actionKey, true, actionData)
  end
  if packet.skateAnim then
    local skateObjId = packet.skateObjId
    local skateEntity = World.CurWorld:getEntity(skateObjId)
    if skateEntity and skateEntity:isValid() then
      skateEntity:updateUpperAction(packet.skateAnim, -1)
    end
  end
end
