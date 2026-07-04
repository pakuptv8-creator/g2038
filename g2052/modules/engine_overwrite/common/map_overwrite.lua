local setting = require("common.setting")
local World = _ENV.World
local Map = T(World, "Map")
local AllCfg = T(Map, "AllCfg")
local aloneList = T(setting, "aloneList")
local MapOverWrite = T(Lib, "MapOverWrite")

function MapOverWrite:addMapCfg(key, cfg)
  local dir = "map/" .. key .. "/"
  AllCfg[key] = cfg
  if World.isClient then
    local newCompletePath = Lib.combinePath(Root.Instance():getGamePath(), dir)
    if not Lib.fileExists(newCompletePath) then
      Lib.mkPath(newCompletePath)
    end
    local newFilePath = Lib.combinePath(dir, "setting.json")
    Lib.saveGameJson(newFilePath, cfg)
  end
  
  function cfg.onReload()
  end
  
  cfg.dir = dir
end

function MapOverWrite:removeMapCfg(key)
  AllCfg[key] = nil
  if World.isClient then
    local dir = "map/" .. key .. "/"
    aloneList[dir] = nil
    local newCompletePath = Lib.combinePath(Root.Instance():getGamePath(), dir)
    Lib.rmdir(newCompletePath)
  end
end
