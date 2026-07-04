local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local settings = {}

function LimitedTimeGiftItemConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_gift_item.csv", 3)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_gift_item.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      awardId = tonumber(vConfig.n_awardId) or 0,
      awardType = tonumber(vConfig.n_awardType) or 0,
      itemId = tonumber(vConfig.n_itemId) or 0,
      itemName = vConfig.s_itemName or "",
      name = vConfig.s_name or "",
      dec = vConfig.s_dec or "",
      itemCount = tonumber(vConfig.n_itemCount) or 0,
      actorName = vConfig.s_actor_name or "",
      actorScale = tonumber(vConfig.n_actor_scale) or 1,
      actorRotateY = tonumber(vConfig.n_actor_rotateY) or 0,
      actorRotateX = tonumber(vConfig.n_actor_rotateX) or 0
    }
    local uiOffset = Lib.splitString(vConfig.s_actor_uiOffset or "", "#", true)
    data.actorUIOffset = Lib.v2(uiOffset[1] or 0, uiOffset[2] or 0)
    if vConfig.s_itemIcon and vConfig.s_itemIcon ~= "" then
      data.itemIcon = vConfig.s_itemIcon
    end
    if vConfig.n_quality and vConfig.n_quality ~= "" then
      data.quality = tonumber(vConfig.n_quality) or 0
    end
    if vConfig.s_extraParams and vConfig.s_extraParams ~= "" then
      data.extraParams = vConfig.s_extraParams
    end
    if vConfig.s_showName and vConfig.s_showName ~= "" then
      data.showName = vConfig.s_showName
    end
    if vConfig.s_showDesc and vConfig.s_showDesc ~= "" then
      data.showDesc = vConfig.s_showDesc
    end
    settings[data.awardId] = data
  end
end

function LimitedTimeGiftItemConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeGiftItemConfig, id:", id)
    return {}
  end
  return Lib.copy(settings[id])
end

function LimitedTimeGiftItemConfig:getAllCfgs()
  return Lib.copy(settings)
end

LimitedTimeGiftItemConfig:init()
return LimitedTimeGiftItemConfig
