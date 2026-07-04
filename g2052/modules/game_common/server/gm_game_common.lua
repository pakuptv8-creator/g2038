local setting = require("common.setting")
local PartCfg = setting:mod("part")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local part
GMItem["game_common/\228\184\128\228\184\170\229\189\169\232\155\1391"] = function(self)
  local cfg = {
    class = "RegionPart",
    properties = {
      cfgName = "myplugin/part_region",
      name = "house_area",
      needSync = "true",
      position = "x:150.71368408203 y:30.717704772949 z:-74.093826293945",
      rotation = "x:0 y:0 z:0",
      scale = "x:29.3196 y:9.3112 z:47.7183",
      selectable = "true"
    }
  }
  local scene = self:getScene()
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    inst:setParent(scene:getRoot())
    part = inst
  end
end
GMItem["game_common/\228\184\128\228\184\170\229\189\169\232\155\1392"] = function(self)
  if part then
    Plugins.CallTargetPluginFunc("part_manager", "destroyPart", part)
  end
end
GMItem["\229\156\176\229\155\190/server\230\159\165\232\175\162\233\155\182\228\187\182"] = GM:inputStr(function(self, value)
  local id = tonumber(value)
  local part = Instance.getByInstanceId(id)
  print("----part--server--", id, Lib.v2s(part))
end)
GMItem["ME/\230\137\147\229\188\128\229\156\176\229\155\190"] = GM:inputStr(function(self, val)
  local map = World.CurWorld:createDynamicMap(val, true)
  self:setMapPos(map, map.cfg.initPos)
end)
GMItem["game_common/\231\148\159\230\136\144\228\184\128\228\184\170\230\181\139\232\175\149\233\155\182\228\187\182"] = function(self)
  local instance = Instance.Create("Part")
  local pos = self:getPosition()
  pos.y = pos.y + 3
  instance:setPosition(pos)
  instance:setProperty("name", "testPart")
  instance:setProperty("useGravity", "false")
  instance:setProperty("materialColor", "r:0.4 g:0.68235294117647 b:1.0 a:1.0")
  instance:setProperty("useAnchor", "true")
  instance:setProperty("bloom", "true")
  local scene = self.map:getScene()
  instance:setParent(scene:getRoot())
end
GMItem["game_common/\230\150\135\229\173\151\232\180\180\232\138\177"] = function(self)
  print("ioooooooooooooooooo")
  local instance = Instance.Create("Part")
  local pos = self:getPosition()
  pos.y = pos.y + 3
  instance:setPosition(pos)
  instance:setProperty("name", "testPart")
  instance:setProperty("useGravity", "false")
  instance:setProperty("useAnchor", "true")
  for i = 1, 6 do
    local TextDecal = Instance.Create("TextDecal")
    TextDecal:setProperty("decalSurface", tostring(i - 1))
    TextDecal:setProperty("textDecalText", "TextDecal_" .. i)
    TextDecal:setParent(instance)
    TextDecal:setSize({x = 100, y = 100})
    TextDecal:setTextColor(Lib.getTextColor("FF00FF"))
    TextDecal:setFont("HT" .. 6 + i * 4)
    TextDecal:setHorzFormatting("CentreAligned")
    TextDecal:setVertFormatting("CentreAligned")
  end
  local scene = self.map:getScene()
  instance:setParent(scene:getRoot())
end
GMItem["game_common/\231\148\159\230\136\144\233\162\132\231\189\174Part"] = GM:inputStr(function(self, val)
  local partCfg = PartCfg:get("myplugin/" .. val)
  if partCfg then
    local pos = self:getPosition()
    pos.y = pos.y + 3
    local int = Instance.newInstance(partCfg, self.map)
    local scene = self.map:getScene()
    if int then
      int:setPosition(pos)
      int:setParent(scene:getRoot())
    end
  end
end)
GMItem["game_common/\231\179\187\231\187\159\230\182\136\230\129\175"] = GM:inputStr(function(self, val)
  self:sendMessageToSystem("g2052.gui.chat.system.login", val)
end)
GMItem["ME/\230\184\133\231\169\186\230\180\187\232\183\131\228\191\161\230\129\175"] = function(self)
  self:setValue("playerActive", {})
end
local i = true
GMItem["ME/\229\136\155\229\187\186\230\180\190\229\175\185\233\128\154\231\159\165"] = function(self)
  local type = {1, 2}
  self:sendPacket({
    pid = "syncNotifyParty",
    content = {
      userId = self.platformUserId,
      name = self.name,
      partyType = #type == 1 and type[1] or 0,
      isVip = i,
      partyId = "1"
    }
  })
  i = not i
end
