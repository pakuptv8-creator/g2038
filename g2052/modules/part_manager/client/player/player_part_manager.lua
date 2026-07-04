local Player = _ENV.Player

function Player:doStartSlideLadder()
  Me:sendPacket({
    pid = "doStartSlideLadder",
    objID = self.objID
  })
end

function Player:clientDoPlayerPartEffect(effectInfo)
  local action = effectInfo.action
  local scale = effectInfo.scale or 1
  if action == "play" then
    Blockman.instance:playEffectByPos(effectInfo.effectName, effectInfo.pos, effectInfo.yaw, -1, {
      x = scale,
      y = scale,
      z = scale
    })
  else
    Blockman.instance:delEffect(effectInfo.effectName, effectInfo.pos)
  end
end

local soundIds = {}
local ti = TdAudioEngine.Instance()
local lightSoundPath = "asset/sound/"

function Player:clientDoPartLight(packet)
  local firePos = packet.firePos
  local effectName = packet.effectName
  local scale = packet.scale or 1
  local yaw = packet.yaw or 0
  local soundName = packet.soundName or "house_fire.mp3"
  local soundVolume = packet.soundVolume or 1
  if firePos and effectName and effectName ~= "" then
    if packet.action == "play" then
      Blockman.instance:playEffectByPos(effectName, firePos, yaw, -1, {
        x = scale,
        y = scale,
        z = scale
      })
      local soundId = ti:play3dSound(lightSoundPath .. soundName, firePos, true)
      ti:setSoundsVolume(soundId, soundVolume)
      ti:set3DRollOffMode(soundId, Sound3DRollOffType.LINEAR)
      ti:set3DMinMaxDistance(soundId, 1, 10)
      soundIds[effectName .. "_" .. firePos.x .. "_" .. firePos.y .. "_" .. firePos.z] = soundId
    else
      Blockman.instance:delEffect(effectName, firePos)
      local soundId = soundIds[effectName .. "_" .. firePos.x .. "_" .. firePos.y .. "_" .. firePos.z]
      if soundId then
        ti:stopSound(soundId)
        soundIds[effectName .. "_" .. firePos.x .. "_" .. firePos.y .. "_" .. firePos.z] = nil
      end
    end
  end
end

function Player:onInitTextDecalText(type, part, params)
  if not part.surfaceInfo then
    part.surfaceInfo = {}
  end
  local info = Lib.splitString(params[1], "$")
  for _, val in pairs(info) do
    local temp = Lib.splitString(val, "#")
    local faceID = tonumber(temp[1])
    if not part.surfaceInfo[faceID] then
      part.surfaceInfo[faceID] = Instance.Create("TextDecal")
      part.surfaceInfo[faceID]:setProperty("decalSurface", temp[1])
      part.surfaceInfo[faceID]:setParent(part)
    end
    part.surfaceInfo[faceID]:setText(Lang:toText(temp[2] or ""))
    part.surfaceInfo[faceID]:setFont(temp[3] or "HT20")
    part.surfaceInfo[faceID]:setTextColor(Lib.getTextColor(temp[4] or "000000"))
    local horz = tonumber(temp[5]) or 1
    if horz == 0 then
      part.surfaceInfo[faceID]:setHorzFormatting("LeftAligned")
    elseif horz == 1 then
      part.surfaceInfo[faceID]:setHorzFormatting("CentreAligned")
    else
      part.surfaceInfo[faceID]:setHorzFormatting("RightAligned")
    end
    local vert = tonumber(temp[5]) or 1
    if vert == 0 then
      part.surfaceInfo[faceID]:setVertFormatting("TopAligned")
    elseif vert == 1 then
      part.surfaceInfo[faceID]:setVertFormatting("CentreAligned")
    else
      part.surfaceInfo[faceID]:setVertFormatting("BottomAligned")
    end
  end
end
