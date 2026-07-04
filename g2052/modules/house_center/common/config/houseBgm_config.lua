local HouseBgmConfig = T(Config, "HouseBgmConfig")
local settings = {}

function HouseBgmConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/houseBgm.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      soundKey = vConfig.s_soundKey,
      name = vConfig.s_name or ""
    }
    settings[data.id] = data
  end
end

function HouseBgmConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgHouseBgmConfig, id:", id)
    return
  end
  return settings[id]
end

function HouseBgmConfig:getAllCfgs()
  return settings
end

function HouseBgmConfig:getIdByKey(key)
  local id
  for i, v in pairs(settings) do
    if v.soundKey == key then
      id = i
      break
    end
  end
  return id
end

HouseBgmConfig:init()
return HouseBgmConfig
