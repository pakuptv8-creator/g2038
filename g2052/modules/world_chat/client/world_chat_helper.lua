local WorldChatHelper = T(Lib, "WorldChatHelper")
local ChatLangConfig = T(Config, "ChatLangConfig")

function WorldChatHelper:init()
  self.playerHeadCacheList = {}
  self.getUserDetailIngPlayer = {}
  self.channelMsgList = {}
  self.blockPlayerMsgList = {}
  self.isBlockChannelMsg = false
  if ChatLangConfig:getCfgByLang(World.LangPrefix) then
    self.curSelectChannel = World.LangPrefix
  else
    self.curSelectChannel = "en"
  end
end

function WorldChatHelper:updateBlockPlayerList(userId, value)
  self.blockPlayerMsgList[userId] = value
  if value then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.world_chat.ignore.tips")
  end
end

function WorldChatHelper:setCurSelectChannel(value)
  self.curSelectChannel = value
end

function WorldChatHelper:setBlockChannelState(value)
  self.isBlockChannelMsg = value
end

function WorldChatHelper:receiveNewWorldMsg(info)
  if self.isBlockChannelMsg then
    return
  end
  if self.curSelectChannel ~= info.language then
    return
  end
  if self.blockPlayerMsgList[info.userId] then
    return
  end
  if not self.channelMsgList[info.language] then
    self.channelMsgList[info.language] = {}
  end
  if #self.channelMsgList[info.language] >= World.cfg.world_chatSetting.channelMsgNum then
    table.remove(self.channelMsgList[info.language], 1)
  end
  table.insert(self.channelMsgList[info.language], info)
  UI:getWnd("worldChatWnd"):addMsgInCacheList(info)
  UI:getWnd("worldChatWnd"):receiveWorldMessage(info)
  if not UI:isOpen("worldChatWnd") then
    Lib.emitEvent(Event.EVENT_UPDATE_WORLD_RED_SHOW, 1)
  end
end

function WorldChatHelper:getWorldDetailInfo(userId)
  if not userId then
    return
  end
  if self.playerHeadCacheList[userId] then
    return self.playerHeadCacheList[userId]
  end
  if userId == Me.platformUserId and Me.userDetailData then
    self.playerHeadCacheList[userId] = Me.userDetailData
    return self.playerHeadCacheList[userId]
  end
  if self.getUserDetailIngPlayer[userId] then
    return
  end
  self.getUserDetailIngPlayer[userId] = true
  AsyncProcess.GetUserDetail(userId, function(data)
    self.getUserDetailIngPlayer[userId] = false
    self.playerHeadCacheList[userId] = data
    if data.picUrl and #data.picUrl > 0 then
      Lib.emitEvent("EVENT_WORLD_USER_PIC_URL" .. userId, data.picUrl)
    end
  end)
  return
end

WorldChatHelper:init()
