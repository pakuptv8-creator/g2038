local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
local settings = {}

function RechargeAwardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/rechargeAward.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.type = tonumber(vConfig.n_type) or 0
    data.goodType = tonumber(vConfig.n_goodType) or 0
    data.pkmId = tonumber(vConfig.n_pkmId) or 0
    data.fullName = vConfig.s_fullName or ""
    data.icon = vConfig.s_icon or ""
    data.count = tonumber(vConfig.n_count) or 0
    data.condition = tonumber(vConfig.n_condition) or 0
    data.initValue = tonumber(vConfig.n_initValue) or 0
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.id < b.id
  end)
end

function RechargeAwardConfig:getItemByItemId(itemId)
  for i, item in pairs(settings) do
    if item.id == itemId then
      return item
    end
  end
end

function RechargeAwardConfig:getItems()
  return settings
end

function RechargeAwardConfig:getRewardTypeItems(awardType, goodType)
  local Items1 = {}
  local condition
  local totalValue = 0
  for i, item in pairs(settings) do
    if item.type == awardType then
      table.insert(Items1, item)
      condition = item.condition
      totalValue = totalValue + item.initValue
    end
  end
  if goodType then
    Items1 = self:getRewardBySex(Items1, goodType)
  end
  return Items1, condition, totalValue
end

function RechargeAwardConfig:getRewardBySex(Items, goodType)
  local Items1 = {}
  for i, item in pairs(Items) do
    if item.sex == goodType then
      table.insert(Items1, item)
    end
  end
  return Items1
end

return RechargeAwardConfig
