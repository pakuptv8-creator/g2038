local widget_base = require("ui.widget.widget_base")
local WidgetGameMainRightFuncBtn = Lib.derive(widget_base)

function WidgetGameMainRightFuncBtn:init(params)
  widget_base.init(self, "GameMainRightFuncBtn.json")
  self.params = params
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetGameMainRightFuncBtn:initUI()
  self.btnFuncBtn = self:child("GameMainRightFuncBtn-FuncBtn")
  self.imgFuncIcon = self:child("GameMainRightFuncBtn-FuncIcon")
  self.imgFuncRedDot = self:child("GameMainRightFuncBtn-FuncRedDot")
  self.imgEffect = self:child("GameMainRightFuncBtn-Effect")
  self.txtEffectTitle = self:child("GameMainRightFuncBtn-Effect_title")
  if self.params.icon then
    self.imgFuncIcon:SetImage(self.params.icon)
  end
  if self.params.btnTxt then
    self.txtEffectTitle:SetText(Lang:toText(self.params.btnTxt))
  end
  self.imgEffect:SetVisible(true)
end

function WidgetGameMainRightFuncBtn:initEvent()
  self:subscribe(self.btnFuncBtn, UIEvent.EventButtonClick, function()
    if self.params.callBack then
      self.params.callBack()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TRIGGER_GUIDE_OPERATION, function(isShow)
    self.imgEffect:SetVisible(isShow)
  end)
end

function WidgetGameMainRightFuncBtn:updateRedDotVisible(isVisible)
  self.imgFuncRedDot:SetVisible(isVisible)
end

function WidgetGameMainRightFuncBtn:updateRedDotVisible(isVisible)
  self.imgFuncRedDot:SetVisible(isVisible)
end

function WidgetGameMainRightFuncBtn:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetGameMainRightFuncBtn
