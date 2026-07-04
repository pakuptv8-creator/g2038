local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeActivityBtn = Lib.derive(widget_base)
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WidgetLimitedTimeActivityBtn:init()
  widget_base.init(self, "LimitedTimeActivityBtn.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitedTimeActivityBtn:initUI()
  self.btnBtn = self:child("LimitedTimeActivityBtn-btn")
  self.txtText = self:child("LimitedTimeActivityBtn-text")
  self.imgRedDot = self:child("LimitedTimeActivityBtn-red_dot")
  self.imgBtnBg = self:child("LimitedTimeActivityBtn-BtnBg")
  self.imgSelectIcon = self:child("LimitedTimeActivityBtn-SelectIcon")
  self.imgSelectIcon:SetVisible(false)
  self.imgRedDot:SetVisible(false)
end

function WidgetLimitedTimeActivityBtn:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventWindowClick, function()
    if self.clickFunc and self.params then
      self.clickFunc(self.params)
    end
  end)
end

function WidgetLimitedTimeActivityBtn:updateView(params)
  if params then
    self.params = params
    self.txtText:SetText(Lang:toText(params.tabName))
    self.imgBtnBg:SetImage(params.tabBgRes)
    self:updateRedDot(LimitTimeClientHelper.activityRedInfo[params.key])
    self.txtText:SetProperty("TextColorLeftTop", params.TextColorLeftTop)
    self.txtText:SetProperty("TextColorRightTop", params.TextColorRightTop)
    self.txtText:SetProperty("TextColorLeftBottom", params.TextColorLeftBottom)
    self.txtText:SetProperty("TextColorRightBottom", params.TextColorRightBottom)
  end
end

function WidgetLimitedTimeActivityBtn:setCallBackFunc(func)
  self.clickFunc = func
end

function WidgetLimitedTimeActivityBtn:updateRedDot(isShow)
  if isShow then
    self.imgRedDot:SetVisible(true)
  else
    self.imgRedDot:SetVisible(false)
  end
end

function WidgetLimitedTimeActivityBtn:updateSelectState(isShow)
  self.imgSelectIcon:SetVisible(isShow)
end

function WidgetLimitedTimeActivityBtn:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeActivityBtn
