local PetStatusConfig = T(Config, "PetStatusConfig")
local settings = {}

function PetStatusConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pet_status.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      performanceBuff = vConfig.s_performanceBuff or "",
      actionName = vConfig.s_actionName or "",
      priority = tonumber(vConfig.n_priority) or 1,
      statusRemoveCond = Lib.splitString(vConfig.s_statusRemoveCond or "", "#", true),
      interactSatisfyKey = vConfig.s_interactSatisfyKey or "",
      interactSatisfyBuff = vConfig.s_interactSatisfyBuff or "",
      interactSatisfyBuffDuration = tonumber(vConfig.n_interactSatisfyBuffDuration) or 20,
      interactSatisfyBuffDelay = tonumber(vConfig.n_interactSatisfyBuffDelay) or 20
    }
    settings[data.id] = data
  end
end

function PetStatusConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPetStatusConfig, id:", id)
    return
  end
  return settings[id]
end

function PetStatusConfig:randomOneStatusCfg()
  local randomLen = 0
  for _, v in ipairs(settings) do
    randomLen = randomLen + v.priority
  end
  local rand = math.random(1, randomLen)
  local count = 0
  for _, v in ipairs(settings) do
    count = count + v.priority
    if rand <= count then
      return v
    end
  end
end

PetStatusConfig:init()
return PetStatusConfig
