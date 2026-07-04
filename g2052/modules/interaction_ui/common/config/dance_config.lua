local DanceConfig = T(Config, "DanceConfig")
local settings = {}

function DanceConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/dance.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sort = tonumber(vConfig.n_sort) or 0,
      danceName = vConfig.s_danceName or "",
      actionName = vConfig.s_actionName or "",
      actionTime = tonumber(vConfig.n_actionTime) or 0,
      showRight = tonumber(vConfig.n_showRight) or 1,
      chatActionMap = vConfig.s_chatActionMap or ""
    }
    data.chatActionMapList = Lib.splitString(data.chatActionMap, "#")
    settings[data.id] = data
  end
end

function DanceConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgDanceConfig, id:", id)
    return
  end
  return settings[id]
end

function DanceConfig:getAllCfgs()
  return settings
end

function DanceConfig:getCfgByActonName(actionName)
  for id, val in pairs(settings) do
    if val.actionName == actionName then
      return id
    end
  end
  return -1
end

function DanceConfig:getChatMsgActionId(msg)
  for id, val in pairs(settings) do
    for _, keyStr in pairs(val.chatActionMapList) do
      if msg == keyStr then
        return id
      end
    end
  end
  return -1
end

function DanceConfig:getCfgMapById(id)
  if not settings[id] then
    Lib.logError("can not find getCfgMapById, id:", id)
    return
  end
  local danceCfg = settings[id]
  local mapVal = {}
  return mapVal
end

DanceConfig:init()
return DanceConfig
