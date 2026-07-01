local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonLeaderboardReceive.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
end

function M:initWnd()
  self.btnConfirm = self:child("PokemonLeaderboardReceive-BtnConfirm")
  self.title = self:child("PokemonLeaderboardReceive-Title")
  self.info = self:child("PokemonLeaderboardReceive-Info")
  self.rewards = self:child("PokemonLeaderboardReceive-Rewards")
  self.reward_grid_view = UIMgr:new_widget("grid_view")
  self.reward_grid_view:SetMoveAble(false)
  self.reward_grid_view:InitConfig(13, 0, 5)
  self.reward_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.reward_grid_view:SetItemAlignment(1)
  self.rewards:AddChildWindow(self.reward_grid_view)
end

function M:initEvent()
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:onShow(subId, rank)
  self.subId = subId
  self.rank = rank
  UI:openWnd("pokemonLeaderboardReceive")
end

function M:onHide()
  UI:closeWnd("pokemonLeaderboardReceive")
end

function M:onOpen()
  Lib.logDebug("onOpen")
  self.title:SetText(Lang:toText("gui.leaderboard.reward." .. self.subId))
  self.info:SetText(Lang:toText({
    "gui.leaderboard.reward.info",
    self.rank
  }))
  self.reward_grid_view:RemoveAllItems()
  local totalCnt = 0
  local rewards = PokemonLeaderboardRewardConfig:getRankRewards(self.subId, self.rank)
  for i = 1, #rewards do
    local reward = rewards[i]
    local fullName = "myplugin/" .. reward[1]
    local itemCount = tonumber(reward[2])
    local item = UIMgr:new_widget("pokemon_item_cell")
    item:invoke("initViewDataWithoutAdapter", fullName, itemCount, function(_, dx, dy)
      UI:getWnd("pokemonItemDetail"):onShow(fullName, dx, dy)
    end)
    item:SetArea({0, 0}, {0, 0}, {0, 92}, {0, 92})
    totalCnt = totalCnt + 1
    self.reward_grid_view:InitConfig(13, 0, totalCnt)
    self.reward_grid_view:AddItem(item)
  end
  local coin = PokemonLeaderboardRewardConfig:getRankCoin(self.subId, self.rank)
  local item = UIMgr:new_widget("pokemon_item_cell")
  item:invoke("initViewDataWithoutCoinAdapter", coin.type, coin.cnt)
  item:SetArea({0, 0}, {0, 0}, {0, 92}, {0, 92})
  totalCnt = totalCnt + 1
  self.reward_grid_view:InitConfig(13, 0, totalCnt)
  self.reward_grid_view:AddItem(item)
end

function M:onClose()
  Lib.logInfo("onClose")
  totalCnt = 0
  Lib.emitEvent(Event.EVENT_CLOSE_REWARD_RECEIVE)
end

return M
