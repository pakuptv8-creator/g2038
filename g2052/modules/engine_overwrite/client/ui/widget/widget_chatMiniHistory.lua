local widget_base = require("ui.widget.widget_base")
local WidgetChatMiniHistory = Lib.derive(widget_base)
local UIChatManage = T(UIMgr, "UIChatManage")

function WidgetChatMiniHistory:init()
  widget_base.init(self, "ChatMiniHistory.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self.isInit = true
end

function WidgetChatMiniHistory:initUI()
  self.imgBg = self:child("ChatMiniHistory-Bg")
  self.txtPlayerName = self:child("ChatMiniHistory-PlayerName")
end

function WidgetChatMiniHistory:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    UIChatManage:setCurPrivateFriend(self.data.userId)
  end)
end

function WidgetChatMiniHistory:onDataChanged(data)
  self.data = data
  self.data.userId = self.data.keyId
  self.txtPlayerName:SetText(self.data.keyId)
  if self.data.userId then
    local detailInfo = UIChatManage:getUserDetailInfo(self.data.keyId)
    if detailInfo then
      self:setUserDetailInfo(detailInfo)
    else
      self:listenDetailInfo(self.data.keyId)
    end
  end
end

function WidgetChatMiniHistory:listenDetailInfo(id)
  if not id then
    Lib.logError("WidgetChatHistoryItem:listenDetailInfo id is nil!")
    return
  end
  if self.userDetailInfoCancel then
    self.userDetailInfoCancel()
  end
  self.userDetailInfoCancel = Lib.lightSubscribeEvent("error!!!!! EVENT_USER_DETAIL", "EVENT_USER_DETAIL" .. id, function(data)
    self:setUserDetailInfo(data)
  end)
  UIChatManage:initDetailInfo(id)
end

function WidgetChatMiniHistory:setUserDetailInfo(data)
  if not self.isInit then
    return
  end
  self.txtPlayerName:SetText(data.nickName)
end

function WidgetChatMiniHistory:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self.isInit = false
end

return WidgetChatMiniHistory
