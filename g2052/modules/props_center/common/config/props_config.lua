local PropsConfig = T(Config, "PropsConfig")
local GenBuffFileHelper = T(Lib, "GenBuffFileHelper")
local settings = {}
local buffFilePR = "prop_buff_"

local function createBuff(id, actionGroupCount)
  local names = {}
  local buffs = {}
  local folderName = Define.Prop.GenBuffFileFolderName
  if not actionGroupCount then
    local name = buffFilePR .. id .. "_" .. 1
    table.insert(names, name)
    table.insert(buffs, "myplugin/" .. folderName .. "/" .. name)
    return names, buffs
  end
  for i = 1, actionGroupCount do
    local name = buffFilePR .. id .. "_" .. i
    table.insert(names, name)
    table.insert(buffs, "myplugin/" .. folderName .. "/" .. name)
  end
  return names, buffs
end

local function TryGenBuffs()
  if World.isClient then
    if not CGame.Instance():isDebuging() then
      return
    end
  else
    local roomGameConfig = Server.CurServer:getConfig()
    if not roomGameConfig then
      return
    end
    if not roomGameConfig:isDebug() then
      return
    end
  end
  GenBuffFileHelper:GenBuffFiles()
end

local function createSkills(string)
  local skills = Lib.splitString(string, "#")
  for i, v in pairs(skills) do
    if v == "nil" then
      skills[i] = nil
    end
  end
  return skills
end

function PropsConfig:tryGenBuffs()
  TryGenBuffs()
end

function PropsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/props.csv", 2)
  for _, vConfig in pairs(config) do
    local actionMappings, actionGroupCount
    if vConfig.s_action_map then
      actionMappings, actionGroupCount = self:parseAction(vConfig.s_action_map)
    end
    if vConfig.s_action_map1 and vConfig.s_action_map1 ~= "" and vConfig.s_action_map2 and vConfig.s_action_map3 then
      actionMappings, actionGroupCount = self:parseActions({
        vConfig.s_action_map1,
        vConfig.s_action_map2,
        vConfig.s_action_map3
      })
    end
    local id = tonumber(vConfig.n_id) or 0
    local buffNames, buffs = createBuff(id, actionGroupCount)
    local cfgName = Lib.splitString(vConfig.s_throwCfgName or "", "/")
    local throwCfgName = ""
    if cfgName[1] and cfgName[3] then
      throwCfgName = cfgName[1] .. "/" .. cfgName[3]
    end
    local data = {
      id = id,
      order = tonumber(vConfig.n_order) or 1,
      unlockType = tonumber(vConfig.n_unlock_type) or Define.Prop.UnlockType.Unlock,
      isVehicle = (tonumber(vConfig.n_isThrowObj) or 0) == 1,
      isThrowObj = tonumber(vConfig.n_isThrowObj) or 0,
      throwPos = Lib.splitString(vConfig.s_throwPos or "", "#", true),
      throwCfgName = throwCfgName,
      throwCfgType = cfgName[2] or "",
      throwMaxNum = tonumber(vConfig.n_throwMaxNum) or 0,
      throwTrigger = tonumber(vConfig.n_throwTrigger) or 0,
      throwActionIndex = tonumber(vConfig.n_throwActionIndex) or 1,
      icon = vConfig.s_icon or "",
      type = tonumber(vConfig.n_type) or 0,
      isNew = tonumber(vConfig.n_isNew) or 0,
      rideOnPlayerIndex = tonumber(vConfig.n_rideOnPlayerIndex) or 0,
      buffs = buffs,
      buffNames = buffNames,
      actionMappings = actionMappings,
      actionGroupCount = actionGroupCount,
      skin = self:parseSkin(vConfig.s_skin),
      skill = createSkills(vConfig.s_skill),
      canGive = tonumber(vConfig.n_can_give) == 1,
      sound = self:parseSound(vConfig.s_sound),
      dynamicPart = self:parseDynamicPart(vConfig.s_dynamic_part),
      buffParams = self:parseBuffParams(vConfig.s_buff_params),
      propParams = self:parsePropParams(vConfig.s_prop_params)
    }
    settings[data.id] = data
  end
  TryGenBuffs()
