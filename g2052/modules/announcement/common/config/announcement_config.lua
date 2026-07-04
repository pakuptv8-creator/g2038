local AnnouncementConfig = T(Config, "AnnouncementConfig")
local settings = {}

function AnnouncementConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/announcement.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      title = vConfig.s_title or "",
      desc = vConfig.s_desc or "",
      icon = vConfig.s_icon or "",
      tagType = tonumber(vConfig.n_tagType) or 0,
      mapPos = vConfig.s_mapPos or "",
      uiName = vConfig.s_uiName or ""
    }
    settings[data.id] = data
  end
end

function AnnouncementConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgAnnouncementConfig, id:", id)
    return
  end
  return settings[id]
end

function AnnouncementConfig:getAllCfgs()
  return settings
end

AnnouncementConfig:init()
return AnnouncementConfig
