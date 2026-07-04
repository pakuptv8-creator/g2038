local Interact = T(World, "Interact")

function Interact.uiOpen(target, params, from, add)
  if params.useCsv then
    params = {
      uiName = params[1]
    }
  end
  UI:openWnd(params.uiName)
end

function Interact.uiClose(target, params, from, add)
  if params.useCsv then
    params = {
      uiName = params[1]
    }
  end
  UI:closeWnd(params.uiName)
end

function Interact.effect(target, params, from, add)
  if params.useCsv then
    local pos_tmp = Lib.split(params[2], ",")
    params = {
      name = params[1],
      pos = Lib.v3(pos_tmp[1], pos_tmp[2], pos_tmp[3])
    }
  end
  if add then
    Blockman.instance:playEffectByPos(params.name, params.pos, 0, -1)
  else
    Blockman.instance:delEffect(params.name, params.pos)
  end
  return true
end

function Interact.face_player(target, value, from, add)
  if add then
    local entityPos = target:getPosition()
    target:setMove(0, entityPos, Lib.v3AngleXZ(Lib.v3cut(from:getPosition(), entityPos)), target:getRotationPitch(), target:cfg().posSyncDelay or 1, 0)
  end
  return true
end

function Interact.glitch(target, params, from, add)
  if params.useCsv then
    params = {
      time = tonumber(params[1]) or 0
    }
  end
  if add then
    Blockman.instance.gameSettings:setEnableGlitch(true)
    if params.time > 0 then
      World.LightTimer("disable interact glitch", params.time, function()
        Blockman.instance.gameSettings:setEnableGlitch(false)
      end)
    end
  else
    Blockman.instance.gameSettings:setEnableGlitch(false)
  end
end

function Interact.action(target, params, from)
  if params.useCsv then
    params = {
      action = params[1],
      time = tonumber(params[2]),
      isFrom = params[3] == "TRUE" or params[3] == "true"
    }
  end
  local actionTarget = target
  if params.isFrom then
    actionTarget = from
  end
  if actionTarget and actionTarget:isValid() then
    Lib.logDebug("interact upperAction  ", params.action)
    local preBaseAction
    if actionTarget.getBaseAction then
      preBaseAction = actionTarget:getBaseAction()
    end
    actionTarget.actionEndTime = actionTarget:updateUpperAction(params.action, params.time) + World.Now()
    if preBaseAction then
      actionTarget:setBaseAction(preBaseAction)
    end
  end
  return true
end

function Interact.baseAction(target, params, from)
  if params.useCsv then
    params = {
      action = params[1],
      time = tonumber(params[2]),
      isFrom = params[3] == "TRUE" or params[3] == "true"
    }
  end
  local actionTarget = target
  if params.isFrom then
    actionTarget = from
  end
  if actionTarget:isValid() then
    actionTarget:setBaseAction(params.action)
  end
  return true
end

function Interact.buyItem(target, params, from, add)
  if not from:isValid() or from.objID ~= Me.objID or not add then
    return false
  end
  Shop.Buy(params.shopCfg)
  return true
end

function Interact.play_sound(target, params, from, add)
  if params.useCsv then
    params = {
      sound = params[1],
      selfOnly = params[2] == "true" or params[2] == "TRUE",
      loop = params[3] == "true" or params[3] == "TRUE",
      volume = tonumber(params[4]),
      path = params[5]
    }
  end
  if not from:isValid() or from.objID ~= Me.objID then
    return false
  end
  if add then
    Me.interactSoundId = Me:playSound(params)
  elseif Me.interactSoundId then
    Me:stopSound(Me.interactSoundId)
    Me.interactSoundId = nil
  end
  return true
end

function Interact.play_bgm(target, params, from)
  if params.useCsv then
    params = {
      bgmSound = params[1],
      bgmVolume = tonumber(params[2])
    }
  end
  Me:playGameBgm(params)
  return true
end

function Interact.fog(target, params, from, add)
  if add then
    if params.useCsv then
      local colorArr = Lib.split(params[6], ",")
      local pEnd = tonumber(params[4])
      params = {
        type = tonumber(params[1]),
        density = tonumber(params[2]),
        start = tonumber(params[3]),
        min = tonumber(params[5]),
        color = Lib.v3(colorArr[1], colorArr[2], colorArr[3])
      }
      params["end"] = pEnd
    end
    Blockman.instance.gameSettings:setCustomFog(params.start, params["end"], params.density, params.color, params.type, params.min)
    Blockman.instance.gameSettings.hideFog = false
  else
    Blockman.instance.gameSettings.hideFog = true
  end
  return true
