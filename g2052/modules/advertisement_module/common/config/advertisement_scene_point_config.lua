local AdvertisementScenePointConfig = T(Config, "AdvertisementScenePointConfig")
local settings = {}
local type_settings = {}

function AdvertisementScenePointConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/advertisement_scene_point.csv", 2)
  for _, vConfig in pairs(config) do
    local parse_v3 = Lib.splitString(vConfig.s_point, "#", true)
    local itemType = tonumber(vConfig.n_itemType) or 0
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      point = Lib.v3(parse_v3[1], parse_v3[2], parse_v3[3]),
      yaw = tonumber(vConfig.n_yaw) or 0,
      itemType = itemType
    }
    settings[data.id] = data
    local type_list = type_settings[itemType] or {}
    type_list[#type_list + 1] = data
    type_settings[itemType] = type_list
  end
end

function AdvertisementScenePointConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find AdvertisementScenePointItem, id:", tostring(id))
    return
  end
  return settings[id]
end

function AdvertisementScenePointConfig:getTypeCfgs(itemType)
  if not type_settings[itemType] then
    Lib.logError("can not find AdvertisementScenePointItem, itemType:", tostring(itemType))
    return
  end
  local type_list = type_settings[itemType]
  local copy_list = {}
  for i = 1, #type_list do
    copy_list[#copy_list + 1] = type_list[i]
  end
  return copy_list
end

function AdvertisementScenePointConfig:getAllCfgs()
  return settings
end

AdvertisementScenePointConfig:init()
return AdvertisementScenePointConfig
