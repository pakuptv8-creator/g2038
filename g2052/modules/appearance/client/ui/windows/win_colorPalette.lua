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

local WinColorPalette = M

function WinColorPalette:init()
  WinBase.init(self, "ColorPalette.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinColorPalette:initUI()
  self.imgContent = self:child("ColorPalette-Content")
  self.imgContentTopBar = self:child("ColorPalette-Content-TopBar")
  self.txtContentTopBarTitle = self:child("ColorPalette-Content-TopBar-Title")
  self.btnContentTopBarBtnClose = self:child("ColorPalette-Content-TopBar-BtnClose")
  self.lytContentBody = self:child("ColorPalette-Content-Body")
  self.btnContentBodyBtnCenter = self:child("ColorPalette-Content-Body-BtnCenter")
  self.imgColorSelect = self:child("ColorPalette-ColorSelect")
  self._colorAreaWidth = self.imgColorSelect:GetWidth()[2]
  self._colorAreaHeight = self.imgColorSelect:GetHeight()[2]
  self.sliderLightSelect = self:child("ColorPalette-LightSelectSlider")
  self.imgLightChange = self:child("ColorPalette-LightChangeBg")
  self.imgCurColor = self:child("ColorPalette-CurColor")
  self.imgHueLocation = self:child("ColorPalette-ColorLocation")
end

function WinColorPalette:initEvent()
  self:subscribe(self.btnContentTopBarBtnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnContentBodyBtnCenter, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
    if self._callBack then
      self._callBack(self._selectColor)
    end
  end)
  self:subscribe(self.imgColorSelect, UIEvent.EventWindowClick, function(window, absX, absY)
    local renderArea = window:GetRenderArea()
    if renderArea and renderArea[1] and renderArea[2] then
      local relX = absX - renderArea[1]
      local relY = absY - renderArea[2]
      local hue = relX / self._colorAreaWidth * 360
      local s = 1 - relY / self._colorAreaHeight
      self._h = hue
      self._s = s
      local r, g, b = hslToRgb(hue, s, self._selectLightness)
      self._selectColor = Color.new(r, g, b)
      self:onClickHueRectangle()
      self.imgHueLocation:SetXPosition({0, relX})
      self.imgHueLocation:SetYPosition({0, relY})
    end
  end)
  
  local function handleSaturationProgress()
    local value = self.sliderLightSelect:GetProgress()
    if 0 <= value and value <= 1 then
      local r, g, b = hslToRgb(self._h, self._s, 1 - value)
      self._selectColor = Color.new(r, g, b)
      self._selectLightness = 1 - value
      self:updateCurSelectColorView()
    end
  end
  
  self:lightSubscribe("error!!!!! : win_setting quality event : EventWindowTouchMove", self.sliderLightSelect, UIEvent.EventWindowTouchMove, handleSaturationProgress)
  self:lightSubscribe("error!!!!! : win_setting quality event : EventWindowTouchUp", self.sliderLightSelect, UIEvent.EventWindowTouchUp, handleSaturationProgress)
end

function WinColorPalette:subscribeEvent()
end

function WinColorPalette:updateCurSelectColorView()
  self.imgCurColor:SetDrawColor({
    self._selectColor.r,
    self._selectColor.g,
    self._selectColor.b,
    1
  })
end

function WinColorPalette:onClickHueRectangle()
  self:updateCurSelectColorView()
  self:updateLightSliderColor()
end

function WinColorPalette:updateLightSliderColor()
  local rHue, gHue, bHue = calculateRGBByHueAngle(self._h)
end

function WinColorPalette:initView()
  self.imgHueLocation:SetXPosition({0, 0})
  self.imgHueLocation:SetYPosition({0, 0})
  self.imgCurColor:SetDrawColor({
    self._selectColor.r,
    self._selectColor.g,
    self._selectColor.b,
    1
  })
  self.sliderLightSelect:SetProgress(1 - self._selectLightness)
end

function WinColorPalette:onHide()
  UI:closeWnd("colorPalette")
end

function WinColorPalette:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("colorPalette")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinColorPalette:onOpen(callBack)
  self._selectColor = Color.new(1, 1, 1)
  self._selectLightness = 1
  self._h = 0
  self._s = 0
  self:initView()
  self:subscribeEvent()
  self._callBack = callBack
end

function WinColorPalette:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinColorPalette
