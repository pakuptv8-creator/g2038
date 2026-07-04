local GenBuffFileHelper = T(Lib, "GenBuffFileHelper")
local PropsConfig = T(Config, "PropsConfig")
local Json = require("cjson")
require("lfs")

local function ClearFolder(directory)
  Lib.rmdir(directory)
end

local function GetDirectoryPath()
  local folderName = Define.Prop.GenBuffFileFolderName
  local directory = Root.Instance():getGamePath() .. "plugin/myplugin/buff/" .. folderName
  return directory
end

local function BuffTable2SortArr(t)
  local arr = {}
  for k, v in pairs(t) do
    local ts = {key = k, val = v}
    if type(v) == "table" then
      ts.val = BuffTable2SortArr(v)
    end
    table.insert(arr, ts)
  end
  table.sort(arr, function(a, b)
    return a.key > b.key
  end)
  return arr
end

local function BuildBuffTable(config, index)
  local t = {}
  t.skin = {}
  if config.skin then
    local skin = config.skin[index] or config.skin[1]
    for k, v in pairs(skin) do
      t.skin[k] = v
    end
  end
  if config.skill then
    local skill = config.skill[index]
    t.skill = skill
  end
  if config.sound then
    local sound = config.sound[index]
    t.soundEffect = sound
  end
  if config.actionMappings then
    local mapping = config.actionMappings[index]
    if mapping then
      t.propActionState = mapping
    end
  end
  t.actionPriority = Define.ActionMapPriority.propPriority
  local params
  if config.buffParams then
    params = config.buffParams[index]
  end
  return BuffTable2SortArr(t), params
end

local function CreateFolder(path)
  Lib.mkPath(path)
end

local function JsonEncode(arr, params)
  local str = ""
  str = str .. "{"
  local len = #arr
  for index, v in pairs(arr) do
    if type(v.key) == "string" then
      str = str .. "\"" .. v.key .. "\"" .. ":"
    end
    local typ = type(v.val)
    if typ == "number" then
      str = str .. tostring(v.val)
    elseif typ == "string" then
      str = str .. "\"" .. v.val .. "\""
    elseif typ == "table" then
      str = str .. JsonEncode(v.val)
    end
    if index ~= len then
      str = str .. ","
    elseif params ~= nil then
      str = str .. "," .. params
    end
  end
  str = str .. "}"
  return str
end

local function GenBuffFile(path, jsonTable, params)
  CreateFolder(path)
  local jsonStr = JsonEncode(jsonTable, params)
  local f = io.open(path .. "/setting.json", "w")
  if f then
    f:write(jsonStr)
  end
  f:close()
end

function GenBuffFileHelper:GenBuffFiles(force)
  if not force and World.cfg.openGenPropBuff == false then
    print("------------ World.cfg.openGenPropBuff == false")
    return
  end
  local directory = GetDirectoryPath()
  ClearFolder(directory)
  CreateFolder(directory)
  local propList = PropsConfig.getAllCfgs()
  for _, v in pairs(propList) do
    if v.buffNames and #v.buffNames > 0 then
      for index = 1, #v.buffNames do
        local folderName = v.buffNames[index]
        local jsonTable, params = BuildBuffTable(v, index)
        local folderPath = directory .. "/" .. folderName
        GenBuffFile(folderPath, jsonTable, params)
      end
    end
  end
end
