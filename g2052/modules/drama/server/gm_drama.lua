local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\229\137\167\230\156\172/\230\181\139\232\175\149\231\148\1681"] = function(self)
  DramaManager:giveALike(2, 24000)
end
GMItem["\229\137\167\230\156\172/\229\136\155\229\187\186\229\183\168\228\186\186\230\177\137\229\160\161"] = function(self)
  local setting = require("common.setting")
  local PartCfg = setting:mod("part")
  local cfgName = "myplugin/hanbao_giant"
  local partCfg = PartCfg:get(cfgName)
  if not partCfg then
    Lib.logError("--error-partCfg-:", cfgName)
    return
  end
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local inst = Instance.newInstance(partCfg, self.map)
  if not inst then
    return
  end
  inst:setParent(scene:getRoot())
  local pos = self:getFrontPos(2, true)
  inst:setPosition(pos)
end
