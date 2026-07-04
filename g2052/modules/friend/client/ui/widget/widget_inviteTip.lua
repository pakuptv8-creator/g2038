local widget_base = require("ui.widget.widget_base")
local WidgetInviteTip = Lib.derive(widget_base)
local defaultAvatar = World.cfg.defaultAvatar or "set:default_icon.json image:header_icon"
local operationType = FriendManager.operationType
local UIAnimationManager = T(UILib, "UIAnimationManager")
local clearTimer
local Bg = {
  [Define.InviteTipType.Normal] = "set:g2052_friend.json image:img_9_friend01",
  [Define.InviteTipType.Agree] = "set:g2052_friend.json image:img_9_friend03",
  [Define.InviteTipType.Refuse] = "set:g2052_friend.json image:img_9_friend02"
}
local TipText = {
  [Define.InviteTipType.Normal] = "",
  [Define.InviteTipType.Agree] = "g2052.gui.friend.agree.success",
  [Define.InviteTipType.Refuse] = "g2052.gui.friend.refuse"
}
local MsgText = {
  [Define.InviteMsgType.Friend] = "g2052.gui.friend.invite"
}

function WidgetInviteTip:init()
  widget_base.init(self, "InviteTip.json")
  self._allEvent = {}
  self._timer = {}
  self:initUI()
end

function WidgetInviteTip:initUI()
  self.type = 0
  self.ani = nil
  self.lytTopTip = self:child("InviteTip-Top-Tip")
  self.imgResponseBg = self:child("InviteTip-ResponseBg")
  self.imgHead = self:child("InviteTip-Head-Icon")
  self.imgSex = self:child("InviteTip-Sex")
  self.imgSex:SetVisible(false)
  self.txtName = self:child("InviteTip-Name")
  self.txtLang = self:child("InviteTip-Lang")
  self.txtMsg = self:child("InviteTip-Msg")
  self.btnView = {}
  self.btnView[Define.InviteTipType.Normal] = self:child("InviteTip-Btn-List")
  self.btnYes = self:child("InviteTip-Yes")
  self.btnNo = self:child("InviteTip-No")
end

function WidgetInviteTip:initEvent()
  if self.type == Define.InviteTipType.Normal then
    self._allEvent[#self._allEvent + 1] = self:subscribe(self.btnYes, UIEvent.EventButtonClick, function()
      if self.msgType == Define.InviteMsgType.Friend then
        self:updateSelfView(Define.InviteTipType.Agree)
        Me:removeReadRequest({
          self.userId
        })
        AsyncProcess.FriendOperation(operationType.AGREE, self.userId)
      end
    end)
    self._allEvent[#self._allEvent + 1] = self:subscribe(self.btnNo, UIEvent.EventButtonClick, function()
      if self.msgType == Define.InviteMsgType.Friend then
        self:updateSelfView(Define.InviteTipType.Refuse)
        Me:removeReadRequest({
          self.userId
        })
        AsyncProcess.FriendOperation(operationType.REFUSE, self.userId)
      end
    end)
  end
end

function WidgetInviteTip:initTip(data)
  if not data.type or not data.tipId then
    print(" ======= WidgetInviteTip:initTip ====== : data.type or data.tipId not exist")
    return
  end
  self.data = data
  self.userId = data.userId
  self.type = data.type
  self.id = data.tipId
  self.msgType = data.msgType
  self.imgHead:SetImage(defaultAvatar)
  local picUrl = data.picUrl
  if picUrl and 0 < #picUrl then
    self.imgHead:SetImageUrl(picUrl)
  end
  self.imgResponseBg:SetImage(Bg[data.type])
  self.imgSex:SetImage(data.sex == 1 and "set:g2052_icon.json image:img_0_gender02" or "set:g2052_icon.json image:img_0_gender01")
  self.txtName:SetText(data.nickName)
  if data.type == 1 then
    self.txtName:SetTextColor(Lib.getTextColor("000000"))
  else
    self.txtName:SetTextColor(Lib.getTextColor("FFFFFF"))
  end
  self.txtLang:SetText(string.format("%s:%s", Lang:toText("g2052.gui.friend.lang"), Lang:toText(data.language or "en")))
  for i, type in pairs(Define.InviteTipType) do
    if self.btnView[type] then
      self.btnView[type]:SetVisible(type == self.type)
    end
  end
  local tipText = TipText
  if tipText[self.type] ~= "" then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText(tipText[self.type]))
  end
  self.txtMsg:SetText(Lang:toText(MsgText[self.msgType] or ""))
  self:initEvent()
  self:playAni()
end

function WidgetInviteTip:updateSelfView(type)
  self.type = type
  self.imgResponseBg:SetImage(Bg[type])
  if type == 1 then
    self.txtName:SetTextColor(Lib.getTextColor("000000"))
  else
    self.txtName:SetTextColor(Lib.getTextColor("FFFFFF"))
  end
  for i, type in pairs(Define.InviteTipType) do
    if self.btnView[type] then
      self.btnView[type]:SetVisible(type == self.type)
    end
  end
  local tipText = TipText
  if tipText[self.type] ~= "" then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText(tipText[self.type]))
  end
  self:playAni()
end

function WidgetInviteTip:playAni()
  if self.ani then
    UIAnimationManager:stop(self.ani)
  end
  local MoveAni = "friendTipMove"
  local StaticAni = "friendTipStatic"
  self.ani = UIAnimationManager:play(self.lytTopTip, self.type ~= Define.InviteTipType.Normal and StaticAni or MoveAni, function()
    UI:getWnd("friend"):removeFriendTip(self.id, nil, self.msgType)
    if self.type == Define.InviteTipType.Normal then
      local defaultData = {friend_respond_result = 3}
      Plugins.CallTargetPluginFunc("report", "report", "friend_respond", defaultData, Me)
    end
  end)
end

function clearTimer(self)
  if self.showCentreTimer then
    self.showCentreTimer()
    self.showCentreTimer = nil
  end
end

function WidgetInviteTip:needKeep()
  return self.type == Define.InviteTipType.Normal
end

function WidgetInviteTip:getId()
  return self.id
end

function WidgetInviteTip:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.ani then
    UIAnimationManager:stop(self.ani)
  end
  clearTimer(self)
end

return WidgetInviteTip
