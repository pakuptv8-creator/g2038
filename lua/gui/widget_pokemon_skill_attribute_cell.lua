local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_skill_attribute_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgSkillIcon = self:child("pokemon_skill_attribute_cell-icon")
  self.txtSkillText = self:child("pokemon_skill_attribute_cell-text")
end

function M:initEvent()
end

function M:setData()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
