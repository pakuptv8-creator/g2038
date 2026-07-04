local WinChatMini = M
local UIAnimationManager = T(UILib, "UIAnimationManager")
local LuaTimer = T(Lib, "LuaTimer")
local chatSetting = World.cfg.chatSetting or {}
local EmojiConfig = T(Config, "EmojiConfig")
local UIChatManage = T(UIMgr, "UIChatManage")

function WinChatMini:init()
  WinBase.init(self, "ChatMini.json")
  self:initUI()
  self:initEvent()
  self:subscribeEvent()
  self:initMiniPos()
end

function WinChatMini:initUI()
  self.lytContentPos = self:child("ChatMini-Content-Pos")
  self.imgContentBg = self:child("ChatMini-Content-Bg")
  self.btnGotoBottom = self:child("ChatMini-Go-Bottom")
  self.imgArray = self:child("ChatMini-array")
  self.lytMiniClose = self:child("ChatMini-Mini-Close")
  self.lytSizeControl = self:child("ChatMini-Size-Control")
  self.lytInputPanel = self:child("ChatMini-InputPanel")
  self.imgInputBg = self:child("ChatMini-InputBg")
  self.btnSend = self:child("ChatMini-Send")
  self.btnSend:SetText(Lang:toText("g2052.gui.tendering.email.send_btn"))
  self.lytEditorPanel = self:child("ChatMini-EditorPanel")
  self.lytCommonPanel = self:child("ChatMini-CommonPanel")
  self.txtCommonText = self:child("ChatMini-CommonText")
  self.editCommonEditor = self:child("ChatMini-CommonEditor")
  self.lytPrivatePanel = self:child("ChatMini-PrivatePanel")
  self.lytPrivateMask = self:child("ChatMini-PrivateMask")
  self.lytPrivateRight = self:child("ChatMini-PrivateRight")
  self.txtPrivateText = self:child("ChatMini-PrivateText")
  self.txtPrivateName = self:child("ChatMini-PrivateName")
  self.editPrivateEditor = self:child("ChatMini-PrivateEditor")
  self.editCommonEditor:SetMaxLength(chatSetting.maxMsgSize or 150)
  self.editPrivateEditor:SetMaxLength(chatSetting.maxMsgSize or 150)
  self.lytInfoPanel = self:child("ChatMini-InfoPanel")
  self.lytInfoPanel:SetVisible(true)
  self.lytExtraPanel = self:child("ChatMini-ExtraPanel")
  self.imgHistoryIcon = self:child("ChatMini-HistoryIcon")
  self.imgVipColorPanel = self:child("ChatMini-VipColorPanel")
  self.imgVipNIcon = self:child("ChatMini-VipNIcon")
  self.imgVoicePack = self:child("ChatMini-VoicePack")
  self.imgVipNIcon:SetDrawColor(Lib.getTextColor("000000"))
  self.imgVoicePack:SetVisible(World.cfg.isUseVoicePack)
  self.lytShortPanel = self:child("ChatMini-ShortPanel")
  self.shortUIWidget = UIMgr:new_widget("chatShortLangView")
  self.shortUIWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytShortPanel:AddChildWindow(self.shortUIWidget)
  self.lytHistoryPanel = self:child("ChatMini-HistoryPanel")
  local params = {
    xDis = 0,
    yDis = 2,
    xCellNum = 1,
    widgetWidth = 255,
    widgetHeight = 38,
    widgetJson = "ChatMiniHistory.json",
    widgetName = "chatMiniHistory",
    gvParent = self.lytHistoryPanel,
    dataList = {}
  }
  self.historyListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.historyGridView = self.historyListView:getGridView()
  self.historyGridView:SetMoveAble(true)
  self.historyGridView:SetvScorllMoveAble(true)
  self.historyGridView:SetAutoColumnCount(false)
  self.historyAdapter = self.historyListView:getAdapter()
  self.newMsgNum = 0
  self.horizontalAlignment = chatSetting.alignment and chatSetting.alignment.horizontalAlignment or 1
  self.verticalAlignment = chatSetting.alignment and chatSetting.alignment.verticalAlignment or 2
  self.contentItemPool = {}
  self.lstContent = UIMgr:new_widget("grid_view")
  self.lstContent:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lstContent:InitConfig(0, 1, 1)
  self.lytContentPos:AddChildWindow(self.lstContent)
  self.contentInfoCache = {}
  self.imgArray:SetVisible(false)
  self.btnGotoBottom:SetVisible(false)
  self.lytMiniClose:SetVisible(false)
  if World.cfg.chatSetting and World.cfg.chatSetting.chatLevel then
    self:root():SetLevel(World.cfg.chatSetting.chatLevel)
    self.lytSizeControl:SetVisible(World.cfg.chatSetting.isShowMiniSizeBtn)
  end
  self.lytSizeControl:SetVisible(false)
  self.lytVoicePanel = self:child("ChatMini-VoicePanel")
  self.txtVoiceNum = self:child("ChatMini-VoiceNum")
  self.btnVoiceBtn = self:child("ChatMini-VoiceBtn")
  self.lytVoiceCancelBg = self:child("ChatMini-VoiceCancelBg")
  self.lytVoiceStatePanel = self:child("ChatMini-VoiceStatePanel")
  self.txtVoiceTime = self:child("ChatMini-VoiceTime")
  self.txtVoiceTime:SetVisible(false)
  self.txtCancelTips = self:child("ChatMini-CancelTips")
  self.txtSendTips = self:child("ChatMini-SendTips")
  self.imgStartVoiceIcon = self:child("ChatMini-StartVoiceIcon")
  self.imgCancelVoiceIcon = self:child("ChatMini-CancelVoiceIcon")
  self.txtSendTips:SetText(Lang:toText("ui.chat.send.voice"))
  self.txtCancelTips:SetText(Lang:toText("ui.chat.cancel.send.voice"))
  self.lastVoiceTime = chatSetting.voiceLastTime or 10
  self:updateVoiceIconShow(1)
  self.unReadMsgNum = 0
  self:initSendInfo()
