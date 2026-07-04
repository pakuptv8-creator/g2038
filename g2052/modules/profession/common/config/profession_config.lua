local ProfessionConfig = T(Config, "ProfessionConfig")
local settings = {}

function ProfessionConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/profession.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      sceneIcon = vConfig.s_sceneIcon or "",
      careerName = vConfig.s_careerName or "",
      isHideCareer = tonumber(vConfig.n_isHideCareer) or 0,
      isNoCall = tonumber(vConfig.n_isNoCall) or 0
    }
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.sortId < b.sortId
  end)
end

function ProfessionConfig:getCfgById(id)
  for _, val in pairs(settings) do
    if val.id == id then
      return val
    end
  end
  Lib.logError("can not find cfgProfessionConfig, id:", id)
  return
end

function ProfessionConfig:getAllCfgs()
  return settings
end

function ProfessionConfig:getAllNormalCfgs()
  local items = {}
  for _, val in pairs(settings) do
    if val.isHideCareer == 0 then
      table.insert(items, val)
    end
  end
  return items
end

function ProfessionConfig:getAllCallCfgs()
  local items = {}
  for _, val in pairs(settings) do
    if val.isNoCall == 0 then
      table.insert(items, val)
    end
  end
  return items
end

ProfessionConfig:init()
return ProfessionConfig
