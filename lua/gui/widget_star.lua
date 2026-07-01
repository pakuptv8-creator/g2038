local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local itemWidth = 49.4
local smoothTime = 5

function M:init()
  widget_base.init(self, "star.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.star = self:child("starBG-star")
end

function M:initEvent()
end

function M:updateUI(wake, withEffect)
  self.showWidth = 0
  self.star:SetImage(not withEffect and wake and "set:g2038_pokemon_star.json image:img_0_bigsize_rareness" .. tostring(wake) or "")
  if withEffect then
    local starEffect = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "StarEffect")
    self:root():AddChildWindow(starEffect)
    starEffect:SetArea({0, 0}, {0, 0}, {1.7, 0}, {1.7, 0})
    starEffect:SetHorizontalAlignment(1)
    starEffect:SetVerticalAlignment(1)
    starEffect:SetEffectName("g2038_startUp_" .. wake .. ".effect")
  end
  self:stopTick()
end

function M:onTick()
  self.time = self.time + 0.15
  local value = 0.5 + math.sin(self.time) * 0.5
  value = math.min(value, 0.6)
  self.star:SetAlpha(value)
  return true
end

function M:startTick()
  self.time = 0
  self.isTicking = true
  self.tickCancel = World.Timer(1, function()
    return self:onTick()
  end)
end

function M:stopTick()
  self.star:SetAlpha(1)
  if self.tickCancel then
    self.tickCancel()
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

function M:onDestroy()
  if self.tickCancel then
    self.tickCancel()
  end
end

return M
