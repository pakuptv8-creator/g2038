local WeatherMgr = T(Lib, "WeatherMgr")
local LuaTimer = T(Lib, "LuaTimer")
local TimeLight = T(Lib, "TimeLight")
local setting = require("common.setting")
local GameTimes = T(Lib, "GameTimes")
local WeatherConfig = T(Config, "WeatherConfig")
local FogControl = T(Lib, "FogControl")

local function getTargetPos(position, from)
  local bm = Blockman.instance
  local camaraYaw = bm:viewerRenderYaw()
  local yaw = (360 - camaraYaw + 90) % 360
  local pos = Lib.tov3(Lib.copy(position))
  local new_off_x, new_off_y = pos.x, pos.z
  local arc1 = math.atan(new_off_y, -new_off_x)
  local deg1 = math.deg(arc1)
  local deg2 = yaw - (360 - deg1 + 90) % 360
  local arc2 = math.rad(deg2)
  local len = (new_off_x ^ 2 + new_off_y ^ 2) ^ 0.5
  local offx = len * math.cos(arc2)
  local offy = len * math.sin(arc2)
  pos.x = -offx
  pos.z = offy
  local targrtpos = from:getPosition() + pos
  return targrtpos
end

function WeatherMgr:setBigTornado(id)
  self.bigTornadoOldPoses = self.bigTornadoOldPoses or {}
  local node = Instance.getByInstanceId(id)
  if not node then
    return
  end
  self.bigTornadoLifes = self.bigTornadoLifes or {}
  if Lib.getTableSize(self.bigTornadoLifes) >= World.cfg.weatherSetting.bigTornadoMaxExist then
    node.isVisible = false
    return
  end
  node.isVisible = true
  if not self.bigTornadoOldPoses[id] then
    self.bigTornadoOldPoses[id] = node:getPosition()
  end
  self.bigTornadoes = self.bigTornadoes or {}
  self.bigTornadoes[id] = node
  self.bigTornadoLifes[id] = World.cfg.weatherSetting.bigTornado[id].moveTime
end

function WeatherMgr:tornadoTick()
  for id, life in pairs(self.bigTornadoLifes or {}) do
    local node = self.bigTornadoes[id]
    if not node then
      return
    end
    if life <= 0 then
      if node.isVisible then
        node:setPosition(self.bigTornadoOldPoses[id])
        node.isVisible = false
      end
      self.bigTornadoLifes[id] = nil
    else
      self.bigTornadoLifes[id] = life - 1
      local pos = node:getPosition()
      node:setPosition(pos + Lib.v3(table.unpack(World.cfg.weatherSetting.bigTornado[id].moveSpeed)))
    end
  end
end

function WeatherMgr:init()
  Lib.subscribeEvent(Event.EVENT_RECORDER_QUIT, function()
    self:restoreLastWeather()
  end)
  self.initSkyColor = EngineSceneManager.Instance():getSkyColor()
  self.isNowIndoor = false
  self.isForceSwitch = false
  self.curRainyEffect = nil
  self.additionalEffect = nil
  self.curRainyEffectPos = nil
  self.rainyEffectInitPos = nil
  self.renderTickListener = Lib.lightSubscribeEvent("error!!!!! : Interact lib event : EVENT_CLIENT_HANDLE_TICK", Event.EVENT_CLIENT_HANDLE_TICK, function()
    if self.curRainyEffect and T(Lib, "Recorder"):IsUsingWeather() then
      self:clearLastWeather()
      self.curRainyEffect = nil
    end
    if Me.map.name == "map001" then
      self:tornadoTick()
      local camera = Camera:getActiveCamera()
      local cam_pos = Vector3.fromTable(camera:getPosition())
      local cam_dir = Vector3.fromTable(camera:getDirection())
      local des_pos = cam_pos + cam_dir * 2.0
      des_pos = {
        x = math.floor(des_pos.x),
        y = math.floor(des_pos.y),
        z = math.floor(des_pos.z)
      }
      if self.curRainyEffect and self.curRainyEffectPos and (des_pos.x ~= self.curRainyEffectPos.x or des_pos.y ~= self.curRainyEffectPos.y or des_pos.z ~= self.curRainyEffectPos.z) then
        local lineEffect = WorldEffectManager:Instance():getSimpleEffect(self.curRainyEffect, self.rainyEffectInitPos)
        local additionalEffect = WorldEffectManager:Instance():getSimpleEffect(self.additionalEffect, self.rainyEffectInitPos)
        if lineEffect then
          lineEffect.mPosition = des_pos
          self.curRainyEffectPos = des_pos
        end
        if additionalEffect then
          additionalEffect.mPosition = des_pos
          self.curRainyEffectPos = des_pos
        end
      end
      self:changeSkyColorByTime()
    end
  end)
  LuaTimer:schedule(function()
    self:updateWetEffect()
  end, 0, World.cfg.weatherSetting.wetEffectCheckTimer * 1000 - 500)
  LuaTimer:schedule(function()
    self:updateSpecialStates()
  end, 0, World.cfg.weatherSetting.specialEffectCheckTime * 1000 - 500)
end

function WeatherMgr:SetAdditionalEffect(effect)
  self.additionalEffect = effect and "asset/effect/" .. effect or nil
  if self.additionalEffect then
    Blockman.instance:playEffectByPos(self.additionalEffect, self.rainyEffectInitPos, 0, -1)
  else
    Blockman.instance:delEffect(self.additionalEffect, self.rainyEffectInitPos)
  end
end

function WeatherMgr:switchWeather(index, isScanIndoor)
  if T(Lib, "Recorder"):IsUsingWeather() then
    self.curWeather = index
    Me:data("main").weather = index
    return
  end
  local cfg = WeatherConfig:getCfgByIdAndMapName(index, Me.map.name)
  if not cfg then
    return
  end
  self:clearLastWeather()
  if not isScanIndoor then
    self:changeSkyBoxByWeather(index, cfg)
  end
  if cfg.rainEffect and cfg.rainEffect ~= "" then
    local camera = Camera:getActiveCamera()
    local cam_pos = Vector3.fromTable(camera:getPosition())
    local cam_dir = Vector3.fromTable(camera:getDirection())
    local des_pos = cam_pos + cam_dir * 2.0
    local finalPos = {
      x = math.floor(des_pos.x),
      y = math.floor(des_pos.y),
      z = math.floor(des_pos.z)
    }
    local path = "asset/effect/" .. cfg.rainEffect
    self.curRainyEffect = path
    self.rainyEffectInitPos = finalPos
    self.curRainyEffectPos = finalPos
    Blockman.instance:playEffectByPos(path, finalPos, 0, -1)
  end
  if cfg.lightEffect and cfg.lightEffect ~= "" then
    if self.lightTimer then
      LuaTimer:cancel(self.lightTimer)
      self.lightTimer = nil
    end
    self.lightTimer = LuaTimer:schedule(function()
      local rate = math.random(1, 10)
      if rate < (cfg.lightRate or 50) / 10 then
        local dirX = math.random(cfg.lightPosX[1] or -10, cfg.lightPosX[2] or 10)
        local dirY = cfg.lightPosY and cfg.lightPosY > 0 and cfg.lightPosY or 5
        local dirZ = math.random(cfg.lightPosZ[1] or 1, cfg.lightPosZ[2] or 10)
        local pos = getTargetPos({
          x = dirX,
          y = dirY,
          z = dirZ
        }, Me)
        local path = "asset/effect/" .. cfg.lightEffect
        Blockman.instance:playEffectByPos(path, pos, 0, 500)
        if cfg.lightSound and 1 <= #cfg.lightSound then
          Me:playSoundByKey(cfg.lightSound[math.random(1, #cfg.lightSound)])
        end
      end
    end, 0, (cfg.lightFrequency or 3) * 1000)
  end
  self.curWeather = index
  Me:data("main").weather = index
  Me:playWeatherBgm()
end

function WeatherMgr:changeSkyBoxByWeather(index, cfg)
  if not cfg then
    return
  end
  local skyBoxCfg = World.cfg.weatherSkybox[cfg.skyBox]
  if skyBoxCfg and skyBoxCfg.skyBox then
    self:switchSkyBox(skyBoxCfg.skyBox)
    local curTime = GameTimes:GetTime()
    local skyColor = skyBoxCfg.skyColor
    if skyColor then
      local color
      for i = 1, #skyColor do
        if tonumber(curTime.hour) >= tonumber(skyColor[i].time) then
          color = skyColor[i].color
        end
      end
      if color then
        EngineSceneManager.Instance():setSkyColor({
          color[1] / 255,
          color[2] / 255,
          color[3] / 255,
          1
        })
      end
    end
  elseif self.curWeather ~= index then
    local mapCfg = setting:loadDir("map/" .. Me.map.name .. "/", true)
    if mapCfg and mapCfg.skyBox then
      self:switchSkyBox(mapCfg.skyBox)
    end
    EngineSceneManager.Instance():setSkyColor(self.initSkyColor)
  end
end

function WeatherMgr:changeSkyColorByTime()
  local cfg = WeatherConfig:getCfgByIdAndMapName(self.curWeather, Me.map.name)
  if not cfg then
    return
  end
  local skyBoxCfg = World.cfg.weatherSkybox[cfg.skyBox]
  if not (skyBoxCfg and skyBoxCfg.skyColor) or #skyBoxCfg.skyColor <= 0 then
    return
  end
  local curTime = GameTimes:GetTime()
  local skyColor = skyBoxCfg.skyColor
  for i = 1, #skyColor do
    if tonumber(curTime.hour) == tonumber(skyColor[i].time) and tonumber(curTime.min) == 0 then
      EngineSceneManager.Instance():setSkyColor({
        skyColor[i].color[1] / 255,
        skyColor[i].color[2] / 255,
        skyColor[i].color[3] / 255,
        1
      })
    end
  end
end

function WeatherMgr:restoreLastWeather()
  local lastWeather = Me:data("main").weather
  if lastWeather then
    self:switchWeather(lastWeather, false)
  end
end

function WeatherMgr:clearLastWeather()
  local lastWeather = Me:data("main").weather
  if lastWeather then
    local cfg = WeatherConfig:getCfgByIdAndMapName(lastWeather, Me.map.name)
    if not cfg then
      return
    end
    if self.curRainyEffect then
      if self.additionalEffect then
        Blockman.instance:delEffect(self.additionalEffect, self.rainyEffectInitPos)
        self.additionalEffect = nil
      end
      Blockman.instance:delEffect(self.curRainyEffect, self.rainyEffectInitPos)
      self.curRainyEffect = nil
      self.curRainyEffectPos = nil
      self.rainyEffectInitPos = nil
    end
    if cfg.rainEffect then
      Player.CurPlayer:removeClientTypeBuff("fullName", cfg.rainEffect)
    end
    if self.lightTimer then
      LuaTimer:cancel(self.lightTimer)
      self.lightTimer = nil
    end
  end
end

function WeatherMgr:switchSkyBox(params)
  local map = Me.map
  map.cfg.skyBox = params
  map:updateSkyBox()
end

function WeatherMgr:playerEnterIndoor(isEnter)
  self:resetSpecialStates()
  if UI:isOpen("cameraSwitch") then
    self:clearLastWeather()
    self.isForceSwitch = true
    return
  end
  if isEnter then
    self.isNowIndoor = true
    self:clearLastWeather()
  else
    if not self.isForceSwitch then
      if not self.isNowIndoor then
        return
      end
    else
      self.isForceSwitch = false
    end
    self.isNowIndoor = false
    local lastWeather = Me:data("main").weather
    if lastWeather then
      self:switchWeather(lastWeather, true)
    end
  end
end

function WeatherMgr:resetSpecialStates()
  Me.forbidHotWeatherFace = nil
end

function WeatherMgr:usingUmbrella()
  local inUseItem = Me:getInUseProp()
  return inUseItem and inUseItem.itemId == 1005
end

function WeatherMgr:updateWetEffect()
  if self.curWeather == Define.Weather.storm and not self.isNowIndoor and not self:usingUmbrella() then
    Me:sendPacket({
      pid = "addBadWeatherBuffer",
      buffer = World.cfg.weatherSetting.stormPlayerBuffer,
      duration = World.cfg.weatherSetting.wetEffectCheckTimer * 20
    })
  end
end

function WeatherMgr:updateSpecialStates()
  if self.curWeather == Define.Weather.hot then
    if not self.isNowIndoor and not Me.forbidHotWeatherFace then
      Me.forbidHotWeatherFace = true
      self:setMainPlayerFace(World.cfg.weatherSetting.hotFaceId)
      if self.faceTimer then
        LuaTimer:cancel(self.faceTimer)
        self.faceTimer = nil
      end
      self.faceTimer = LuaTimer:scheduleTimer(function()
        self:setMainPlayerFace(Me.dressId)
      end, World.cfg.weatherSetting.faceDuration * 1000, 1)
    end
  elseif self.curWeather == Define.Weather.snow and not self.isNowIndoor then
    self:setMainPlayerFace(World.cfg.weatherSetting.coldFaceId)
    if self.faceTimer then
      LuaTimer:cancel(self.faceTimer)
      self.faceTimer = nil
    end
    self.faceTimer = LuaTimer:scheduleTimer(function()
      self:setMainPlayerFace(Me.dressId)
    end, World.cfg.weatherSetting.faceDuration * 1000, 1)
    self:doBadWeatherAction(World.cfg.weatherSetting.coldActionId)
    if self.coldActionTimer then
      LuaTimer:cancel(self.coldActionTimer)
      self.coldActionTimer = nil
    end
    self.coldActionTimer = LuaTimer:scheduleTimer(function()
      self:doBadWeatherAction(0)
    end, World.cfg.weatherSetting.coldActionDuration * 1000, 1)
  end
end

function WeatherMgr:doBadWeatherAction(actionId)
  local upper = Me:getUpperAction()
  local base = Me:getBaseAction()
  if (upper ~= "idle" or base ~= "idle") and upper ~= "g2052_face_freeze" and base ~= "g2052_face_freeze" then
    return
  end
  Me:sendPacket({
    pid = "doBadWeatherAction",
    actionId = actionId
  })
end

function WeatherMgr:setMainPlayerFace(id)
  local info = Me:getShapeInfo()
  for _, v in pairs(info) do
    if World.cfg.weatherSetting.forbidChangeFaceSuits[v] then
      return
    end
  end
  if not id or id == 0 or id < 40000 then
    local skinData = {}
    local originalSkin = Me:getOriginalSkin()
    skinData.custom_face = originalSkin.custom_face or ""
    Me:sendPacket({
      pid = "roleChangeSkin",
      skinData = skinData,
      isReset = false,
      conflictParts = {},
      id = 0,
      lockState = 0
    })
    return
  end
  local data = T(Config, "AppearanceConfig"):getCfgById(id)
  if not data then
    return
  end
  Me:sendPacket({
    pid = "roleChangeSkin",
    skinData = data.parts,
    isReset = false,
    conflictParts = data.conflictParts,
    conflictOriginal = data.conflictOriginal,
    id = data.id,
    lockState = data.lockState,
    needBuy = data.needBuy
  })
end

function WeatherMgr:switchByPlayer(index)
  Me:sendPacket({
    pid = "switchWeatherByPlayer",
    index = index
  })
end

WeatherMgr:init()
return WeatherMgr
