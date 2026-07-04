local max = math.max
local min = math.min
local abs = math.abs

local function rgbToHsl(r, g, b)
  local maxVal = max(r, g, b)
  local minVal = min(r, g, b)
  local delta = maxVal - minVal
  local h, s
  local l = (maxVal + minVal) / 2
  if maxVal == minVal then
    h = 0
    s = 0
  else
    s = 0.5 < l and delta / (2 - maxVal - minVal) or delta / (maxVal + minVal)
    if g < r and b < r then
      h = (g - b) / delta + (g < b and 6 or 0)
    elseif b < g then
      h = (b - r) / delta + 2
    else
      h = (r - g) / delta + 4
    end
    h = h / 6
  end
  return h, s, l
end

local function hslToRgb(h, s, l)
  local c = (1 - abs(2 * l - 1)) * s
  local x = c * (1 - abs(h / 60 % 2 - 1))
  local m = l - c / 2
  local rgb
  if 0 <= h and h < 60 then
    rgb = Lib.v3(c, x, 0)
  elseif 60 <= h and h < 120 then
    rgb = Lib.v3(x, c, 0)
  elseif 120 <= h and h < 180 then
    rgb = Lib.v3(0, c, x)
  elseif 180 <= h and h < 240 then
    rgb = Lib.v3(0, x, c)
  elseif 240 <= h and h < 300 then
    rgb = Lib.v3(x, 0, c)
  elseif 300 <= h and h < 360 then
    rgb = Lib.v3(c, 0, x)
  elseif h == 360 then
    rgb = Lib.v3(c, x, 0)
  end
  return rgb.x + m, rgb.y + m, rgb.z + m
end

local function calculateRGBByHueAngle(angle)
  if angle < 0 or 360 < angle then
    return
  end
  local r = 0
  local g = 0
  local b = 0
  if 0 <= angle and angle < 120 then
    g = angle / 120 * 1
    r = 1 - angle / 120 * 1
  elseif 120 <= angle and angle < 240 then
    b = (angle - 120) / 120 * 1
    g = 1 - (angle - 120) / 120 * 1
  else
    r = (angle - 240) / 120 * 1
    b = 1 - (angle - 240) / 120 * 1
  end
  return r, g, b
end

local widget_base = require("ui.widget.widget_base")
local WidgetColorPaletteWidget = Lib.derive(widget_base)

function WidgetColorPaletteWidget:init(callback, initSelectColor)
  widget_base.init(self, "ColorPaletteWidget.json")
  self._allEvent = {}
  self._initColor = initSelectColor
  self._selectColor = initSelectColor or Color.new(1, 1, 1)
  local h, s, l = rgbToHsl(self._selectColor.r, self._selectColor.g, self._selectColor.b)
  self._selectLightness = l
  self.panelStatus = {
    progress = self._selectLightness
  }
  self._h = h * 360
  self._s = s
  self._callback = callback
  self:initUI()
  self:initEvent()
end

function WidgetColorPaletteWidget:updatePanelStatus()
  local x = self.panelStatus.x
  local y = self.panelStatus.y
  local progress = self.panelStatus.progress
  if not (x and y) or not progress then
    return
  end
  self._selectLightness = progress
  self.sliderLightSelect:SetProgress(1 - self._selectLightness)
  local renderArea = self.imgColorSelect:GetRenderArea()
  if renderArea and renderArea[1] and renderArea[2] then
    local relX = x - renderArea[1]
    local relY = y - renderArea[2]
    local hue = relX / self._colorAreaWidth * 360
    local s = 1 - relY / self._colorAreaHeight
    self._h = hue
    self._s = s
    local r, g, b = hslToRgb(hue, s, self._selectLightness)
    self._selectColor = Color.new(r, g, b)
    self:onClickHueRectangle()
    self.imgHueLocation:SetXPosition({0, relX})
    self.imgHueLocation:SetYPosition({0, relY})
    self.panelStatus.x = x
    self.panelStatus.y = y
  end
end

function WidgetColorPaletteWidget:initUI()
  self.imgColorSelectBg = self:child("ColorPaletteWidget-ColorSelectBg")
  self.imgColorSelect = self:child("ColorPaletteWidget-ColorSelect")
  self.imgHueLocation = self:child("ColorPaletteWidget-ColorLocation")
  self.imgLightChangeBg = self:child("ColorPaletteWidget-LightChangeBg")
  self.sliderLightSelect = self:child("ColorPaletteWidget-LightSelectSlider")
  self._colorAreaWidth = self.imgColorSelect:GetWidth()[2]
  self._colorAreaHeight = self.imgColorSelect:GetHeight()[2]
  self.sliderLightSelect:SetProgress(1 - self._selectLightness)
  self.imgHueLocation:SetXPosition({
    0,
    self._colorAreaWidth * self._h
  })
  self.imgHueLocation:SetYPosition({
    0,
    (1 - self._s) * self._colorAreaHeight
  })
end

function WidgetColorPaletteWidget:initEvent()
  self:subscribe(self.imgColorSelect, UIEvent.EventWindowClick, function(window, absX, absY)
    self.panelStatus.x = absX
    self.panelStatus.y = absY
    self:updatePanelStatus()
  end)
  
  local function handleSaturationProgress()
    local value = self.sliderLightSelect:GetProgress()
    if 0 <= value and value <= 1 then
      local r, g, b = hslToRgb(self._h, self._s, 1 - value)
      self._selectColor = Color.new(r, g, b)
      self._selectLightness = 1 - value
      self:updateCurSelectColorView()
      self.panelStatus.progress = 1 - value
    end
  end
  
  self:lightSubscribe("error!!!!! : win_setting quality event : EventWindowTouchMove", self.sliderLightSelect, UIEvent.EventWindowTouchMove, handleSaturationProgress)
  self:lightSubscribe("error!!!!! : win_setting quality event : EventWindowTouchUp", self.sliderLightSelect, UIEvent.EventWindowTouchUp, handleSaturationProgress)
end

function WidgetColorPaletteWidget:updateCurSelectColorView()
  if self._callback then
    self._callback(self._selectColor, self.panelStatus)
  end
end

function WidgetColorPaletteWidget:onClickHueRectangle()
  self:updateCurSelectColorView()
  self:updateLightSliderColor()
end

function WidgetColorPaletteWidget:updateLightSliderColor()
  local rHue, gHue, bHue = calculateRGBByHueAngle(self._h)
end

function WidgetColorPaletteWidget:resetInitColor()
  if not self._initColor then
    return
  end
  self._selectColor = self._initColor
  local h, s, l = rgbToHsl(self._selectColor.r, self._selectColor.g, self._selectColor.b)
  self._selectLightness = l
  self._h = h * 360
  self._s = s
  self.sliderLightSelect:SetProgress(1 - self._selectLightness)
  self.imgHueLocation:SetXPosition({
    0,
    self._colorAreaWidth * self._h
  })
  self.imgHueLocation:SetYPosition({
    0,
    (1 - self._s) * self._colorAreaHeight
  })
end

function WidgetColorPaletteWidget:setPanelStatus(panelStatus)
  self.panelStatus = panelStatus or {
    progress = self._selectLightness
  }
  self:updatePanelStatus()
end

function WidgetColorPaletteWidget:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetColorPaletteWidget
