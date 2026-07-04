local WinWorldChatWnd = M
local ChatLangConfig = T(Config, "ChatLangConfig")
local WorldChatHelper = T(Lib, "WorldChatHelper")

function WinWorldChatWnd:init()
  WinBase.init(self, "WorldChatWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinWorldChatWnd:initUI()
  self.lytMaskPanel = self:child("WorldChatWnd-MaskPanel")
  self.lytChatPanel = self:child("WorldChatWnd-chatPanel")
  self.imgBg = self:child("WorldChatWnd-Bg")
  self.lytContentPanel = self:child("WorldChatWnd-ContentPanel")
  self.lytTopPanel = self:child("WorldChatWnd-TopPanel")
  self.imgBlockIcon = self:child("WorldChatWnd-BlockIcon")
  self.lytTabTitlePanel = self:child("WorldChatWnd-TabTitlePanel")
  self.imgTabShowIcon = self:child("WorldChatWnd-TabShowIcon")
  self.imgTabHideIcon = self:child("WorldChatWnd-TabHideIcon")
  self.txtTitleName = self:child("WorldChatWnd-TitleName")
  self.txtLangText = self:child("WorldChatWnd-LangText")
  self.lytLangPanel = self:child("WorldChatWnd-LangPanel")
  self.lytInput = self:child("WorldChatWnd-Input")
  self.btnEmoji = self:child("WorldChatWnd-Emoji")
  self.lytEditorPanel = self:child("WorldChatWnd-EditorPanel")
  self.editInputBox = self:child("WorldChatWnd-Input-Box")
  self.txtInputBoxText = self:child("WorldChatWnd-Input-Box-Text")
  self.btnInputBtnSend = self:child("WorldChatWnd-Input-BtnSend")
  self.btnBottomBtn = self:child("WorldChatWnd-BottomBtn")
  self.txtNewText = self:child("WorldChatWnd-NewText")
  self.txtTitleName:SetText(Lang:toText("g2052.gui.world_chat.title"))
  self.btnInputBtnSend:SetText(Lang:toText("g2052.gui.tendering.email.send_btn"))
  self.txtInputBoxText:SetText(Lang:toText("ui.chat.click.chat"))
  self.editInputBox:SetMaxLength(World.cfg.world_chatSetting.maxMsgSize or 150)
  self.lstTabContentEx = {}
  self.exInfoCache = {}
  self.allLangList = ChatLangConfig:getAllCfgs()
  for key, val in pairs(self.allLangList) do
    self.lstTabContentEx[val.langName] = UIMgr:new_widget("grid_view")
    self.lstTabContentEx[val.langName]:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
    self.lstTabContentEx[val.langName]:SetAutoColumnCount(false)
    self.lstTabContentEx[val.langName]:InitConfig(0, 1, 1)
    self.lytContentPanel:AddChildWindow(self.lstTabContentEx[val.langName])
    self.lstTabContentEx[val.langName]:SetVisible(false)
    self.exInfoCache[val.langName] = {}
  end
  self:initCalcText()
  self.sendWordMsgText = ""
  self.newMsgNum = 0
  self:initLangAdapter()
  self:updateBlockIconState()
  self:updateLangPanelShow(false)
end

function WinWorldChatWnd:initLangAdapter()
  local params = {
    xDis = 0,
    yDis = 2,
    xCellNum = 1,
    widgetWidth = 211,
    widgetHeight = 52,
    widgetJson = "WorldLangItem.json",
    widgetName = "worldLangItem",
    gvParent = self.lytLangPanel,
    dataList = {}
  }
  self.worldLangView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.worldLangView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(false)
  self.worldLangAdapter = self.worldLangView:getAdapter()
  self.worldLangAdapter:setData(self.allLangList)
end

function WinWorldChatWnd:initCalcText()
  self.pStaticText = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "CalcText")
  self.pStaticText:SetTouchable(false)
  self.pStaticText:SetHorizontalAlignment(1)
  self.pStaticText:SetVerticalAlignment(0)
  self.pStaticText:SetTextScale(1)
  self.pStaticText:SetFontSize("HT16")
  self.pStaticText:SetWordWrap(true)
  self.pStaticText:SetTextColor({
    1,
    1,
    1
  })
end

function WinWorldChatWnd:splitStringToMultiLine(width, msg)
  local outList = {}
  outList = self.pStaticText:GetFont():SplitStringToMultiLine(width, self.pStaticText:GetTextColor(), msg, outList, {})
  return outList
end

function WinWorldChatWnd:initEvent()
  for key, val in pairs(self.allLangList) do
    self:subscribe(self.lstTabContentEx[val.langName], UIEvent.EventScrollMoveChange, function()
      if WorldChatHelper.curSelectChannel ~= val.langName then
        return
      end
      if not self.btnBottomBtn:IsVisible() then
        return
      end
      local offset = self.lstTabContentEx[val.langName]:GetScrollOffset()
      local minOffset = self.lstTabContentEx[val.langName]:GetMinScrollOffset()
      self.btnBottomBtn:SetVisible(false)
      if offset <= minOffset then
        self.btnBottomBtn:SetVisible(false)
      end
    end)
  end
  self:subscribe(self.lytMaskPanel, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
  self:subscribe(self.imgBlockIcon, UIEvent.EventWindowClick, function()
    WorldChatHelper:setBlockChannelState(not WorldChatHelper.isBlockChannelMsg)
    self:updateBlockIconState()
    if WorldChatHelper.isBlockChannelMsg then
      local desc = Lang:toText({
        "g2052.gui.world_chat.block",
        Lang:toText(WorldChatHelper.curSelectChannel)
      })
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", desc)
    else
      local desc = Lang:toText({
        "g2052.gui.world_chat.cancel_block",
        Lang:toText(WorldChatHelper.curSelectChannel)
      })
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", desc)
    end
  end)
  self:subscribe(self.lytTabTitlePanel, UIEvent.EventWindowClick, function()
    if self.lytLangPanel:IsVisible() then
      self:updateLangPanelShow(false)
    else
      self:updateLangPanelShow(true)
    end
  end)
  self:subscribe(self.btnEmoji, UIEvent.EventButtonClick, function()
    UI:getWnd("worldEmojiWnd"):onShow(true)
  end)
  self:subscribe(self.btnInputBtnSend, UIEvent.EventButtonClick, function()
    if not self:checkIsCanSend() then
      return
    end
    self:sendWorldChatMessage()
  end)
  self:subscribe(self.btnBottomBtn, UIEvent.EventButtonClick, function()
    self:gotoBottom()
  end)
  self:lightSubscribe("error!!!!! WinWorldChatWnd editInputBox event : EventEditTextInput", self.editInputBox, UIEvent.EventEditTextInput, function(window, trigger)
    local inputStr = self.editInputBox:GetPropertyString("Text", "") or ""
    self.sendWordMsgText = tostring(inputStr)
    local msgList = self:splitStringToMultiLine(self.lytEditorPanel:GetPixelSize().x - 25, self.sendWordMsgText)
    if msgList[1] then
      if msgList[1] ~= "" then
        self.editInputBox:SetProperty("Text", msgList[1] .. (msgList[2] and ".." or ""))
      elseif msgList[2] ~= "" then
        self.editInputBox:SetProperty("Text", msgList[2] .. (msgList[3] and ".." or ""))
      end
    end
  end)
  self:lightSubscribe("error!!!!! WinWorldChatWnd editInputBox event : EventWindowTouchDown", self.editInputBox, UIEvent.EventWindowTouchDown, function()
    self.txtInputBoxText:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! WinWorldChatWnd editInputBox event : EventWindowTouchUp", self.editInputBox, UIEvent.EventWindowTouchUp, function()
    self.editInputBox:SetProperty("Text", self.sendWordMsgText)
    self.txtInputBoxText:SetVisible(false)
  end)
end

function WinWorldChatWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_WORLD_CHAT_SEND_EMOJI, function(emoji)
    self:sendWordChatToServer("", emoji)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_WORLD_CHAT_LANG_SELECT, function(langName)
    self:updateLangSelectShow(langName)
    self:updateLangPanelShow(false)
    WorldChatHelper:setBlockChannelState(false)
    self:updateBlockIconState()
    self:updateTabContentShow()
    local desc = Lang:toText({
      "g2052.gui.world_chat.lang.tips",
      Lang:toText(langName)
    })
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", desc)
  end)
end

function WinWorldChatWnd:sendWorldChatMessage()
  local msg = self.sendWordMsgText
  if not msg or #msg < 1 then
    return
  end
  if not self:checkIsCanSend() then
    return
  end
  self:sendWordChatToServer(msg)
  self:setInitEditorShow()
end

function WinWorldChatWnd:sendWordChatToServer(msg, emoji)
  self.lastSendTime = os.time()
  Me:clientSendWorldChatMsg(msg, emoji)
end

function WinWorldChatWnd:checkIsCanSend()
  self.duration = World.cfg.world_chatSetting.sendCDTime
  local time = self.duration - math.ceil(os.time() - self.lastSendTime)
  if 0 < time then
    local text = string.format(Lang:toText("ui.chat.can.not.send"), time)
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
    return false
  end
  return true
end

function WinWorldChatWnd:setInitEditorShow()
  self.editInputBox:SetProperty("Text", "")
  self.sendWordMsgText = ""
  self.txtInputBoxText:SetVisible(true)
end

function WinWorldChatWnd:initView()
  self.lastSendTime = 0
  self:updateLangListShow()
  self.txtLangText:SetText(Lang:toText(WorldChatHelper.curSelectChannel))
  self:loadExMsgCache(WorldChatHelper.curSelectChannel)
  self:updateTabContentShow()
  self:setInitEditorShow()
end

