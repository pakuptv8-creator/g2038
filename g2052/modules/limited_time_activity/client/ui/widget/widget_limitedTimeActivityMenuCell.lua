local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeActivityMenuCell = Lib.derive(widget_base)
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WidgetLimitedTimeActivityMenuCell:init()
  widget_base.init(self, "LimitedTimeActivityMenuCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitedTimeActivityMenuCell:initUI()
  self.txtName = self:child("LimitedTimeActivityMenuCell-name")
  self.imgRedDot = self:child("LimitedTimeActivityMenuCell-RedDot")
  self.btnBtn = self:child("LimitedTimeActivityMenuCell-btn")
  self.lytEffect = self:child("LimitedTimeActivityMenuCell-effect")
  self:updateRedState(false)
end

function WidgetLimitedTimeActivityMenuCell:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_ENTRY_RED_DOY, function(value, type)
    if self.data and self.data.type == type then
      self:updateRedState(value)
    end
  end)
  self._allEvent[#self._allEvent + 1] = self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if not self.data then
      return
    end
    if self.data.type == Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY then
      if LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY) then
        LimitTimeClientHelper:updateMustFishClick(true)
      end
      Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeActivityWnd")
    elseif self.data.type == Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT then
      Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeCombinedWnd")
    elseif self.data.type == Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT then
      Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeSignalWnd")
    end
  end)
end

function WidgetLimitedTimeActivityMenuCell:updateView(data, font)
  if not data then
    return
  end
  self.data = data
  self.txtName:SetText(Lang:toText(data.name))
  self.btnBtn:SetNormalImage(data.icon)
  self.btnBtn:SetPushedImage(data.icon)
  self.btnBtn:SetVisible(true)
  if not data.effect or data.effect == "" then
    self.lytEffect:SetVisible(false)
  else
    self.lytEffect:SetEffectName(data.effect)
    self.lytEffect:SetVisible(true)
  end
  if font then
    self.txtName:SetProperty("Font", tostring(font))
  end
end

function WidgetLimitedTimeActivityMenuCell:empty()
  self.lytEffect:SetVisible(false)
  self.btnBtn:SetVisible(false)
  self.txtName:SetText()
end

function WidgetLimitedTimeActivityMenuCell:updateRedState(value)
  self.imgRedDot:SetVisible(value)
end

function WidgetLimitedTimeActivityMenuCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeActivityMenuCell
