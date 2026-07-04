local CarBgmConfig = T(Config, "CarBgmConfig")
local settings = {}

function CarBgmConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/carBgm.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      soundKey = vConfig.s_soundKey or "",
      name = vConfig.s_name or ""
    }
    settings[data.id] = data
  end
end

function CarBgmConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgCarBgmConfig, id:", id)
    return
  end
  return settings[id]
end

function CarBgmConfig:getAllCfgs()
  return settings
end

function CarBgmConfig:getBgmList()
  local ret = {}
  for _, v in pairs(settings) do
    ret[#ret + 1] = v
  end
  table.sort(ret, function(a, b)
    return a.id < b.id
  end)
  return ret
end

function CarBgmConfig:getIdByKey(key)
  local id
  for i, v in pairs(settings) do
    if v.soundKey == key then
      id = i
      break
    end
  end
  return id
end

CarBgmConfig:init()
return CarBgmConfig
