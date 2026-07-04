local PetConfig = T(Config, "PetConfig")
local settings = {}

local function readPetCSV()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pet.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id),
      cfgName = vConfig.s_cfgName or "",
      name = vConfig.s_name or "",
      petSort = tonumber(vConfig.n_sort) or 0,
      icon = vConfig.s_icon or "",
      actorName = vConfig.s_actor_name or "",
      lockState = tonumber(vConfig.n_lockState) or 0,
      lockTips = vConfig.s_lockTips or "",
      needReceive = tonumber(vConfig.n_needReceive) or 0,
      feedFood = vConfig.s_feedFood or "",
      foodFrontDis = tonumber(vConfig.n_foodFrontDis) or 0,
      foodSpeed = tonumber(vConfig.n_foodSpeed) or 0,
      happyAction = Lib.splitString(vConfig.s_happyAction or "", "#"),
      type = tonumber(vConfig.n_type) or 0,
      speedUpBuff = vConfig.s_speedUpBuff or "",
      speedUpTime = tonumber(vConfig.n_speedUpTime) or 0,
      speedUpCD = tonumber(vConfig.n_speedUpCD) or 0,
      needBuy = tonumber(vConfig.n_needBuy) or 0,
      isWatchAd = tonumber(vConfig.n_isWatchAd) or 0,
      feedOffset = Lib.createV3ByString(vConfig.s_feedOffset or ""),
      levelInfo = {}
    }
    settings[data.id] = data
  end
end

function PetConfig:init()
  readPetCSV()
end

function PetConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPetConfig, id:", id)
    return
  end
  return settings[id]
end

function PetConfig:getActorAndSkin(id)
  if not settings[id] then
    return
  end
  local actorName = settings[id].actorName
  return actorName
end

function PetConfig:getPetIcon(id)
  if not settings[id] then
    return ""
  end
  return settings[id].icon
end

function PetConfig:getAllCfg()
  return settings
end

function PetConfig:getAllAvailablePets(player, type)
  local petType = type or Define.PET_TYPE.None
  local pets = {}
  for id, v in pairs(settings) do
    if petType == Define.PET_TYPE.None or petType == v.type then
      pets[#pets + 1] = v
    end
  end
  table.sort(pets, function(a, b)
    if a.petSort < b.petSort then
      return true
    elseif a.petSort == b.petSort then
      return a.id < b.id
    end
    return false
  end)
  return pets
end

return PetConfig
