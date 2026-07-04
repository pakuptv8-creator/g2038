local adapter_base = require("ui.adapter.adapter_base")
local M = Lib.derive(adapter_base)

function M:init(width, height)
  adapter_base.init(self)
  self.width = width
  self.height = height
end

function M:getWidgetName()
  return "danceItem"
end

function M:getJsonName()
  return "DanceItem.json"
end

function M:getItemWidth()
  return {
    0,
    self.width
  }
end

function M:getItemHeight()
  return {
    0,
    self.height
  }
end

return M
