local EmergencyConfig = T(Config, "EmergencyConfig")
local settings = {}

function EmergencyConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/emergency.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      name = vConfig.s_name or "",
      trigger_interval = tonumber(vConfig.n_trigger_interval) or 0,
      trigger_probability = tonumber(vConfig.n_trigger_probability) or 0,
      notified_profession = tonumber(vConfig.n_notified_profession) or -1
    }
    settings[data.id] = data
  end
end

function EmergencyConfig:getCfgById(id)
  if not settings[id] then
    return
  end
  return settings[id]
end

function EmergencyConfig:getAllCfg()
  return settings
end

EmergencyConfig:init()
return EmergencyConfig
