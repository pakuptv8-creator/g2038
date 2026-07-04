local widget_base = require("ui.widget.widget_base")
local WidgetHalloweenCandyNum = Lib.derive(widget_base)

function WidgetHalloweenCandyNum:init()
  widget_base.init(self, "HalloweenCandyNum.json")
  self.oldNum = 0
  self._allEvent = {}
  self.delEffectTimer = {}
  self:initUI()
  self:initEvent()
end

function WidgetHalloweenCandyNum:initUI()
  self.txtTextNum = self:child("HalloweenCandyNum-TextNum")
end

function WidgetHalloweenCandyNum:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HALLOWEEN_CANDY_NUM_UPDATE, function(value)
    self:numChange(value)
  end)
end

function WidgetHalloweenCandyNum:numChange(newValue)
  if not newValue or type(newValue) ~= "number" then
    return
  end
  self.txtTextNum:SetText(newValue)
  local diff = newValue - self.oldNum
  if 0 < diff and self.oldNum > 0 then
    self:showEffect(diff)
  end
  self.oldNum = newValue
end

function WidgetHalloweenCandyNum:showEffect(num)
  local effectName = World.cfg.halloweenSetting.candyNumEffect.numEffectList[tostring(num)]
  if not effectName then
    return
  end
  local posx = World.cfg.halloweenSetting.candyNumEffect.posOffsetX or 50
  local posy = World.cfg.halloweenSetting.candyNumEffect.posOffsetY or -30
  local size = World.cfg.halloweenSetting.candyNumEffect.size or 200
  local showEffect = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "show-effect")
  showEffect:SetTouchable(false)
  showEffect:SetArea({0, posx}, {0, posy}, {0, size}, {0, size})
  showEffect:SetHorizontalAlignment(1)
  showEffect:SetVerticalAlignment(1)
  showEffect:PlayEffect1(effectName)
  self._root:AddChildWindow(showEffect)
  local timer = World.Timer(60, function()
    self._root:RemoveChildWindow1(showEffect)
    table.remove(self.delEffectTimer, 1)
  end)
  table.insert(self.delEffectTimer, timer)
end

function WidgetHalloweenCandyNum:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.delEffectTimer then
    for i, fun in pairs(self.delEffectTimer) do
      fun()
    end
    self.delEffectTimer = {}
  end
end

return WidgetHalloweenCandyNum
