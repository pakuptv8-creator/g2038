local HouseConfig = T(Config, "HouseConfig")
local settings = {}
local landSetting = {}

function HouseConfig:initLandCfg()
  landSetting = {}
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/land.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      type = tonumber(vConfig.n_type) or 0,
      landName = vConfig.s_landName ~= "" and vConfig.s_landName,
      landPanelOffset = Lib.createV3ByString(vConfig.s_landPanelOffset),
      landPanelLang = vConfig.s_landPanelLang or "",
      houseTransferPos = Lib.createV3ByString(vConfig.s_houseTransferPos),
      cameraPosOffset = Lib.createV3ByString(vConfig.s_cameraPosOffset),
      needPrivilege = tonumber(vConfig.n_needPrivilege) or 0
    }
    landSetting[data.landName] = data
  end
end

function HouseConfig:init()
  settings = {}
  self:initLandCfg()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/house.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      name = vConfig.s_name or "",
      landName = Lib.splitString(vConfig.s_landName, "#"),
      icon = vConfig.s_icon or "",
      cfgName = vConfig.s_cfgName or "",
      isLock = tonumber(vConfig.n_isLock) or 0,
      isNew = tonumber(vConfig.n_isNew) or 0,
      price = vConfig.s_price or "",
      posOffset = Lib.createV3ByString(vConfig.s_posOffset),
      rotateOffset = Lib.createV3ByString(vConfig.s_rotateOffset),
      panelOffset = Lib.createV3ByString(vConfig.s_panelOffset),
      monitorId = tonumber(vConfig.n_monitorId) or 0,
      default = tonumber(vConfig.n_default) == 1,
      doorLock = vConfig.s_doorLock,
      haveGarage = tonumber(vConfig.n_haveGarage) == 1,
      garageDoorName = vConfig.s_garageDoorName ~= "" and vConfig.s_garageDoorName,
      maxDisasterNum = tonumber(vConfig.n_maxDisasterNum),
      colorChangingPart = Lib.splitString(vConfig.s_colorChangingPart, "#"),
      glassChangingPart = Lib.splitString(vConfig.s_glassChangingPart, "#"),
      needPrivilege = tonumber(vConfig.n_needPrivilege) or 0,
      needBuy = tonumber(vConfig.n_needBuy) or 0,
      isWatchAd = tonumber(vConfig.n_isWatchAd) or 0,
      lockState = tonumber(vConfig.n_lockState) or 0
    }
    data.cameraOffset = {}
    if vConfig.s_securityCameraOffset ~= nil and vConfig.s_securityCameraOffset ~= "" then
      local group = Lib.splitString(vConfig.s_securityCameraOffset, ";")
      local groupNum = #group
      for i = 1, groupNum do
        data.cameraOffset[i] = {}
        local posArr = Lib.splitString(group[i], ",")
        data.cameraOffset[i].cameraPosOffset = Lib.createV3ByString(posArr[1]) or {
          0,
          0,
          0
        }
        data.cameraOffset[i].targetPosOffset = Lib.createV3ByString(posArr[2]) or {
          0,
          0,
          0
        }
      end
    end
    for _, landName in pairs(data.landName or {}) do
      if not settings[landName] then
        settings[landName] = {}
      end
      table.insert(settings[landName], data)
    end
  end
  for _, v in pairs(settings) do
    table.sort(v, function(a, b)
      return a.sortId < b.sortId
    end)
  end
end

function HouseConfig:getCfgById(id)
  for _, v in pairs(settings) do
    for _, val in pairs(v) do
      if val.id == id then
        return val
      end
    end
  end
  Lib.logError("can not find cfgHouseConfig, id:", id)
  return
end

function HouseConfig:getAllCfgs()
  return Lib.copy(settings)
end

function HouseConfig:getAllHouseByLandName(landName)
  if not settings or not settings[landName] then
    return
  end
  return Lib.copy(settings[landName])
end

function HouseConfig:getHouseInfoByCfgName(landName, cfgName)
  if settings[landName] then
    for _, v in pairs(settings[landName]) do
      if v.cfgName == cfgName then
        return Lib.copy(v)
      end
    end
  end
end

function HouseConfig:updateIsNewStatusById(id)
  for _, v in pairs(settings) do
    for _, val in pairs(v) do
      if val.id == id then
        val.isNew = 0
        return
      end
    end
  end
end

function HouseConfig:getNewHouses()
  local houses = {}
  for _, v in pairs(settings) do
    for _, val in pairs(v) do
      if val.isNew == 1 then
        houses[#houses + 1] = val
      end
    end
  end
  return houses
end

function HouseConfig:getAllHouseLand()
  local data = {}
  for key, v in pairs(landSetting) do
    data[key] = true
  end
  return data
end

function HouseConfig:getLandInfo(landName)
  for key, v in pairs(landSetting) do
    if key == landName then
      return v
    end
  end
  return
end

function HouseConfig:rewriteCfg(tbData)
  if not tbData or type(tbData) ~= "table" then
    return
  end
  local path = Root.Instance():getGamePath() .. "config/house.csv"
  local _data, header = Lib.read_csv_file(path)
  for index, v in pairs(Lib.copy(_data)) do
    if v.n_id == tbData.n_id then
      for key, v in pairs(tbData) do
        _data[index][key] = v
      end
      break
    end
  end
  local data = {
    items = _data or {},
    header = header
  }
  Lib.write_csv(path, data)
  self:init()
end

HouseConfig:init()
return HouseConfig
