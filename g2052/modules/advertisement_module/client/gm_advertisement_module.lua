local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local AdvertisementScenePartConfig = T(Config, "AdvertisementScenePartConfig")
local AdvertisementScenePointConfig = T(Config, "AdvertisementScenePointConfig")
local carPart
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\232\189\189\229\133\183#\229\129\143\231\167\187"] = GM:inputStr(function(self, value)
  if not value or value == "" then
    return
  end
  local parse_list = Lib.splitString(value, "#", true)
  if not parse_list or #parse_list ~= 2 then
    return
  end
  local itemId = parse_list[1]
  local offsetY = parse_list[2]
  if carPart and carPart:isValid() then
    carPart:destroy()
  end
  local pos = Me:getPosition()
  local yaw = Me:getRotationYaw()
  pos.y = pos.y + offsetY
  carPart = AdvertisementModuleHelper:createSceneAdvertisementPart(Define.BUSINESS_ITEM_TYPE.Car, itemId, pos, yaw)
end)
local petPart
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\229\174\160\231\137\169#\229\129\143\231\167\187"] = GM:inputStr(function(self, value)
  if not value or value == "" then
    return
  end
  local parse_list = Lib.splitString(value, "#", true)
  if not parse_list or #parse_list ~= 2 then
    return
  end
  local itemId = parse_list[1]
  local offsetY = parse_list[2]
  if petPart and petPart:isValid() then
    petPart:destroy()
  end
  local pos = Me:getPosition()
  local yaw = Me:getRotationYaw()
  pos.y = pos.y + offsetY
  petPart = AdvertisementModuleHelper:createSceneAdvertisementPart(Define.BUSINESS_ITEM_TYPE.Pet, itemId, pos, yaw)
end)
local dressPart
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\232\163\133\230\137\174#\229\129\143\231\167\187"] = GM:inputStr(function(self, value)
  if not value or value == "" then
    return
  end
  local parse_list = Lib.splitString(value, "#", true)
  if not parse_list or #parse_list ~= 2 then
    return
  end
  local itemId = parse_list[1]
  local offsetY = parse_list[2]
  if dressPart and dressPart:isValid() then
    dressPart:destroy()
  end
  local pos = Me:getPosition()
  local yaw = Me:getRotationYaw()
  pos.y = pos.y + offsetY
  dressPart = AdvertisementModuleHelper:createSceneAdvertisementPart(Define.BUSINESS_ITEM_TYPE.Dress, itemId, pos, yaw)
end)
local btnPart
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\230\140\137\233\146\174\229\129\143\231\167\187"] = GM:inputNumber(function(self, offsetY)
  if offsetY == nil then
    return
  end
  if btnPart and btnPart:isValid() then
    btnPart:destroy()
  end
  local pos = Me:getPosition()
  pos.y = pos.y + offsetY
  btnPart = AdvertisementModuleHelper:createSceneAdvertisementButton(nil, pos)
end)
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\231\167\187\233\153\164\232\189\189\229\133\183"] = function()
  if carPart and carPart:isValid() then
    carPart:destroy()
  end
  carPart = nil
end
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\231\167\187\233\153\164\229\174\160\231\137\169"] = function()
  if petPart and petPart:isValid() then
    petPart:destroy()
  end
  petPart = nil
end
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\231\167\187\233\153\164\232\163\133\230\137\174"] = function()
  if dressPart and dressPart:isValid() then
    dressPart:destroy()
  end
  dressPart = nil
end
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\231\167\187\233\153\164\230\140\137\233\146\174"] = function()
  if btnPart and btnPart:isValid() then
    btnPart:destroy()
  end
  btnPart = nil
end
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\228\188\160\233\128\129point"] = GM:inputNumber(function(self, pointId)
  if not pointId then
    return
  end
  local scenePointCfg = AdvertisementScenePointConfig:getCfgById(pointId)
  if not scenePointCfg then
    return
  end
  local point = scenePointCfg.point
  Me:setPos(Lib.v3(point.x, point.y + 0.2, point.z))
  Me:setRotationYaw(scenePointCfg.yaw)
end)
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\230\137\147\229\141\176\229\157\144\230\160\135\230\151\139\232\189\172"] = function(self)
  if not Me then
    return
  end
  local pos = Me:getPosition()
  local yaw = Me:getRotationYaw()
  Lib.logInfo("player pos x:", pos.x, " y:", pos.y, " z:", pos.z, " yaw:", yaw)
end
GMItem["\229\185\191\229\145\138\230\168\161\231\187\132/\230\137\147\229\141\176\229\156\186\230\153\175\229\185\191\229\145\138"] = function(self)
  if not Me then
    return
  end
  AdvertisementModuleHelper:printSceneAdvertisementPart()
end
