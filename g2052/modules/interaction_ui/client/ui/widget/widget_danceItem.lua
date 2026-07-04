local widget_base = require("ui.widget.widget_base")
local WidgetDanceItem = Lib.derive(widget_base)

function WidgetDanceItem:init()
  widget_base.init(self, "DanceItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDanceItem:initUI()
  self.imgNormalIcon = self:child("DanceItem-NormalIcon")
  self.imgSelectIcon = self:child("DanceItem-SelectIcon")
  self.txtActionTitle = self:child("DanceItem-ActionTitle")
end

function WidgetDanceItem:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.id then
      Lib.emitEvent(Event.EVENT_DANCE_ACTION_CLICK, self.id)
    end
  end)
end

function WidgetDanceItem:onDataChanged(data)
  self.data = data
  if not data.id then
    return
  end
  if data.select then
    self.imgNormalIcon:SetVisible(false)
    self.imgSelectIcon:SetVisible(true)
  else
    self.imgNormalIcon:SetVisible(true)
    self.imgSelectIcon:SetVisible(false)
  end
  self.actionEvent = data.actionEvent
  self.id = data.id
  self.txtActionTitle:SetText(Lang:toText(data.danceName))
end

function WidgetDanceItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDanceItem
