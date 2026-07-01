local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local star_png_width = 38
local star_png_height = 36
local star_max_num = 6

function M:init()
  widget_base.init(self, "pokemon_star_item_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.greyStarVisible = false
  self:setHInterval(0)
  self.starList = {}
end

function M:initEvent()
end

function M:setGreyStarVisible(visible)
  self.greyStarVisible = visible
end

function M:setHInterval(hIntervalPercent)
  self.m_hIntervalPercent = hIntervalPercent
  self.layout_width = star_png_width * star_max_num + star_png_width * self.m_hIntervalPercent * (star_max_num - 1)
end

function M:updateUI(star_level, wake_level, horizontalAlignment)
  horizontalAlignment = horizontalAlignment or 1
  local star_count = star_level
  local parent = self:root():GetParent()
  if parent then
    local parent_width = parent:GetPixelSize().x
    local parent_height = math.min(parent:GetPixelSize().y, parent_width / self.layout_width * star_png_height)
    self:root():SetHeight({0, parent_height})
  end
  self:root():SetHorizontalAlignment(horizontalAlignment)
  local star_height = self:root():GetPixelSize().y
  local star_width = star_height / star_png_height * star_png_width
  local hInterval = star_width * self.m_hIntervalPercent
  local starsLength = star_width * (self.greyStarVisible and 6 or star_count) + hInterval * ((self.greyStarVisible and 6 or star_count) - 1)
  local positionX = 0 - starsLength / 2 + star_width / 2
  if horizontalAlignment == 0 then
    positionX = 0
  end
  if horizontalAlignment == 2 then
    positionX = 0 - starsLength + star_width
  end
  for index = 1, star_count do
    if not self.starList[index] then
      self.starList[index] = self:spawnStar()
    end
    self.starList[index]:SetVisible(true)
    self.starList[index]:SetArea({0, positionX}, {0, 0}, {0, star_width}, {0, star_height})
    self.starList[index]:SetImage("set:g2038_pokemon_star.json image:img_0_bigsize_rareness" .. tostring(wake_level + 1))
    self.starList[index]:SetHorizontalAlignment(horizontalAlignment)
    positionX = positionX + star_width + hInterval
  end
  for index = star_count + 1, 6 do
    if not self.starList[index] then
      self.starList[index] = self:spawnStar()
    end
    self.starList[index]:SetVisible(self.greyStarVisible)
    self.starList[index]:SetArea({0, positionX}, {0, 0}, {0, star_width}, {0, star_height})
    self.starList[index]:SetImage("set:g2038_pokemon_star.json image:img_0_bigsize_rareness0")
    self.starList[index]:SetHorizontalAlignment(horizontalAlignment)
    positionX = positionX + star_width + hInterval
  end
  for index = 0, 5 do
    self.starList[6 - index]:SetLevel(1)
  end
end

function M:spawnStar()
  local starImg = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "SmallStar")
  starImg:SetProperty("Material", "CullBackLinear")
  self:root():AddChildWindow(starImg)
  return starImg
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
