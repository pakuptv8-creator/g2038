local WinPlayerInteractPop = M
local PlayerInteractiveConfig = T(Config, "PlayerInteractiveConfig")

function WinPlayerInteractPop:init()
  WinBase.init(self, "PlayerInteractPop.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPlayerInteractPop:initUI()
  self.btnCloseBtn = self:child("PlayerInteractPop-CloseBtn")
  self.txtNameText = self:child("PlayerInteractPop-NameText")
  self.lytHeadPanel = self:child("PlayerInteractPop-HeadPanel")
  self.imgHeadImg = self:child("PlayerInteractPop-HeadImg")
  self.imgHeadFrame = self:child("PlayerInteractPop-HeadFrame")
  self.txtLikeNum = self:child("PlayerInteractPop-LikeNum")
  self.btnAddLike = self:child("PlayerInteractPop-AddLike")
  self.imgLikeEffect = self:child("PlayerInteractPop-LikeEffect")
  self.imgLikeEffect:SetVisible(false)
  self.lytActionView = self:child("PlayerInteractPop-ActionView")
  self.lytActionView:SetVisible(false)
  self.actionPanel = {}
  self.actionItem = {}
  for i = 1, 4 do
    self.actionPanel[i] = self:child("PlayerInteractPop-actionPanel" .. i)
  end
  self.btnFriendBtn = self:child("PlayerInteractPop-FriendBtn")
  self.txtFriendText = self:child("PlayerInteractPop-FriendText")
  self.btnPrivateBtn = self:child("PlayerInteractPop-PrivateBtn")
  self.txtPrivateText = self:child("PlayerInteractPop-PrivateText")
  self.btnVisitBtn = self:child("PlayerInteractPop-VisitBtn")
  self.txtVisitText = self:child("PlayerInteractPop-VisitText")
  self.btnFriendBtn:SetEnabled(false)
  self.btnFriendBtn:SetTouchable(false)
  self.lytFriendMask = self:child("PlayerInteractPop-FriendMask")
  self.lytFriendMask:SetVisible(false)
  self.btnInviteBtn = self:child("PlayerInteractPop-InviteBtn")
  self.txtInviteText = self:child("PlayerInteractPop-InviteText")
  self.btnIgnoreBtn = self:child("PlayerInteractPop-IgnoreBtn")
  self.txtIgnoreText = self:child("PlayerInteractPop-IgnoreText")
  self.txtPrivateText:SetText(Lang:toText("ui.chat.private"))
  self.txtVisitText:SetText(Lang:toText("g2052.gui.friend.pop.invite"))
  self.txtInviteText:SetText(Lang:toText("g2052.gui.world_chat.invite"))
  self.txtIgnoreText:SetText(Lang:toText("g2052.gui.world_chat.ignore"))
end

function WinPlayerInteractPop:initEvent()
  self:subscribe(self.btnInviteBtn, UIEvent.EventButtonClick, function()
    if not self.curPlayerUserId then
      return
    end
    Lib.emitEvent(Event.EVENT_INVITE_GAME, self.curPlayerUserId)
    self:onHide()
  end)
  self:subscribe(self.btnIgnoreBtn, UIEvent.EventButtonClick, function()
    if not self.curPlayerUserId then
      return
    end
    local isIgnore = Plugins.CallTargetPluginFunc("world_chat", "getBlockPlayerMsgState", self.curPlayerUserId)
    Plugins.CallTargetPluginFunc("world_chat", "updateBlockPlayerMsgState", self.curPlayerUserId, not isIgnore)
    self:onHide()
  end)
  self:subscribe(self.btnAddLike, UIEvent.EventButtonClick, function()
    if not self.curPlayerUserId then
      return
    end
    Plugins.CallTargetPluginFunc("drama", "doDramaThumbUpPlayer", self.curPlayerUserId)
    self.btnAddLike:SetVisible(false)
    self:playLikeEffect()
  end)
  self:subscribe(self.btnVisitBtn, UIEvent.EventButtonClick, function()
    if not self.curPlayerUserId then
      return
    end
    local houseLimitList = Me:getHouseLimitList()
    local curPlayerIndex
    for i, id in pairs(houseLimitList) do
      if self.curPlayerUserId == id then
        curPlayerIndex = i
        break
      end
    end
    if self.inLimit then
      if curPlayerIndex then
        table.remove(houseLimitList, curPlayerIndex)
      end
      Me:setHouseLimitList(houseLimitList)
      Plugins.CallTargetPluginFunc("report", "report", "house_visit_on", nil, Me)
    else
      if not curPlayerIndex then
        table.insert(houseLimitList, self.curPlayerUserId)
      end
      Me:setHouseLimitList(houseLimitList)
      Plugins.CallTargetPluginFunc("report", "report", "house_visit_off", nil, Me)
    end
    self:onHide()
  end)
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnFriendBtn, UIEvent.EventButtonClick, function()
    if not self.curPlayerUserId then
      return
    end
    if self.curPlayerIsFriend then
      local UIChatManage = T(UIMgr, "UIChatManage")
      UIChatManage:doDeleteFriendOperate(self.curPlayerUserId)
    else
      AsyncProcess.FriendOperation(FriendManager.operationType.ADD_FRIEND, self.curPlayerUserId)
      local defaultData = {
        friend_add_way = 1,
        job_id = Me:getProfessionId()
      }
      Plugins.CallTargetPluginFunc("report", "report", "friend_add", defaultData, Me)
      Me:clientHeartWarmAddFriend(self.curPlayerUserId)
    end
    self:onHide()
  end)
  self:subscribe(self.btnPrivateBtn, UIEvent.EventButtonClick, function()
    if not self.curPlayerUserId then
      return
    end
    Lib.emitEvent(Event.EVENT_OPEN_PRIVATE_CHAT, self.curPlayerUserId)
    self:onHide()
  end)
end

function WinPlayerInteractPop:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_LIKES_NUM, function(data)
    if data.userId == self.curPlayerUserId then
      self:updateUserDetailInfo(data)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_THUMB_UP_RESULT, function(targetUserId, isSuccess)
    if targetUserId == self.curPlayerUserId then
      self:updateAddLikeBtnShow()
      if isSuccess and self.likeData.likes then
        self:updateLikeNumShow(self.likeData.likes + 1)
      end
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, function(value)
    if not value then
      self:onHide()
    end
  end)
end

function WinPlayerInteractPop:initView(targetID, isNoAction)
  self.likeData = {}
  self.curTargetID = targetID
  self:updateWndShowPos(targetID)
  if isNoAction then
    self.curPlayerUserId = targetID
    if self.curPlayerUserId == Me.platformUserId then
      self.lytActionView:SetVisible(false)
      self.btnVisitBtn:SetVisible(false)
      self.btnPrivateBtn:SetVisible(false)
      self.btnIgnoreBtn:SetVisible(false)
      self.btnInviteBtn:SetVisible(false)
    else
      self.lytActionView:SetVisible(false)
      self.btnVisitBtn:SetVisible(false)
      self.btnPrivateBtn:SetVisible(false)
      self.btnIgnoreBtn:SetVisible(true)
      self.btnInviteBtn:SetVisible(true)
    end
  else
    self.lytActionView:SetVisible(true)
    self.btnVisitBtn:SetVisible(true)
    self.btnPrivateBtn:SetVisible(true)
    self.btnIgnoreBtn:SetVisible(false)
    self.btnInviteBtn:SetVisible(false)
    local interactiveCfg = Lib.copy(PlayerInteractiveConfig:getAllCfgs())
    for i = 1, 4 do
      if interactiveCfg[i] then
        self.actionPanel[i]:SetVisible(true)
        if not self.actionItem[i] then
          self.actionItem[i] = UIMgr:new_widget("playerInteractItem")
          self.actionItem[i]:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
          self.actionItem[i]:invoke("onDataChanged", interactiveCfg[i])
          self.actionPanel[i]:AddChildWindow(self.actionItem[i])
        end
        self.actionItem[i]:invoke("updateTargetInfo", targetID)
      else
        self.actionPanel[i]:SetVisible(false)
      end
    end
    self:startDistanceTimer(targetID)
    local targetEntity = World.CurWorld:getEntity(targetID)
    if not targetEntity or not targetEntity:isValid() then
      self:onHide()
      return
    end
    local userId = targetEntity.platformUserId
    self.curPlayerUserId = userId
    self:updateHouseLimitList(self.houseLimitList)
  end
  self:updatePlayerInfo(self.curPlayerUserId)
  self:updateFriendBtnState()
  self:updateAddLikeBtnShow()
  self:updateIgnoreBtnState()
  self.lytActionView:SetVisible(false)
end

function WinPlayerInteractPop:updateWndShowPos(targetID)
  local targetEntity = World.CurWorld:getEntity(targetID)
  if not targetEntity or not targetEntity:isValid() then
    self._root:SetXPosition({0, -206})
    self._root:SetHorizontalAlignment(2)
  else
    local targetPos = targetEntity:getPosition()
    local result = Blockman.instance:getScreenPos(targetPos)
    if result and result.x and result.x > 0.5 then
      self._root:SetXPosition({0, 206})
      self._root:SetHorizontalAlignment(0)
    else
      self._root:SetXPosition({0, -206})
      self._root:SetHorizontalAlignment(2)
    end
  end
end

function WinPlayerInteractPop:playLikeEffect()
  self.imgLikeEffect:SetVisible(true)
  self.imgLikeEffect:PlayEffect()
end

