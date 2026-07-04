require("common.entity_game_common")
require("common.event_game_common")
require("common.define_game_common")
require("common.lib_common")
require("common.config.sound_config")
require("common.report_helper_common")
require("common.brightness_helper_common")
require("common.sound_helper_common")

local function registerGameRDProfile()
  local RedDotConfig = T(Config, "RedDotConfig")
  Plugins.CallPluginFunc("registerProfile", RedDotConfig.profile)
end

require("common.config.chat_short_lang_config")
if World.isClient then
  require("client.player.player_game_common")
  require("client.player.packet_game_common")
  require("client.entity.entity_value_func_game_common")
  require("client.gm_game_common")
  require("client.entity.entity_game_common")
  registerGameRDProfile()
  registerGameRDProfile()
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(playerInfo)
    if playerInfo.userId == Me.platformUserId then
      Me:playSoundByKey("bgm_born")
      Me:playWeatherBgm()
    end
  end)
  Blockman.instance.gameSettings:setUseNewFirstViewer(true)
  local operationType = FriendManager.operationType
  Lib.subscribeEvent(Event.EVENT_FRIEND_OPERATION_CLIENT, function(opType, userId)
    if opType == operationType.AGREE then
      local defaultData = {friend_respond_result = 1}
      Plugins.CallTargetPluginFunc("report", "report", "friend_respond", defaultData, Me)
    elseif opType == operationType.REFUSE then
      local defaultData = {friend_respond_result = 2}
      Plugins.CallTargetPluginFunc("report", "report", "friend_respond", defaultData, Me)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local BrightnessScaleHelper = T(Lib, "brightnessScaleHelper")
    BrightnessScaleHelper:changePlayerBrightnessScale(objID)
  end)
  local old_scene_event = L("SceneEvent", scene_event)
  
  function scene_event(instance, signalKey, argsTable)
    old_scene_event(instance, signalKey, argsTable)
    if signalKey == "client_create_instance" then
      instance:onClientCreated()
    end
  end
else
  require("server.player.player_game_common")
  require("server.player.packet_game_common")
  require("server.gm_game_common")
  require("server.entity.entity_game_common")
  require("server.chatMsgCacheHelper")
end
local handlers = {}

function handlers.defaultSetting()
  return {
    settingKey = "gameCommonSetting"
  }
end

if World.isClient then
  function handlers.CHANGE_MAIN_WND_PLAY_MODEL(model, modelData)
    Me:changePlayModel(model, modelData)
  end
  
  function handlers.UpdateCommonWaitWndShow(isShow)
    if isShow then
      UI:openWnd("commonWaitWnd")
    else
      UI:closeWnd("commonWaitWnd")
    end
  end
else
  local roomGameConfig = Server.CurServer:getConfig()
  local regionId = roomGameConfig:getRegionId()
  local runtimeTime
  
  function handlers.GAME_GO()
    if runtimeTime then
      return
    end
    runtimeTime = World.Timer(1728000, function()
      Game.QuitServer()
    end)
  end
  
  function handlers.ENTER_MOBILE_EDITOR_MODE(player)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncChangePlayModel",
        model = "MobileEditor",
        modelData = {}
      })
    end
  end
  
  function handlers.LEAVE_MOBILE_EDITOR_MODE(player)
    if player and player:isValid() then
      player:sendPacket({
        pid = "syncChangePlayModel",
        model = "Normal",
        modelData = {}
      })
    end
  end
  
  local InteractSoundHelper = T(Lib, "InteractSoundHelper")
  
  function handlers.ENTITY_ENTER(context)
    local entity = context.obj1
    if not entity or not entity:isValid() then
      return
    end
    if entity.isPlayer then
      InteractSoundHelper:sendPlayLoopSounds(entity)
    else
    end
  end
  
  local ChatMsgCacheHelper = T(Lib, "ChatMsgCacheHelper")
  
  function handlers.OnPlayerLogin(player)
    ChatMsgCacheHelper:pushClientCacheChatMsg(player)
    local packet = {
      pid = "SCPushClientRegionId",
      regionId = regionId
    }
    if player and player:isValid() then
      player:sendPacket(packet)
    end
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
