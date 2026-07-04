local widget_base = require("ui.widget.widget_base")
local WidgetFriendItem = Lib.derive(widget_base)
local defaultAvatar = World.cfg.defaultAvatar or "set:default_icon.json image:header_icon"
local operationType = FriendManager.operationType

function WidgetFriendItem:init()
  widget_base.init(self, "FriendItem.json")
  self._allEvent = {}
  self._timer = {}
  self:initUI()
  self:initEvent()
end

function WidgetFriendItem:initUI()
  self.type = 0
  self.imgHeadIcon = self:child("FriendItem-HeadIcon")
  self.imgSexIcon = self:child("FriendItem-Sex-Icon")
  self.imgSexIcon:SetVisible(false)
  self.txtName = self:child("FriendItem-Name")
  self.txtLang = self:child("FriendItem-Lang")
  self.btnBtnYes = self:child("FriendItem-Btn-Yes")
  self.btnBtnNo = self:child("FriendItem-Btn-No")
  self.btnBtnAdd = self:child("FriendItem-Btn-Add")
  self.btnBtnDelete = self:child("FriendItem-Btn-Delete")
  self.imgOffLine = self:child("FriendItem-OffLine")
  self.txtInviteText = self:child("FriendItem-InviteText")
  self.btnInviteBtn = self:child("FriendItem-InviteBtn")
  self.txtInviteText:SetText(Lang:toText("g2052.gui.friend.invite.btn"))
  self.btnPrivateBtn = self:child("FriendItem-PrivateBtn")
  self.btnPrivateBtn:SetVisible(false)
  self.imgRedDot = self:child("FriendItem-Red-Dot")
  self.imgRedDot:SetVisible(false)
  self.btnView = {}
  self.btnView[Define.FriendTabType.Request] = self:child("FriendItem-Request-View")
  self.btnView[Define.FriendTabType.Near] = self:child("FriendItem-Near-View")
  self.btnView[Define.FriendTabType.Friend] = self:child("FriendItem-Friend-View")
end

function WidgetFriendItem:initEvent()
  self:subscribe(self.btnBtnYes, UIEvent.EventButtonClick, function()
    Me:removeReadRequest({
      self.userId
    })
    self:friendOperation(operationType.AGREE)
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.friend.agree.success"))
    Me:addPlayerFriendFromExist(self.userId, Define.friendStatus.gameFriend)
  end)
  self:subscribe(self.btnBtnNo, UIEvent.EventButtonClick, function()
    Me:removeReadRequest({
      self.userId
    })
    self:friendOperation(operationType.REFUSE)
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.friend.refuse"))
  end)
  self:subscribe(self.btnBtnAdd, UIEvent.EventButtonClick, function()
    if not FriendManager.CanAddFriend(self.userId) then
      return
    end
    if self:friendOperation(operationType.ADD_FRIEND) then
      FriendManager.UpdateCdTime(self.userId, operationType.ADD_FRIEND)
      self:setCd(self.btnBtnAdd, operationType.ADD_FRIEND)
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("ui.chat.friend.send_add"))
      Me:clientHeartWarmAddFriend(self.userId)
      local defaultData = {
        friend_add_way = 2,
        job_id = Me:getProfessionId()
      }
      Plugins.CallTargetPluginFunc("report", "report", "friend_add", defaultData, Me)
    end
  end)
  self:subscribe(self.btnBtnDelete, UIEvent.EventButtonClick, function()
    UI:getWnd("commonDialog"):onShow(true, {
      title = "g2052.gui.friend.delete.title",
      desc = "g2052.gui.friend.delete.desc",
      confirmCallback = function()
        self:friendOperation(operationType.DELETE)
      end,
      cancelCallback = function()
      end
    })
  end)
  self:subscribe(self.btnPrivateBtn, UIEvent.EventButtonClick, function()
    if not self.userId then
      return
    end
    Lib.emitEvent(Event.EVENT_OPEN_PRIVATE_CHAT, self.userId)
    UI:getWnd("friend"):onShow(false)
  end)
  self:subscribe(self.btnInviteBtn, UIEvent.EventButtonClick, function()
    if not self.userId then
      return
    end
    Plugins.CallTargetPluginFunc("report", "report", "friend_invite", nil, Me)
    Lib.emitEvent(Event.EVENT_INVITE_GAME, self.userId)
    UI:getWnd("friend"):onShow(false)
  end)