function WinPlayerInteractPop:updateFriendBtnState()
  self.curPlayerIsFriend = nil
  self.curPlayerIsFriend = Me:checkUserIDIsFriend(self.curPlayerUserId)
  if self.curPlayerIsFriend then
    self.txtFriendText:SetText(Lang:toText("ui.chat.isfriend"))
    self.btnFriendBtn:SetEnabled(false)
    self.btnFriendBtn:SetTouchable(false)
    self.lytFriendMask:SetVisible(true)
  else
    self.txtFriendText:SetText(Lang:toText("ui.chat.player_addFriend"))
    self.btnFriendBtn:SetEnabled(true)
    self.btnFriendBtn:SetTouchable(true)
    self.lytFriendMask:SetVisible(false)
  end
  if self.curPlayerUserId == Me.platformUserId then
    self.btnFriendBtn:SetVisible(false)
  end
end

function WinPlayerInteractPop:updateAddLikeBtnShow()
  if self.curPlayerUserId == Me.platformUserId then
    self.btnAddLike:SetVisible(false)
  else
    local isAdd = Plugins.CallTargetPluginFunc("drama", "getDramaThumbUpState", self.curPlayerUserId)
    self.btnAddLike:SetVisible(not isAdd)
  end
end

function WinPlayerInteractPop:updateIgnoreBtnState()
  local isIgnore = Plugins.CallTargetPluginFunc("world_chat", "getBlockPlayerMsgState", self.curPlayerUserId)
  if isIgnore then
    self.txtIgnoreText:SetText(Lang:toText("g2052.gui.world_chat.ignored"))
  else
    self.txtIgnoreText:SetText(Lang:toText("g2052.gui.world_chat.ignore"))
  end
end

function WinPlayerInteractPop:updatePlayerInfo(userId)
  self.txtNameText:SetText("")
  self:updateLikeNumShow(0)
  self.imgHeadImg:SetImage("set:default_icon.json image:header_icon")
  Plugins.CallTargetPluginFunc("drama", "getDramaPlayerLikesInfo", userId)
end

function WinPlayerInteractPop:updateUserDetailInfo(data)
  self.likeData = data
  self.txtNameText:SetText(data.nickName)
  if data.picUrl and #data.picUrl > 1 then
    self.imgHeadImg:SetImageUrl(data.picUrl)
  else
    self.imgHeadImg:SetImage("set:default_icon.json image:header_icon")
  end
  self:updateLikeNumShow(data.likes)
end

function WinPlayerInteractPop:updateLikeNumShow(likes)
  self.txtLikeNum:SetText(Lib.toNewThousandthString(likes or 0))
end

function WinPlayerInteractPop:startDistanceTimer(targetID)
  self:stopDistanceTimer()
  local targetEntity = World.CurWorld:getEntity(targetID)
  if not targetEntity or not targetEntity:isValid() then
    self:onHide()
    return
  end
  self.distanceTimer = World.Timer(10, function()
    if not targetEntity or not targetEntity:isValid() then
      self:onHide()
      return
    end
    local MePos = Me:getPosition()
    if (Lib.v3(MePos.x, MePos.y, MePos.z) - targetEntity:getPosition()):len() > World.cfg.interaction_uiSetting.playerPopHideDis then
      self:onHide()
      return
    end
    return true
  end)
end

function WinPlayerInteractPop:stopDistanceTimer()
  if self.distanceTimer then
    self.distanceTimer()
    self.distanceTimer = nil
  end
end

function WinPlayerInteractPop:updateHouseLimitList(list)
  self.houseLimitList = list or {}
  if self.curPlayerUserId then
    self.inLimit = false
    for _, id in pairs(self.houseLimitList) do
      if id == self.curPlayerUserId then
        self.inLimit = true
      end
    end
  end
  self:updateLimitBtn()
end

function WinPlayerInteractPop:updateLimitBtn()
  local str = self.inLimit and "g2052.gui.friend.pop.unfreeze" or "g2052.gui.friend.pop.add.limit"
  self.txtVisitText:SetText(Lang:toText(str))
  local img = self.inLimit and "set:g2052_buttons.json image:btn_9_general04" or "set:g2052_buttons.json image:btn_9_general06"
  self.btnVisitBtn:SetNormalImage(img)
  self.btnVisitBtn:SetPushedImage(img)
end

function WinPlayerInteractPop:onHide()
  UI:closeWnd("playerInteractPop")
end

function WinPlayerInteractPop:onShow(isShow, targetID, isNoAction)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("playerInteractPop", targetID, isNoAction)
    else
      self:initView(targetID, isNoAction)
    end
  else
    self:onHide()
  end
end

function WinPlayerInteractPop:onOpen(targetID, isNoAction)
  self:initView(targetID, isNoAction)
  self:subscribeEvent()
  Me:closeRightFunctionWnd()
end

function WinPlayerInteractPop:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:stopDistanceTimer()
  self.imgLikeEffect:SetVisible(false)
  Lib.emitEvent(Event.EVENT_UPDATE_INTERACT_CLICK_SHOW, self.curTargetID, false)
end

return WinPlayerInteractPop
