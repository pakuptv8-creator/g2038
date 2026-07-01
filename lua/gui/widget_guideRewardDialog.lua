local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "GuideRewardDialog.json")
  self:initWnd()
end

function M:initWnd()
  self.txtTitle = self:child("GuideRewardDialog-Title")
  self.txtInfo = self:child("GuideRewardDialog-Info")
  self.txtProgress = self:child("GuideRewardDialog-Progress")
  self.ltRewardList = self:child("GuideRewardDialog-Reward-List")
  self.item_grid_view = UIMgr:new_widget("grid_view")
  self.item_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.item_grid_view:InitConfig(33, 0, 3)
  self.item_grid_view:SetMoveAble(false)
  self.ltRewardList:AddChildWindow(self.item_grid_view)
end

function M:initView(title, info, pos, size, alig, items, root)
  self.txtTitle:SetText(Lang:toText(title))
  self.txtInfo:SetText(Lang:toText(info))
  for _, item in pairs(items) do
    local item_name = "myplugin/" .. item[1]
    local item_count = item[2]
    local node = UIMgr:new_widget("pokemon_item_cell")
    node:invoke("initViewDataWithoutAdapter", item_name, item_count, function(_, dx, dy)
      UI:getWnd("pokemonItemDetail"):onShow(item_name, dx, dy)
    end)
    self.item_grid_view:InitConfig(33, 0, #items)
    local itemWidth = 62
    node:SetArea({0, 0}, {0, 0}, {0, itemWidth}, {0, itemWidth})
    self.item_grid_view:AddItem(node, true)
  end
  self._root:SetArea({
    pos[1],
    pos[2]
  }, {
    pos[3],
    pos[4]
  }, {
    0,
    size[1]
  }, {
    0,
    size[2]
  })
  self._root:SetHorizontalAlignment(alig[1])
  self._root:SetVerticalAlignment(alig[2])
  root:AddChildWindow(self._root)
  return self._root
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
