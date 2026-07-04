local widget_base = require("ui.widget.widget_base")
local WidgetWorldEmojiItem = Lib.derive(widget_base)

function WidgetWorldEmojiItem:init()
  widget_base.init(self, "WorldEmojiItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetWorldEmojiItem:initUI()
end

function WidgetWorldEmojiItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_WORLD_CHAT_SEND_EMOJI, self.icon)
  end)
end

function WidgetWorldEmojiItem:onDataChanged(data)
  self._root:SetImage(data.icon)
  self.icon = data.icon
end

function WidgetWorldEmojiItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetWorldEmojiItem
