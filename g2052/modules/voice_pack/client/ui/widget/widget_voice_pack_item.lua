local widget_base = require("ui.widget.widget_base")
local WidgetVoice_pack_item = Lib.derive(widget_base)

function WidgetVoice_pack_item:init()
  widget_base.init(self, "voice_pack_item.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetVoice_pack_item:initUI()
  self.imgVoicePackItemBG = self:child("voice_pack_item-BG")
  self.txtVoicePackItemName = self:child("voice_pack_item-Name")
  self.imgVoicePackItemTag = self:child("voice_pack_item-Tag")
end

function WidgetVoice_pack_item:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    Plugins.CallTargetPluginFunc("voice_pack", "playVoicePack", Me, self.data.id)
  end)
end

function WidgetVoice_pack_item:onDataChanged(cfg)
  self.data = cfg.data
  self.txtVoicePackItemName:SetText(Lang:toText(self.data.name))
end

function WidgetVoice_pack_item:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetVoice_pack_item
