local WorldCommonTipsConfig = T(Config, "WorldCommonTipsConfig")
local settings = {}

function WorldCommonTipsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/world_common_tips.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.tip_type = tonumber(vConfig.n_tip_type) or 0
    data.quality_limit = tonumber(vConfig.n_quality_limit) or 0
    data.wash_growthS_num = tonumber(vConfig.n_wash_growthS_num) or 0
    data.show_type = Lib.split(vConfig.s_show_type, "#")
    data.tip_desc = vConfig.s_tip_desc or ""
    data.star_level = tonumber(vConfig.n_star_level) or 0
    data.synthetic_num = tonumber(vConfig.n_synthetic_num) or 0
    settings[data.id] = data
  end
end

function WorldCommonTipsConfig:getConfigById(Id)
  return settings[tonumber(Id)]
end

function WorldCommonTipsConfig:getConfigByTipTypeAndLimit(tipsInfo)
  local resultIds = {}
  for key, val in pairs(settings) do
    if val.tip_type == tipsInfo.tipType then
      local match = true
      if match and val.quality_limit > 0 and tipsInfo.quality and val.quality_limit > tipsInfo.quality then
        match = false
      end
      if match and 0 < val.wash_growthS_num and tipsInfo.growthSCount and val.wash_growthS_num > tipsInfo.growthSCount then
        match = false
      end
      if match and 0 < val.star_level and tipsInfo.starLevel and val.star_level > tipsInfo.starLevel then
        match = false
      end
      if match and 0 < val.synthetic_num and tipsInfo.syntheticNum and val.synthetic_num > tipsInfo.syntheticNum then
        match = false
      end
      if match then
        table.insert(resultIds, val.id)
      end
    end
  end
  return resultIds
end

return WorldCommonTipsConfig