end

function PropsConfig:parseSound(str)
  if str == "" then
    return
  end
  local tbSoundData = {}
  local tbSound = Lib.split(str, "$")
  for k, sound in pairs(tbSound) do
    if sound ~= "" and sound ~= "none" then
      tbSoundData[k] = sound
    end
  end
  return tbSoundData
end

function PropsConfig:parseDynamicPart(str)
  if not str or str == "" then
    return nil
  end
  local result = {}
  local list = Lib.split(str, "#")
  for _, val in pairs(list) do
    local l = Lib.split(val, ".")
    local ls = Lib.split(l[2], ":")
    local id, part, res = l[1], ls[1], ls[2]
    if not (id and part) or not res then
      return nil
    end
    local basketId = tonumber(id)
    result[basketId] = {
      inUsePropId = basketId,
      part = {
        [part] = res
      }
    }
  end
  return result
end

function PropsConfig:parseBuffParams(str)
  if not str or str == "" then
    return nil
  end
  str = string.gsub(str, "\226\128\157", "\"")
  str = string.gsub(str, "\226\128\156", "\"")
  local ret = {}
  local l = Lib.split(str, "$")
  if #l == 0 then
    return nil
  end
  for _, s in pairs(l) do
    local ll = Lib.split(s, "#")
    ret[tonumber(ll[1])] = ll[2]
  end
  return ret
end

function PropsConfig:parsePropParams(str)
  if not str or str == "" then
    return nil
  end
  local ret = {}
  local l = Lib.split(str, "#")
  if #l == 0 then
    return nil
  end
  for _, s in pairs(l) do
    local ll = Lib.split(s, ":")
    ret[ll[1]] = ll[2]
  end
  return ret
end

function PropsConfig:parseAction(str)
  if str == "" then
    return
  end
  local l = Lib.split(str, "$")
  if #l == 0 then
    return
  end
  return self:parseActions(l)
end

function PropsConfig:parseActions(l)
  local ret = {}
  for _, s in pairs(l) do
    if s ~= "" then
      local ts = {}
      local ls = Lib.split(s, "#")
      for _, ss in pairs(ls) do
        local info = Lib.split(ss, ":")
        local sk = info[1]
        local sv = info[2]
        ts[sk] = sv
      end
      table.insert(ret, ts)
    end
  end
  return ret, #ret
end

function PropsConfig:parseSkin(str)
  if str == "" then
    return
  end
  local l = Lib.split(str, "$")
  if #l < 1 then
    return
  end
  local t = {}
  for _, s in pairs(l) do
    local st = {}
    local ll = Lib.split(s, "#")
    if 0 < #ll then
      for _, ss in pairs(ll) do
        local info = Lib.split(ss, ":")
        if 0 < #info then
          local part = info[1]
          local res = info[2]
          st[part] = res
        end
      end
    end
    table.insert(t, st)
  end
  return t
end

function PropsConfig:getCfgById(id)
  id = tonumber(id)
  if not settings[id] then
    Lib.logError("can not find cfgPropsConfig, id:", id)
    return
  end
  return Lib.copy(settings[id])
end

function PropsConfig:getCfgByThrowName(name)
  for _, v in pairs(settings) do
    if v.throwCfgName == name then
      return v
    end
  end
end

function PropsConfig:getAllCfgs()
  return settings
end

function PropsConfig:canPlaceToWorld(id)
  id = tonumber(id)
  if not settings[id] then
    return false
  end
  return settings[id].throwCfgName ~= "", settings[id].throwCfgName
end

function PropsConfig:updateIsNewStatusById(id)
  for i, v in pairs(settings) do
    if i == id then
      v.isNew = 0
      break
    end
  end
end

PropsConfig:init()
return PropsConfig
