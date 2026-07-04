local AppearanceConfig = T(Config, "AppearanceConfig")
local table_insert = table.insert
local table_remove = table.remove
local random = math.random
local settings = {}

function AppearanceConfig:init()
  local config_category = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/appearance_category.csv", 2)
  for _, vConfig in pairs(config_category) do
    local category = tonumber(vConfig.n_category) or 0
    if not settings[category] then
      settings[category] = {
        list = {}
      }
    end
    if vConfig.s_categoryIcon ~= "" then
      settings[category].icon = vConfig.s_categoryIcon
      settings[category].category = category
    end
    local id = tonumber(vConfig.n_id) or 0
    settings[category].list[id] = {
      tabIcon = vConfig.s_tabIcon,
      member = {},
      id = id
    }
  end
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/appearance.csv", 2)
  for _, vConfig in pairs(config) do
    local index = tonumber(vConfig.n_index)
    local category = tonumber(string.sub(index, 1, 1))
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      icon = vConfig.s_icon or "",
      priority = tonumber(vConfig.n_priority) or 0,
      isNew = tonumber(vConfig.n_isNew) or 0,
      lockState = tonumber(vConfig.n_lockState) or 0,
      lockTips = vConfig.s_lockTips ~= "" and vConfig.s_lockTips,
      needBuy = tonumber(vConfig.n_needBuy) or 0,
      isWatchAd = tonumber(vConfig.n_isWatchAd) or 0
    }
    local partName = vConfig.s_partName or ""
    local allPart = Lib.splitString(partName, ";")
    local parts = {}
    for _, v in ipairs(allPart) do
      local partArr = Lib.splitString(v, "#")
      parts[partArr[1]] = partArr[2]
    end
    data.parts = parts
    local conflictParts = vConfig.s_conflictParts or ""
    local allConfParts = Lib.splitString(conflictParts, "#")
    data.conflictParts = allConfParts
    local conflictOriginal = vConfig.s_conflictOriginal or ""
    local allConfOriginal = Lib.splitString(conflictOriginal, "#")
    data.conflictOriginal = allConfOriginal
    if settings[category] and settings[category].list[index] then
      table_insert(settings[category].list[index].member, data)
    end
  end
end

function AppearanceConfig:getItemsByIndex(index)
  if not index then
    return
  end
  local category = tonumber(string.sub(index, 1, 1))
  if not settings[category] then
    Lib.logError("can not find cfgAppearanceConfig, category:", category)
    return
  end
  if settings[category].list[index] then
    return settings[category].list[index].member
  end
end

function AppearanceConfig:randomItemsByIndexes(indexTab)
  local items = {}
  if not indexTab or type(indexTab) ~= "table" then
    return items
  end
  local randomIndexTab = {}
  while 0 < #indexTab do
    local rand = random(1, #indexTab)
    local index = table_remove(indexTab, rand)
    randomIndexTab[#randomIndexTab + 1] = index
  end
  indexTab = randomIndexTab
  for _, index in ipairs(indexTab) do
    local members = AppearanceConfig:getItemsByIndex(index)
    if members then
      local count = #members
      local dressId
      while not dressId do
        local ranIdx = random(1, count)
        if members[ranIdx].lockState == 0 then
          dressId = members[ranIdx].id
        end
      end
      items[#items + 1] = dressId
    end
  end
  return items
end

function AppearanceConfig:getConflictPartsByPart(partName, partValue)
  if not partName or not partValue then
    return
  end
  for _, v in ipairs(settings) do
    local list = v.list
    for index, vv in pairs(list) do
      local member = vv.member
      for _, conf in ipairs(member) do
        local parts = conf.parts
        for pName, pVal in pairs(parts) do
          if pName == partName and pVal == partValue then
            return conf.conflictParts
          end
        end
      end
    end
  end
end

function AppearanceConfig:getConflictOriginal(partName, partValue)
  if not partName or not partValue then
    return
  end
  for _, v in ipairs(settings) do
    local list = v.list
    for index, vv in pairs(list) do
      local member = vv.member
      for _, conf in ipairs(member) do
        local parts = conf.parts
        for pName, pVal in pairs(parts) do
          if pName == partName and pVal == partValue then
            return conf.conflictOriginal
          end
        end
      end
    end
  end
end

function AppearanceConfig:getCfgById(id)
  for _, v in ipairs(settings) do
    local list = v.list
    for index, vv in pairs(list) do
      local member = vv.member
      for _, conf in ipairs(member) do
        if conf.id == id then
          return conf
        end
      end
    end
  end
end

function AppearanceConfig:getAllAwardLockCfg()
  local result = {}
  for _, v in ipairs(settings) do
    local list = v.list
    for index, vv in pairs(list) do
      local member = vv.member
      for _, conf in ipairs(member) do
        if conf.lockState == 1 then
          result[conf.id] = conf
        end
      end
    end
  end
  return result
end

function AppearanceConfig:updateIsNewStatus(index)
  local setRecord = {}
  for _, v in ipairs(settings) do
    local list = v.list
    for idx, vv in pairs(list) do
      if idx == index then
        local member = vv.member
        for _, conf in ipairs(member) do
          if conf.isNew == 1 then
            conf.isNew = 0
            setRecord[#setRecord + 1] = conf.id
          end
        end
      end
    end
  end
  return setRecord
end

function AppearanceConfig:updateIsNewStatusById(id)
  for _, v in ipairs(settings) do
    local list = v.list
    for index, vv in pairs(list) do
      local member = vv.member
      for _, conf in ipairs(member) do
        if conf.id == id then
          conf.isNew = 0
        end
      end
    end
  end
end

function AppearanceConfig:getAllCfgs()
  return settings
end

AppearanceConfig:init()
return AppearanceConfig
