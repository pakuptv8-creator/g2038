require("common.config.voice_pack_config")
if World.isClient then
  require("client.packet.voice_pack_pk_handler")
  require("client.packet.voice_pack_pk_sender")
  require("client.voice_pack_gm")
else
  require("server.packet.voice_pack_pk_handler")
  require("server.packet.voice_pack_pk_sender")
  require("server.web.voice_pack_web")
  require("server.voice_pack_gm")
end
local handlers = {}

function handlers.onPlayerReady(player)
  if World.isClient then
    return
  end
  if player.voicePackData then
    return
  end
  local SVoicePackData = require("server.data.s_voice_pack_data")
  player.voicePackData = SVoicePackData.new(player)
end

function handlers.onGameReady()
  if not World.isClient then
    return
  end
  World.LightTimer("[voice_pack]:handlers.onGameReady()", 1, function()
    if Me.voicePackData then
      return
    end
    local CVoicePackData = require("client.data.c_voice_pack_data")
    Me.voicePackData = CVoicePackData.new(Me)
  end)
end

function handlers.addVoicePack(player, id)
  if not player.voicePackData then
    return
  end
  player.voicePackData:addVoicePack(id)
end

function handlers.removeVoicePack(player, id)
  if not player.voicePackData then
    return
  end
  player.voicePackData:removeVoicePack(id)
end

function handlers.hasVoicePack(player, id)
  if not player.voicePackData then
    return false
  end
  return player.voicePackData:hasVoicePack(id)
end

function handlers.playVoicePack(player, id)
  if World.isClient then
    local CVoicePackPkSender = T(Player, "PackageSender")
    CVoicePackPkSender:sendPlayVoicePack(id)
  else
    local handles = T(Player, "PackageHandlers")
    handles.PlayVoicePack(player, {id = id})
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
