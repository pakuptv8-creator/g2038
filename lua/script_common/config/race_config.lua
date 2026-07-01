local RaceConfig = T(Config, "RaceConfig")
local settings = {}

local function initSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/race.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.name = vConfig.name or ""
    data.icon = vConfig.icon or ""
    data.skill_bg = vConfig.skill_bg or ""
    data.classify_icon = vConfig.classify_icon or ""
    data.color_bg = Lib.splitString(vConfig.color_bg or "", "#")
    data.raceData = {}
    for i = 1, 6 do
      data.raceData[i] = tonumber(vConfig["race_" .. i]) or 0
    end
    settings[vConfig.id] = data
  end
end

function RaceConfig:init()
  initSetting()
end

function RaceConfig:RaceConfig(Id)
  return settings[tostring(Id)]
end

function RaceConfig:getRaceDataById(Id)
  if settings[tostring(Id)] then
    return settings[tostring(Id)].raceData
  end
  return nil
end

function RaceConfig:getClassifyIcon(Id)
  local config = settings[tostring(Id)]
  if config then
    return config.classify_icon
  end
  return "set:pokemon_pet_race.json image:img_0_race_all"
end

function RaceConfig:getSkillBg(Id)
  local config = settings[tostring(Id)]
  if config then
    return config.skill_bg
  end
  return ""
end

function RaceConfig:getIcon(Id)
  local config = settings[tostring(Id)]
  if config then
    return config.icon
  end
  return ""
end

function RaceConfig:getName(Id)
  local config = settings[tostring(Id)]
  if config then
    return config.name
  end
  return "gui.race.name.all"
end

function RaceConfig:getColorBg(Id)
  local config = settings[tostring(Id)]
  if config then
    return config.color_bg
  end
  return ""
end

function RaceConfig:getAllRaceId()
  local raceIds = {}
  for _, race in pairs(settings) do
    table.insert(raceIds, tonumber(race.id))
  end
  table.sort(raceIds, function(a, b)
    return a < b
  end)
  return raceIds
end

function RaceConfig:getDamageRateByRaceInfo(targetRace, skillRace)
  local setting = settings[tostring(skillRace)]
  if setting then
    return setting.raceData[targetRace]
  end
  return false
end

RaceConfig:init()
return RaceConfig
