local Player = _ENV.Player
local handles = T(Player, "PackageHandlers")
local EmojiConfig = T(Config, "EmojiConfig")
local chatSetting = World.cfg.chatSetting or {}
local ShortConfig = T(Config, "ShortConfig")
local VoiceEffect = {
  effect = "g2042_voice_1.effect",
  pos = {
    x = 0,
    y = 2,
    z = 0
  },
  yaw = 0,
  time = 10000
}
local playerHeadEffect = {}

function handles:ChatMessage(packet)
  self:clientChatMessage(packet)
end

function Player:clientChatMessage(packet, isCacheMsg, isNoBubble)
  if not self:isOpenedChatTabType(packet.args[3]) then
    return
  end
  Lib.emitEvent(Event.EVENT_CHAT_MESSAGE, packet.msg, packet.fromname, packet.voiceTime, packet.emoji or false, packet.args, nil, packet.msgPack, nil, packet.textVipColor, isCacheMsg)
  if packet.args[3] ~= Define.Page.COMMON or packet.args[2] == Define.ChatPlayerType.server then
    return
  end
  if not isNoBubble then
    self:addOneHeadBubbleMsg(packet.args[1], packet.msg, packet.textVipColor, packet.emoji, packet.voiceTime)
  end
end

function Player:addOneHeadBubbleMsg(objID, msg, textVipColor, emoji, voiceTime)
  local entity = World.CurWorld:getEntity(objID)
  if entity and entity:isValid() then
    if emoji then
      if emoji.type == Define.chatEmojiTab.FACE then
        msg = EmojiConfig:getTextByIcon(emoji.emojiData) and Lang:toText(EmojiConfig:getTextByIcon(emoji.emojiData)) or "emoji"
        if chatSetting.chatBubbleSetting then
          if not entity.headBubbleWnd then
            entity.headBubbleWnd = UILib.headTopUIFollowObject("chatBubbleWnd", entity.objID)
          end
          entity.headBubbleWnd:invoke("addOneNewMsg", msg, nil, entity.platformUserId, textVipColor)
        else
          entity:showHeadMessage(msg)
        end
      end
    else
      local item = ShortConfig:getItemByName(msg)
      if item then
        msg = Lang:toText(string.len(item.headText or "") > 0 and item.headText or msg)
      end
      if chatSetting.chatBubbleSetting then
        if not entity.headBubbleWnd then
          entity.headBubbleWnd = UILib.headTopUIFollowObject("chatBubbleWnd", entity.objID)
        end
        entity.headBubbleWnd:invoke("addOneNewMsg", msg, voiceTime, entity.platformUserId, textVipColor)
      else
        entity:showHeadMessage(msg)
      end
    end
  end
end

function handles:ChatSystemMessage(packet)
  if not self:isOpenedChatTabType(packet.args[3]) then
    return
  end
  local msg = Lang:toText(packet.msg)
  local content = World.CurWorld:filterWord(msg)
  if packet.msg2 then
    msg = Lang:toText({
      packet.msg,
      packet.msg2
    })
    content = msg
  end
  Lib.emitEvent(Event.EVENT_CHAT_MESSAGE, content, packet.fromname, packet.voiceTime, packet.emoji or false, packet.args, nil, packet.msgPack)
end
