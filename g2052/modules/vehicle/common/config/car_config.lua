local CarConfig = T(Config, "CarConfig")
local settings = {}
local defaultStandby = ""
local defaultStarted = ""

function CarConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/car.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      name1 = vConfig.unname1 or "",
      name2 = vConfig.unname2 or "",
      icon = vConfig.s_icon or "",
      order = tonumber(vConfig.n_order) or 0,
      action_map = vConfig.s_action_map or "",
      carType = tonumber(vConfig.n_carType) or 0,
      throwPos = Lib.splitString(vConfig.s_throwPos or "", "#", true),
      throwCfgName = vConfig.s_throwCfgName or "",
      isNew = tonumber(vConfig.n_isNew) or 0,
      engineAcc = vConfig.s_engineAcc or "",
      speedMax = Lib.splitString(vConfig.s_speedMax or "", "#", true),
      brakeDec = vConfig.s_brakeDec or "",
      brakeSpeedMax = vConfig.s_brakeSpeedMax or "",
      steerMaxAnglePer = vConfig.s_steerMaxAnglePer or "",
      needMulPartSize = vConfig.s_needMulPartSize == "1" and "true" or "false",
      wheelRelPos = vConfig.s_wheelRelPos or "",
      groundDis = vConfig.s_groundDis or "",
      suspensionTravel = vConfig.s_suspensionTravel or "",
      steerVaildStart = vConfig.s_steerVaildStart or "",
      steerVaildEnd = vConfig.s_steerVaildEnd or "",
      honkSound = vConfig.s_honkSound or "",
      standby = vConfig.s_standby or "",
      started = vConfig.s_started or "",
      cameraFollowDis = tonumber(vConfig.n_cameraFollowDis) or 5,
      playRunSoundSpeed = tonumber(vConfig.n_playRunSoundSpeed) or 0,
      cameraFollowOffset = Lib.splitString(vConfig.s_cameraFollowOffset or "", "#", true),
      cameraFollowPitch = Lib.splitString(vConfig.s_cameraFollowPitch or "", "#", true),
      oilGunLocalPos = Lib.splitString(vConfig.s_oilGunLocalPos or "", "#", true),
      defaultColor = self:parseColor(vConfig.s_defaultColor),
      needPrivilege = tonumber(vConfig.n_needPrivilege) or 0,
      lockState = tonumber(vConfig.n_lockState) or 0,
      needBuy = tonumber(vConfig.n_needBuy) or 0,
      isWatchAd = tonumber(vConfig.n_isWatchAd) or 0
    }
    for i = 1, 10 do
      local str = vConfig["s_custom_func" .. i]
      if str then
        data["custom_func" .. i] = Lib.splitString(str, "#")
      end
    end
    settings[data.id] = data
    if defaultStandby == "" and data.standby ~= "" then
      defaultStandby = data.standby
    end
    if defaultStarted == "" and data.started ~= "" then
      defaultStarted = data.started
    end
  end
end

function CarConfig:parseColor(hexStr)
  if not hexStr then
    return
  end
  local color = Lib.splitString(hexStr, "#")
  if #color ~= 3 then
    Lib.logError("CarConfig:parseColor invalid format", hexStr, #color)
    return
  end
  for k, v in ipairs(color) do
    color[k] = tonumber(v, 16) / 255
  end
  table.insert(color, 1)
  return color
end

function CarConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgCarConfig, id:", id)
    return
  end
  return settings[id]
end

function CarConfig:getAllCfgs()
  return settings
end

function CarConfig:isPrimaryCar(id)
  if settings[id] then
    return settings[id].carType == Define.VEHICLE_TYPE.Primary
  end
end

function CarConfig:isAdvancedCar(id)
  if settings[id] then
    return settings[id].carType == Define.VEHICLE_TYPE.Advanced
  end
end

function CarConfig:isCar(fullName)
  for _, v in pairs(settings) do
    if v.throwCfgName == fullName then
      return true
    end
  end
  return false
end

function CarConfig:getCfgByName(fullName)
  for _, v in pairs(settings) do
    if v.throwCfgName == fullName then
      return v
    end
  end
end

function CarConfig:updateIsNewStatusById(id)
  for _, v in pairs(settings) do
    if v.id == id then
      v.isNew = 0
      break
    end
  end
end

function CarConfig:getNewCars()
  local cars = {}
  for _, v in pairs(settings) do
    if v.isNew == 1 then
      cars[#cars + 1] = v
    end
  end
  return cars
end

function CarConfig:getStandbySound(id, userid)
  local tb = settings[id]
  if not tb then
    Lib.logError("invalid id CarConfig:getStandbySound, id:", id or "" .. "userid: " .. userid or "")
    return defaultStandby
  end
  return "myplugin/" .. tb.standby
end

function CarConfig:getStartedSound(id)
  local tb = settings[id]
  if not tb then
    Lib.logError("invalid id CarConfig:getStartedSound, id:", id)
    return defaultStarted
  end
  return "myplugin/" .. tb.started
end

CarConfig:init()
return CarConfig
