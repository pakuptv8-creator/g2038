local UIChatManage = T(UIMgr, "UIChatManage")
local PlayerSpInfoManager = T(Lib, "PlayerSpInfoManager")
local cjson = require("cjson")
local chatSetting = World.cfg.chatSetting or {}
local operationType = FriendManager.operationType

function UIChatManage:voiceStartFunc(curTab)
end

function UIChatManage:voiceEndFunc(curTab)
end

function UIChatManage:initEvent()
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_CHAT_MESSAGE", Event.EVENT_CHAT_MESSAGE, function(msg, fromname, voiceTime, emoji, args, extraMsgArgs, msgPack, isWorldMsg, textVipColor, isCacheMsg)
    if not args then
      return
    end
    self:receiveChatMessage(msg, fromname, voiceTime, emoji, args[1], args[2], args[3], args[4], extraMsgArgs, msgPack, isWorldMsg, textVipColor, isCacheMsg)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat event : EVENT_SET_IGNORE", Event.EVENT_SET_IGNORE, function(id, objId, name, btn)
    if not self.ignoreList[id] then
      self.ignoreList[id] = true
      if btn then
        btn:SetText(Lang:toText("ui.chat.disignore"))
      end
    else
      self.ignoreList[id] = false
      if btn then
        btn:SetText(Lang:toText("ui.chat.ignore"))
      end
    end
    Client.ShowTip(1, Lang:toText(self.ignoreList[id] and "ui.chat.ignore.tip" or "ui.chat.disignore.tip"), 40)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_OPEN_PRIVATE_CHAT", Event.EVENT_OPEN_PRIVATE_CHAT, function(userId)
    self:setCurPrivateFriend(userId)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_CHAT_VOICE_START", Event.EVENT_CHAT_VOICE_START, function(path)
    self:voiceStartFunc(path)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_CHAT_VOICE_END", Event.EVENT_CHAT_VOICE_END, function(path)
    self:voiceEndFunc(path)
  end)
  Lib.subscribeEvent(Event.EVENT_FRIEND_OPERATION_NOTICE, function(opType, playerPlatformId)
    if opType == operationType.AGREE then
      Me:doRequestServerFriendInfo(Define.chatFriendType.game)
      Me:doRequestServerFriendInfo(Define.chatFriendType.platform)
      Me:addPlayerFriendFromExist(playerPlatformId, Define.friendStatus.gameFriend)
    elseif opType == operationType.DELETE then
      Me:doRequestServerFriendInfo(Define.chatFriendType.game)
      Me:doRequestServerFriendInfo(Define.chatFriendType.platform)
      Me:removePlayerFriendFromExist(playerPlatformId)
    elseif opType == operationType.ADD_FRIEND then
      AsyncProcess.LoadUserRequests()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_INVITE_GAME, function(userId)
    self:sendInviteMsg(userId)
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_STATUS, function(status, uId, uName)
    if status == 1 and self.headNameColor[uId] then
      self.headNameColor[uId] = nil
    end
  end)
  Lib.subscribeEvent(Event.EVENT_OPEN_PLAYER_INFORMATION, function(userId)
    UI:getWnd("chatMyProfile"):onShow(true, userId)
  end)
end

function UIChatManage:receiveChatMessage(msg, fromname, voiceTime, emoji, objID, dign, type, platId, extraMsgArgs, msgPack, isWorldMsg, textVipColor, isCacheMsg)
  if not self.requireChatContentItem then
    local class = require("modules/engine_overwrite/client/ui/widget/widget_chatContentItem")
    if not class then
      return
    end
    self.requireChatContentItem = true
  end
  if platId and self.ignoreList[platId] then
    return
  end
  Me:receiveChatMsgBuriedPoint(msg, fromname, voiceTime, emoji, objID, dign, type, platId, extraMsgArgs, msgPack, isWorldMsg)
  if platId and platId ~= Me.platformUserId then
    self:initDetailInfo(platId)
  end
  local nameColor = self:checkNameColor(platId)
  if type == Define.Page.TEAM and extraMsgArgs then
    local info = {
      type = type,
      msg = msg,
      fromname = fromname,
      voiceTime = voiceTime,
      emoji = emoji,
      objID = objID,
      dign = dign,
      platId = platId,
      msgPack = msgPack,
      isWorldMsg = isWorldMsg
    }
    info.teamInviteData = extraMsgArgs
    if nameColor then
      info.nameColor = nameColor
    end
    info.msg = Me:getTeamInviteMiniStr(extraMsgArgs)
    self:addMsg(type, info)
  else
    local h, msgLen = 20, string.len(msg or "")
    if (msg == "nil" or msgLen == 0) and not emoji then
      return
    end
    local info = {
      type = type,
      msg = msg,
      fromname = fromname,
      voiceTime = voiceTime,
      emoji = emoji,
      objID = objID,
      dign = dign,
      platId = platId,
      msgPack = msgPack,
      isWorldMsg = isWorldMsg,
      textVipColor = textVipColor
    }
    if nameColor then
      info.nameColor = nameColor
    end
    self:addMsg(type, info, extraMsgArgs, isCacheMsg)
  end
