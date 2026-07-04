local handles = Player.PackageHandlers
local Interact = T(World, "Interact")

function handles:interact(packet)
  local prop = packet.prop
  if Interact[prop.func] then
    local target = World.CurWorld:getEntity(packet.targetID)
    local from = World.CurWorld:getEntity(packet.fromID)
    local exec_result = Interact[prop.func](target, prop.params, from, not packet.disable, packet.params)
    if exec_result and prop.executionCallback then
      Interact.tryInteract(target, prop.executionCallback, from, packet)
    end
  end
end

function handles:interactBroadcast(packet)
  WorldServer.BroadcastPacket({
    pid = "interact",
    targetID = packet.targetID,
    fromID = self.objID,
    prop = packet.prop,
    disable = packet.disable
  })
end

function handles:interactDungeonBroadcast(packet)
  local map = self.map
  if map then
    packet = {
      pid = "interact",
      targetID = packet.targetID,
      fromID = packet.objID,
      prop = packet.prop,
      disable = packet.disable
    }
    Plugins.CallTargetPluginFunc("dungeon", "dungeonBroadcastPacketByMap", map, packet)
  else
    print("dungeon no map !!!!!!!!!!!!!!!!!!!!!!!!!!!")
  end
end

if World.isClient then
  function handles:showNumProgress(packet)
    Plugins.CallTargetPluginFunc("common", "showNumProgress", packet)
  end
end
