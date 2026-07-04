local HouseConfig = T(Config, "HouseConfig")
local RedDotConfig = T(Config, "RedDotConfig")
local cjson = require("cjson")
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local DisasterConfig = T(Config, "DisasterConfig")
local Player = _ENV.Player

function Player:updateHouseInfo(params)
  if not self.allHouseInfo then
    self.allHouseInfo = {}
  end
  for i, v in pairs(params or {}) do
    self.allHouseInfo[v.index] = v
    if v.ownerId == self.platformUserId then
      UI:getWnd("house"):updateOwnHouseInfo(self.allHouseInfo[v.index])
    end
  end
  if self:doIOwnAHouse() then
    Lib.emitEvent(Event.EVENT_SHOW_OPERATION_PANEL, "house")
  else
    Lib.emitEvent(Event.EVENT_REMOVE_OPERATION_PANEL, "house")
  end
  Lib.emitEvent(Event.EVENT_UPDATE_HOUSE_INFO, self.allHouseInfo)
  self:updateHouseAreaLimit()
end

function Player:getOwnHouseInfo()
  for i, v in pairs(self.allHouseInfo or {}) do
    if v.ownerId == self.platformUserId then
      return v
    end
  end
  return
end

function Player:doIOwnAHouse()
  if not self.allHouseInfo then
    return false
  end
  for i, v in ipairs(self.allHouseInfo) do
    if v.ownerId == Me.platformUserId then
      return true, v, i
    end
  end
  return false
end

function Player:getFirstVacantHouseIndex()
  if not self.allHouseInfo then
    return 1
  end
  for i, v in ipairs(self.allHouseInfo) do
    if not v.ownerId then
      return i
    end
  end
  return 1
end

local function verifyingPlayerPermissions(player, limitList, ownerId)
  if player.platformUserId == ownerId then
    return true
  end
  for _, id in pairs(limitList) do
    if id == player.platformUserId then
      return false
    end
  end
  return true
end

function Player:updateHouseAreaLimit()
  if not self.allHouseInfo then
    return
  end
  if not self.allHouseAreas then
    self.allHouseAreas = {}
  end
  for id, node in pairs(self.allHouseAreas) do
    if node and node:isValid() then
      local needClean = true
      for i, v in pairs(self.allHouseInfo) do
        if v.houseId and id == v.houseId then
          needClean = false
          break
        end
      end
      if needClean then
        node:destroy()
        self.allHouseAreas[id] = nil
      end
    else
      self.allHouseAreas[id] = nil
    end
  end
  local manager = World.CurWorld:getSceneManager()
  for _, v in pairs(self.allHouseInfo) do
    if v.houseId then
      if not verifyingPlayerPermissions(Me, v.limitList, v.ownerId) then
        if not self.allHouseAreas[v.houseId] then
          local pos = v.pos
          local rotation = v.rotation
          local map = World.CurWorld:getMapById(v.mapId)
          if map then
            local landArea = PartCfg:get("myplugin/" .. v.landName .. "_area")
            if not landArea then
              return
            end
            local scene = manager:getOrCreateScene(map.obj)
            local area = Lib.createPartHelper(landArea, scene, map, rotation, pos)
            self.allHouseAreas[v.houseId] = area
          else
            Lib.logError("--map is nil-infoMapID and curMapId", v.mapId, Me.map.id)
          end
        end
      elseif self.allHouseAreas[v.houseId] then
        if self.allHouseAreas[v.houseId]:isValid() then
          self.allHouseAreas[v.houseId]:destroy()
        end
        self.allHouseAreas[v.houseId] = nil
      end
    end
  end
end

function Player:loadNewHouseRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewHouseRecord-" .. userId .. ".json"
  local file = io.open(path, "r")
  if not file then
    self.newHouseRecord = {}
    return
  end
  file:close()
  self.newHouseRecord = Lib.read_json_file(path) or {}
  for id, _ in pairs(self.newHouseRecord) do
    HouseConfig:updateIsNewStatusById(tonumber(id))
  end
end

function Player:saveNewHouseRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewHouseRecord-" .. userId .. ".json"
  local file, errmsg = io.open(path, "w")
  if not file then
    print("\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129saveNewHouseRecord  error \239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129")
    print(errmsg)
    return false
  end
  local ok, content = pcall(cjson.encode, self.newHouseRecord)
  assert(ok, path)
  file:write(Lib.jsonToFormat(content))
  file:close()
end

function Player:updateHouseRedDotStatus()
  local allCfg = HouseConfig:getAllCfgs()
  for _, v in pairs(allCfg) do
    if v.isNew == 1 then
      Plugins.CallPluginFunc("resetRedDotState", RedDotConfig.RD_KEY.HasNewHouse, 1)
      return
    end
  end
  Plugins.CallPluginFunc("resetRedDotState", RedDotConfig.RD_KEY.HasNewHouse, 0)
