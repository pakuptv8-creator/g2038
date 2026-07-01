local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_leaderboard_reward_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.place = self:child("pokemon_leaderboard_reward_cell-rank")
  self.rewards = self:child("pokemon_leaderboard_reward_cell-rewards")
  self.reward_grid_view = UIMgr:new_widget("grid_view")
  self.reward_grid_view:SetMoveAble(false)
  self.reward_grid_view:InitConfig(13, 0, 5)
  self.reward_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.rewards:AddChildWindow(self.reward_grid_view)
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowTouchDown, function()
    Lib.logDebug("touch down reward item")
  end)
  self:subscribe(self._root, UIEvent.EventWindowTouchMove, function()
    Lib.logDebug("touch move reward item")
  end)
end

function M:initItem(index, ranks, rewards, coin)
  local _, num = math.modf(index / 2)
  if num == 0 then
    self._root:SetBackImage("set:pokemon_leaderboard.json image:img_9_rewardlist_1")
  else
    self._root:SetBackImage("set:pokemon_leaderboard.json image:img_9_rewardlist_2")
  end
  if tonumber(ranks[1]) == 0 then
    self.place:SetText("No." .. ranks[2])
  else
    self.place:SetText("No." .. ranks[1] .. " ~ " .. "No." .. ranks[2])
  end
  self.reward_grid_view:RemoveAllItems()
  Lib.logDebug("rewards count = ", #rewards)
  for i = 1, #rewards do
    local reward = rewards[i]
    local fullName = "myplugin/" .. reward[1]
    local count = tonumber(reward[2])
    local item = UIMgr:new_widget("pokemon_item_cell")
    item:invoke("initViewDataWithoutAdapter", fullName, count, function(_, dx, dy)
      UI:getWnd("pokemonItemDetail"):onShow(fullName, dx, dy)
    end)
    item:SetArea({0, 0}, {0, 0}, {0, 58}, {0, 58})
    self.reward_grid_view:AddItem(item)
  end
  local item = UIMgr:new_widget("pokemon_item_cell")
  item:invoke("initViewDataWithoutCoinAdapter", coin.type, coin.cnt)
  item:SetArea({0, 0}, {0, 0}, {0, 58}, {0, 58})
  self.reward_grid_view:AddItem(item)
end

function M:initViewDataWithoutAdapter(index, ranks, rewards, coin)
  self:initItem(index, ranks, rewards, coin)
end

function M:onDataChanged(data)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
