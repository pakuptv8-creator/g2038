local NPCPokemonConfig = T(Config, "NPCPokemonConfig")
local settings = {}

function NPCPokemonConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/npc_pokemon.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.region = tonumber(vConfig.region) or 0
    data.serialnum = tonumber(vConfig.serialnum) or 0
    data.pokemon_id = tonumber(vConfig.pokemon_id) or 0
    data.level = tonumber(vConfig.level) or 0
    data.is_random_skill = tonumber(vConfig.is_random_skill) or 1
    data.active_skill_list = {}
    local active_skill_list = Lib.split(vConfig.active_skill_list, ",")
    for _, skill in pairs(active_skill_list) do
      table.insert(data.active_skill_list, tonumber(skill) or 0)
    end
    data.passive_skill_list = {}
    local passive_skill_list = Lib.split(vConfig.passive_skill_list, ",")
    for _, skill in pairs(passive_skill_list) do
      table.insert(data.passive_skill_list, tonumber(skill) or 0)
    end
    data.npc_hp = tonumber(vConfig.npc_hp) or -1
    data.npc_speed = tonumber(vConfig.npc_speed) or -1
    data.npc_pAtk = tonumber(vConfig.npc_pAtk) or -1
    data.npc_pDef = tonumber(vConfig.npc_pDef) or -1
    data.npc_sAtk = tonumber(vConfig.npc_sAtk) or -1
    data.npc_sDef = tonumber(vConfig.npc_sDef) or -1
    data.npc_star = tonumber(vConfig.npc_star) or 0
    data.npc_wake = tonumber(vConfig.npc_wake) or 0
    settings[data.id] = data
  end
end

function NPCPokemonConfig:getPokemonById(id)
  local data = settings[id]
  if data then
    return data
  else
    perror("NPCPokemonConfig:getPokemonById fail,id is:", id)
    return nil
  end
end

return NPCPokemonConfig
