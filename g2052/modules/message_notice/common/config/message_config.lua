local MessageConfig = T(Config, "MessageConfig")
local settings = {}

function MessageConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/message.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      white = (tonumber(vConfig.n_white) or 0) == 1,
      remark = vConfig.s_remark or "",
      icon = vConfig.s_icon or "",
      text = vConfig.s_text or "",
      showTime = tonumber(vConfig.n_showTime) or 0,
      broadcast = tonumber(vConfig.n_broadcast) or 0,
      level = tonumber(vConfig.n_level) or 0,
      push_cd = tonumber(vConfig.n_pushCD) or 0,
      check_player_cd = tonumber(vConfig.n_checkPlayerCD) or 0,
      p1 = vConfig.s_p1 or ""
    }
    settings[data.id] = data
  end
end

function MessageConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgMessageConfig, id:", id)
    return
  end
  return settings[id]
end

function MessageConfig:needCheckSendCD(id)
  if not settings[id] then
    return false
  end
  return settings[id].check_player_cd > 0
end

function MessageConfig:getAllCfgs()
  return settings
end

function MessageConfig:isBroadCast(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.broadcast == 1
  end
  return false
end

MessageConfig:init()
return MessageConfig
