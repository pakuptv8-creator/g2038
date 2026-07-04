local table_insert = table.insert
local MonitorConfig = T(Config, "MonitorConfig")
local settings = {}

function MonitorConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/monitor.csv", 2)
  for _, vConfig in pairs(config) do
    local id = tonumber(vConfig.n_id) or 0
    local data = {
      id = id,
      index = tonumber(vConfig.n_index) or 0,
      partName = vConfig.s_partName or ""
    }
    if not settings[id] then
      settings[id] = {}
    end
    table_insert(settings[data.id], data)
  end
  for _, v in pairs(settings) do
    table.sort(v, function(a, b)
      return a.index < b.index
    end)
  end
end

function MonitorConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgMonitorConfig, id:", id)
    return
  end
  return settings[id]
end

function MonitorConfig:getAllCfgs()
  return settings
end

MonitorConfig:init()
return MonitorConfig
