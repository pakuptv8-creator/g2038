local GraffitiConfig = T(Config, "GraffitiConfig")
local settings = {}

function GraffitiConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/graffiti.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      imagePath = vConfig.s_imagePath or ""
    }
    table.insert(settings, data)
  end
end

function GraffitiConfig:getCfgById(id)
  for key, val in pairs(settings) do
    if id == val.id then
      return val
    end
  end
  Lib.logError("can not find cfgGraffitiConfig, id:", id)
  return
end

function GraffitiConfig:getAllCfgs()
  return settings
end

function GraffitiConfig:getOneRandomCfg()
  local key = math.random(1, #settings)
  return settings[key]
end

GraffitiConfig:init()
return GraffitiConfig
