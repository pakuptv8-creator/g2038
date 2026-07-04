local AdvertisementScenePartConfig = T(Config, "AdvertisementScenePartConfig")
local settings = {}

function AdvertisementScenePartConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/advertisement_scene_part.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      itemType = tonumber(vConfig.n_itemType) or 0,
      itemId = tonumber(vConfig.n_itemId) or 0,
      itemCount = tonumber(vConfig.n_itemCount) or 0,
      offsetY = tonumber(vConfig.n_offsetY) or 0,
      btnOffsetY = tonumber(vConfig.n_btnOffsetY) or 0
    }
    settings[data.id] = data
  end
end

function AdvertisementScenePartConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find AdvertisementScenePartItem, id:", tostring(id))
    return
  end
  return settings[id]
end

function AdvertisementScenePartConfig:getAllCfgs()
  return settings
end

AdvertisementScenePartConfig:init()
return AdvertisementScenePartConfig
