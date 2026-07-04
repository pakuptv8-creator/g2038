local TimingSoundConfig = T(Config, "TimingSoundConfig")
local settings = {}
local involveKey = {}

function TimingSoundConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/timing_sound.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      key = vConfig.s_key or "",
      sound = vConfig.s_sound ~= "" and vConfig.s_sound,
      range = Lib.splitString(vConfig.s_range or "", "#", true),
      loop = tonumber(vConfig.n_loop)
    }
    data.controlInfo = {}
    for i = 1, 7 do
      local info = Lib.splitString(vConfig["s_day" .. i] or "", "#")
      if not Lib.table_is_empty(info) then
        data.controlInfo[i] = info
      end
    end
    settings[data.key] = data
    involveKey[data.key] = true
  end
end

function TimingSoundConfig:getCfgById(key)
  if not settings[key] then
    Lib.logError("can not find cfgTimingSoundConfig, id:", key)
    return
  end
  return settings[key]
end

function TimingSoundConfig:getAllCfgs()
  return settings
end

function TimingSoundConfig:getKeyList()
  return Lib.copy(involveKey)
end

function TimingSoundConfig:getControlInfoByKeyAndDay(key, day)
  if settings[key] and settings[key].controlInfo and settings[key].controlInfo[day] then
    return Lib.copy(settings[key].controlInfo[day])
  end
end

TimingSoundConfig:init()
return TimingSoundConfig
