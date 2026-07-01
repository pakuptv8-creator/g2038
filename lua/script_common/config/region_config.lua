local RegionConfig = T(Config, "RegionConfig")
local settings = {}

function RegionConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/region.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.level = tonumber(vConfig.level)
    data.map = vConfig.map
    data.born = {}
    local born = Lib.split(vConfig.born, ",")
    data.born[1] = tonumber(born[1]) or 0
    data.born[2] = tonumber(born[2]) or 0
    data.born[3] = tonumber(born[3]) or 0
    settings[data.id] = data
  end
end

function RegionConfig:getRegionById(id)
  Lib.logDebug("getRegionById id = ", id)
  local data = settings[id]
  if data then
    return data
  else
    perror("RegionConfig:getRegionById fail,id is:", id)
    return nil
  end
end

return RegionConfig
