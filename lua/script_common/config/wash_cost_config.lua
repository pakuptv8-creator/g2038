local WashCostConfig = T(Config, "WashCostConfig")
local setting = require("common.setting")
local settings = {}
local cfgs = setting:modCfgs("item")

local function toTable(str)
  local data = Lib.splitString(str or "", "#")
  for key, childStr in pairs(data) do
    data[key] = Lib.splitString(childStr, ",")
    if #data[key] == 1 then
      data[key] = data[key][1]
    end
  end
  return data
end

local function getFullName(itemId)
  local fullName
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemId) == tonumber(itemId) then
      fullName = _fullName
      break
    end
  end
  return fullName
end

local function initSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/wash_cost.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.lockNum = tonumber(vConfig.lockNum) or 0
    data.costMap = toTable(vConfig.costMap) or {}
    for _, cost in pairs(data.costMap) do
      local itemId = cost[1]
      cost[1] = getFullName(itemId)
      cost[2] = tonumber(cost[2]) or 99999
    end
    settings[vConfig.id] = data
  end
end

function WashCostConfig:init()
  initSetting()
end

function WashCostConfig:getConfigById(Id)
  return settings[tostring(Id)]
end

function WashCostConfig:getCostMap(lockNum)
  for _, config in pairs(settings) do
    if tonumber(lockNum) == config.lockNum then
      return config.costMap
    end
  end
  return {}
end

WashCostConfig:init()
return WashCostConfig
