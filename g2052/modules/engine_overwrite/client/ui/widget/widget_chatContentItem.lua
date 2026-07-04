local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local chatSetting = World.cfg.chatSetting
local EmojiConfig = T(Config, "EmojiConfig")
local ShortConfig = T(Config, "ShortConfig")
local UIChatManage = T(UIMgr, "UIChatManage")

local function getColorOfRGB(str)
  local newstr = string.gsub(str, "#", "")
  local colorlist = {}
  local index = 1
  while index < string.len(newstr) do
    local tempstr = string.sub(newstr, index, index + 1)
    table.insert(colorlist, tonumber(tempstr, 16))
    index = index + 2
  end
  return {
    (colorlist[1] or 0) / 255,
    (colorlist[2] or 0) / 255,
    (colorlist[3] or 0) / 255
  }
end

local voiceImageList = {
  "set:g2052_chat_box.json image:img_0_voiceicon_other",
  "set:g2052_chat_box.json image:img_0_voiceicon_other01",
  "set:g2052_chat_box.json image:img_0_voiceicon_other02"
}

function M:init()
  widget_base.init(self, "ChatContentItem.json")
  self:initWnd()
  self:initData()
  self:initEvent()
end

function M:initWnd()
  local size = chatSetting.alignment and chatSetting.alignment.miniSize or {
    450,
    250,
    400
  }
  self._root:SetHeight({
    0,
    chatSetting.chtBarHeight or 30
  })
  self._root:SetWidth({
    0,
    size[1] - 10
  })
  self.imgSound = self:child("ChatContentItem-Sound-Bar")
  self.txtChat = self:child("ChatContentItem-Text")
  self.txtChat:SetFontSize(chatSetting.chatFont or "HT16")
  self.imgPoint = self:child("ChatContentItem-Point")
  self.txtSoundTime = self:child("ChatContentItem-Sound-Time")
  self.lytOpenPlayer = self:child("ChatContentItem-Open-Player")
  self.imgEffect = self:child("ChatContentItem-Effect")
  self.imgEmoji = self:child("ChatContentItem-Emoji")
  self.imgHornIcon = self:child("ChatContentItem-HornIcon")
  local miniContentSpacing = chatSetting.miniContentSpacing or 0
  self.txtChat:SetTextLineExtraSpace(miniContentSpacing)
  self.imgTypeBg = self:child("ChatContentItem-typeBg")
  self.txtTypeStr = self:child("ChatContentItem-typeStr")
  self.txtTypeStr:SetFontSize(chatSetting.chatFont or "HT16")
  self.imgVipIcon = self:child("ChatContentItem-VipIcon")
  self.imgVipIcon:SetVisible(false)
  if chatSetting.chatMiniVoiceColor then
    self.txtSoundTime:SetTextColor(getColorOfRGB(chatSetting.chatMiniVoiceColor))
  end
  self.imgEffect:SetImage(voiceImageList[1])
end

function M:initData()
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_chatContentItem imgSound event : EventWindowClick", self.imgSound, UIEvent.EventWindowClick, function()
    if not self.data.playing then
      self:onPlaySound()
    end
  end)
  self:lightSubscribe("error!!!!! script_client widget_chatContentItem lytOpenPlayer event : EventWindowClick", self.lytOpenPlayer, UIEvent.EventWindowClick, function()
    if self.data and #self.data.fromname > 0 and self.data.platId ~= Me.platformUserId then
      UIChatManage:setCurPrivateFriend(self.data.platId)
    end
  end)
  self.voiceStart = Lib.lightSubscribeEvent("error!!!!! script_client widget_chatContentItem Lib event : EVENT_CHAT_VOICE_START", Event.EVENT_CHAT_VOICE_START, function(path)
    local voiceName = string.sub(path, -19)
    if not self.data then
      return
    end
    local voiceName2 = string.sub(self.data.msg, -19)
    if voiceName2 == voiceName then
      self.data.isRead = true
      self.data.playing = true
      self.imgPoint:SetVisible(false)
      self:playSoundAni()
    end
  end)
  self.voiceEnd = Lib.lightSubscribeEvent("error!!!!! script_client widget_chatContentItem Lib event : EVENT_CHAT_VOICE_END", Event.EVENT_CHAT_VOICE_END, function(path)
    if not self.data then
      return
    end
    local voiceName = string.sub(path, -19)
    local voiceName2 = string.sub(self.data.msg, -19)
    if voiceName == voiceName2 then
      self.data.playing = false
      self:stopSoundAni()
    end
  end)
