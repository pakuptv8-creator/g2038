local GymConfig = T(Config, "GymConfig")
local settings = {}

function GymConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/gym.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.type = tonumber(vConfig.type) or 0
    data.is_honor = tonumber(vConfig.is_honor) or 0
    data.map = vConfig.map or ""
    data.is_pvp = tonumber(vConfig.is_pvp) or 0
    data.in_region_id = tonumber(vConfig.in_region_id) or 0
    data.out_region_id = tonumber(vConfig.out_region_id) or 0
    data.unlock = tonumber(vConfig.unlock) or 0
    data.name = vConfig.name or ""
    data.is_team = tonumber(vConfig.is_team) or 0
    settings[data.id] = data
  end
end

function GymConfig:getGymById(id)
  local data = settings[id]
  if data then
    return data
  else
    perror("GymConfig:getGymById fail,id is:", id)
    return nil
  end
end

function GymConfig:getPVPGyms()
  local datas = {}
  for _, gym_data in pairs(settings) do
    if gym_data.is_pvp == 1 and gym_data.type ~= 0 then
      table.insert(datas, gym_data)
    end
  end
  return datas
end

function GymConfig:getHonorGyms()
  local datas = {}
  for _, gym_data in pairs(settings) do
    if gym_data.is_honor == 1 then
      table.insert(datas, gym_data)
    end
  end
  return datas
end

return GymConfig
