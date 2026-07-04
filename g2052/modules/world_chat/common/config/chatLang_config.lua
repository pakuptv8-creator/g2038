local ChatLangConfig = T(Config, "ChatLangConfig")
local settings = {}

function ChatLangConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/chatLang.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      langName = vConfig.s_langName or "",
      sortID = tonumber(vConfig.n_sortID) or 0
    }
    if data.langName == World.LangPrefix then
      data.index = 1
    else
      data.index = 2
    end
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    if a.index == b.index then
      return a.sortID < b.sortID
    end
    return a.index < b.index
  end)
end

function ChatLangConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgChatLangConfig, id:", id)
    return
  end
  return settings[id]
end

function ChatLangConfig:getCfgByLang(lang)
  for key, val in pairs(settings) do
    if val.langName == lang then
      return val
    end
  end
  return false
end

function ChatLangConfig:getAllCfgs()
  return settings
end

ChatLangConfig:init()
return ChatLangConfig