end

function WidgetFriendItem:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_FRIEND_UPDATE_STATUS, function(uId, status)
    if self.data and uId == self.userId then
      self:refreshOnlineState()
    end
  end)
end

function WidgetFriendItem:onDataChanged(data)
  self:clear()
  if not data.type then
    return
  end
  self.data = data
  self.userId = data.userId
  self.type = data.type
  self.imgHeadIcon:SetImage(defaultAvatar)
  local picUrl = data.picUrl
  if picUrl and 0 < #picUrl then
    self.imgHeadIcon:SetImageUrl(picUrl)
  end
  self.imgSexIcon:SetImage(data.sex == 1 and "set:g2052_icon.json image:img_0_gender02" or "set:g2052_icon.json image:img_0_gender01")
  self.txtName:SetText(data.nickName)
  self.txtLang:SetText(string.format("%s:%s", Lang:toText("g2052.gui.friend.lang"), Lang:toText(data.language or "en")))
  for i, type in pairs(Define.FriendTabType) do
    self.btnView[type]:SetVisible(type == self.type)
  end
  if self.data.isNew then
    self.imgRedDot:SetVisible(true)
  else
    self.imgRedDot:SetVisible(false)
  end
  if self.type == Define.FriendTabType.Request then
    self.btnPrivateBtn:SetVisible(false)
  else
    self.btnPrivateBtn:SetVisible(true)
  end
  if self.type == Define.FriendTabType.Near then
    local canOperate = not FriendManager.friendsMap[self.userId]
    self.btnBtnAdd:SetVisible(canOperate)
    self:setCd(self.btnBtnAdd, operationType.ADD_FRIEND)
  end
  self:refreshOnlineState()
  self:subscribeEvent()
end

function WidgetFriendItem:refreshOnlineState()
  if self.type == Define.FriendTabType.Near then
    self.imgOffLine:SetImage("set:g2052_friend.json image:icon_0_online01")
  else
    local isSameServer = Game.GetPlayerByUserId(self.data.userId) and true or false
    local isOnline = World.GameName == self.data.gameId or isSameServer
    if isOnline then
      self.imgOffLine:SetImage("set:g2052_friend.json image:icon_0_online01")
    elseif self.data.status ~= 30 then
      self.imgOffLine:SetImage("set:g2052_friend.json image:icon_0_online01")
    else
      self.imgOffLine:SetImage("set:g2052_friend.json image:icon_0_online02")
    end
  end
end

function WidgetFriendItem:friendOperation(opType)
  if not self.userId then
    return
  end
  local selfInfo = UserInfoCache.GetCache(Me.platformUserId)
  if not selfInfo then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.friend.again"))
    return false
  end
  AsyncProcess.FriendOperation(opType, self.userId)
  return true
end

function WidgetFriendItem:clear()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  for _, timer in pairs(self._timer or {}) do
    if timer then
      timer()
    end
  end
end

function WidgetFriendItem:onDestroy()
  self:clear()
end

function WidgetFriendItem:setCd(btn, type)
  local time = FriendManager.GetLastCdTime(self.userId, type)
  btn:SetEnabled(true)
  if time <= 0 then
    return
  end
  btn:SetEnabled(false)
  self._timer[#self._timer + 1] = Me:lightTimer("friendBtnCdTime", time * 20, function()
    btn:SetEnabled(true)
  end)
end

return WidgetFriendItem
