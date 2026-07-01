local BlessItemConfig = T(Config, "BlessItemConfig")
local setting = require("common.setting")
local settings = {}
local cfgs = setting:modCfgs("item")

local function initDetail(data)
  local fullName
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemId) == tonumber(data.itemId) then
      data.fullName = _fullName
      data.desc = cfg.desc
      break
    end
  end
  return fullName
end

local function initSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_bless_item.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.lockNum = tonumber(vConfig.lockNum) or 0
    data.bless_type = tonumber(vConfig.bless_type) or 0
    data.bless_level = tonumber(vConfig.bless_level) or 0
    data.bless_value = tonumber(vConfig.bless_value) or 0
    data.itemId = tonumber(vConfig.itemId) or 0
    initDetail(data)
    if data.fullName then
      settings[vConfig.id] = data
    end
  end
end

function BlessItemConfig:init()
  initSetting()
end

function BlessItemConfig:getConfigByTypeAndLevel(type, level)
  type = tonumber(type)
  level = tonumber(level)
  for _, config in pairs(settings) do
    if config.bless_type == type and config.bless_level == level then
      return config
    end
  end
end

function BlessItemConfig:getAllConfig()
  local configs = {}
  for _, config in pairs(settings) do
    table.insert(configs, config)
  end
  return configs
end

function BlessItemConfig:getConfigByFullName(fullName)
  for _, config in pairs(settings) do
    if config.fullName == fullName then
      return config
    end
  end
end

function BlessItemConfig:getConfigListByType(type)
  local list = {}
  for _, config in pairs(settings) do
    if config.bless_type == type then
      table.insert(list, config)
    end
  end
  return list
end

BlessItemConfig:init()
return BlessItemConfig
