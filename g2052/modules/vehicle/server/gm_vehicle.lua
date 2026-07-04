local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\232\189\189\229\133\183/\230\183\187\229\138\160\228\184\128\232\190\134\230\177\189\232\189\166"] = function(self)
  local params = {
    cfgName = "myplugin/car_03",
    map = self.map,
    pos = Lib.v3(107, 40.1, 180)
  }
  EntityServer.Create(params)
end
GMItem["\232\189\189\229\133\183/\228\189\191\231\148\168\230\137\139\230\142\168\232\189\166"] = function(self)
  local pos = self:getFrontPos(-1, true, false)
  local params = {
    cfgName = "myplugin/trolley_01",
    map = self.map,
    pos = pos
  }
  EntityServer.Create(params)
end
GMItem["\232\189\189\229\133\183/\229\136\155\229\187\186\231\155\180\229\141\135\230\156\186"] = function(self)
  local pos = self:getFrontPos(5, true, false)
  local params = {
    cfgName = "myplugin/helicopter",
    map = self.map,
    pos = pos
  }
  EntityServer.Create(params)
end
GMItem["\232\189\189\229\133\183/\229\136\155\229\187\186\230\156\168\232\136\185"] = function(self)
  local pos = self:getFrontPos(5, true, false)
  pos.y = pos.y + 0.5
  local params = {
    cfgName = "myplugin/ship_boat",
    map = self.map,
    pos = pos
  }
  EntityServer.Create(params)
end
GMItem["\232\189\189\229\133\183/\229\136\155\229\187\186\230\149\145\231\148\159\232\136\185"] = function(self)
  local pos = self:getFrontPos(5, true, false)
  pos.y = pos.y + 0.5
  local params = {
    cfgName = "myplugin/ship_lifeboat",
    map = self.map,
    pos = pos
  }
  EntityServer.Create(params)
end
