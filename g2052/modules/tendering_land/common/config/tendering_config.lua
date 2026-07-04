local TenderingConfig = T(Config, "TenderingConfig")
local settings = {}
local regionGroup = {}

function TenderingConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/tendering.csv", 2)
  for _, vConfig in pairs(config) do
    local screenShot = Lib.splitString(vConfig.s_screenShot, "#", true)
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      landName = vConfig.s_landName or "",
      buildName = vConfig.s_buildName or "",
      regionId = tonumber(vConfig.n_regionId) or 0,
      bidId = vConfig.n_bidId or "",
      initialBuildings = vConfig.s_initialBuildings or "",
      curBuildings = vConfig.s_curBuildings or "",
      posOffset = Lib.createV3ByString(vConfig.s_posOffset),
      rotateOffset = Lib.createV3ByString(vConfig.s_rotateOffset),
      signOffset = Lib.createV3ByString(vConfig.s_signOffset),
      signRotate = Lib.createV3ByString(vConfig.s_signRotate),
      billboardOffset = Lib.createV3ByString(vConfig.s_billboardOffset),
      billboardRotate = Lib.createV3ByString(vConfig.s_billboardRotate),
      billboardRange = tonumber(vConfig.n_billboardRange) or 0,
      publicOffset = Lib.createV3ByString(vConfig.s_publicOffset),
      publicRotate = Lib.createV3ByString(vConfig.s_publicRotate),
      publicRange = tonumber(vConfig.n_publicRange) or 0,
      winClothes = tonumber(vConfig.n_winClothes) or 0,
      winTxt = vConfig.s_winTxt or "",
      winColor = vConfig.s_winColor or "",
      takeInCloths = tonumber(vConfig.n_takeInCloths) or 0,
      takeInPet = tonumber(vConfig.n_takeInPet) or 0,
      landIcon = vConfig.s_landIcon or "",
      landMapPos = Lib.splitString(vConfig.s_landMapPos or "", "#"),
      landAwardIcon = Lib.splitString(vConfig.s_landAwardIcon or "", "#"),
      landAwardLang = Lib.splitString(vConfig.s_landAwardLang or "", "#"),
      landAwardType = Lib.splitString(vConfig.s_landAwardType or "", "#", true),
      landAwardItem = Lib.splitString(vConfig.s_landAwardItem or "", "#"),
      screenShot = {
        pos = {
          x = screenShot[1],
          y = screenShot[2],
          z = screenShot[3]
        },
        yaw = screenShot[4],
        pitch = screenShot[5]
      }
    }
    data.landAwardList = {}
    for k, val in pairs(data.landAwardIcon) do
      data.landAwardList[k] = {}
      data.landAwardList[k].icon = data.landAwardIcon[k] or ""
      data.landAwardList[k].text = data.landAwardLang[k] or ""
      data.landAwardList[k].gainType = data.landAwardType[k] or 1
      data.landAwardList[k].itemInfo = {}
      if data.landAwardItem[k] then
        data.landAwardList[k].itemInfo = Lib.splitString(data.landAwardItem[k] or "", "$")
      end
    end
    if not settings[data.landName] then
      settings[data.landName] = {}
    end
    settings[data.landName][data.regionId] = data
    if not regionGroup[data.regionId] then
      regionGroup[data.regionId] = {}
    end
    table.insert(regionGroup[data.regionId], data)
  end
end

function TenderingConfig:getCfgById(id)
  for landName, lands in pairs(settings or {}) do
    for regionId, v in pairs(lands or {}) do
      if v.id == id then
        return v
      end
    end
  end
  Lib.logError("can not find cfgTenderingConfig, id:", id)
  return
end

function TenderingConfig:getCfgByLandName(landName)
  if not settings[landName] then
    return Lib.logError("can not find cfgTenderingConfig, landName:", landName)
  end
  return settings[landName]
end

function TenderingConfig:getCfgByRegionId(regionId)
  if not regionGroup[regionId] then
    return Lib.logError("can not find cfgTenderingConfig, regionId:", regionId)
  end
  return regionGroup[regionId]
end

function TenderingConfig:getCfgByLandNameAndRegionId(landName, regionId, needWarning)
  if settings[landName] and settings[landName][regionId] then
    return settings[landName][regionId]
  end
  if needWarning then
    Lib.logError("can not find cfgTenderingConfig, landName:", landName, ",regionId:", regionId)
  end
  return
end

function TenderingConfig:getAllCfgs()
  return settings
end

TenderingConfig:init()
return TenderingConfig
