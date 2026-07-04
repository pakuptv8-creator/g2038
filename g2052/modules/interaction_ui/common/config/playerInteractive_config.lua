local PlayerInteractiveConfig = T(Config, "PlayerInteractiveConfig")
local settings = {}

function PlayerInteractiveConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/playerInteractive.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      normalIcon = vConfig.s_normalIcon or "",
      actionName = vConfig.s_actionName or "",
      ridePos = tonumber(vConfig.n_ridePos) or 1
    }
    settings[data.id] = data
  end
end

function PlayerInteractiveConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPlayerInteractiveConfig, id:", id)
    return
  end
  return settings[id]
end

function PlayerInteractiveConfig:getAllCfgs()
  return settings
end

PlayerInteractiveConfig:init()
return PlayerInteractiveConfig