end

function Player:updateHousePanelUI(key, landPanelOffset)
  local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
  for _, info in pairs(self.allHouseInfo) do
    if info.landName == key and info.mapId == Me.map.id then
      local key = "housePanelUI" .. info.index
      local ui = Plugins.CallTargetPluginFunc("scene_ui", "getSceneUI", key)
      local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName)
      local rotate = Lib.copy(info.rotation)
      local pos = Lib.copy(info.pos)
      local panelOffset = landPanelOffset[info.landName] or Lib.v3(0, 0, 0)
      pos = pos + Lib.correctMoveDistance(rotate, Lib.v3(panelOffset.x, panelOffset.y, panelOffset.z))
      if houseInfo then
        pos = pos + Lib.correctMoveDistance(rotate, houseInfo.panelOffset)
      end
      local uiName = "housePanel"
      local default = {
        width = 8,
        viewDistance = 64,
        uiName = uiName,
        rotate = rotate,
        position = pos,
        key = key,
        params = info
      }
      if ui then
        Plugins.CallTargetPluginFunc("scene_ui", "updateSceneUI", ui, default)
      else
        table.insert(uiCfgList, default)
        Plugins.CallTargetPluginFunc("scene_ui", "createSceneUI", default)
      end
    end
  end
end

function Player:previewAllHouse()
  if Me.allHouseInfo then
    local houseInfo = Me.allHouseInfo
    if 0 < #houseInfo then
      local cameraData = {}
      local lastIndex = Me:getLastHouseTransportIndex()
      local initIndex
      local needReset = houseInfo[lastIndex] and houseInfo[lastIndex].ownerId
      local isOwner
      for i, v in ipairs(houseInfo) do
        if houseInfo[i].mapId == Me.map.id then
          if v.ownerId and v.ownerId == self.platformUserId then
            isOwner = true
          end
          local landInfo = HouseConfig:getLandInfo(houseInfo[i].landName) or {}
          local initPos = houseInfo[i].initPosInfo.pos
          local yaw = houseInfo[i].initPosInfo.yaw
          local cameraPos = Lib.v3(initPos.x, initPos.y, initPos.z)
          if landInfo.cameraPosOffset then
            cameraPos = cameraPos + Lib.correctMoveDistance(Lib.v3(0, -1 * yaw, 0), Lib.v3(landInfo.cameraPosOffset.x, landInfo.cameraPosOffset.y, landInfo.cameraPosOffset.z))
          end
          cameraData[i] = {
            landId = houseInfo[i].id,
            targetPos = houseInfo[i].pos,
            cameraPos = cameraPos,
            initPosInfo = houseInfo[i].initPosInfo
          }
          if needReset and not v.ownerId and (i < lastIndex or not initIndex and i > lastIndex) then
            initIndex = i
          end
        end
      end
      if not isOwner and initIndex then
        lastIndex = initIndex
        Me:setLastHouseTransportIndex(lastIndex)
      end
      if lastIndex > #cameraData then
        lastIndex = initIndex or 1
        Me:setLastHouseTransportIndex(lastIndex)
      end
      Me:openGuideUI("cameraSwitch", cameraData, lastIndex, true, true)
    end
  end
end

function Player:disasterSelectCDRecord(id)
  if not id then
    return
  end
  local cfg = DisasterConfig:getCfgById(id)
  if not cfg or cfg.selectCD <= 0 then
    return
  end
  if not self.disasterSelectCDRecordData then
    self.disasterSelectCDRecordData = {}
  end
  self.disasterSelectCDRecordData[id] = os.time()
  if not self.disasterSelectCDTimer then
    self.disasterSelectCDTimer = World.Timer(20, function()
      if not self.disasterSelectCDRecordData then
        return
      end
      for k, _ in pairs(self.disasterSelectCDRecordData) do
        if self:getDisasterSelectRemainCD(k) <= 0 then
          self.disasterSelectCDRecordData[k] = nil
        end
      end
      Lib.emitEvent(Event.EVENT_UPDATE_DISASTER_CD)
      if next(self.disasterSelectCDRecordData) == nil then
        self:clearDisasterSelectCDTimer()
      else
        return true
      end
    end)
  end
end

function Player:getDisasterSelectRemainCD(id)
  if not id then
    return 0
  end
  if not self.disasterSelectCDRecordData or not self.disasterSelectCDRecordData[id] then
    return 0
  end
  local cfg = DisasterConfig:getCfgById(id)
  if not cfg or 0 >= cfg.selectCD then
    return 0
  end
  return cfg.selectCD - (os.time() - self.disasterSelectCDRecordData[id])
end

function Player:clearDisasterSelectCDTimer()
  if self.disasterSelectCDTimer then
    self.disasterSelectCDTimer()
    self.disasterSelectCDTimer = nil
  end
end
