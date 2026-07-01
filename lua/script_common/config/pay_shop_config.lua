local PayShopConfig = T(Config, "PayShopConfig")
local settings = {}

function PayShopConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pay_shop.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.tabId = tonumber(vConfig.n_tabId) or 0
    data.subTabId = tonumber(vConfig.n_subTabId) or 0
    data.sort_id = tonumber(vConfig.s_sort_id) or 0
    data.name = vConfig.s_name or ""
    data.itemName = vConfig.s_itemName or ""
    data.desc = vConfig.s_desc or ""
    data.currencyType = tonumber(vConfig.n_currencyType) or 0
    data.originalPrice = tonumber(vConfig.n_originalPrice) or 0
    data.discount = tonumber(vConfig.n_discount) or 1
    data.buyCount = tonumber(vConfig.n_buyCount) or 0
    data.levelLimit = vConfig.s_levelLimit or ""
    data.showRedDot = tonumber(vConfig.n_showRedDot) or 0
    data.showEffect = tonumber(vConfig.n_showEffect) or 0
    data.weight = vConfig.s_weight or ""
    data.icon = vConfig.s_icon or ""
    data.itemCount = tonumber(vConfig.n_itemCount) or 0
    data.rarity = tonumber(vConfig.n_rarity) or 1
    if World.cfg.useFDiamonds and data.currencyType == 0 then
      data.currencyType = 4
    end
    if data.currencyType == 0 then
      data.isPay = true
    else
      data.isPay = false
    end
    data.items = {}
    local itemNames = Lib.split(tostring(data.itemName), "#")
    local itemCounts = Lib.split(tostring(data.itemCount), "#")
    for i, itemName in pairs(itemNames) do
      data.items[itemName] = tonumber(itemCounts[i])
    end
    data.isShow = true
    if data.weight ~= "" then
      data.weightInfo = {}
      local info = Lib.split(tostring(data.weight), "#")
      data.weightInfo.group = tonumber(info[1])
      data.weightInfo.weight = tonumber(info[2])
      data.isShow = false
    end
    if data.levelLimit ~= "" then
      data.levelLimitInfo = {}
      local info = Lib.split(tostring(data.levelLimit), "#")
      data.levelLimitInfo.min = tonumber(info[1])
      data.levelLimitInfo.max = tonumber(info[2])
      data.isShow = false
    end
    table.insert(settings, data)
  end
end

function PayShopConfig:getSettings()
  return settings
end

function PayShopConfig:getNeatenAfterSettings(newData)
  local items = newData
  if not items or not next(items) then
    items = settings
  end
  local data = {}
  for _, setting in pairs(items) do
    if not data[setting.tabId] then
      data[setting.tabId] = {}
    end
    if not data[setting.tabId][setting.subTabId] then
      data[setting.tabId][setting.subTabId] = {}
    end
    table.insert(data[setting.tabId][setting.subTabId], setting)
  end
  return data
end

function PayShopConfig:getNeatenAfterSettingsByBuyInfo(buyInfo)
  local items = {}
  local playerLevel = Me:getPlayerLevel()
  for _, setting in pairs(Lib.copy(settings)) do
    local isRandomShow = false
    local isLevelShow = true
    if setting.levelLimitInfo and (playerLevel < setting.levelLimitInfo.min or playerLevel > setting.levelLimitInfo.max) then
      isLevelShow = false
    end
    for _, itemId in pairs(buyInfo.randomItem or {}) do
      if setting.id == itemId then
        isRandomShow = true
      end
    end
    if isLevelShow and isRandomShow or setting.isShow then
      table.insert(items, setting)
    end
  end
  for itemId, count in pairs(buyInfo.haveBuy or {}) do
    for _, item in pairs(items) do
      if itemId == item.id then
        item.curBuyCount = count
        break
      end
    end
  end
  return self:getNeatenAfterSettings(items)
end

function PayShopConfig:getItemByItemId(itemId)
  local item
  for _, setting in pairs(settings) do
    if itemId == setting.id then
      item = setting
    end
  end
  return item
end

local function getRandomItemId(items)
  local itemId
  local max = 0
  local weights = {}
  for _, item in pairs(items or {}) do
    weights[item.id] = {}
    table.insert(weights[item.id], max + 1)
    max = max + item.weightInfo.weight
    table.insert(weights[item.id], max)
  end
  if 0 < max then
    local num = math.random(max)
    for id, weight in pairs(weights or {}) do
      if num >= weight[1] and num <= weight[2] then
        itemId = id
      end
    end
  end
  return itemId
end

function PayShopConfig:getNewRandomItems()
  local weightInfoArr = {}
  for _, setting in pairs(settings) do
    if setting.weightInfo then
      if weightInfoArr[setting.weightInfo.group] then
        table.insert(weightInfoArr[setting.weightInfo.group], setting)
      else
        weightInfoArr[setting.weightInfo.group] = {}
        table.insert(weightInfoArr[setting.weightInfo.group], setting)
      end
    end
  end
  local randomItems = {}
  for group, items in pairs(weightInfoArr or {}) do
    randomItems[group] = getRandomItemId(items)
  end
  return randomItems
end

return PayShopConfig
