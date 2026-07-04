local PartSceneNameConfig = T(Config, "PartSceneNameConfig")
local settings = {}

function PartSceneNameConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/part_scene_name.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      partName = vConfig.s_partName or "",
      showName = vConfig.s_showName or "",
      showOffset = Lib.createV3ByString(vConfig.s_showOffset),
      showRange = tonumber(vConfig.n_showRange) or 0,
      isAutoScale = (tonumber(vConfig.n_isAutoScale) or 0) == 1,
      minScale = tonumber(vConfig.n_minScale) or 0.1,
      maxScale = tonumber(vConfig.n_maxScale) or 1
    }
    settings[data.partName] = data
  end
end

function PartSceneNameConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPartSceneNameConfig, id:", id)
    return
  end
  return settings[id]
end

function PartSceneNameConfig:getAllCfgs()
  return settings
end

PartSceneNameConfig:init()
return PartSceneNameConfig
