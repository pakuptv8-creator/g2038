local ProfessionRecommendConfig = T(Config, "ProfessionRecommendConfig")
local settings = {}

function ProfessionRecommendConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/profession_recommend.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      remark = vConfig.s_remark or "",
      totalNum = tonumber(vConfig.n_totalNum) or 0,
      recommendType1 = tonumber(vConfig.n_recommendType1) or 0,
      recommendId1 = tonumber(vConfig.n_recommendId1) or 0,
      recommendType2 = tonumber(vConfig.n_recommendType2) or 0,
      recommendId2 = tonumber(vConfig.n_recommendId2) or 0,
      recommendType3 = tonumber(vConfig.n_recommendType3) or 0,
      recommendId3 = tonumber(vConfig.n_recommendId3) or 0,
      recommendType4 = tonumber(vConfig.n_recommendType4) or 0,
      recommendId4 = tonumber(vConfig.n_recommendId4) or 0,
      recommendType5 = tonumber(vConfig.n_recommendType5) or 0,
      recommendId5 = tonumber(vConfig.n_recommendId5) or 0,
      recommendList = {}
    }
    settings[data.id] = data
  end
  self:transData()
end

function ProfessionRecommendConfig:transData()
  for _, data in pairs(settings) do
    for i = 1, data.totalNum do
      local type = data["recommendType" .. i] or 0
      local id = data["recommendId" .. i] or 0
      if 0 < type and 0 < id then
        local t = {}
        t.recommendType = type
        t.recommendId = id
        table.insert(data.recommendList, t)
      end
    end
  end
end

function ProfessionRecommendConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgProfessionRecommendConfig, id:", id)
    return
  end
  return settings[id]
end

function ProfessionRecommendConfig:getAllCfgs()
  return settings
end

function ProfessionRecommendConfig:getRecommendListById(id)
  if not settings[id] then
    Lib.logError("getRecommendListById,can not find cfgProfessionRecommendConfig, id:", id)
    return
  end
  return settings[id].recommendList
end

ProfessionRecommendConfig:init()
return ProfessionRecommendConfig
