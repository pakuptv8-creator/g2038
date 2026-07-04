local ChatShortLangConfig = T(Config, "ChatShortLangConfig")
local settings = {}

function ChatShortLangConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/chat_short_lang.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      shortTitle = vConfig.s_shortTitle or "",
      shortDesc = vConfig.s_shortDesc or ""
    }
    data.triggerType = {}
    local triggers = Lib.splitString(vConfig.s_triggerType or "", "#", true)
    for _, val in pairs(triggers) do
      data.triggerType[val] = true
    end
    data.actionList = Lib.splitString(vConfig.s_actionName or "", "#")
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.sortId < b.sortId
  end)
end

function ChatShortLangConfig:getCfgById(id)
  for _, val in pairs(settings) do
    if val.id == id then
      return val
    end
  end
  Lib.logError("can not find cfgChatShortLangConfig, id:", id)
end

function ChatShortLangConfig:getAllCfgs()
  return settings
end

function ChatShortLangConfig:getAllCfgByTriggerType(key)
  local result = {}
  for _, val in pairs(settings) do
    if val.triggerType[key] then
      table.insert(result, val)
    end
  end
  return result
end

function ChatShortLangConfig:getOneShortActionById(id)
  local actionList = {}
  for _, val in pairs(settings) do
    if val.id == id then
      actionList = val.actionList
    end
  end
  local totalNum = #actionList
  if 0 < totalNum then
    local num = math.random(1, totalNum)
    return actionList[num]
  end
  return false
end

ChatShortLangConfig:init()
return ChatShortLangConfig