end

function WinChatMini:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self.lytInfoPanel:SetVisible(true)
    self.chatMiniShowTime = 0
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  end)
  self:subscribe(self.btnGotoBottom, UIEvent.EventButtonClick, function()
    self:gotoBottom()
  end)
  self:subscribe(self.btnSend, UIEvent.EventButtonClick, function()
    self:sendChatMessage()
  end)
  self:subscribe(self.lytPrivateMask, UIEvent.EventWindowClick, function()
    self.sendMsgText = ""
    UIChatManage:setCurPrivateFriend()
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  end)
  self:subscribe(self.imgVipColorPanel, UIEvent.EventWindowClick, function()
    self:updateVipColorShow()
  end)
  self:subscribe(self.imgVoicePack, UIEvent.EventWindowClick, function()
    self:updateVoiceBtnState()
  end)
  self:subscribe(self.imgHistoryIcon, UIEvent.EventWindowClick, function()
    local privateFriend = UIChatManage:getCurPrivateFriend()
    if privateFriend then
      UIChatManage:setCurPrivateFriend()
      if self.historyShowState then
        self:updateHistoryPanelShow(false)
      end
    elseif self.historyShowState then
      self:updateHistoryPanelShow(false)
    else
      self:updateHistoryPanelShow(true)
    end
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  end)
  self:lightSubscribe("error!!!!! win_chatMini lytSizeControl event : EventWindowTouchDown", self.lytSizeControl, UIEvent.EventWindowTouchDown, function()
    if self.winSizeType == Define.chatWinSizeType.smallMiniChat then
      self.winSizeType = Define.chatWinSizeType.bigMiniChat
    elseif self.winSizeType == Define.chatWinSizeType.bigMiniChat then
      self.winSizeType = Define.chatWinSizeType.smallMiniChat
    end
    self:updateWinSize()
  end)
  self:lightSubscribe("error!!!!! script_client win_chat lstContent event : EventWindowTouchDown", self.lstContent, UIEvent.EventWindowTouchDown, function()
    self.lstTouchDown = true
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_chat lstContent event : EventWindowTouchDown", self.lstContent, UIEvent.EventWindowTouchMove, function()
    self.lstMove = true
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_chat lstContent event : EventWindowTouchDown", self.lstContent, UIEvent.EventWindowTouchUp, function()
    if not self.lstTouchDown or not self.lstMove then
    end
    self.lstTouchDown = false
    self.lstMove = false
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  end)
  self:subscribe(self.lstContent, UIEvent.EventScrollMoveChange, function()
    if not self.isShow or not self.btnGotoBottom:IsVisible() then
      return
    end
    local offset = self.lstContent:GetScrollOffset()
    local minOffset = self.lstContent:GetMinScrollOffset()
    if offset <= minOffset then
      self.btnGotoBottom:SetVisible(false)
      self.newMsgNum = 0
    end
  end)
  self:lightSubscribe("error!!!!! win_chatMini editCommonEditor event : EventEditTextInput", self.editCommonEditor, UIEvent.EventEditTextInput, function(window)
    local inputStr = self.editCommonEditor:GetPropertyString("Text", "") or ""
    self:updateSendMsgText(tostring(inputStr))
    self:updateCommonEditEndShow()
    self.sendPassTime = -1
  end)
  self:lightSubscribe("error!!!!! win_chatMini editCommonEditor event : EventWindowTouchDown", self.editCommonEditor, UIEvent.EventWindowTouchDown, function()
    self.sendPassTime = -1
    self.txtCommonText:SetVisible(false)
    if self.historyShowState then
      self:updateHistoryPanelShow(false)
    end
  end)
  self:lightSubscribe("error!!!!! win_chatMini editCommonEditor event : EventWindowTouchUp", self.editCommonEditor, UIEvent.EventWindowTouchUp, function()
    self.txtCommonText:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! win_chatMini editCommonEditor event : EventEditTextInput", self.editPrivateEditor, UIEvent.EventEditTextInput, function(window)
    local inputStr = self.editPrivateEditor:GetPropertyString("Text", "") or ""
    self:updateSendMsgText(tostring(inputStr))
    self:updatePrivateEditEndShow()
    self.sendPassTime = -1
  end)
  self:lightSubscribe("error!!!!! win_chatMini editCommonEditor event : EventWindowTouchDown", self.editPrivateEditor, UIEvent.EventWindowTouchDown, function()
    self.txtPrivateText:SetVisible(false)
    self.sendPassTime = -1
  end)
  self:lightSubscribe("error!!!!! win_chatMini editCommonEditor event : EventWindowTouchUp", self.editPrivateEditor, UIEvent.EventWindowTouchUp, function()
    self.txtPrivateText:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client WinChatMini btnVoiceBtn event : EventWindowTouchDown", self.btnVoiceBtn, UIEvent.EventWindowTouchDown, function()
    if not Me:getCanSendSound() then
      UI:openWnd("chatShop")
      return
    end
    self:startRecordMsg()
    self:updateVoiceIconShow(2)
  end)
  self:lightSubscribe("error!!!!! script_client WinChatMini btnVoiceBtn event : EventWindowTouchUp", self.btnVoiceBtn, UIEvent.EventWindowTouchUp, function()
    self:updateVoiceIconShow(1)
    self:stopRecordMsg()
  end)
  self:lightSubscribe("error!!!!! script_client WinChatMini btnVoiceBtn event : EventWindowTouchMove", self.btnVoiceBtn, UIEvent.EventWindowTouchMove, function()
    if not self.isRecording then
      return
    end
    self:updateVoiceIconShow(2)
  end)
  self:lightSubscribe("error!!!!! script_client WinChatMini lytVoiceCancelBg event : EventWindowTouchUp", self.lytVoiceCancelBg, UIEvent.EventWindowTouchMove, function()
    if not self.isRecording then
      return
    end
    self:updateVoiceIconShow(3)
  end)
  self:lightSubscribe("error!!!!! script_client WinChatMini lytVoiceCancelBg event : EventWindowTouchUp", self.lytVoiceCancelBg, UIEvent.EventWindowTouchUp, function()
    self:cancelRecordMsg()
    self:updateVoiceIconShow(1)
  end)
end

function WinChatMini:subscribeEvent()
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_SET_CHAT_ALIGNMENT", Event.EVENT_SET_CHAT_ALIGNMENT, function(horizontalType, verticalType, offset)
    self:setAlignmentType(horizontalType, verticalType, offset or false)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_UPDATE_FRIEND_PRIVATE_SHOW", Event.EVENT_UPDATE_FRIEND_PRIVATE_SHOW, function()
    if not UI:isOpen(self) then
      UIChatManage:showChatViewByType(Define.chatWinSizeType.smallMiniChat)
    end
    self:updateChatTabType()
    local curPrivateUserId = UIChatManage:getCurPrivateFriend()
    if curPrivateUserId and 0 < curPrivateUserId then
      self.txtPrivateText:SetVisible(false)
      self.sendPassTime = -1
      self.editPrivateEditor:OpenKeyboard()
    end
  end)
  Lib.lightSubscribeEvent("error!!!!!  : EVENT_UPDATE_PRIVATE_HISTORY", Event.EVENT_UPDATE_PRIVATE_HISTORY, function()
    self:updateHistoryInfo()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_SOUND_TIME_CHANGE", Event.EVENT_SOUND_TIME_CHANGE, function(value)
    self:updateSoundTimes()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_FREE_SOUND_TIME_CHANGE", Event.EVENT_FREE_SOUND_TIME_CHANGE, function(value)
    self:updateSoundTimes()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_SOUND_MOON_CHANGE", Event.EVENT_SOUND_MOON_CHANGE, function(value)
    self:updateSoundTimes()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_CHAT_SEND_VOICE", Event.EVENT_CHAT_SEND_VOICE, function(time, url)
    if not self:checkCanSend() then
      self:cancelRecordMsg()
      return
    end
    self:sendVoiceMsg(time, url)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_chat Lib event : EVENT_CHAT_VOICE_FILE_ERROR", Event.EVENT_CHAT_VOICE_FILE_ERROR, function(errorType)
    Client.ShowTip(1, Lang:toText("ui.chat.voicefail"), 40)
  end)
  Lib.subscribeEvent(Event.EVENT_GAME_PAUSE, function()
    if not self.isRecording then
      return
    end
    self:cancelRecordMsg()
    self:updateVoiceIconShow(1)
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_VIP_CHAT_TEXT, function(value)
    self.imgVipNIcon:SetDrawColor(Lib.getTextColor(value))
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    self:updateVipPanelShow()
  end)
end

function WinChatMini:initView(winSizeType)
  self.winSizeType = winSizeType or Define.chatWinSizeType.smallMiniChat
  self:updateWinSize()
  self:initChatSendInfo()
  self:updateSoundTimes()
  self:updateVoiceIconShow(1)
  self:updateVipPanelShow()
  self:resetExtraIconShow()
  self.imgVipNIcon:SetDrawColor(Lib.getTextColor(Me:getTextVipColor()))
end

function WinChatMini:updateVipPanelShow()
  if World.cfg.isUseChatVIP and Me:checkPlayerIsVipByUserId(Me.platformUserId) then
    self.imgVipColorPanel:SetVisible(true)
  else
    self.imgVipColorPanel:SetVisible(false)
    UI:closeWnd("chatVipWnd")
  end
end

function WinChatMini:resetExtraIconShow()
  self.imgVipNIcon:SetVisible(true)
  if World.cfg.isUseVoicePack then
    self.imgVoicePack:SetImage("set:g2052_main.json image:icon_0_voice")
  end
end

function WinChatMini:updateVipColorShow(isForceHide)
  if UI:isOpen("chatVipWnd") then
    UI:closeWnd("chatVipWnd")
  else
    UI:openWnd("chatVipWnd")
  end
end

function WinChatMini:updateVoiceBtnState(isForceHide)
  if UI:isOpen("voice_pack") then
    UI:closeWnd("voice_pack")
    self.imgVoicePack:SetImage("set:g2052_main.json image:icon_0_voice")
  else
    UI:openWnd("voice_pack")
    self.imgVoicePack:SetImage("set:g2052_main.json image:icon_0_voice01")
  end
end

function WinChatMini:updateVoiceIconShow(vState)
  if vState == 1 then
    self.lytVoiceStatePanel:SetVisible(false)
    self.imgStartVoiceIcon:SetVisible(false)
    self.imgCancelVoiceIcon:SetVisible(false)
    self.lytVoiceCancelBg:SetVisible(false)
  elseif vState == 2 then
    self.lytVoiceStatePanel:SetVisible(true)
    self.imgStartVoiceIcon:SetVisible(true)
    self.imgCancelVoiceIcon:SetVisible(false)
    self.lytVoiceCancelBg:SetVisible(true)
  elseif vState == 3 then
    self.lytVoiceStatePanel:SetVisible(true)
    self.imgStartVoiceIcon:SetVisible(false)
    self.imgCancelVoiceIcon:SetVisible(true)
    self.lytVoiceCancelBg:SetVisible(true)
  end
end

function WinChatMini:updateSoundTimes()
  if not Me.getSoundMoonCardEnable then
    return
  end
  if Me:getSoundMoonCardEnable() then
    Lib.logDebug("is moon card")
    self.txtVoiceNum:SetText("*")
  elseif Me:getSoundTimes() > 0 then
    Lib.logDebug("is purchase sound")
    self.txtVoiceNum:SetText(Me:getSoundTimes())
  elseif 0 < Me:getFreeSoundTimes() then
    local freeSoundTimes = Me:getFreeSoundTimes()
    self.txtVoiceNum:SetText(freeSoundTimes)
  else
    self.txtVoiceNum:SetText("")
  end
end

function WinChatMini:startRecordMsg()
  self.isRecording = true
  self.sendPassTime = -1
  local curPrivateUserId = UIChatManage:getCurPrivateFriend()
  VoiceManager:startRecord(self.curTab == Define.Page.PRIVATE and curPrivateUserId or false)
  local curIndex = 0
  self.imgStartVoiceIcon:SetImage("set:g2052_chat_box.json image:pbar_0_voice")
  self.txtVoiceTime:SetVisible(false)
  local voiceRemainTime = chatSetting.voiceMaxTime or 60
  self.voiceTimer = World.Timer(20, function()
    voiceRemainTime = voiceRemainTime - 1
    if voiceRemainTime <= (chatSetting.voiceLastTime or 10) then
      self.txtVoiceTime:SetVisible(true)
      if 1 > self.lastVoiceTime then
        self.txtVoiceTime:SetVisible(false)
        self.lastVoiceTime = chatSetting.voiceLastTime or 10
        self.voiceTimer = nil
        VoiceManager:stopRecord(self.curTab == Define.Page.PRIVATE and curPrivateUserId or false)
        self:updateVoiceIconShow(1)
        self.isRecording = false
        return false
      end
      self.lastVoiceTime = self.lastVoiceTime - 1
      self.txtVoiceTime:SetText(self.lastVoiceTime .. "s")
    end
    curIndex = curIndex % 4 + 1
    self.imgStartVoiceIcon:SetImage("set:g2052_chat_box.json image:pbar_0_voice_schedule0" .. curIndex)
    return true
  end)
end

function WinChatMini:stopRecordMsg()
  self.sendPassTime = 0
  if not Me:getCanSendSound() then
    UI:openWnd("chatShop")
    return
  end
  if not self.isRecording then
    return
  end
  self.isRecording = false
  local curPrivateUserId = UIChatManage:getCurPrivateFriend()
  local receiverUserId = self.curTab == Define.Page.PRIVATE and curPrivateUserId or false
  VoiceManager:stopRecord(receiverUserId)
  if self.voiceTimer then
    self.voiceTimer()
    self.txtVoiceTime:SetVisible(false)
    self.lastVoiceTime = chatSetting.voiceLastTime or 10
    self.voiceTimer = nil
  end
  local defaultData = {
    chat_type = receiverUserId and 2 or 1
  }
  Plugins.CallTargetPluginFunc("report", "report", "chat_new_voice", defaultData, Me)
end

function WinChatMini:cancelRecordMsg()
  self.sendPassTime = 0
  if not Me:getCanSendSound() then
    UI:openWnd("chatShop")
    return
  end
  if self.isRecording then
    Client.ShowTip(1, Lang:toText("ui.chat.voicefail"), 40)
  end
  self.isRecording = false
  local curPrivateUserId = UIChatManage:getCurPrivateFriend()
  VoiceManager:cancelRecord(self.curTab == Define.Page.PRIVATE and curPrivateUserId or false)
  if self.voiceTimer then
    self.voiceTimer()
    self.txtVoiceTime:SetVisible(false)
    self.lastVoiceTime = chatSetting.voiceLastTime or 10
    self.voiceTimer = nil
  end
end

function WinChatMini:sendVoiceMsg(time, url)
  if not self:checkCanSend() then
    return
  end
  self:sendChatMsgToServer(url, time)
end

function WinChatMini:initChatSendInfo()
  self:setInitEditorShow()
  self.chatMiniShowTime = 0
  self:startChatSendTimer()
  self:updateHistoryPanelShow(false)
  self:updateChatTabType()
  self:updateUnReadNum(0)
end

function WinChatMini:updateUnReadNum(num)
  self.unReadMsgNum = num
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_CHAT_RED, self.unReadMsgNum)
end

function WinChatMini:setAlignmentType(horizontalType, verticalType, offset)
  if not horizontalType then
    return
  end
  if not verticalType then
    return
  end
  self.horizontalAlignment = horizontalType
  self.verticalAlignment = verticalType
  self.alignmentOffset = offset
  self:initMiniPos()
end

function WinChatMini:initMiniPos()
  self._root:SetHorizontalAlignment(self.horizontalAlignment)
  self._root:SetVerticalAlignment(self.verticalAlignment)
  local offset = chatSetting.alignment and chatSetting.alignment.offset or {
    0,
    0,
    0,
    0
  }
  local _off = self.alignmentOffset or offset
  self._root:SetXPosition({
    _off[1],
    _off[2]
  })
  self._root:SetYPosition({
    _off[3],
    _off[4]
  })
end

function WinChatMini:updateWinSize()
  self:refreshWin()
  self.lytInfoPanel:SetVisible(true)
end

function WinChatMini:refreshWin()
  self.lstContent:InitConfig(0, 1, 1)
  self:gotoBottom()
end

local function cleanDoubleMaxInfoTable(tb)
  local tbCnt = #tb
  if tbCnt > Define.miniChatMaxCnt then
    table.remove(tb, 1)
  end
end

function WinChatMini:addMiniMsgInList(data)
  if not self.isShow then
    table.insert(self.contentInfoCache, data)
    cleanDoubleMaxInfoTable(self.contentInfoCache)
    self:updateUnReadNum(self.unReadMsgNum + 1)
    return
  end
  local pageCnt = self.lstContent:GetItemCount()
  if pageCnt >= Define.miniChatMaxCnt then
    local item = self.lstContent:GetItem(0)
    self.lstContent:RemoveItem(item, false)
    item:invoke("initViewByData", data)
    self.lstContent:AddItem(item)
  else
    local cell
    if 0 < #self.contentItemPool then
      cell = table.remove(self.contentItemPool)
    else
      cell = UIMgr:new_widget("chatContentItem")
    end
    cell:invoke("initViewByData", data)
    self.lstContent:AddItem(cell)
  end
  self.lytInfoPanel:SetVisible(true)
end

function WinChatMini:gotoBottom()
  self.btnGotoBottom:SetVisible(false)
  self.newMsgNum = 0
  World.LightTimer("lstScroll", 2, function()
    self.lstContent:GoLastScroll()
  end)
end

function WinChatMini:cleanMiniChatItem()
  local pageCnt = self.lstContent:GetItemCount()
  for i = 1, pageCnt do
    local item = self.lstContent:GetItem(0)
    self.lstContent:RemoveItem(item, false)
    table.insert(self.contentItemPool, item)
  end
  self.contentInfoCache = {}
end

function WinChatMini:refreshMiniChatWin()
  self:cleanMiniChatItem()
  self:loadAllMiniMsgItem()
  self.lstContent:GoLastScroll()
end

function WinChatMini:loadAllMiniMsgItem()
  local miniChatShowDataList = UIChatManage:getMiniChatShowDataList()
  for _, data in pairs(miniChatShowDataList) do
    self:addMiniMsgInList(data)
  end
end

function WinChatMini:loadMiniMsgCache()
  local cnt = #self.contentInfoCache
  local doCnt = cnt - math.max(cnt - Define.MainChatMaxCnt, 0)
  for i = 1, doCnt do
    self:addMiniMsgInList(self.contentInfoCache[cnt - doCnt + i])
  end
  self.contentInfoCache = {}
  self:updateUnReadNum(0)
end

function WinChatMini:receiveChatMessage(type, msg, fromname, voiceTime, isCacheMsg)
  local calcOffset = self.lstContent:GetScrollOffset() or 0
  local upTooFar = calcOffset - self.lstContent:GetMinScrollOffset() > 40
  if upTooFar and fromname ~= Me.name then
  else
    for _, pageType in pairs(UIChatManage:getCurMiniMsgList()) do
      if pageType == type then
        self:gotoBottom()
        break
      end
    end
  end
  self.chatMiniShowTime = 0
  self.lytInfoPanel:SetVisible(true)
  if voiceTime and Me:getIsAutoPlayVoice() and not isCacheMsg and fromname ~= Me.name and type ~= Define.Page.PRIVATE then
    World.Timer(1, function()
      VoiceManager:autoPlayVoice(msg)
    end)
  end
end

function WinChatMini:resetAutoHideTime()
  self.chatMiniShowTime = 0
  self.sendPassTime = 0
end

function WinChatMini:addNewMsgTips()
  if not self.newMsgNum then
    self.newMsgNum = 0
  end
  self.newMsgNum = self.newMsgNum + 1
  self.btnGotoBottom:SetVisible(true)
  self.btnGotoBottom:SetText(Lang:toText({
    "ui.chat.newMsg",
    "\226\150\162FFAAEF16" .. self.newMsgNum
  }))
end

function WinChatMini:updateChatTabType()
  local curPrivateUserId = UIChatManage:getCurPrivateFriend()
  if curPrivateUserId and 0 < curPrivateUserId then
    self.curTab = Define.Page.PRIVATE
    self.lytPrivatePanel:SetVisible(true)
    self.lytCommonPanel:SetVisible(false)
    local detailInfo = UIChatManage:getUserDetailInfo(curPrivateUserId)
    if detailInfo then
      self:setUserDetailInfo(detailInfo)
    else
      self:listenDetailInfo(curPrivateUserId)
    end
    if self.historyShowState then
      self:updateHistoryPanelShow(false)
    end
    self.sendPassTime = 0
    self:updateSendPanelShow(true)
  else
    self.curTab = Define.Page.COMMON
    self.lytPrivatePanel:SetVisible(false)
    self.lytCommonPanel:SetVisible(true)
  end
  self.lytInfoPanel:SetVisible(true)
end

function WinChatMini:listenDetailInfo(platId)
  if not platId then
    Lib.logError("WidgetChatPrivate:listenDetailInfo id is nil!")
    return
  end
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
  end
  self.userDetailInfoCancel = Lib.lightSubscribeEvent("error!!!!! EVENT_USER_DETAIL", "EVENT_USER_DETAIL" .. platId, function(data)
    self:setUserDetailInfo(data)
  end)
  UIChatManage:initDetailInfo(platId)
end

function WinChatMini:setUserDetailInfo(data)
  local curPrivateUserId = UIChatManage:getCurPrivateFriend()
  local privateColor = UIChatManage:checkNameColor(curPrivateUserId)
  local privateName = self:getOneShortName(data.nickName)
  if World.cfg.isUseChatVIP and Me:checkPlayerIsVipByUserId(curPrivateUserId) then
    privateColor = World.cfg.ChatVipNameColor
  end
  self.txtPrivateName:SetText("\226\150\162FF" .. privateColor .. privateName)
  local nameWidth = self.txtPrivateName:GetFont():GetStringWidth(privateName)
  self.txtPrivateName:SetWidth({0, nameWidth})
  self.lytPrivateMask:SetWidth({0, nameWidth})
  self.lytPrivateRight:SetWidth({
    1,
    -(nameWidth + 8)
  })
end

function WinChatMini:getOneShortName(name)
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

function WinChatMini:initSendInfo()
  self.curTab = Define.Page.COMMON
  self.sendMsgText = ""
  self.lastSendTime = 0
  self.duration = chatSetting.duration or 2
  self:updateChatTabType()
  self:setInitEditorShow()
  self:updateHistoryPanelShow(false)
end

function WinChatMini:updateHistoryPanelShow(isShow)
  self.historyShowState = isShow
  if self.historyShowState then
    self.imgHistoryIcon:SetImage("set:g2052_chat_box.json image:btn_0_private_chat02")
  else
    self.imgHistoryIcon:SetImage("set:g2052_chat_box.json image:btn_0_private_chat01")
  end
  self.lytHistoryPanel:SetVisible(isShow)
end

function WinChatMini:sendChatMessage()
  local msg = self.sendMsgText
  if not msg or #msg < 1 then
    return
  end
  if not self:checkCanSend() then
    return
  end
  self:sendChatMsgToServer(msg)
  self:setInitEditorShow()
end

function WinChatMini:sendChatMsgToServer(msg, time)
  UIChatManage:requestServerSendChatMsg(self.curTab, msg, time)
  self.lastSendTime = os.time()
  if self.curTab == Define.Page.PRIVATE then
    local defaultData = {
      chat_type = 2,
      job_id = Me:getProfessionId()
    }
    Plugins.CallTargetPluginFunc("report", "report", "chat_text", defaultData, Me)
  else
    local defaultData = {
      chat_type = 1,
      job_id = Me:getProfessionId()
    }
    Plugins.CallTargetPluginFunc("report", "report", "chat_text", defaultData, Me)
  end
end

function WinChatMini:checkCanSend()
  local time = self.duration - math.ceil(os.time() - self.lastSendTime)
  if 0 < time then
    local text = string.format(Lang:toText("ui.chat.can.not.send"), time)
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
    return false
  end
  return true
end

function WinChatMini:updateSendMsgText(str)
  local msgList = UIChatManage:splitStringToMultiLine(self.lytCommonPanel:GetPixelSize().x - 10, str)
  if msgList[1] then
    self.sendMsgText = string.gsub(str, "\n", " ")
  else
    self.sendMsgText = str
  end
end

function WinChatMini:updateCommonEditEndShow()
  local msgList = UIChatManage:splitStringToMultiLine(self.lytCommonPanel:GetPixelSize().x - 10, self.sendMsgText)
  if msgList[1] then
    self.editCommonEditor:SetProperty("Text", msgList[1] .. (msgList[2] and ".." or ""))
  end
end

function WinChatMini:updatePrivateEditEndShow()
  local msgList = UIChatManage:splitStringToMultiLine(self.lytPrivatePanel:GetPixelSize().x - 85, self.sendMsgText)
  if msgList[1] then
    self.editPrivateEditor:SetProperty("Text", msgList[1] .. (msgList[2] and ".." or ""))
  end
end

function WinChatMini:setInitEditorShow()
  self.editCommonEditor:SetProperty("Text", "")
  self.txtCommonText:SetText(Lang:toText("ui.chat.click.chat"))
  self.editPrivateEditor:SetProperty("Text", "")
  self.txtPrivateText:SetText(Lang:toText("ui.chat.click.chat"))
  self.txtCommonText:SetVisible(true)
  self.txtPrivateText:SetVisible(true)
  self.sendPassTime = 0
  self.chatMiniShowTime = 0
  self:updateSendPanelShow(true)
  self.sendMsgText = ""
end

function WinChatMini:updateHistoryInfo()
  self.historyAdapter:clearItems()
  local allHistoryList = {}
  for _, data in pairs(UIChatManage.privateHistoryList) do
    table.insert(allHistoryList, data)
  end
  table.sort(allHistoryList, function(a, b)
    return a.lastMsgTime > b.lastMsgTime
  end)
  local topData = {}
  for i = 1, 3 do
    if allHistoryList[i] then
      table.insert(topData, allHistoryList[i])
    end
  end
  self.historyAdapter:setData(topData)
  self.historyGridView:ResetPos()
end

function WinChatMini:startChatSendTimer()
  self.chatSendTimer = World.Timer(20, function()
    if self:isHaveExtraWndShow() then
      if self.sendPassTime >= 0 then
        self.sendPassTime = 0
      end
      self:updateSendPanelShow(true)
      return
    end
    if self.sendPassTime >= 0 then
      if self.sendPassTime <= chatSetting.miniInputTime then
        self:updateSendPanelShow(true)
      else
        self:updateSendPanelShow(false)
      end
      self.sendPassTime = self.sendPassTime + 1
      if self.sendPassTime <= 1 then
        self.chatMiniShowTime = 0
      end
      if self.chatMiniShowTime >= chatSetting.miniHideTime then
        self.lytInfoPanel:SetVisible(false)
      end
      self.chatMiniShowTime = self.chatMiniShowTime + 1
    else
      self.chatMiniShowTime = 0
    end
    return true
  end)
end

function WinChatMini:isHaveExtraWndShow()
  if World.cfg.isUseVoicePack and UI:isOpen("voice_pack") then
    return true
  end
  if UI:isOpen("chatVipWnd") then
    return true
  end
  return false
end

function WinChatMini:updateSendPanelShow(isShow)
  self.imgContentBg:SetVisible(isShow)
  self.lytInputPanel:SetVisible(isShow)
  self.lytVoicePanel:SetVisible(isShow)
  self.lytExtraPanel:SetVisible(isShow)
end

function WinChatMini:stopChatSendTimer()
  if self.chatSendTimer then
    self.chatSendTimer()
    self.chatSendTimer = nil
  end
end

function WinChatMini:onHide()
  UI:closeWnd("chatMini")
end

function WinChatMini:onShow(isShow, winSizeType)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("chatMini", winSizeType)
      self:loadMiniMsgCache()
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinChatMini:onOpen(winSizeType)
  self.isShow = true
  self:initView(winSizeType)
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_CHAT_ICON, true)
  self.needOpenOtherChat = false
  if UI:isOpen("worldChatWnd") then
    UI:closeWnd("worldChatWnd")
    self.needOpenOtherChat = true
  end
end

function WinChatMini:onClose()
  self.isShow = false
  self:stopChatSendTimer()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_CHAT_ICON, false)
  if World.cfg.isUseVoicePack and UI:isOpen("voice_pack") then
    UI:closeWnd("voice_pack")
  end
  if UI:isOpen("chatVipWnd") then
    UI:closeWnd("chatVipWnd")
  end
  if self.needOpenOtherChat and not UI:isOpen("worldChatWnd") then
    UI:getWnd("worldChatWnd"):onShow(true)
  end
end

return WinChatMini