function WinWorldChatWnd:updateTabContentShow()
  self.allLangList = ChatLangConfig:getAllCfgs()
  for key, val in pairs(self.allLangList) do
    self.lstTabContentEx[val.langName]:SetVisible(val.langName == WorldChatHelper.curSelectChannel)
  end
  self:gotoBottom()
end

function WinWorldChatWnd:updateBlockIconState()
  if WorldChatHelper.isBlockChannelMsg then
    self.imgBlockIcon:SetImage("set:g2052_chat_world.json image:icon_0_receiving02")
  else
    self.imgBlockIcon:SetImage("set:g2052_chat_world.json image:icon_0_receiving01")
  end
end

function WinWorldChatWnd:updateLangPanelShow(isShow)
  self.lytLangPanel:SetVisible(isShow)
  self.imgTabShowIcon:SetVisible(isShow)
  self.imgTabHideIcon:SetVisible(not isShow)
end

function WinWorldChatWnd:updateLangSelectShow(langName)
  self.txtLangText:SetText(Lang:toText(langName))
  WorldChatHelper:setCurSelectChannel(langName)
  Me:clientJoinWorldChatChannel(langName)
  self:updateLangListShow()
end

function WinWorldChatWnd:updateLangListShow()
  for key, val in pairs(self.worldLangAdapter.data) do
    if val.langName == WorldChatHelper.curSelectChannel then
      self.worldLangAdapter.data[key].select = true
    else
      self.worldLangAdapter.data[key].select = false
    end
  end
  self.worldLangAdapter:notifyDataChange()
end

function WinWorldChatWnd:receiveWorldMessage(info)
  if info.language ~= WorldChatHelper.curSelectChannel then
    return
  end
  local calcOffset = self.lstTabContentEx[info.language]:GetScrollOffset()
  local upTooFar = calcOffset - self.lstTabContentEx[info.language]:GetMinScrollOffset() > 40
  if upTooFar and info.userId ~= Me.platformUserId then
    self:addNewMsgTips()
  else
    self:gotoBottom()
  end
end

function WinWorldChatWnd:addNewMsgTips()
  self.newMsgNum = self.newMsgNum + 1
  self.btnBottomBtn:SetVisible(true)
  self.txtNewText:SetText(Lang:toText({
    "ui.chat.newMsg",
    self.newMsgNum
  }))
end

function WinWorldChatWnd:gotoBottom()
  self.btnBottomBtn:SetVisible(false)
  self.newMsgNum = 0
  World.LightTimer("lstScroll", 2, function()
    self.lstTabContentEx[WorldChatHelper.curSelectChannel]:GoLastScroll()
  end)
end

function WinWorldChatWnd:loadExMsgCache(langType)
  if not self.exInfoCache[langType] then
    return
  end
  local cnt = #self.exInfoCache[langType]
  local doCnt = cnt - math.max(cnt - World.cfg.world_chatSetting.channelMsgNum, 0)
  for i = 1, doCnt do
    self:addMsgInCacheList(self.exInfoCache[langType][cnt - doCnt + i])
  end
  self.exInfoCache[langType] = {}
end

local function cleanDoubleMaxInfoTable(tb)
  local tbCnt = #tb
  if tbCnt > World.cfg.world_chatSetting.channelMsgNum then
    table.remove(tb, 1)
  end
end

function WinWorldChatWnd:addMsgInCacheList(data)
  if not UI:isOpen(self) then
    table.insert(self.exInfoCache[data.language], data)
    cleanDoubleMaxInfoTable(self.exInfoCache[data.language])
    return
  end
  local pageCnt = self.lstTabContentEx[data.language]:GetItemCount()
  if pageCnt >= World.cfg.world_chatSetting.channelMsgNum then
    local cell = self.lstTabContentEx[data.language]:GetItem(0)
    self.lstTabContentEx[data.language]:RemoveItem(cell, false)
    cell:invoke("updateItemByData", data)
    self.lstTabContentEx[data.language]:AddItem(cell)
  else
    local cell = UIMgr:new_widget("worldChatItem")
    cell:invoke("updateItemByData", data)
    self.lstTabContentEx[data.language]:AddItem(cell)
  end
end

function WinWorldChatWnd:onHide()
  UI:closeWnd("worldChatWnd")
end

function WinWorldChatWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("worldChatWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinWorldChatWnd:onOpen()
  self:initView()
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_WORLD_ICON_SHOW, true)
  Lib.emitEvent(Event.EVENT_UPDATE_WORLD_RED_SHOW, 0)
  self.needOpenOtherChat = false
  if UI:isOpen("chatMini") then
    UI:closeWnd("chatMini")
    self.needOpenOtherChat = true
  end
end

function WinWorldChatWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  Lib.emitEvent(Event.EVENT_UPDATE_WORLD_ICON_SHOW, false)
  if self.needOpenOtherChat and not UI:isOpen("chatMini") then
    UI:getWnd("chatMini"):onShow(true)
  end
end

return WinWorldChatWnd
