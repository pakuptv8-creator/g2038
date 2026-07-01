local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")

function M:init()
  WinBase.init(self, "PokemonLeaderboardReward.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.rankType = 0
end

function M:initWnd()
  self.btnClose = self:child("PokemonLeaderboardReward-BtnClose")
  self.title = self:child("PokemonLeaderboardReward-Title")
  self.stRank = self:child("PokemonLeaderboardReward-Head-Rank")
  self.stReward = self:child("PokemonLeaderboardReward-Head-Reward")
  self.rewards = self:child("PokemonLeaderboardReward-Rewards")
  self.reward_grid_view = UIMgr:new_widget("grid_view")
  self.reward_grid_view:SetMoveAble(true)
  self.reward_grid_view:InitConfig(0, 0, 1)
  self.reward_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.rewards:AddChildWindow(self.reward_grid_view)
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:onShow(rankType)
  self.rankType = rankType
  self.title:SetText(Lang:toText("gui.leaderboard.reward." .. self.rankType))
  self.stRank:SetText(Lang:toText("gui.leaderboard.reward.rank"))
  self.stReward:SetText(Lang:toText("gui.leaderboard.reward.reward"))
  local rank_rewards = PokemonLeaderboardRewardConfig:getRewards(self.rankType)
  Lib.logDebug("rank_rewards = ", Lib.v2s(rank_rewards))
  self.reward_grid_view:RemoveAllItems()
  for i = 1, #rank_rewards.ranks do
    local node = UIMgr:new_widget("pokemon_leaderboard_reward_cell")
    node:invoke("initViewDataWithoutAdapter", i, rank_rewards.ranks[i], rank_rewards.rewards[i], rank_rewards.coin[i])
    self.reward_grid_view:AddItem(node, true)
  end
  UI:openWnd("pokemonLeaderboardReward")
end

function M:onHide()
  UI:closeWnd("pokemonLeaderboardReward")
end

function M:onOpen()
  Lib.logDebug("onOpen")
end

function M:onClose()
  Lib.logDebug("onClose")
end

return M
