local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local DEG2RAD = 0.01745329

local function calculatePoint(properties, radius)
  local angle = 360 / #properties
  local curAngle = 180 - angle
  local points = {}
  for _, property in pairs(properties) do
    local distance = property.value * radius
    local point = {
      x = math.cos(curAngle * DEG2RAD) * distance,
      y = -math.sin(curAngle * DEG2RAD) * distance,
      z = 0
    }
    if (curAngle + 90) % 180 == 0 then
      point.x = 0
    end
    if curAngle % 180 == 0 then
      point.y = 0
    end
    table.insert(points, point)
    curAngle = curAngle - angle
  end
  return points
end

function M:init()
  widget_base.init(self, nil, "Irregular", "PropertyIrregularView")
  self:setSize(500)
  self:root():SetTouchable(false)
end

function M:setSize(size)
  self.radius = size / 2
  self:root():SetWidth({0, size})
  self:root():SetHeight({0, size})
  self._root:SetHorizontalAlignment(1)
  self._root:SetVerticalAlignment(1)
end

function M:setProperties(properties, color)
  self:root():CleanupChildren()
  if #properties < 3 then
    return
  end
  local points = calculatePoint(properties, self.radius)
  self._root:SetDrawColor(color)
  self._root:SetPoints(points)
end

return M
