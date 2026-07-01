local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")
local settings = {}

function PokemonLeaderboardRewardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_leaderboard_reward.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.type = tonumber(vConfig.type)
    data.ranks = {}
    local ranks = Lib.split(vConfig.ranks, ",")
    for i = 1, #ranks do
      local rank = Lib.split(ranks[i], "#")
      table.insert(data.ranks, rank)
    end
    data.rewards = {}
    local rewards = Lib.split(vConfig.rewards, "$")
    for i = 1, #rewards do
      local rank_rewards = {}
      local reward = Lib.split(rewards[i], ",")
      for j = 1, #reward do
        local r = Lib.split(reward[j], "#")
        table.insert(rank_rewards, r)
      end
      table.insert(data.rewards, rank_rewards)
    end
    data.coin = {}
    local coin = Lib.split(vConfig.coin, "$")
    for i = 1, #coin do
      local rank_coin = {}
      local r = Lib.split(coin[i], "#")
      rank_coin.type = tostring(r[1])
      rank_coin.cnt = tonumber(r[2])
      table.insert(data.coin, rank_coin)
    end
    settings[data.type] = data
  end
end

local function getRewardIndex(ranks, rank)
  local index = 0
  for i = 1, #ranks do
    local r = ranks[i]
    if rank >= tonumber(r[1]) and rank <= tonumber(r[2]) then
      index = i
      break
    end
  end
  return index
end

function PokemonLeaderboardRewardConfig:getRankRewards(type, rank)
  for _, data in pairs(settings) do
    if data.type == type then
      local rewardIndex = getRewardIndex(data.ranks, rank)
      if rewardIndex ~= 0 then
        return data.rewards[rewardIndex]
      end
    end
  end
  return nil
end

function PokemonLeaderboardRewardConfig:getRankCoin(type, rank)
  for _, data in pairs(settings) do
    if data.type == type then
      local rewardIndex = getRewardIndex(data.ranks, rank)
      if rewardIndex ~= 0 then
        return data.coin[rewardIndex]
      end
    end
  end
  return nil
end

function PokemonLeaderboardRewardConfig:getRewards(type)
  local data = settings[type]
  if data then
    return data
  else
    perror("PokemonLeaderboardRewardConfig:getGuideData fail,type is:", type)
    return nil
  end
end

return PokemonLeaderboardRewardConfig
