local WinFriend = M
local operationType = FriendManager.operationType
local GameId = World.GameName
local playerImgPool = {}
local NoneTip = {
  [Define.FriendTabType.Friend] = "g2052.gui.friend.none.friend",
  [Define.FriendTabType.Near] = "g2052.gui.friend.none.near",
  [Define.FriendTabType.Request] = "g2052.gui.friend.none.request"
}
local PlayerState = {LogIn = 0, Logout = 1}

function WinFriend:init()
  WinBase.init(self, "Friend.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinFriend:initUI()
  self.lytBg = self:child("Friend-Bg")
  self.btnClose = self:child("Friend-Close")
  self.lytContent = self:child("Friend-Content")
  self.lytNonePanel = self:child("Friend-NonePanel")
  self.imgNoneIcon = self:child("Friend-NoneIcon")
  self.txtNoneTip = self:child("Friend-None-Tip")
  self.lytNonePanel:SetVisible(false)
  self.txtTitleName = self:child("Friend-TitleName")
  self.imgFriendRedIcon = self:child("Friend-FriendRedIcon")
  self.txtFriendRedNum = self:child("Friend-FriendRedNum")
  self.imgNearRedIcon = self:child("Friend-NearRedIcon")
  self.txtNearRedNum = self:child("Friend-NearRedNum")
  self.imgRequestRedIcon = self:child("Friend-RequestRedIcon")
  self.txtRequestRedNum = self:child("Friend-RequestRedNum")
  self.tipId = 0
  self.isFirst = true
  self.dataList = {}
  self.tipList = {}
  self.tipInfoList = {}
  self.redDotNum = {}
  self.newFriends = {}
  self.txtTitleName:SetText(Lang:toText("g2052.gui.friend.top.title"))
  self.tabList = {}
  self.tabList[Define.FriendTabType.Friend] = self:child("Friend-Friend-Btn")
  self.tabList[Define.FriendTabType.Near] = self:child("Friend-Near-Btn")
  self.tabList[Define.FriendTabType.Request] = self:child("Friend-Request-Btn")
  self.tabList[Define.FriendTabType.Friend]:SetText(Lang:toText("g2052.gui.friend.tab.friend"))
  self.tabList[Define.FriendTabType.Near]:SetText(Lang:toText("g2052.gui.friend.tab.near"))
  self.tabList[Define.FriendTabType.Request]:SetText(Lang:toText("g2052.gui.friend.tab.request"))
  for i, type in pairs(Define.FriendTabType) do
    self.tabList[type]:SetTextColor({
      0.4235294117647059,
      0.4235294117647059,
      0.4235294117647059,
      1
    })
    self.tabList[type]:SetNormalImage("set:g2052_buttons.json image:btn_9_general02")
    self:updateTabRedShow(type, 0)
  end
  self:initAdapterView()
  self:initOnLineState()
end

function WinFriend:initOnLineState()
  self.onLinePlayer = {}
  for i, type in pairs(Define.FriendTabType) do
    self.onLinePlayer[type] = {}
  end
end

function WinFriend:initAdapterView()
  local params = {
    xDis = 0,
    yDis = 25,
    xCellNum = 1,
    widgetWidth = 677,
    widgetHeight = 90,
    widgetJson = "FriendItem.json",
    widgetName = "friendItem",
    gvParent = self.lytContent,
    dataList = {}
  }
  self.contentView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.gvContent = self.contentView:getGridView()
  self.gvContent:SetMoveAble(true)
  self.gvContent:SetvScorllMoveAble(true)
  self.gvContent:SetAutoColumnCount(false)
  self.contentAdapter = self.contentView:getAdapter()
end

function WinFriend:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  for i, type in pairs(Define.FriendTabType) do
    self:subscribe(self.tabList[type], UIEvent.EventRadioStateChanged, function()
      self:onRadioChanged(type)
    end)
  end
  Lib.subscribeEvent(Event.EVENT_FRIEND_OPERATION_NOTICE, function(opType, playerPlatformId)
    self:loadData()
    if opType == operationType.ADD_FRIEND then
      self:addFriendTip(Define.InviteTipType.Normal, playerPlatformId, Define.InviteMsgType.Friend)
      self:refreshData(Define.FriendTabType.Request)
    elseif opType == operationType.AGREE then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.friend.agree.success"))
      Me:addPlayerFriendFromExist(playerPlatformId, Define.friendStatus.gameFriend)
    elseif opType == operationType.REFUSE then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("gui_lang_refuse_friend"))
    end
  end)
  Lib.subscribeEvent(Event.EVENT_FINISH_LOAD_FRIEND_DATA, function()
    self:refreshData(Define.FriendTabType.Near)
    local userIds = FriendManager.friends
    if 0 < #userIds then
      local function callFunc(data)
        for _, onlineData in pairs(data) do
          self.onLinePlayer[Define.FriendTabType.Friend][onlineData.userId] = onlineData.status
        end
        self:refreshData(Define.FriendTabType.Friend)
      end
      
      AsyncProcess.GetPlayerOnlineState(userIds, callFunc)
    else
      self:refreshData(Define.FriendTabType.Friend)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_FINISH_PARSE_REQUESTS_DATA, function()
    local userIds = {}
    for _, info in pairs(FriendManager.requests) do
      table.insert(userIds, info.userId)
    end
    if 0 < #userIds then
      local function callFunc(data)
        for _, onlineData in pairs(data) do
          self.onLinePlayer[Define.FriendTabType.Request][onlineData.userId] = onlineData.status
        end
        self:refreshData(Define.FriendTabType.Request)
      end
      
      AsyncProcess.GetPlayerOnlineState(userIds, callFunc)
    else
      self:refreshData(Define.FriendTabType.Request)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_STATUS, function(status, uId, uName)
    print("EVENT_PLAYER_STATUS", status, uId, uName)
    if self.curTab ~= Define.FriendTabType.Near then
      self:refreshData(Define.FriendTabType.Near)
    end
    local data = self.dataList[Define.FriendTabType.Friend]
    if data then
      local itemData
      for _, friend in pairs(data) do
        if friend.userId == uId then
          itemData = friend
          break
        end
      end
      if status == PlayerState.LogIn then
        local info = UserInfoCache.GetCache(uId)
        if info then
          info.gameId = GameId
        end
        if itemData then
          itemData.gameId = GameId
        end
      elseif status == PlayerState.Logout then
        local info = UserInfoCache.GetCache(uId)
        if info then
          info.gameId = nil
        end
        if itemData then
          itemData.gameId = nil
        end
      end
      if UI:isOpen("friend") then
        self:updateFriendTabText(data)
      end
      Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_STATUS, uId, status)
    end
  end)
  
  local function updateTipList(self, inviteTipType)
    local info = self.tipInfoList[#self.tipInfoList]
    local data = Lib.copy(UserInfoCache.GetCache(info.userId))
    if not data then
      return
    end
    data.type = info.type
    data.tipId = info.id
    data.msgType = inviteTipType
    local tip = UIMgr:new_widget("inviteTip")
    UI._desktop:AddChildWindow(tip)
    tip:SetTouchable(false)
    tip:invoke("initTip", data)
    table.insert(self.tipList, tip)
  end
  
  Lib.subscribeEvent(Event.EVENT_UPDATE_FRIEND_TIP, function()
    updateTipList(self, Define.InviteMsgType.Friend)
  end)
  Lib.subscribeEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, function(type, redNum)
    self:updateTabRedShow(type, redNum)
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_NEAR_PLAYER, function()
    local playersInfo = Game.GetAllPlayersInfo()
    local data = {}
    local userList = {}
    for _, info in pairs(playersInfo) do
      if info.userId ~= Me.platformUserId then
        local _info = Lib.copy(UserInfoCache.GetCache(info.userId))
        if _info and not userList[info.userId] then
          _info.type = Define.FriendTabType.Near
          table.insert(data, _info)
          userList[info.userId] = true
        end
      end
    end
    self.dataList[Define.FriendTabType.Near] = data
    self.tabList[Define.FriendTabType.Near]:SetText(#data <= 0 and Lang:toText("g2052.gui.friend.tab.near") or string.format("%s(%d)", Lang:toText("g2052.gui.friend.tab.near"), #data))
  end)
end

function WinFriend:subscribeEvent()
end

function WinFriend:updateTabRedShow(type, redNum)
  if type == Define.FriendTabType.Friend then
    self.imgFriendRedIcon:SetVisible(0 < redNum)
    self.txtFriendRedNum:SetText(redNum)
  elseif type == Define.FriendTabType.Near then
    self.imgNearRedIcon:SetVisible(0 < redNum)
    self.txtNearRedNum:SetText(redNum)
  elseif type == Define.FriendTabType.Request then
    self.imgRequestRedIcon:SetVisible(0 < redNum)
    self.txtRequestRedNum:SetText(redNum)
  end
end

function WinFriend:initView()
  self:initOnLineState()
  if self.isFirst then
    self.isFirst = false
    for i, type in pairs(Define.FriendTabType) do
      self:refreshData(type)
    end
    local initType = Define.FriendTabType.Near
    self.tabList[initType]:SetSelected(true)
    self.tabList[initType]:SetTextColor({
      0,
      0,
      0,
      1
    })
  end
  self:loadData()
  self:updateTabText()
end

function WinFriend:onRadioChanged(type)
  self.tabList[type]:SetTextColor(self.tabList[type]:IsSelected() and {
    0,
    0,
    0,
    1
  } or {
    0.4235294117647059,
    0.4235294117647059,
    0.4235294117647059,
    1
  })
  self.tabList[type]:SetNormalImage(self.tabList[type]:IsSelected() and "set:g2052_buttons.json image:btn_9_general01" or "set:g2052_buttons.json image:btn_9_general02")
  if self.tabList[type]:IsSelected() then
    self.curTab = type
    self:updateContent()
  end
  if type == Define.FriendTabType.Friend then
    self.newFriends = {}
    Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, Define.FriendTabType.Friend, 0)
  elseif type == Define.FriendTabType.Request then
    self:recordReadRequestList()
    Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, Define.FriendTabType.Request, 0)
  elseif type == Define.FriendTabType.Near then
    self:refreshData(Define.FriendTabType.Near)
  end
end

function WinFriend:recordReadRequestList()
  local data = self.dataList[Define.FriendTabType.Request]
  if not data or #data == 0 then
    return
  end
  local userIds = {}
  for _, info in pairs(data) do
    table.insert(userIds, info.userId)
  end
  Me:addReadRequest(userIds)
end

function WinFriend:updateTabText()
  for _, type in pairs(Define.FriendTabType) do
    local data = self.dataList[type]
    if data == nil then
      return
    end
    if type == Define.FriendTabType.Friend then
      self:updateFriendTabText(data)
    elseif type == Define.FriendTabType.Near then
      self.tabList[type]:SetText(#data <= 0 and Lang:toText("g2052.gui.friend.tab.near") or string.format("%s(%d)", Lang:toText("g2052.gui.friend.tab.near"), #data))
    elseif type == Define.FriendTabType.Request then
      self.tabList[type]:SetText(#data <= 0 and Lang:toText("g2052.gui.friend.tab.request") or string.format("%s(%d)", Lang:toText("g2052.gui.friend.tab.request"), #data))
    end
  end
end

function WinFriend:updateFriendTabText(data)
  local onlineNum = 0
  for _, info in ipairs(data) do
    local isSameServer = Game.GetPlayerByUserId(info.userId) and true or false
    local isOnline = World.GameName == info.gameId or isSameServer
    if isOnline then
      onlineNum = onlineNum + 1
    end
  end
  self.tabList[Define.FriendTabType.Friend]:SetText(#data <= 0 and Lang:toText("g2052.gui.friend.tab.friend") or string.format("%s(%d / %d)", Lang:toText("g2052.gui.friend.tab.friend"), onlineNum, #data))
end

function WinFriend:addFriendTip(type, userId, inviteTipType)
  self.tipId = self.tipId + 1
  table.insert(self.tipInfoList, {
    type = type,
    userId = userId,
    id = self.tipId
  })
  if 1 < #self.tipInfoList then
    local tip = self.tipList[#self.tipList]
    if tip then
      self:removeFriendTip(tip:invoke("getId"), tip:invoke("needKeep"), inviteTipType)
    end
  else
    self:openFriendTip(inviteTipType)
  end
end

function WinFriend:openFriendTip(inviteTipType)
  local info = self.tipInfoList[#self.tipInfoList]
  local userIds = {
    info.userId
  }
  if inviteTipType == Define.InviteMsgType.Friend then
    UserInfoCache.LoadCacheByUserIds(userIds, "EVENT_UPDATE_FRIEND_TIP")
  end
end

function WinFriend:removeFriendTip(id, keepInfo, inviteTipType)
  for i, _tip in pairs(self.tipList) do
    if _tip:invoke("getId") == id then
      UI._desktop:RemoveChildWindow1(_tip)
      GUIWindowManager.instance:DestroyGUIWindow(_tip)
      table.remove(self.tipList, i)
      break
    end
  end
  if not keepInfo then
    for j, info in pairs(self.tipInfoList) do
      if info.id == id then
        table.remove(self.tipInfoList, j)
        break
      end
    end
  end
  if #self.tipInfoList > 0 then
    self:openFriendTip(inviteTipType)
  end
end

function WinFriend:refreshData(type)
  if type == Define.FriendTabType.Friend then
    self:refreshFriendData()
  elseif type == Define.FriendTabType.Near then
    self:refreshNearData()
  elseif type == Define.FriendTabType.Request then
    self:refreshRequestData()
  end
  if self.curTab == type then
    self:updateContent()
  end
end

function WinFriend:updateContent()
  local data = self.dataList[self.curTab]
  if not data or #data == 0 then
    self.gvContent:SetVisible(false)
    self.lytNonePanel:SetVisible(true)
    self.txtNoneTip:SetText(Lang:toText(NoneTip[self.curTab]))
    return
  end
  if self.curTab == Define.FriendTabType.Friend then
    for _, v in pairs(data) do
      v.isNew = false
      if self.newFriends[tostring(v.userId)] then
        v.isNew = true
      end
    end
  end
  self.contentAdapter:clearItems()
  self.contentAdapter:setData(data)
  self.lytNonePanel:SetVisible(false)
  self.gvContent:SetVisible(true)
end

function WinFriend:refreshFriendData()
  local friends = FriendManager.friends
  local data = {}
  local friendMap = {}
  local onlineNum = 0
  for _, id in pairs(friends) do
    local info = Lib.copy(UserInfoCache.GetCache(id))
    if info then
      local isSameServer = Game.GetPlayerByUserId(info.userId) and true or false
      local isOnline = World.GameName == info.gameId or isSameServer
      info.type = Define.FriendTabType.Friend
      info.status = self.onLinePlayer[Define.FriendTabType.Friend][info.userId] or 30
      if isOnline or info.status ~= 30 then
        table.insert(data, 1, info)
        onlineNum = onlineNum + 1
      else
        table.insert(data, info)
      end
    end
    friendMap[tostring(id)] = true
  end
  local newFriends = Me:updateFriends(friendMap)
  self:updateNewFriends(newFriends)
  self.dataList[Define.FriendTabType.Friend] = data
  self.tabList[Define.FriendTabType.Friend]:SetText(#data <= 0 and Lang:toText("g2052.gui.friend.tab.friend") or string.format("%s(%d / %d)", Lang:toText("g2052.gui.friend.tab.friend"), onlineNum, #data))
end

function WinFriend:updateNewFriends(newFriends)
  if not next(newFriends) then
    return
  end
  for i, v in pairs(newFriends) do
    if not self.newFriends[tostring(i)] then
      self.newFriends[tostring(i)] = true
    end
  end
end

function WinFriend:refreshNearData()
  local userIds = {}
  local playersInfo = Game.GetAllPlayersInfo()
  for _, info in pairs(playersInfo) do
    table.insert(userIds, info.userId)
  end
  UserInfoCache.LoadCacheByUserIds(userIds, "EVENT_UPDATE_NEAR_PLAYER")
end

function WinFriend:getNewRequestNum(requests)
  local num = 0
  if requests and 0 < #requests then
    local readList = Me:getReadRequestList()
    for _, info in pairs(requests) do
      if not readList[info.userId] then
        num = num + 1
      end
    end
  end
  return num
end

function WinFriend:refreshRequestData()
  local requests = {}
  for _, info in pairs(FriendManager.requests) do
    local _info = Lib.copy(info)
    _info.type = Define.FriendTabType.Request
    _info.status = self.onLinePlayer[Define.FriendTabType.Request][_info.userId] or 30
    table.insert(requests, _info)
  end
  self.dataList[Define.FriendTabType.Request] = requests
  self.tabList[Define.FriendTabType.Request]:SetText(#requests <= 0 and Lang:toText("g2052.gui.friend.tab.request") or string.format("%s(%d)", Lang:toText("g2052.gui.friend.tab.request"), #requests))
  Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, Define.FriendTabType.Request, self:getNewRequestNum(requests))
end

function WinFriend:loadData()
  FriendManager.LoadFriendData(true)
  AsyncProcess.LoadUserRequests()
end

function WinFriend:onHide()
  UI:closeWnd("friend")
end

function WinFriend:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("friend")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinFriend:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinFriend:onClose()
  self:recordReadRequestList()
  Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, Define.FriendTabType.Friend, 0)
  Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, Define.FriendTabType.Request, 0)
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinFriend
