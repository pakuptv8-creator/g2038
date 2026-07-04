local widget_base = require("ui.widget.widget_base")
local WidgetChatBubbleWnd = Lib.derive(widget_base)

function WidgetChatBubbleWnd:init()
  widget_base.init(self, "ChatBubbleWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetChatBubbleWnd:initUI()
  self.lytPanel = self:child("ChatBubbleWnd-Panel")
  self.chatBubbleSetting = World.cfg.chatSetting.chatBubbleSetting
  self.itemList = {}
  self.itemCache = {}
  self.totalHeight = self.chatBubbleSetting.itemHeight * self.chatBubbleSetting.showNum
  self._root:SetHeight({
    0,
    self.totalHeight
  })
  self._root:SetWidth({
    0,
    self.chatBubbleSetting.maxWidth
  })
end

function WidgetChatBubbleWnd:initEvent()
end

function WidgetChatBubbleWnd:deleteOneItem(index)
  local item = table.remove(self.itemList, index)
  item.widget:SetVisible(false)
  table.insert(self.itemCache, item)
end

function WidgetChatBubbleWnd:createOneItem(msg, voiceTime, userId, textVipColor)
  if not self.lytPanel then
    return
  end
  if #self.itemCache > 0 then
    local item = table.remove(self.itemCache, 1)
    item.widget:SetVisible(true)
    item.widget:invoke("updateTextShow", msg, voiceTime, userId, textVipColor)
    item.bornTime = os.time()
    table.insert(self.itemList, 1, item)
  else
    local widget = UIMgr:new_widget("chatBubbleItem")
    self.lytPanel:AddChildWindow(widget)
    widget:SetArea({0, 0}, {0, 0}, {1, 0}, {
      0,
      self.chatBubbleSetting.itemHeight
    })
    widget:invoke("updateTextShow", msg, voiceTime, userId, textVipColor)
    widget:SetVisible(true)
    local item = {
      widget = widget,
      bornTime = os.time()
    }
    table.insert(self.itemList, 1, item)
  end
end

function WidgetChatBubbleWnd:addOneNewMsg(msg, voiceTime, userId, textVipColor)
  if #self.itemList >= self.chatBubbleSetting.showNum then
    self:deleteOneItem(1)
  end
  self:createOneItem(msg, voiceTime, userId, textVipColor)
  self:updateMsgItemList()
  if not self.showTimer then
    self.showTimer = World.Timer(20, function()
      self:updateMsgItemList()
      return true
    end)
  end
end

function WidgetChatBubbleWnd:updateMsgItemList()
  for i = #self.itemList, 1, -1 do
    local passTime = os.time() - self.itemList[i].bornTime
    if passTime > self.chatBubbleSetting.showTime then
      self:deleteOneItem(i)
    end
  end
  local initPosY = self.totalHeight - self.chatBubbleSetting.itemHeight
  for i = 1, #self.itemList do
    self.itemList[i].widget:SetYPosition({0, initPosY})
    initPosY = initPosY - self.chatBubbleSetting.itemHeight
  end
end

function WidgetChatBubbleWnd:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.showTimer then
    self.showTimer()
    self.showTimer = nil
  end
  for key, val in pairs(self.itemList) do
    self.lytPanel:RemoveChildWindow1(val.widget)
    GUIWindowManager.instance:DestroyGUIWindow(val.widget)
  end
  self.itemList = {}
  for key, val in pairs(self.itemCache) do
    self.lytPanel:RemoveChildWindow1(val.widget)
    GUIWindowManager.instance:DestroyGUIWindow(val.widget)
  end
  self.itemCache = {}
end

return WidgetChatBubbleWnd
