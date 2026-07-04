local DramaCoverConfig = T(Config, "DramaCoverConfig")
local settings = {}

function DramaCoverConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/drama_cover.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      img = vConfig.s_img or "",
      smallImg = vConfig.s_smallImg or ""
    }
    settings[data.id] = data
  end
end

function DramaCoverConfig:getCfgById(id)
  local newId = tonumber(id)
  if not newId or not settings[newId] then
    Lib.logError("can not find cfgDramaCoverConfig, id:", id)
    return
  end
  return settings[newId]
end

function DramaCoverConfig:getAllCfgs()
  return settings
end

DramaCoverConfig:init()
return DramaCoverConfig
