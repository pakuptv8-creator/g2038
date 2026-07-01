local WorldServer = _ENV.WorldServer
local Map = T(World, "Map")
local engine_loadMap = WorldServer.loadMap

function WorldServer:loadMap(...)
  local id, name, static = ...
  local cfg = Map.GetCfg(name)
  if cfg and type(cfg.battleFieldPos) == "table" then
    setmetatable(cfg.battleFieldPos, {
      __newindex = function(t, k, v)
        Lib.logInfo("battleFieldPos", k, debug.traceback())
      end
    })
    Lib.logDebug("setmetatable battleFieldPos")
  end
  local map = engine_loadMap(self, ...)
  return map
end
