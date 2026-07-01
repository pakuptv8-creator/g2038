local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local settings = {}

function PokemonGuideConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_guide.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 1
    data.next_guide_index = tonumber(vConfig.next_guide_index) or 0
    data.continue_guide_index = tonumber(vConfig.continue_guide_index) or 0
    data.prev_guide_index = tonumber(vConfig.prev_guide_index) or 0
    data.desc = vConfig.desc or ""
    data.title = vConfig.title or ""
    data.dialog_pos = vConfig.dialog_pos or ""
    data.scene_pos = vConfig.scene_pos or ""
    data.time = vConfig.time or 1
    data.trans_mask = tonumber(vConfig.trans_mask) == 1
    data.lucency_area_1 = vConfig.lucency_area_1 or ""
    data.show_lucency_area_2 = vConfig.show_lucency_area_2 or 0
    data.lucency_area_2 = vConfig.lucency_area_2 or ""
    data.arrows_area_1 = vConfig.arrows_area_1 or ""
    data.arrows_img_1 = vConfig.arrows_img_1 or ""
    data.arrows_area_2 = vConfig.arrows_area_2 or ""
    data.arrows_img_2 = vConfig.arrows_img_2 or ""
    data.npc_id = vConfig.npc_id or ""
    data.reward_title = vConfig.reward_title or ""
    data.reward_desc = vConfig.reward_desc or ""
    data.reward_pos = vConfig.reward_pos or ""
    data.reward_items = {}
    local reward_items = Lib.split(vConfig.reward_items, ",")
    for i = 1, #reward_items do
      local item = Lib.split(reward_items[i], "#")
      table.insert(data.reward_items, item)
    end
    data.reward_details = {}
    local reward_details = Lib.split(vConfig.reward_details, ",")
    for i = 1, #reward_details do
      local detail = Lib.split(reward_details[i], "#")
      table.insert(data.reward_details, detail)
    end
    data.reward_exp = tonumber(vConfig.reward_exp) or 0
    data.reward_index = tonumber(vConfig.reward_index) or 0
    settings[data.id] = data
  end
end

function PokemonGuideConfig:getGuideData(id)
  local data = settings[id]
  if data then
    return data
  else
    perror("PokemonGuideConfig:getGuideData fail,id is:", id)
    return nil
  end
end

function PokemonGuideConfig:getGuideCnt(id)
  return #settings
end

return PokemonGuideConfig
