local handles = T(Player, "PackageHandlers")
local BrightnessScaleHelper = T(Lib, "brightnessScaleHelper")
local InteractSoundHelper = T(Lib, "InteractSoundHelper")
local InteractionHelper = T(Lib, "InteractionHelper")
local ChatShortLangConfig = T(Config, "ChatShortLangConfig")
local emptyPos = {
  x = 0,
  y = 0,
  z = 0
}

function handles:StartCameraSmoothMovement(packet)
  if not packet.params then
    return
  end
  local mainCamera = CameraManager.Instance():findCamera("mainCamera")
  if not mainCamera then
    return
  end
  local curCamPos = mainCamera:getPosition()
  local curPos = packet.params.curPos
  local targetPos = packet.params.targetPos
  curPos = Lib.tov3(curPos or emptyPos)
  targetPos = Lib.tov3(targetPos or emptyPos)
  local offset = curCamPos - curPos
  local targetCamPos = targetPos + offset
  local time = packet.params.time
  self:startCameraSmoothMovement(curCamPos, targetCamPos, time)
end

function handles:deltaEntityProp(packet)
  if packet.isNeedRecover then
    self:recoverEntityProp(packet.key)
  end
  self:deltaEntityProp(packet.key, packet.value)
end

function handles:updateAreaBgm(packet)
  if Me.carMusic then
    return
  end
  local key = packet.key
  if key then
    if key == "weather" then
      Me:playWeatherBgm()
    else
      Me:switchBgmSoundByKey(key)
    end
  end
end

function handles:onPlaySoundEffect(packet)
  local key = packet.key
  if key then
    local sid, info = Me:playSoundByKey(key)
    if info and info.loop then
      Me:setCurInteractiveSound(sid)
    end
  end
end

function handles:StopSoundEffect(packet)
  Me:stopSound(packet.sid)
end

function handles:Play3dSoundByKey(packet)
  local params = packet.params or {}
  local sid = self:play3dSoundByKey(params.key, params.pos or self:getPosition(), params.time)
  if not Me.Sound3DTable then
    Me.Sound3DTable = {}
  end
  table.insert(Me.Sound3DTable, sid)
end

function handles:StopAll3dSound()
  for _, sid in pairs(Me.Sound3DTable or {}) do
    Me:stopSound(sid)
  end
  Me.Sound3DTable = nil
end

function handles:playCarMusic(packet)
  local params = packet.params or {}
  local key = params.key
  if not key or key == "" then
    return
  end
  if Me.carMusic and Me.carMusic.key == key then
    return
  end
  self:switchBgmSoundByKey(key)
  if not Me.carMusic then
    Me.carMusic = {key = key}
  end
end

function handles:stopCarMusic(packet)
  if not Me.carMusic then
    return
  end
  Me:stopGameBgm()
  Me:switchBgmSoundByKey("bgm_day")
  Me.carMusic = nil
end

function handles:transformState(packet)
  if packet.isStart == 1 then
    Lib.emitEvent(Event.EVENT_TRANSFORM_START)
  else
    Lib.emitEvent(Event.EVENT_TRANSFORM_END)
  end
end

function handles:openPasswordInput(packet)
  UI:openWnd("password", packet.password, function()
    Me:sendPacket({
      pid = "triggerPartInteractC2S",
      partID = packet.partID
    })
  end)
end

function handles:openColorSelect(packet)
  local partName = packet.partName
  local effectInfo = packet.effectInfo or {}
  if not partName then
    return
  end
  local partStr = Lang:toText("g2052.gui.part." .. partName)
  UI:openWnd("dyeingColorSelect", {
    title = Lang:toText({
      "g2052.gui.dyeing.part.color",
      partStr
    }),
    leaveCb = function()
      UI:closeWnd("dyeingColorSelect")
    end,
    confirmCb = function(color)
      if color then
        UI:getWnd("dyeingColorSelect"):setLocked()
        Me.disableJumpToLeavePart = true
        Me:sendPacket({
          pid = "reqDyeingPart",
          partName = partName,
          color = {
            r = color.r,
            g = color.g,
            b = color.b
          },
          effectInfo = effectInfo
        })
      end
    end
  })
end

function handles:closeColorSelect(packet)
  if UI:isOpen("dyeingColorSelect") then
    UI:closeWnd("dyeingColorSelect")
  end
end

function handles:syncChangePlayModel(packet)
  Me:changePlayModel(packet.model, packet.modelData)
end

function handles:UpdatePlayerBrightnessScaleList(packet)
  BrightnessScaleHelper:updatePlayerBrightnessScale(packet.info, packet.all)
end

function handles:clientPlayInteractSound(packet)
  InteractSoundHelper:playSound(packet.data)
end

function handles:clientStopInteractSound(packet)
  InteractSoundHelper:stopSound(packet.data)
end

function handles:SendSoundToOthers(packet)
  if packet.host and packet.host == self.platformUserId then
    return
  end
  local data = packet.data
  data.isToOthers = false
  InteractSoundHelper:playSound(data)
end

function handles:SendPlayLoopSounds(packet)
  local loopSounds = packet.loopSounds or {}
  for _, v in pairs(loopSounds) do
    InteractSoundHelper:playSound(v)
  end
end

function handles:PushClientCacheChatMsg(packet)
  for _, v in pairs(packet.msgList or {}) do
    self:clientChatMessage(v, true)
  end
end

function handles:SCPushClientRegionId(packet)
  Plugins.CallTargetPluginFunc("tendering_land", "updateClientRegionId", packet.regionId)
  Plugins.CallTargetPluginFunc("drama", "updateClientRegionId", packet.regionId)
end

function handles:syncNotifyParty(packet)
  local content = packet.content
  if not (content and content.userId and content.name and content.partyId) or not content.partyType then
    return
  end
  UI:getWnd("gameMain"):showNotifyParty(content)
end

function handles:SCPlayOnceAction(packet)
  InteractionHelper:updateOnceActionData(packet)
end

function handles:SCPartSendShortMsg(packet)
  local shortCfg = ChatShortLangConfig:getCfgById(packet.shortId)
  if shortCfg then
    local msg = World.CurWorld:filterWord(Lang:toText(shortCfg.shortDesc))
    if packet.needHead then
      self:addOneHeadBubbleMsg(packet.args[1], msg, packet.textVipColor, false)
    end
    if packet.needChat then
      packet.msg = msg
      self:clientChatMessage(packet, false, true)
    end
  end
end
