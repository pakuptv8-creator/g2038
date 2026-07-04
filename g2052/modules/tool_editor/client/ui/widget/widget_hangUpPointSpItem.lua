local widget_base = require("ui.widget.widget_base")
local WidgetHangUpPointSpItem = Lib.derive(widget_base)

function WidgetHangUpPointSpItem:init(callBack)
  widget_base.init(self, "hangUpPointSpItem.json")
  self._allEvent = {}
  self.callBack = callBack
  self.index = 0
  self:initUI()
  self:initEvent()
end

function WidgetHangUpPointSpItem:initUI()
  self.txtHangUpPointSpItemParamIndex = self:child("hangUpPointSpItem-paramIndex")
  self.editHangUpPointSpItemParamInput = self:child("hangUpPointSpItem-paramInput")
  self.btnHangUpPointSpItemAddBtn = self:child("hangUpPointSpItem-addBtn")
  self.btnHangUpPointSpItemSubBtn = self:child("hangUpPointSpItem-subBtn")
end

function WidgetHangUpPointSpItem:initEvent()
  self:subscribe(self.btnHangUpPointSpItemAddBtn, UIEvent.EventButtonClick, function()
    local param = self.editHangUpPointSpItemParamInput:GetPropertyString("Text", "") or 0
    if not tonumber(param) then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\233\157\158\230\149\176\229\173\151\233\131\168\229\136\134\230\151\160\230\179\149\232\191\155\232\161\140\230\173\164\230\147\141\228\189\156")
      return
    end
    local addParam = tonumber(param) + 0.1
    self.editHangUpPointSpItemParamInput:SetProperty("Text", tostring(addParam))
    self:setParam()
  end)
  self:subscribe(self.btnHangUpPointSpItemSubBtn, UIEvent.EventButtonClick, function()
    local param = self.editHangUpPointSpItemParamInput:GetPropertyString("Text", "") or 0
    if not tonumber(param) then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\233\157\158\230\149\176\229\173\151\233\131\168\229\136\134\230\151\160\230\179\149\232\191\155\232\161\140\230\173\164\230\147\141\228\189\156")
      return
    end
    local addParam = tonumber(param) - 0.1
    self.editHangUpPointSpItemParamInput:SetProperty("Text", tostring(addParam))
    self:setParam()
  end)
  self:subscribe(self.editHangUpPointSpItemParamInput, UIEvent.EventEditTextInput, function()
    local param = self.editHangUpPointSpItemParamInput:GetPropertyString("Text", "")
    self:setParam(param)
  end)
end

function WidgetHangUpPointSpItem:setParam(param)
  if param then
    self.editHangUpPointSpItemParamInput:SetProperty("Text", tostring(param))
  else
    param = self.editHangUpPointSpItemParamInput:GetPropertyString("Text", "")
    self.editHangUpPointSpItemParamInput:SetProperty("Text", param)
  end
  if self.callBack then
    self.callBack(self.index, param)
  end
end

function WidgetHangUpPointSpItem:setData(index, param)
  self.index = index
  self.txtHangUpPointSpItemParamIndex:SetText("\229\143\130\230\149\176" .. index)
  self.editHangUpPointSpItemParamInput:SetProperty("Text", param)
end

function WidgetHangUpPointSpItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHangUpPointSpItem
