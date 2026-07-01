local NPCConfig = T(Config, "NPCConfig")
local settings = {}

function NPCConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.is_pvp = tonumber(vConfig.is_pvp) or 0
    data.gym_id = tonumber(vConfig.gym_id) or 0
    data.free_challenge_per_day = tonumber(vConfig.free_challenge_per_day) or 0
    data.region = tonumber(vConfig.region) or 0
    data.serailnum = tonumber(vConfig.serailnum) or 0
    data.props_to_challenge = {}
    local props_to_challenge = Lib.split(vConfig.props_to_challenge, ",")
    data.props_to_challenge[1] = tonumber(props_to_challenge[1]) or 0
    data.props_to_challenge[2] = tonumber(props_to_challenge[2]) or 0
    data.pokemon_list = {}
    local pokemon_list = Lib.split(vConfig.pokemon_list, ",")
    for _, pokemon in pairs(pokemon_list) do
      table.insert(data.pokemon_list, tonumber(pokemon))
    end
    data.pokemon_per_round = tonumber(vConfig.pokemon_per_round) or 1
    data.dynamic_strength = {}
    local dynamic_strength = Lib.split(vConfig.dynamic_strength, ",")
    for _, strength in pairs(dynamic_strength) do
      table.insert(data.dynamic_strength, tonumber(strength))
    end
    data.trigger = vConfig.trigger or ""
    data.gym_progress = tonumber(vConfig.gym_progress) or 0
    data.gym_index = tonumber(vConfig.gym_index) or 0
    data.is_gym_boss = tonumber(vConfig.is_gym_boss) or 0
    data.trans_gyms = {}
    local trans_gyms = Lib.split(vConfig.trans_gyms, ",")
    for _, gym_id in pairs(trans_gyms) do
      table.insert(data.trans_gyms, tonumber(gym_id))
    end
    data.action_id = tonumber(vConfig.action_id) or 0
    data.medal_id = tonumber(vConfig.medal_id) or 0
    if vConfig.map == nil or vConfig.map == "" then
      data.map = "map002"
    else
      data.map = vConfig.map
    end
    data.team_id = tonumber(vConfig.team_id) or 0
    data.cfg = vConfig.cfg or ""
    data.host_cfg = vConfig.host_cfg or ""
    data.host_pokemon_list = {}
    local pokemon_list = Lib.split(vConfig.host_pokemon_list, ",")
    for _, pokemon in pairs(pokemon_list) do
      table.insert(data.host_pokemon_list, tonumber(pokemon))
    end
    data.challenge_race = tonumber(vConfig.challenge_race) or 0
    data.min_challenge_power = tonumber(vConfig.min_challenge_power) or 0
    settings[data.id] = data
  end
end

function NPCConfig:getMate(npc_id, team_id)
  for _, data in pairs(settings) do
    if data.team_id == team_id and data.id ~= npc_id then
      return data
    end
  end
  Lib.logInfo("getMate cannot find same team npc = ", npc_id, team_id)
  return nil
end

function NPCConfig:getNPCById(id)
  local data = settings[id]
  if data then
    return data
  else
    return nil
  end
end

function NPCConfig:getNPCByGymIdAndGymProgress(gym_id, gym_progress)
  local npcs = {}
  for _, npc in pairs(settings) do
    if npc.gym_id == gym_id and npc.gym_progress == gym_progress then
      table.insert(npcs, npc)
    end
  end
  return npcs
end

return NPCConfig
