local widget_base = require("ui.widget.widget_base")
local WidgetWorldLangItem = Lib.derive(widget_base)
local WorldChatHelper = T(Lib, "WorldChatHelper")

function WidgetWorldLangItem:init()
  widget_base.init(self, "WorldLangItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetWorldLangItem:initUI()
  self.imgNormalIcon = self:child("WorldLangItem-NormalIcon")
  self.imgSelectIcon = self:child("WorldLangItem-SelectIcon")
  self.txtLangName = self:child("WorldLangItem-LangName")
end

function WidgetWorldLangItem:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if WorldChatHelper.curSelectChannel == self.data.langName then
      return
    end
    Lib.emitEvent(Event.EVENT_WORLD_CHAT_LANG_SELECT, self.data.langName)
  end)
end

function WidgetWorldLangItem:onDataChanged(data)
  self.data = data
  if data.select then
    self.imgNormalIcon:SetVisible(false)
    self.imgSelectIcon:SetVisible(true)
  else
    self.imgNormalIcon:SetVisible(true)
    self.imgSelectIcon:SetVisible(false)
  end
  self.txtLangName:SetText(Lang:toText(data.langName))
end

function WidgetWorldLangItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WidgetWorldLangItem
