local widget_base = require("ui.widget.widget_base")
local WidgetChatShortLangItem = Lib.derive(widget_base)

function WidgetChatShortLangItem:init()
  widget_base.init(self, "ChatShortLangItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetChatShortLangItem:initUI()
  self.lytShortItem = {}
  self.imgNormalIcon = {}
  self.txtShortText = {}
  self.totalCount = 3
  for i = 1, self.totalCount do
    self.lytShortItem[i] = self:child("ChatShortLangItem-ShortItem" .. i)
    self.txtShortText[i] = self:child("ChatShortLangItem-ShortText" .. i)
  end
end

function WidgetChatShortLangItem:initEvent()
  for i = 1, self.totalCount do
    self:subscribe(self.lytShortItem[i], UIEvent.EventWindowClick, function()
      if self.itemData[i] then
        UI:getWnd("chatMini"):resetAutoHideTime()
        Me:sendShortChatById(self.itemData[i])
      end
    end)
  end
end

function WidgetChatShortLangItem:initShortItemData(itemData)
  self.itemData = itemData
  for i = 1, self.totalCount do
    if itemData[i] then
      self.lytShortItem[i]:SetVisible(true)
      self.txtShortText[i]:SetText(Lang:toText(itemData[i].shortTitle))
    else
      self.lytShortItem[i]:SetVisible(false)
    end
  end
end

function WidgetChatShortLangItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetChatShortLangItem
