local DisasterConfig = T(Config, "DisasterConfig")
local settings = {}

function DisasterConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/disaster.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      disasterName = vConfig.s_disasterName or "",
      isFree = tonumber(vConfig.n_isFree) or 0,
      messageNoticeId = tonumber(vConfig.n_messageNoticeId) or 0,
      selectCD = tonumber(vConfig.n_selectCD) or 0
    }
    data.switchPartList = Lib.splitString(vConfig.s_switchPart, "#")
    settings[data.id] = data
  end
end

function DisasterConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgDisasterConfig, id:", id)
    return
  end
  return settings[id]
end

function DisasterConfig:getAllCfgs()
  return settings
end

DisasterConfig:init()
return DisasterConfig
