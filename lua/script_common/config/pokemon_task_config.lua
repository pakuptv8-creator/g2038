local PokemonTaskConfig = T(Config, "PokemonTaskConfig")
local settings = {}

function PokemonTaskConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_task.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.type = tonumber(vConfig.type) or 0
    data.desc = vConfig.desc or ""
    data.name = vConfig.name or ""
    data.min_level = tonumber(vConfig.min_level) or 0
    data.max_level = tonumber(vConfig.max_level) or 0
    data.gym = tonumber(vConfig.gym) or 0
    data.active_day = tonumber(vConfig.active_day) or 0
    data.targets = {}
    local targets = Lib.split(vConfig.targets, ",")
    for i = 1, #targets do
      local target = Lib.split(targets[i], "#")
      table.insert(data.targets, target)
    end
    data.condition = tonumber(vConfig.condition) or 1
    data.map = {}
    local map = Lib.split(vConfig.map, ",")
    for i = 1, #map do
      table.insert(data.map, map[i])
    end
    data.pos = {}
    local pos = Lib.split(vConfig.pos, ",")
    for i = 1, #pos do
      local p = Lib.split(pos[i], "#")
      table.insert(data.pos, p)
    end
    data.ui_type = tonumber(vConfig.ui_type) or 0
    data.active_reward = tonumber(vConfig.active_reward) or 0
    data.exp_reward = tonumber(vConfig.exp_reward) or 0
    data.item_reward = {}
    local item_reward = Lib.split(vConfig.item_reward, "#")
    data.item_reward[1] = "myplugin/" .. item_reward[1] or ""
    data.item_reward[2] = tonumber(item_reward[2]) or 0
    data.weight = tonumber(vConfig.weight) or 0
    settings[data.id] = data
  end
end

function PokemonTaskConfig:getTaskById(id)
  local data = settings[id]
  if data then
    return data
  else
    perror("PokemonTaskConfig:getTaskById fail,id is:", id)
    return nil
  end
end

function PokemonTaskConfig:getTaskByType(type, condition, targetId)
  Lib.logDebug("getTaskByType type = ", type)
  Lib.logDebug("getTaskByType condition = ", condition)
  Lib.logDebug("getTaskByType targetId = ", targetId)
  local datas = {}
  for _, data in pairs(settings) do
    if data.type == type and data.condition == condition then
      for i = 1, #data.targets do
        Lib.logDebug("data.targets[i][1] = ", data.targets[i][1])
        Lib.logDebug("targetId = ", targetId)
        if tostring(data.targets[i][1]) == tostring(targetId) or targetId == 0 then
          Lib.logDebug("found task id = ", data.id)
          table.insert(datas, data.id)
        end
      end
    end
  end
  return datas
end

local function randomByWeight(type, level, gym, active_day)
  local datas = {}
  for _, data in pairs(settings) do
    if type == data.type and level <= data.max_level and level >= data.min_level and active_day >= data.active_day then
      table.insert(datas, data.id)
    end
  end
  if 0 < #datas then
    local task_index = math.random(1, #datas)
    local task_id = datas[task_index]
    return task_id
  else
    return 0
  end
end

function PokemonTaskConfig:getTask(level, gym, active_day)
  local datas = {}
  for i = 1, 8 do
    local task_id = randomByWeight(i, level, gym, active_day)
    if task_id ~= 0 then
      table.insert(datas, task_id)
    end
  end
  return datas
end

return PokemonTaskConfig