end

function Interact.dynamic_skybox(target, params, from)
  if params.useCsv then
    params = {
      {
        transition = tonumber(params[1]),
        time = tonumber(params[2]),
        texture = Lib.split(params[3], ",")
      }
    }
  end
  local map = from.map
  map.cfg.skyBox = params
  map:updateSkyBox()
  return true
end

local cameraSaveData

function Interact.static_camera(target, params, from)
  if params.useCsv then
    local posArr = Lib.split(params[2], ",")
    params = {
      time = tonumber(params[1]) or 0,
      pos = Lib.v3(posArr[1], posArr[2], posArr[3]),
      yaw = tonumber(params[3]),
      pitch = tonumber(params[4]),
      distance = tonumber(params[5])
    }
  end
  if params.time > 0 and not Me.cameraTimer then
    local bm = Blockman.instance
    local cameraInfo = bm:getCameraInfo()
    cameraSaveData = {
      curInfo = cameraInfo.curInfo
    }
    Blockman.instance:setPersonView(4)
    Me:changeCameraView(params.pos, params.yaw, params.pitch, params.distance)
    Me.cameraTimer = World.LightTimer("reset camera", params.time, function()
      bm:setPersonView(cameraSaveData.curInfo.curPersonView)
      bm:setCanSwitchView(cameraSaveData.curInfo.canSwitchView)
      cameraSaveData = nil
      Me.cameraTimer = nil
    end)
  end
  return true
end

function Interact.showOrHideChatUI(target, params, from)
  if params.useCsv then
    params = {
      chatType = tonumber(params[1])
    }
  end
  Plugins.CallTargetPluginFunc("platform_chat", "openChatWndByType", params.chatType)
  return true
end

function Interact.updateSceneLoadLevel(target, params, from)
  if params.useCsv then
    params = {
      loadLevel = tonumber(params[1])
    }
  end
  World.CurMap:setSceneLoadLevel(params.loadLevel)
  return true
end

function Interact.buff(target, value, from, add)
  if type(value) == "table" then
    if value.useCsv then
      value = {
        name = value[1],
        time = tonumber(value[2]),
        isFrom = value[3] == "TRUE" or value[3] == "true"
      }
    end
  elseif type(value) == "string" then
    value = {name = value}
  end
  local buffTarget = target
  if value.isFrom then
    buffTarget = from
  end
  if buffTarget and buffTarget:isValid() then
    buffTarget:addClientBuff(value.name, value.time)
  end
  return true
end

function Interact.create_entity(target, params, from, notDisable, extraParams)
  if params.useCsv then
    local posArr = Lib.split(params[2], ",")
    params = {
      name = params[1],
      pos = Lib.v3(posArr[1], posArr[2], posArr[3]),
      yaw = tonumber(params[3]),
      lifeTime = tonumber(params[4])
    }
    if extraParams and type(extraParams) == "table" then
      for key, value in pairs(params) do
        for k, v in pairs(extraParams) do
          if key == k then
            params[key] = v
          end
        end
      end
    end
  end
  local map = target and target.map
  map = map or from and from.map
  local entity = EntityClient.CreateClientEntity({
    cfgName = params.name,
    map = map,
    pos = params.pos,
    ry = params.yaw,
    name = "",
    owner = from
  })
  if params.lifeTime > 0 then
    World.Timer(params.lifeTime, function()
      if entity:isValid() then
        entity:destroy()
      end
    end)
  end
  return true
end

function Interact.full_screen_effect(target, params, from)
  local userId = from.userId
  userId = userId or from.platformUserId
  if not userId or userId ~= Me.platformUserId then
    return
  end
  if params.useCsv then
    local scale = Lib.splitString(params[3], ",")
    local offset = Lib.splitString(params[4], ",")
    params = {
      effect = params[1],
      time = tonumber(params[2]),
      scale = Lib.v2(tonumber(scale[1]) or 1, tonumber(scale[2]) or 1),
      offset = Lib.v3(tonumber(offset[1]) or 0, tonumber(offset[2]) or -0.5, tonumber(offset[3]) or 0),
      subIndex = tonumber(params[5]) or 1,
      uiLevel = tonumber(params[6]) or 1
    }
  end
  Lib.emitEvent(Event.EVENT_FULL_SCREEN_EFFECT, params)
  return true
end
