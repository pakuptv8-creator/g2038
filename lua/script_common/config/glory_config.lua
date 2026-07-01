local GloryConfig = T(Config, "GloryConfig")
local settings = {}

function GloryConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/glory.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.icon = vConfig.s_icon or ""
    data.type = tonumber(vConfig.n_type) or 0
    data.type_int = tonumber(vConfig.n_type_int) or 0
    data.rare = tonumber(vConfig.n_rare) or 0
    data.name = vConfig.s_name or ""
    data.title = vConfig.s_title or ""
    data.info = vConfig.s_info or ""
    data.mutex = tonumber(vConfig.n_mutex) or 0
    data.forever = tonumber(vConfig.n_forever) or 0
    data.lost_time = tonumber(vConfig.n_lost_time) or 0
    data.effect = vConfig.s_effect or ""
    table.insert(settings, data)
  end
end

function GloryConfig:getAllData()
  return settings
end

function GloryConfig:getGloryById(id)
  return settings[id]
end

function GloryConfig:getGloryIdByGymIdAndGymProgress(gymId, gymProgress)
  for _, glory in pairs(settings) do
    if glory.type == gymId and glory.type_int == gymProgress then
      return glory.id
    end
  end
  return false
end

return GloryConfig
