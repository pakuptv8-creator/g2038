local widget_base = require("ui.widget.widget_base")
local WidgetEditor_map_info_cell = Lib.derive(widget_base)

function WidgetEditor_map_info_cell:init()
  widget_base.init(self, "editor_map_info_cell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetEditor_map_info_cell:initUI()
  self.txtEditorMapInfoCellInfoName = self:child("editor_map_info_cell-infoName")
  self.editorMapInfoCellInfoValue = self:child("editor_map_info_cell-infoValue")
end

function WidgetEditor_map_info_cell:initEvent()
  self:subscribe(self.editorMapInfoCellInfoValue, UIEvent.EventEditTextInput, function()
    if self.callback then
      self.callback(self.editorMapInfoCellInfoValue:GetPropertyString("Text", ""))
    end
  end)
end

function WidgetEditor_map_info_cell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetEditor_map_info_cell:setData(key, value)
  self.txtEditorMapInfoCellInfoName:SetText(key)
  self.editorMapInfoCellInfoValue:SetProperty("Text", value)
end

function WidgetEditor_map_info_cell:valueUpdate(callback)
  self.callback = callback
end

function WidgetEditor_map_info_cell:keyDoubleCLick(callback)
  self.doubleClickKeyCallback = callback
  if callback then
    self:subscribe(self.txtEditorMapInfoCellInfoName, UIEvent.EventWindowDoubleClick, function()
      if self.doubleClickKeyCallback then
        self.doubleClickKeyCallback()
      end
    end)
  end
end

return WidgetEditor_map_info_cell