end

function UIChatManage:addMsg(type, info, extraMsgArgs, isCacheMsg)
  Lib.logDebug("UIChatManage:addMsg:", Lib.v2s(info, 2))
  Lib.logDebug("UIChatManage:addMsg2:", Lib.v2s(extraMsgArgs, 2))
  if type == Define.Page.PRIVATE then
    local keyId = extraMsgArgs.keyId
    if not self.chatTabDataList[type][keyId] then
      self.chatTabDataList[type][keyId] = {}
    end
    if #self.chatTabDataList[type][keyId] >= Define.miniChatMaxCnt then
      table.remove(self.chatTabDataList[type][keyId], 1)
    end
    self.curMsgOrderId = self.curMsgOrderId + 1
    info.msgOrderId = self.curMsgOrderId
    info.privateName = extraMsgArgs.privateName or extraMsgArgs.targetName or extraMsgArgs.receiverUserId or ""
    info.receiverUserId = extraMsgArgs.receiverUserId or keyId
    table.insert(self.chatTabDataList[type][keyId], info)
    self:updateHistory(keyId, info, extraMsgArgs)
  else
    if #self.chatTabDataList[type] >= Define.miniChatMaxCnt then
      table.remove(self.chatTabDataList[type], 1)
    end
    self.curMsgOrderId = self.curMsgOrderId + 1
    info.msgOrderId = self.curMsgOrderId
    table.insert(self.chatTabDataList[type], info)
  end
  if not extraMsgArgs or not extraMsgArgs.isHistory then
    for _, pageType in pairs(self:getCurMiniMsgList()) do
      if pageType == type then
        UI:getWnd("chatMini"):addMiniMsgInList(info)
        UI:getWnd("chatMini"):receiveChatMessage(type, info.msg, info.fromname, info.voiceTime, isCacheMsg)
        break
      end
    end
  end
end

function UIChatManage:showChatViewByType(chatWinType, openTab)
  if Me:checkIsMobileEditor() then
    return
  end
  self.curChatWinType = chatWinType
  if self.curChatWinType == Define.chatWinSizeType.noChatWnd then
    if UI:isOpen("chatMini") then
      UI:getWnd("chatMini"):onShow(false)
    end
    if UI:isOpen("chatBar") then
      UI:getWnd("chatBar"):ShowBar(false)
    end
  elseif self.curChatWinType == Define.chatWinSizeType.mainChat then
    if UI:isOpen("chatMini") then
      UI:getWnd("chatMini"):onShow(false)
    end
    if UI:isOpen("chatBar") then
      UI:getWnd("chatBar"):ShowBar(false)
    end
    Plugins.CallTargetPluginFunc("email_system", "SetEmailBarVisible", false)
  elseif self.curChatWinType == Define.chatWinSizeType.bigMiniChat then
    UI:getWnd("chatMini"):onShow(true, Define.chatWinSizeType.bigMiniChat)
    UI:getWnd("chatBar"):ShowBar(true)
    Plugins.CallTargetPluginFunc("email_system", "SetEmailBarVisible", true)
  elseif self.curChatWinType == Define.chatWinSizeType.smallMiniChat then
    UI:getWnd("chatMini"):onShow(true, Define.chatWinSizeType.smallMiniChat)
    UI:getWnd("chatBar"):ShowBar(true)
    Plugins.CallTargetPluginFunc("email_system", "SetEmailBarVisible", true)
  end
end

function UIChatManage:setCurPrivateFriend(userId)
  self.curPrivateUserId = userId
  self:checkHistoryIsNewAndDel(userId)
  Lib.emitEvent(Event.EVENT_UPDATE_FRIEND_PRIVATE_SHOW)
end

function UIChatManage:requestAppSendOnePrivate(targetUserId, msg, emoji)
  msg = World.CurWorld:filterWord(msg)
  local content = self:encodeJsonPrivateMsg(targetUserId, msg, emoji)
  local messageType = Define.privateMessageType.txtMsg
  local sourceType = Define.privateMessageSource.gameMsg
  if emoji then
    messageType = Define.privateMessageType.emojiMsg
  end
  local isPcPlatform = CGame.instance:getPlatformId() == 1
  if isPcPlatform and chatSetting.isPcTest then
    self:receivePlatformPrivateMsg(sourceType, messageType, content)
    self:testSendPrivateMsgToOthers(messageType, content)
  else
    CGame.instance:getShellInterface():onSendMessage(messageType, content)
  end
end

function UIChatManage:receiveFriendPrivateMsg(privateMsg, isHistory)
  local keyId, privateName
  if tonumber(privateMsg.senderUserId) == Me.platformUserId then
    keyId = tonumber(privateMsg.receiverUserId)
    if not keyId then
      return
    end
    local detailInfo = UIChatManage:getUserDetailInfo(keyId)
    if detailInfo then
      privateName = detailInfo.nickName or ""
      self:updateFriendPrivateMsg(privateMsg, isHistory, keyId, privateName)
    else
      if self["userDetailInfoCancel" .. keyId] then
        self["userDetailInfoCancel" .. keyId]()
      end
      self["userDetailInfoCancel" .. keyId] = Lib.lightSubscribeEvent("error!!!!! EVENT_USER_DETAIL", "EVENT_USER_DETAIL" .. keyId, function(data)
        privateName = data.nickName or privateMsg.receiverUserId or ""
        self:updateFriendPrivateMsg(privateMsg, isHistory, keyId, privateName)
        self["userDetailInfoCancel" .. keyId]()
      end)
      UIChatManage:initDetailInfo(keyId)
    end
  else
    keyId = tonumber(privateMsg.senderUserId)
    if not keyId then
      return
    end
    local detailInfo = UIChatManage:getUserDetailInfo(keyId)
    if detailInfo then
      privateName = detailInfo.nickName or privateMsg.senderNickname or privateMsg.senderUserId or ""
      self:updateFriendPrivateMsg(privateMsg, isHistory, keyId, privateName)
    else
      if self["userDetailInfoCancel" .. keyId] then
        self["userDetailInfoCancel" .. keyId]()
      end
      self["userDetailInfoCancel" .. keyId] = Lib.lightSubscribeEvent("error!!!!! EVENT_USER_DETAIL", "EVENT_USER_DETAIL" .. keyId, function(data)
        privateName = data.nickName or privateMsg.senderNickname or privateMsg.senderUserId or ""
        self:updateFriendPrivateMsg(privateMsg, isHistory, keyId, privateName)
        self["userDetailInfoCancel" .. keyId]()
      end)
      UIChatManage:initDetailInfo(keyId)
    end
  end
end

function UIChatManage:updateFriendPrivateMsg(privateMsg, isHistory, keyId, privateName)
  if self:checkHistoryIsNewAndDel(keyId) then
    if not self.cacheNewMsgDic[keyId] then
      self.cacheNewMsgDic[keyId] = {}
    end
    table.insert(self.cacheNewMsgDic[keyId], privateMsg)
  end
  local extraMsgArgs = {
    senderUserId = tonumber(privateMsg.senderUserId),
    fromname = privateMsg.senderNickname or privateMsg.senderUserId,
    targetName = privateMsg.receiverUserId,
    receiverUserId = tonumber(privateMsg.receiverUserId),
    keyId = keyId,
    privateName = privateName,
    messageType = privateMsg.messageType,
    isHistory = isHistory
  }
  self:receiveChatMessage(privateMsg.msgInfo.msg, extraMsgArgs.fromname, privateMsg.msgInfo.voiceTime, privateMsg.msgInfo.emoji, 0, nil, Define.Page.PRIVATE, extraMsgArgs.senderUserId, extraMsgArgs)
  Lib.emitEvent(Event.EVENT_RECEIVE_PRIVATE_MSG, extraMsgArgs)
end
