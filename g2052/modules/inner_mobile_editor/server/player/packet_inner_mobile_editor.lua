local cjson = require("cjson")
local handles = T(Player, "PackageHandlers")

function handles:EnterEditorMode()
  Plugins.CallTargetPluginFunc("interaction_ui", "cleanPlayerAllInteraction", self)
  self:removePetFromWorld(true)
  local map = World.CurWorld:createDynamicMap("map_empty", true)
  local oldPos = self:getPosition()
  self.enterEditorModePos = oldPos
  self:setMapPos(map, map.cfg.initPos)
  self:setProp("gravity", -0.08)
  Plugins.CallPluginFunc("ENTER_MOBILE_EDITOR_MODE", self)
  local VehicleManager = T(Lib, "VehicleManager")
  VehicleManager:removeSummonedVehicle(self.platformUserId)
  return true
end

function handles:LeaveEditorMode(packet)
  Plugins.CallTargetPluginFunc("interaction_ui", "cleanPlayerAllInteraction", self)
  local map
  if packet.leaveType == "reEnter" then
    map = World.CurWorld:createDynamicMap("map_empty_temp", true)
  else
    map = World.CurWorld:getOrCreateStaticMap("map001")
    self:resetInitGravity()
  end
  if self.enterEditorModePos then
    local targetPos = Lib.copy(self.enterEditorModePos)
    targetPos.y = targetPos.y + 2
    self:setMapPos(map, self.enterEditorModePos)
  else
    self:setMapPos(map, World.cfg.initPos)
  end
  Plugins.CallPluginFunc("LEAVE_MOBILE_EDITOR_MODE", self)
  self:removeUsingVehicle()
  local VehicleManager = T(Lib, "VehicleManager")
  VehicleManager:removeSummonedVehicle(self.platformUserId)
end

function handles:EditorPlayerModel(packet)
  local mapCfg = cjson.decode(packet.mapCfg)
  local mapName = packet.mapName
  Plugins.CallTargetPluginFunc("engine_overwrite", "addMapCfg", mapName, mapCfg)
  local map = World.CurWorld:createDynamicMap(mapName, true)
  self:setMapPos(map, map.cfg.initPos)
  self:resetInitGravity()
  Plugins.CallTargetPluginFunc("engine_overwrite", "removeMapCfg", mapName)
end
