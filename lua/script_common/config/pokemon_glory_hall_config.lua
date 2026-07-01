local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")
local settings = {}

function PokemonGloryHallConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_glory_hall.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      gymIcon = vConfig.s_gym_icon or "",
      goldIcon = vConfig.s_gold_icon or ""
    }
    data.openDay = Lib.split(vConfig.s_open_day, "#")
    data.itemList = Lib.split(vConfig.s_itemName, "#")
    data.pkmList = Lib.split(vConfig.s_pkm_id, "#")
    settings[data.id] = data
  end
end

function PokemonGloryHallConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPokemonGloryHallConfig, id:", id)
    return
  end
  return settings[id]
end

function PokemonGloryHallConfig:getAllRemainOpenTime()
  local curWeekDay = tonumber(os.date("%w", os.time()))
  local timeList = {}
  for _, cfg in pairs(settings) do
    local minTime
    for _, day in pairs(cfg.openDay) do
      local openDay = tonumber(day)
      local curTime
      if openDay == curWeekDay then
        curTime = 0
      elseif curWeekDay < openDay then
        curTime = (openDay - curWeekDay - 1) * 24 * 60 * 60
      elseif curWeekDay > openDay then
        curTime = (7 - curWeekDay + openDay - 1) * 24 * 60 * 60
      end
      if minTime ~= nil and minTime > curTime then
        minTime = curTime
      elseif minTime == nil then
        minTime = curTime
      end
    end
    timeList[cfg.id] = minTime + Lib.getDayEndTime(os.time()) - os.time()
  end
  return timeList
end

function PokemonGloryHallConfig:getCfgByOpenDay(weekDay)
  local items = {}
  for _, cfg in pairs(settings) do
    for _, day in pairs(cfg.openDay) do
      if tonumber(weekDay) == tonumber(day) then
        table.insert(items, cfg)
      end
    end
  end
  return items
end

function PokemonGloryHallConfig:getAwardByOpenDay(weekDay)
  local items = self:getCfgByOpenDay(weekDay)
  local results = {}
  local awardList = {}
  local pkmList = {}
  local hasGoldAward = false
  for _, cfg in ipairs(items) do
    for _, temp in pairs(cfg.itemList) do
      awardList[temp] = true
    end
    for _, temp in ipairs(cfg.pkmList) do
      pkmList[temp] = true
    end
    if cfg.goldIcon ~= "" then
      hasGoldAward = cfg.goldIcon
    end
  end
  for pkmId, pkmNum in pairs(pkmList) do
    local temp = {
      pkmId = tonumber(pkmId),
      awardType = 1
    }
    table.insert(results, temp)
  end
  for fullName, num in pairs(awardList) do
    local temp = {fullName = fullName, awardType = 2}
    table.insert(results, temp)
  end
  if hasGoldAward then
    local temp = {goldIcon = hasGoldAward, awardType = 3}
    table.insert(results, temp)
  end
  return results
end

function PokemonGloryHallConfig:getAllCfgs()
  return settings
end

return PokemonGloryHallConfig
