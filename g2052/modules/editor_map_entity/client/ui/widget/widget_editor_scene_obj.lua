local widget_base = require("ui.widget.widget_base")
local WidgetEditor_scene_obj = Lib.derive(widget_base)

function WidgetEditor_scene_obj:init()
  widget_base.init(self, "editor_scene_obj.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetEditor_scene_obj:initUI()
  self.txtEditorSceneObjName = self:child("editor_scene_obj-name")
end

function WidgetEditor_scene_obj:initEvent()
  self:subscribe(self.txtEditorSceneObjName, UIEvent.EventWindowClick, function()
    if self.callback then
      self.callback(self.id)
    end
  end)
end

function WidgetEditor_scene_obj:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetEditor_scene_obj:setText(text)
  self.txtEditorSceneObjName:SetText(text)
end

function WidgetEditor_scene_obj:clickCallBack(id, callback)
  self.id = id
  self.callback = callback
end

function WidgetEditor_scene_obj:selected(flag)
  if flag then
    self.txtEditorSceneObjName:SetTextColor({
      0.094117,
      0.674509,
      0.474509,
      1
    })
  else
    self.txtEditorSceneObjName:SetTextColor({
      1,
      1,
      1,
      1
    })
  end
end

return WidgetEditor_scene_obj
