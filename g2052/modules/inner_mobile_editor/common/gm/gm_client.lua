local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GM.setItemsShowPriorityMap("ME", 996)
local show_collision = false
GMItem["ME/\230\152\190\231\164\186\231\162\176\230\146\158\228\189\147"] = function()
  show_collision = not show_collision
  local debugDraw = DebugDraw.instance
  if show_collision and not debugDraw:isEnabled() then
    debugDraw:setEnabled(show_collision)
  end
  debugDraw:setDrawColliderEnabled(show_collision)
  debugDraw:setDrawAuraEnabled(show_collision)
  debugDraw:setDrawRegionEnabled(show_collision)
end
GMItem["ME/scene\229\173\152\230\161\1631"] = function(self)
  Lib.emitEvent(Event.EVENT_SAVE_MAP_CHANGE)
end
GMItem["ME/\233\154\144\232\151\143\232\167\146\232\137\178"] = function(self)
  local self = Me
  Me:setActorHide(true)
end
GMItem["ME/\230\152\190\231\164\186\232\167\146\232\137\178"] = function(self)
  local self = Me
  Me:setActorHide(false)
end
GMItem["ME/\230\152\190\231\164\186\229\174\158\230\151\182\233\152\180\229\189\177"] = function()
  Blockman.Instance().gameSettings:setEnableRealtimeShadow(0.0013)
end
GMItem["ME/\229\133\179\233\151\173\229\174\158\230\151\182\233\152\180\229\189\177"] = function()
  Blockman.Instance().gameSettings:setEnableRealtimeShadow(-0.0013)
end
GMItem["ME/\233\152\180\229\189\177bias +"] = function()
  local val = Blockman.Instance().gameSettings:getEnableRealtimeShadow()
  Lib.logDebug("+ getEnableRealtimeShadow val = ", val)
  val = val + 1.0E-5
  Blockman.Instance().gameSettings:setEnableRealtimeShadow(val)
end
GMItem["ME/\233\152\180\229\189\177bias -"] = function()
  local val = Blockman.Instance().gameSettings:getEnableRealtimeShadow()
  val = val - 1.0E-5
  Lib.logDebug("- getEnableRealtimeShadow val = ", val)
  Blockman.Instance().gameSettings:setEnableRealtimeShadow(val)
end
GMItem["ME/\230\181\139\232\175\1491"] = function(self)
  local manager = World.CurWorld:getSceneManager()
  local path = "map/test_land/setting.json"
  local obj = Lib.readGameJson(path)
  local scene = manager:getCurScene()
  local root = scene:getRoot()
  local count = root:getChildrenCount()
  Lib.logDebug("scene children count = ", count)
  local sceneTable = {}
  for i = 1, count do
    local child = root:getChildAt(i - 1)
    if child and child.name ~= "floor" then
      Lib.logDebug("child = ", child)
      local data = {}
      local className
      if child:isA("Part") then
        className = "Part"
      elseif child:isA("MeshPart") then
        className = "MeshPart"
      elseif child:isA("Model") then
        className = "Model"
      end
      if className then
        data.class = className
        local properties = {}
        child:getAllPropertiesAsTable(properties)
        data.properties = properties
        data.properties.id = child:getInstanceID() .. ""
        table.insert(sceneTable, data)
      end
    end
  end
  obj.scene = sceneTable
  Lib.saveGameJson(path, obj)
end
GMItem["ME/\230\181\139\232\175\149effect"] = function(self)
  local self = Me
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local pos = self:getFrontPos(1, true, true) + Lib.v3(0, 0, 5)
  local effect = EffectNode.Load("asset/effect/g2052_rain_big.effect")
  effect:start()
  effect:setWorldPosition(pos)
end
GMItem["ME/\230\181\139\232\175\149model"] = function(self)
  local self = Me
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  manager:setCurScene(scene)
  self.scene = scene
  local pos = self:getFrontPos(1, true, true) + Lib.v3(0, 0, 5)
  local part = Instance.Create("Model")
  part:setPosition(pos)
  part:setParent(scene:getRoot())
  local part1 = Instance.Create("Part")
  part1:setParent(part)
  part1:setPosition(pos)
  part1:setMaterialPath("part_zhuankuai.tga")
  part1:setShape(4)
  local part2 = Instance.Create("Part")
  part2:setParent(part)
  part2:setPosition(pos + Lib.v3(1, 1, 0))
  part2:setMaterialPath("part_zhuankuai.tga")
  part2:setShape(1)
end
GMItem["ME/\230\137\147\230\168\161\230\157\191"] = function(self)
  local gameRootPath = CGame.Instance():getGameRootDir()
  Lib.logDebug("gameRootPath = ", gameRootPath)
  local gameName = World.GameName
  Lib.logDebug("gameName = ", gameName)
  local gameType = "g2054"
  local inputPath = gameRootPath
  local outputPath = gameRootPath
  CGame.instance:onProcessGameFolderMobileEditor(inputPath, gameType, 0, outputPath)
end
GMItem["ME/\230\181\139\232\175\149model1"] = function(self)
end
GMItem["ME/\232\191\155\229\133\165\231\188\150\232\190\145\230\168\161\229\188\143"] = function()
  Plugins.CallTargetPluginFunc("inner_mobile_editor", "enterEditorMode", {
    blockId = "xuweiceshi",
    screenShot = {
      pos = {
        x = 0,
        y = 35,
        z = 0
      },
      yaw = 15,
      pitch = 0
    }
  })
end
GMItem["ME/\233\128\128\229\135\186\231\188\150\232\190\145\230\168\161\229\188\143"] = function()
  Plugins.CallTargetPluginFunc("inner_mobile_editor", "leaveEditorMode")
end
GMItem["ME/\229\142\139\231\188\169\229\156\176\229\155\190\230\150\135\228\187\182"] = GM:inputStr(function(self, val)
  local DataManager = T(MobileEditor, "DataManager")
  DataManager:instance():compressMapJson(val)
end)
return GMItem
