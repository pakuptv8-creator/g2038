local AdvertisementPoolConfig = T(Config, "AdvertisementPoolConfig")
local settings = {}
local settings_list = {}

function AdvertisementPoolConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/advertisement_pool.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      itemType = tonumber(vConfig.n_itemType) or 0,
      itemId = tonumber(vConfig.n_itemId) or 0,
      itemCount = tonumber(vConfig.n_itemCount) or 0,
      weight = tonumber(vConfig.n_weight) or 0
    }
    settings[data.id] = data
    settings_list[#settings_list + 1] = data
  end
end

function AdvertisementPoolConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgAnnouncementConfig, id:", id)
    return
  end
  return settings[id]
end

function AdvertisementPoolConfig:getAllCfgs()
  return settings_list
end

AdvertisementPoolConfig:init()
return AdvertisementPoolConfig
