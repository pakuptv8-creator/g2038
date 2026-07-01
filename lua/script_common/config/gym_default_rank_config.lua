local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")
local settings = {}

function GymDefaultRankConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/gym_default_rank.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.type = tonumber(vConfig.type) or 0
    data.rank = tonumber(vConfig.rank) or 0
    data.score = tonumber(vConfig.score) or 0
    data.name = vConfig.name or ""
    data.npc_id = tonumber(vConfig.npc_id) or 0
    data.cfg_fullname = vConfig.cfg_fullname or ""
    settings[data.id] = data
  end
end

function GymDefaultRankConfig:getRanksByType(type)
  local datas = {}
  for _, data in pairs(settings) do
    if data.type == type then
      table.insert(datas, data)
    end
  end
  return datas
end

function GymDefaultRankConfig:getSpecificNpc(type, npc_id)
  Lib.logDebug("getSpecificNpc type and npc_id  = ", type, npc_id)
  for _, data in pairs(settings) do
    if data.type == type and data.npc_id == npc_id then
      return data
    end
  end
  return nil
end

function GymDefaultRankConfig:getNpc(type, rank)
  for _, data in pairs(settings) do
    if data.type == type and data.rank == rank then
      return data
    end
  end
end

return GymDefaultRankConfig