end

function M:onPlaySound()
  if not self.data.isRead then
    self.data.isRead = true
    self.imgPoint:SetVisible(false)
  end
  VoiceManager:playVoice(self.data.msg, math.floor((self.data.voiceTime or self.data.times) / 1000) or 0)
end

function M:playSoundAni()
  self.voiceAniIndex = 1
  self.voiceAniTimer = World.Timer(10, function()
    local num = #voiceImageList
    local index = self.voiceAniIndex % num + 1
    self.imgEffect:SetImage(voiceImageList[index])
    self.voiceAniIndex = self.voiceAniIndex + 1
    return true
  end)
end

function M:stopSoundAni()
  if self.voiceAniTimer then
    self.voiceAniTimer()
    self.voiceAniTimer = nil
  end
  self.imgEffect:SetImage(voiceImageList[1])
end

local function getBorderColor(str)
  local curColorStr = str or "000000"
  local newstr = string.gsub(curColorStr, "#", "")
  local colorlist = {}
  local index = 1
  while index < string.len(newstr) do
    local tempstr = string.sub(newstr, index, index + 1)
    table.insert(colorlist, tonumber(tempstr, 16))
    index = index + 2
  end
  return tostring(colorlist[1] / 255) .. " " .. tostring(colorlist[2] / 255) .. " " .. tostring(colorlist[3] / 255) .. " 1"
end

local function getColorStr(colorlist)
  local curColorStr = "FF"
  for i = 1, 3 do
    local num = math.floor(colorlist[i] * 255)
    local tempStr = string.sub(string.format("%#x", num), 3)
    curColorStr = curColorStr .. tempStr
  end
  return curColorStr
end

function M:initNameColor(data)
  if data.type == Define.Page.SYSTEM then
    self.nameColorStr = ""
    return
  end
  self.voiceColorStr = "FF" .. (chatSetting.chatMiniVoiceColor or "000000")
  if World.cfg.isUseChatVIP and Me:checkPlayerIsVipByUserId(data.platId) then
    self.nameColorStr = "FF" .. World.cfg.ChatVipNameColor
  else
    local defaultNameColor = chatSetting.miniNiceNameColor or "FF0000"
    if chatSetting.isOpenChatHeadColor then
      self.nameColorStr = "FF" .. (data.nameColor or defaultNameColor)
    else
      self.nameColorStr = "FF" .. defaultNameColor
    end
    if data.platId == Me.platformUserId then
    elseif data.dign == Define.ChatPlayerType.server then
      self.nameColorStr = "98FB98"
    elseif data.dign == Define.ChatPlayerType.vip then
      self.nameColorStr = "FFFAFF07"
    elseif data.dign == Define.ChatPlayerType.svip then
      self.nameColorStr = "FFEC0420"
    end
  end
end

function M:initSystemMsg(data)
  self.nameColorStr = ""
  self.imgHornIcon:SetVisible(true)
  self.imgEffect:SetVisible(false)
  self.imgSound:SetVisible(false)
  self.imgEmoji:SetVisible(false)
  self.lytOpenPlayer:SetVisible(false)
  local preNullStr = "      "
  self.imgTypeBg:SetVisible(false)
  self.txtTypeStr:SetVisible(false)
  self.imgVipIcon:SetVisible(false)
  self.contentColorStr = "FF" .. chatSetting.chatTypeColor[Define.Page.SYSTEM] or "000000"
  local finalShowStr = preNullStr .. "\226\150\162" .. self.contentColorStr .. "" .. data.msg
  self:autoBarSize(preNullStr .. data.msg, nil, 30)
  self.txtChat:SetText(finalShowStr)
end

function M:getOneShortName(name)
  local p1, p2 = string.find(name, "&%$", 1)
  local nameStr = name
  local preStr = ""
  local endStr = ""
  if p1 and p2 then
    local p3, p4 = string.find(name, "%$", p2 + 1)
    if p3 and p4 then
      local p5, p6 = string.find(name, "%$&", p4 + 1)
      if p5 and p6 then
        nameStr = string.sub(name, p4 + 1, p5 - 1)
        preStr = string.sub(name, 1, p4)
        endStr = string.sub(name, p5)
      end
    end
  end
  local p7 = string.find(nameStr, "%[S=", 1)
  local p8 = string.find(nameStr, ".json%]", -6)
  if p7 and p8 then
    nameStr = string.sub(nameStr, 1, p7 - 1)
  end
  local endIndex = Lib.subStringGetTotalIndex(nameStr)
  local maxLen = chatSetting.miniChatNameMaxLen or 7
  if endIndex > maxLen then
    local content = Lib.subStringUTF8(nameStr, 1, maxLen)
    local result = preStr .. content .. endStr .. "..."
    return result
  else
    return name
  end
end

function M:listenDetailInfo(platId)
  if not platId then
    Lib.logError("ChatContentItem:listenDetailInfo id is nil!")
    return
  end
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
  end
  self.userDetailInfoCancel = Lib.lightSubscribeEvent("error!!!!! EVENT_USER_DETAIL", "EVENT_USER_DETAIL" .. platId, function(data)
    local startIndex, endIndex = string.find(self.data.finalShowStr, self.data.fromname, 1, true)
    if data.nickName and startIndex and 0 < startIndex then
      local preStr = string.sub(self.data.finalShowStr, 1, startIndex - 1)
      local endStr = string.sub(self.data.finalShowStr, endIndex + 1)
      self.data.finalShowStr = preStr .. data.nickName .. endStr
    end
  end)
  UIChatManage:initDetailInfo(platId)
end

function M:initViewByData(data)
  if self.voiceAniTimer then
    self.voiceAniTimer()
    self.voiceAniTimer = nil
  end
  self.data = data
  if data.type == Define.Page.SYSTEM then
    self:initSystemMsg(data)
    return
  end
  self.imgHornIcon:SetVisible(false)
  self.lytOpenPlayer:SetVisible(true)
  self:initNameColor(data)
  local preTypeStr = ""
  if self.data.platId then
    print("initViewByData self.data.platId:", self.data.platId)
    local detailInfo = UIChatManage:getUserDetailInfo(self.data.platId)
    if detailInfo then
      data.fromname = detailInfo.nickName or ""
    else
      self:listenDetailInfo(self.data.platId)
    end
  end
  local preNullStr = ""
  self.imgTypeBg:SetVisible(false)
  self.txtTypeStr:SetVisible(false)
  local vipTextColor = data.textVipColor or World.cfg.ChatTextColor or "000000"
  local privatePreStr = ""
  if World.cfg.isUseChatVIP then
    if data.type == Define.Page.PRIVATE then
      if self.data.platId == Me.platformUserId then
        privatePreStr = "{" .. Lang:toText("g2052.gui.chat.private.target") .. " "
        if false and data.receiverUserId and Me:checkPlayerIsVipByUserId(data.receiverUserId) then
          preNullStr = "      "
          self.imgVipIcon:SetVisible(true)
        else
          preNullStr = ""
          self.imgVipIcon:SetVisible(false)
        end
      else
        privatePreStr = "{" .. Lang:toText("g2052.gui.chat.private.NewFrom") .. " "
        if false and Me:checkPlayerIsVipByUserId(data.platId) then
          preNullStr = "      "
          self.imgVipIcon:SetVisible(true)
        else
          preNullStr = ""
          self.imgVipIcon:SetVisible(false)
        end
      end
      local strW = self.txtChat:GetStringWidth(privatePreStr)
      self.imgVipIcon:SetXPosition({0, strW})
      if Me:checkPlayerIsVipByUserId(data.platId) then
        self.contentColorStr = "FF" .. vipTextColor
      else
        self.contentColorStr = "FF" .. (World.cfg.ChatTextColor or "000000")
      end
    else
      if false and Me:checkPlayerIsVipByUserId(data.platId) then
        preNullStr = "      "
        self.imgVipIcon:SetVisible(true)
      else
        preNullStr = ""
        self.imgVipIcon:SetVisible(false)
      end
      if Me:checkPlayerIsVipByUserId(data.platId) then
        self.contentColorStr = "FF" .. vipTextColor
      else
        self.contentColorStr = "FF" .. (World.cfg.ChatTextColor or "000000")
      end
      self.imgVipIcon:SetXPosition({0, 0})
    end
  else
    preNullStr = ""
    self.imgVipIcon:SetVisible(false)
    self.contentColorStr = "FF" .. (chatSetting.chatFontColor or "000000")
    self.imgVipIcon:SetXPosition({0, 0})
  end
  local initNameStr = ""
  local preNameStr = ""
  local nameLen = 0
  if data.type then
    if data.type == Define.Page.PRIVATE then
      local fromName
      if self.data.platId == Me.platformUserId then
        local receiveName = self:getOneShortName(data.privateName)
        fromName = self:getOneShortName(Me.name)
        initNameStr = receiveName .. "}:"
      else
        fromName = self:getOneShortName(data.privateName)
        initNameStr = fromName .. "}:"
      end
      preNameStr = privatePreStr .. preNullStr .. initNameStr
      local preStrWidth = self.txtTypeStr:GetStringWidth(privatePreStr .. preNullStr)
      self.lytOpenPlayer:SetXPosition({
        0,
        5 + preStrWidth
      })
    else
      local designationTxt = Plugins.CallTargetPluginFunc("tendering_land", "getTenderDesignationAward", self.data.platId)
      if designationTxt and designationTxt ~= "" then
        initNameStr = "[" .. designationTxt .. self:getOneShortName(data.fromname) .. "]:"
      else
        initNameStr = "[" .. self:getOneShortName(data.fromname) .. "]:"
      end
      preNameStr = preNullStr .. initNameStr
      local preStrWidth = self.txtTypeStr:GetStringWidth(preNullStr or "")
      self.lytOpenPlayer:SetXPosition({
        0,
        5 + preStrWidth
      })
    end
  end
  nameLen = self.txtChat:GetStringWidth(preNameStr)
  local nameWidth = self.txtChat:GetStringWidth(initNameStr)
  self.lytOpenPlayer:SetWidth({0, nameWidth})
  if data.dign == Define.ChatPlayerType.server then
    preTypeStr = Lang:toText("ui.chat.chatMsgType" .. Define.Page.SYSTEM)
    preNameStr = preNullStr
  end
  self.txtTypeStr:SetText(preTypeStr)
  self.data.finalShowStr = ""
  self.imgEmoji:SetVisible(false)
  self.imgSound:SetVisible(false)
  self.imgEffect:SetVisible(false)
  if data.emoji and data.emoji.type == Define.chatEmojiTab.FACE then
    self.imgEmoji:SetVisible(true)
    self.imgEmoji:SetImage(data.emoji.emojiData)
    self.data.finalShowStr = "\226\150\162" .. self.nameColorStr .. preNameStr
    self.imgEmoji:SetXPosition({
      0,
      15 + nameLen
    })
    self:autoBarSize(preNullStr .. initNameStr)
  else
    local finalMsg = data.msg
    if data.voiceTime then
      self.imgEffect:SetVisible(true)
      self.imgSound:SetVisible(true)
      if not data.isRead then
        data.isRead = data.objID == Me.objID
      end
      self.imgPoint:SetVisible(not data.isRead)
      local times = math.floor(data.voiceTime / 1000)
      self.txtSoundTime:SetText("\226\150\162" .. self.voiceColorStr .. times .. "''")
      finalMsg = ""
    end
    if data.dign == Define.ChatPlayerType.server then
      preTypeStr = Lang:toText("ui.chat.chatMsgType" .. Define.Page.SYSTEM)
      local msg = Lang:toText(data.msg)
      self.data.finalShowStr = preNullStr .. "\226\150\162" .. self.contentColorStr .. "" .. msg
    elseif data.type == Define.Page.PRIVATE then
      local text = data.msg
      local item = ShortConfig:getItemByName(text)
      if item then
        finalMsg = Lang:toText(text)
      end
      local privateColor = "\226\150\162FF" .. World.cfg.ChatPrivateColor
      if self.data.platId == Me.platformUserId then
        local receiveName = self:getOneShortName(data.privateName)
        local fromName = self:getOneShortName(Me.name)
        local fromColor = "\226\150\162" .. self.nameColorStr
        local receiverColor = "\226\150\162FF" .. UIChatManage:checkNameColor(data.receiverUserId or Me.platformUserId)
        if World.cfg.isUseChatVIP and data.receiverUserId and Me:checkPlayerIsVipByUserId(data.receiverUserId) then
          receiverColor = "\226\150\162FF" .. World.cfg.ChatVipNameColor
        end
        local receiveText = receiveName .. "}:"
        local receiveStr = receiverColor .. receiveName .. privateColor .. "}:"
        preNameStr = privateColor .. privatePreStr .. preNullStr .. receiveStr
        if data.voiceTime then
          self.data.finalShowStr = preNameStr
          self:autoBarSize(privatePreStr .. preNullStr .. receiveText, true)
        else
          self:autoBarSize(privatePreStr .. preNullStr .. receiveText .. finalMsg)
          self.data.finalShowStr = preNameStr .. finalMsg
        end
      else
        local fromName = self:getOneShortName(data.privateName)
        local fromColor = "\226\150\162" .. self.nameColorStr
        local fromText = fromName .. "}:"
        local fromStr = fromColor .. fromName .. privateColor .. "}:"
        preNameStr = privateColor .. privatePreStr .. preNullStr .. fromStr
        if data.voiceTime then
          self.data.finalShowStr = preNameStr
          self:autoBarSize(privatePreStr .. preNullStr .. fromText, true)
        else
          self:autoBarSize(privatePreStr .. preNullStr .. fromText .. finalMsg)
          self.data.finalShowStr = preNameStr .. finalMsg
        end
      end
    elseif data.fromname and #data.fromname > 0 then
      local text = data.msg
      local item = ShortConfig:getItemByName(text)
      if item then
        finalMsg = Lang:toText(text)
      end
      local designationTxt = Plugins.CallTargetPluginFunc("tendering_land", "getTenderDesignationAward", self.data.platId, true)
      if designationTxt and designationTxt ~= "" then
        local nameText = preNullStr .. "[" .. designationTxt .. "\226\150\162" .. self.nameColorStr .. self:getOneShortName(data.fromname) .. "]:"
        if data.voiceTime then
          self.data.finalShowStr = "\226\150\162" .. self.nameColorStr .. nameText
          self:autoBarSize(preNullStr .. initNameStr .. finalMsg, true)
        else
          self.data.finalShowStr = "\226\150\162" .. self.nameColorStr .. nameText .. "\226\150\162" .. self.contentColorStr .. "" .. finalMsg
          self:autoBarSize(preNullStr .. initNameStr .. finalMsg)
        end
      elseif data.voiceTime then
        self.data.finalShowStr = "\226\150\162" .. self.nameColorStr .. preNameStr
        self:autoBarSize(preNullStr .. initNameStr .. finalMsg, true)
      else
        self.data.finalShowStr = "\226\150\162" .. self.nameColorStr .. preNameStr .. "\226\150\162" .. self.contentColorStr .. "" .. finalMsg
        self:autoBarSize(preNullStr .. initNameStr .. finalMsg)
      end
    else
      preTypeStr = Lang:toText("ui.chat.chatMsgType" .. Define.Page.SYSTEM)
      self.data.finalShowStr = preNullStr .. "\226\150\162" .. self.contentColorStr .. "" .. data.msg
      self:autoBarSize(preNullStr .. initNameStr .. finalMsg)
    end
  end
  self.txtChat:SetText(self.data.finalShowStr)
end

function M:autoBarSize(msg, isVoice, onlineHeight)
  local onlineHeight = onlineHeight or chatSetting.chtBarHeight or 30
  local strW = self.txtChat:GetStringWidth(msg)
  local rootW = self._root:GetWidth()[2]
  local txtNodeW = self.txtChat:GetWidth()
  local uiW = rootW * txtNodeW[1] + txtNodeW[2]
  uiW = 0 < uiW and uiW or -uiW
  local voiceDis = 15
  local voiceW = self.imgSound:GetWidth()[2] + voiceDis
  if strW > uiW then
    local offsetLine = math.ceil(strW / uiW)
    local miniContentSpacing = chatSetting.miniContentSpacing or 0
    local curHeight = onlineHeight + (offsetLine - 1) * (onlineHeight + miniContentSpacing)
    if isVoice then
      self._root:SetHeight({
        0,
        curHeight + onlineHeight
      })
      self.imgSound:SetYPosition({
        0,
        curHeight - 10
      })
      self.imgSound:SetXPosition({0, voiceDis})
    else
      self._root:SetHeight({0, curHeight})
    end
  elseif isVoice then
    if uiW < strW + voiceW then
      self._root:SetHeight({
        0,
        onlineHeight * 2
      })
      self.imgSound:SetYPosition({
        0,
        onlineHeight - 10
      })
      self.imgSound:SetXPosition({0, voiceDis})
    else
      self._root:SetHeight({
        0,
        onlineHeight + 10
      })
      self.imgSound:SetYPosition({0, 0})
      self.imgSound:SetXPosition({
        0,
        voiceDis + strW
      })
    end
  else
    self._root:SetHeight({0, onlineHeight})
  end
end

function M:SetWidth(width1, width2)
  self._root:SetWidth({width1, width2})
end

function M:onDestroy()
  if self.voiceStart then
    self.voiceStart()
  end
  if self.voiceEnd then
    self.voiceEnd()
  end
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
  end
  if self.voiceAniTimer then
    self.voiceAniTimer()
    self.voiceAniTimer = nil
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
