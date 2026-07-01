local MapConfig = T(Config, "MapConfig")
local settings = {}

function MapConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/map.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.desc = vConfig.desc or ""
    data.title = vConfig.title or ""
    data.level = {}
    local level = Lib.split(vConfig.level, ",")
    data.level[1] = tonumber(level[1]) or 0
    data.level[2] = tonumber(level[2]) or 0
    data.born = {}
    local born = Lib.split(vConfig.born, ",")
    data.born[1] = tonumber(born[1]) or 0
    data.born[2] = tonumber(born[2]) or 0
    data.born[3] = tonumber(born[3]) or 0
    data.pokemon_level = {}
    local pokemon_level = Lib.split(vConfig.pokemon_level, ",")
    data.pokemon_level[1] = tonumber(pokemon_level[1]) or 0
    data.pokemon_level[2] = tonumber(pokemon_level[2]) or 0
    data.pokemon_list = {}
    local pokemon_list = Lib.split(vConfig.pokemon_list, ",")
    for _, pokemon in pairs(pokemon_list) do
      table.insert(data.pokemon_list, tonumber(pokemon))
    end
    data.item_list = {}
    local item_list = Lib.split(vConfig.item_list, ",")
    for _, item in pairs(item_list) do
      table.insert(data.item_list, "myplugin/" .. item)
    end
    data.map_name = tostring(vConfig.s_map_name)
    data.map_pos_range = {}
    data.unlock_npc = tonumber(vConfig.unlock_npc) or 0
    data.pokemon_list_effect = {}
    local pokemon_list_effect = Lib.split(vConfig.pokemon_list_effect or {}, "#")
    for _, effectIndex in pairs(pokemon_list_effect) do
      table.insert(data.pokemon_list_effect, tonumber(effectIndex))
    end
    data.item_list_effect = {}
    local item_list_effect = Lib.split(vConfig.item_list_effect or {}, "#")
    for _, effectIndex in pairs(item_list_effect) do
      table.insert(data.item_list_effect, tonumber(effectIndex))
    end
    settings[data.id] = data
  end
end

function MapConfig:getMapById(id)
  local data = settings[id]
  if data then
    return data
  else
    perror("MapConfig:getMapById fail,id is:", id)
    return nil
  end
end

function MapConfig:getMapIdByNpc(unlock_npc)
  local mapId = 0
  for _, data in pairs(settings) do
    if tostring(data.unlock_npc) == tostring(unlock_npc) then
      mapId = data.id
      break
    end
  end
  return mapId
end

return MapConfig
