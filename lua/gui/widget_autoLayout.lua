local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "AutoLayout.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
end

function M:initEvent()
end

function M:initLayout(items, parent)
  self.hAlignment = 1
  self.hIntervalPercent = 0
  self.itemWidth = items
  self.itemHeight = parent:GetPixelSize().y
  self.items = {}
  self.parent = parent
  for _, item in pairs(items) do
    self._root:AddChildWindow(item)
    table.insert(self.items, item)
  end
  self._root:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  parent:AddChildWindow(self._root)
  self:updateLayout(items, parent)
end

function M:setAlignment(alignment)
  self.hAlignment = alignment
  self:updateLayout()
end

function M:setHInterval(hIntervalPercent)
  self.hIntervalPercent = hIntervalPercent
  self:updateLayout()
end

function M:updateLayout()
  if not self or #self.items == 0 then
    return
  end
  local width = self.items[1]:GetPixelSize().x
  local interval = width * self.hIntervalPercent
  local tolLength = #self.items * width + (#self.items - 1) * interval
  local positionX = 0 - tolLength / 2 + width / 2
  if self.hAlignment == 0 then
    positionX = 0
  end
  if self.hAlignment == 2 then
    positionX = 0 - tolLength + width / 2
  end
  for index = 1, #self.items do
    self.items[index]:SetHorizontalAlignment(self.hAlignment)
    self.items[index]:SetArea({0, positionX}, {0, 0}, {0, width}, {
      0,
      self.itemHeight
    })
    positionX = positionX + width + interval
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
