local widget_base = require("ui.widget.widget_base")
local WidgetEditorMapUIParamsCell = Lib.derive(widget_base)
local baseType = {
  {
    name = "\230\149\176\229\173\151",
    strToValue = function(value)
      return tonumber(value)
    end,
    valueToStr = function(value)
      return tostring(value)
    end
  },
  {
    name = "bool",
    strToValue = function(value)
      return Lib.toBool(value)
    end,
    valueToStr = function(value)
      return tostring(value)
    end
  },
  {
    name = "\229\173\151\231\172\166",
    strToValue = function(value)
      return value
    end,
    valueToStr = function(value)
      return tostring(value)
    end
  },
  {
    name = "vector3",
    strToValue = function(value)
      return Lib.strToV3(value)
    end,
    valueToStr = function(value)
      return value.x .. "," .. value.y .. "," .. value.z
    end
  }
}

function WidgetEditorMapUIParamsCell:init()
  widget_base.init(self, "EditorMapUIParamsCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetEditorMapUIParamsCell:initUI()
  self.editKey = self:child("EditorMapUIParamsCell-Key")
  self.editValue = self:child("EditorMapUIParamsCell-Value")
  self.txtType = self:child("EditorMapUIParamsCell-Type")
  self.btnDel = self:child("EditorMapUIParamsCell-Del")
end

function WidgetEditorMapUIParamsCell:initEvent()
  self:subscribe(self.btnDel, UIEvent.EventButtonClick, function()
    self.delCallback()
  end)
  self:subscribe(self.editKey, UIEvent.EventEditTextInput, function()
    self.key = self.editKey:GetPropertyString("Text", "")
    self.editKey:SetProperty("Text", string.sub(self.key, 1, 8))
    self:updateKey()
    self:dataChanged()
  end)
  self:subscribe(self.editValue, UIEvent.EventEditTextInput, function()
    local strValue = self.editValue:GetPropertyString("Text", "")
    self.value = baseType[self.curValueType].strToValue(strValue)
    self.editValue:SetProperty("Text", string.sub(strValue, 1, 8))
    self:updateValue()
    self:dataChanged()
  end)
  self:subscribe(self.txtType, UIEvent.EventWindowDoubleClick, function()
    self.curValueType = self.curValueType + 1
    if self.curValueType > 4 then
      self.curValueType = 1
    end
    self:updateValueType()
  end)
end

function WidgetEditorMapUIParamsCell:getValueType(value)
  local valueType = type(value)
  if valueType == "number" then
    return 1
  elseif valueType == "bool" then
    return 2
  elseif valueType == "string" then
    return 3
  end
  if valueType == "table" and value.x ~= nil and value.y ~= nil and value.z ~= nil then
    return 4
  end
  return 3
end

function WidgetEditorMapUIParamsCell:updateValueType()
  self.txtType:SetText(baseType[self.curValueType].name)
end

function WidgetEditorMapUIParamsCell:updateKey()
  self.editKey:SetProperty("Text", self.key)
end

function WidgetEditorMapUIParamsCell:updateValue()
  local strValue = baseType[self.curValueType].valueToStr(self.value)
  self.editValue:SetProperty("Text", strValue)
end

function WidgetEditorMapUIParamsCell:setData(key, value)
  self.key = key
  self.value = value
  self.curValueType = self:getValueType(value)
  self:updateValueType()
  self:updateKey()
  self:updateValue()
end

function WidgetEditorMapUIParamsCell:dataChanged()
  self.valueUpdateCallback(self.key, self.value)
end

function WidgetEditorMapUIParamsCell:dataUpdate(callback, delCallback)
  self.valueUpdateCallback = callback
  self.delCallback = delCallback
end

function WidgetEditorMapUIParamsCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetEditorMapUIParamsCell
