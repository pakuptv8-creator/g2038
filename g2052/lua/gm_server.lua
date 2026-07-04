local GMItem = GM:createGMItem()
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local HouseConfig = T(Config, "HouseConfig")
local CW = World.CurWorld
GMItem["template/server"] = function(self)
end
GMItem["HandItem/\229\141\160\228\189\141"] = function()
end
GMItem["\228\184\154\229\138\161\233\128\154\231\148\168/+N\229\133\131"] = GM:inputStr(function(self, value)
  self:addCurrency("gold", tonumber(value), "gm")
end)
GMItem["\228\184\154\229\138\161\233\128\154\231\148\168/+N\229\133\131"] = GM:inputStr(function(self, value)
  self:addCurrency("gold", tonumber(value), "gm")
end)
GMItem["\229\156\176\229\155\190/\232\183\179\232\189\172\229\156\176\229\155\190"] = GM:inputStr(function(self, value)
  local arr = Lib.splitString(value, ",")
  if #arr ~= 4 then
    return
  end
  local pos = {
    x = arr[2],
    y = arr[3],
    z = arr[4]
  }
  local map = arr[1]
  self:setMapPos(map, pos)
end)
GMItem["\229\156\176\229\155\190/\229\155\158\229\136\157\229\167\139\229\156\176\229\155\190"] = function(self)
  self:setMapPos(World.cfg.defaultMap or "map001", World.cfg.initPos)
end
GMItem["\229\156\176\229\155\190/\229\137\141\229\190\128\230\176\180"] = function(self)
  self:setMapPos("map001", {
    x = 66,
    y = 1.75,
    z = 131
  })
end

local function createLockPart(self, initMesh, initPos)
  local propertyList = {
    mesh = initMesh,
    restitution = "0.3",
    useAnchor = "true",
    useGravity = "false"
  }
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local part = Instance.Create("MeshPart")
  for k, v in pairs(propertyList or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  local pos = Lib.copy(initPos) or self:getPosition()
  pos.y = pos.y + 3
  part:setPosition(pos)
  return part
end

GMItem["\229\156\176\229\155\190/\233\155\182\228\187\182\233\135\141\229\164\141\229\136\135\230\141\162mesh"] = GM:inputStr(function(self, value)
  local initMesh = "asset/house/mesh/2052_lock01.mesh"
  local curMesh = "asset/house/mesh/2052_lock02.mesh"
  local part = createLockPart(self, initMesh)
  local time = tonumber(value) or 1
  World.Timer(time, function()
    if not part or not part:isValid() then
      return
    end
    if part:getProperty("mesh") == initMesh then
      part:setProperty("mesh", curMesh)
    else
      part:setProperty("mesh", initMesh)
    end
    return true
  end)
end)
GMItem["\229\156\176\229\155\190/\229\136\135\230\141\162mesh\229\185\182\229\136\160\233\153\164"] = GM:inputStr(function(self, value)
  local time = tonumber(value) or 1
  local initPos = self:getPosition()
  World.Timer(time, function()
    if not self or not self:isValid() then
      return
    end
    local part = createLockPart(self, "asset/house/mesh/2052_lock01.mesh", initPos)
    part:setProperty("mesh", "asset/house/mesh/2052_lock02.mesh")
    print("--part--1-")
    World.Timer(time, function()
      if part and part:isValid() then
        print("--part--2-")
        part:destroy()
      end
    end)
    return true
  end)
end)
GMItem["\229\156\176\229\155\190/\229\136\155\229\187\186part"] = function(self)
  local propertyList = {density = 0.1, restitution = 1.0}
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local part = Instance.Create("Part")
  part:setSize(Lib.v3(1, 1, 1))
  part:setShape(1)
  for k, v in pairs(propertyList or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  part:setPosition(self:getPosition())
end
GMItem["\229\156\176\229\155\190/part2222"] = function(self)
  print("--PartCfg--", Lib.v2s(PartCfg))
  local cfg = PartCfg:get("myplugin/land_area")
  print("---cfg--", Lib.v2s(cfg))
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  cfg.scene = scene
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    inst:setParent(scene:getRoot())
  end
  inst:setPosition(self:getPosition())
end
GMItem["\229\156\176\229\155\190/part2333"] = function(self)
  if self.part233Timer then
    return
  end
  print("--PartCfg--", Lib.v2s(PartCfg))
  local cfg = PartCfg:get("myplugin/text_pc")
  print("---cfg--", Lib.v2s(cfg))
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  cfg.scene = scene
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    inst:setParent(scene:getRoot())
  end
  local nodes = {}
  Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
  local curPos = inst:getPosition()
  local targetPos = self:getPosition()
  scene.move(nodes, {
    x = targetPos.x - curPos.x,
    y = targetPos.y - curPos.y,
    z = targetPos.z - curPos.z
  }, true)
  print("--node--", Lib.v2s(inst))
  local count = inst:getChildrenCount()
  local decal
  for i = 0, count - 1 do
    local n = inst:getChildAt(i)
    if n and n.name == "Decal" then
      decal = n
    end
  end
  if decal then
    local img = {
      "asset/scene/2052_tiehua01.png",
      "asset/scene/2052_tiehua02.png",
      "asset/scene/2052_tiehua03.png",
      "asset/scene/2052_tiehua04.png",
      "asset/scene/2052_tiehua05.png"
    }
    local i = 1
    self.part233Timer = World.Timer(20, function()
      if not img[i] then
        i = 1
      end
      decal:setTexture(img[i])
      i = i + 1
      return true
    end)
  end
end
GMItem["\229\156\176\229\155\190/\232\132\154\228\184\139\229\136\155\229\187\186entity"] = GM:inputStr(function(self, value)
  local params = {
    cfgName = value,
    map = self.map,
    pos = self:getPosition()
  }
  EntityServer.Create(params)
end)
GMItem["\229\156\176\229\155\190/\229\136\155\229\187\186\230\137\128\230\156\137\230\136\191\229\177\139"] = function(self)
  if self.ddsdsdsa then
    return
  end
  self.ddsdsdsa = true
  local pos = Lib.v3(-97, 108, -66)
  self:setMapPos("map001", pos)
  
  local function createPartHelper(cfg, scene, map, targetRotation, targetPos, houseId)
    local templateInstanceId = houseId * 10000
    local inst = Instance.newInstance(cfg, map)
    if inst then
      local nodes = {}
      Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
      if targetRotation then
        scene.rotate(nodes, targetRotation)
      end
      if targetPos then
        scene.move(nodes, targetPos, true)
      end
      inst:setParent(scene:getRoot())
    else
      return
    end
    return inst
  end
  
  local houseInfo = HouseConfig:getAllCfgs()
  local index = 0
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  for _, v in pairs(houseInfo) do
    for _, val in pairs(v) do
      local houseCfg = PartCfg:get(val.cfgName or "")
      pos.x = pos.x + 60
      if houseCfg then
        createPartHelper(houseCfg, scene, self.map, nil, pos, val.id)
      end
      index = index + 1
    end
  end
end
GMItem["\229\156\176\229\155\190/\231\155\180\229\141\135\230\156\186\230\148\185\228\189\141\231\189\174"] = function(self)
  local setting = require("common.setting")
  local PartCfg = setting:mod("part")
  local CW = World.CurWorld
  local cfg = PartCfg:get("myplugin/che")
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  cfg.scene = scene
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    inst:setParent(scene:getRoot())
  end
  local nodes = {}
  Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
  scene.rotate(nodes, {
    x = 0,
    y = 0,
    z = 0
  })
  local targetPos = self:getPosition()
  scene.move(nodes, targetPos, true)
end
GMItem["\229\156\176\229\155\190/\229\136\155\229\187\186\232\173\166\232\189\166"] = function(self)
  local setting = require("common.setting")
  local PartCfg = setting:mod("part")
  local CW = World.CurWorld
  local cfg = PartCfg:get("myplugin/qiuche")
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  cfg.scene = scene
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    inst:setParent(scene:getRoot())
  end
  local nodes = {}
  Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
  scene.rotate(nodes, {
    x = 0,
    y = 0,
    z = 0
  })
  local targetPos = self:getFrontPos(5, false, true) + Lib.v3(0, 3, 0)
  scene.move(nodes, targetPos, true)
end
GMItem["\229\156\176\229\155\190/\232\173\166\232\189\166"] = function(self)
  local setting = require("common.setting")
  local PartCfg = setting:mod("part")
  local CW = World.CurWorld
  local cfg = PartCfg:get("myplugin/jingche")
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  cfg.scene = scene
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    local nodes = {}
    Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
    scene.rotate(nodes, {
      x = 0,
      y = 0,
      z = 0
    })
    local targetPos = self:getFrontPos(5, false, true) + Lib.v3(0, 1, 0)
    scene.move(nodes, targetPos, true)
    inst:setParent(scene:getRoot())
  end
end

local function createPart(position, shapeType, sizeScale, propertyList, player)
  local part
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(player.map.obj)
  local part = Instance.Create("Part")
  part:setSize(sizeScale)
  part:setShape(shapeType)
  for k, v in pairs(propertyList or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  part:setPosition(position)
  return part
end

GMItem["\229\156\176\229\155\190/\230\182\136\233\152\178\232\189\166"] = function(self)
  local setting = require("common.setting")
  local PartCfg = setting:mod("part")
  local CW = World.CurWorld
  local cfg = PartCfg:get("myplugin/che")
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  cfg.scene = scene
  local inst = Instance.newInstance(cfg, self.map)
  if inst then
    inst:setParent(scene:getRoot())
  end
  local nodes = {}
  Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
  scene.rotate(nodes, {
    x = 0,
    y = 0,
    z = 0
  })
  local targetPos = self:getPosition()
  scene.move(nodes, targetPos, true)
end

local function Sleep(n)
  if 0 < n then
    os.execute("ping -n " .. tonumber(n + 1) .. " localhost > NUL")
  end
end

local fpsTimer
local creat_house = false
GMItem["g2052\229\183\165\229\133\183/\229\156\176\229\157\151\229\136\155\229\187\186\230\136\191\229\177\139"] = function(self)
  if creat_house then
    return
  end
  creat_house = true
  local LuaTimer = T(Lib, "LuaTimer")
  local houseInfo = HouseConfig:getAllCfgs()
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  table.sort(houseInfo, function(a, b)
    return a.id < b.id
  end)
  local pos_list = {}
  local rotate_list = {}
  
  local function createPartHelper(cfg, scene, map, targetRotation, targetPos, houseId)
    local templateInstanceId = houseId * 10000
    local inst = Instance.newInstance(cfg, map)
    if inst then
      local nodes = {}
      Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
      if targetRotation then
        scene.rotate(nodes, targetRotation)
      end
      if targetPos then
        scene.move(nodes, targetPos, true)
      end
      inst:setParent(scene:getRoot())
    else
      return
    end
    return inst
  end
  
  local function foreachNode(node)
    local scriptName = node:getScriptName()
    if node.name == "ground_01" then
      table.insert(pos_list, node:getPosition())
      table.insert(rotate_list, node.rotation)
    end
    if node.name == "build01" or node.name == "build" then
      local pos = Lib.v3(-97, -108, -66)
      node:setPosition(pos)
    end
    for k, v in pairs(node:getAllChild()) do
      foreachNode(v)
    end
  end
  
  local sceneManager = World.CurWorld:getSceneManager()
  for index, scene in ipairs(sceneManager:getAllScene()) do
    foreachNode(scene:getRoot())
  end
  fpsTimer = LuaTimer:schedule(function()
    local num = math.random(4)
    if num == 1 then
      pos_list[1].y = pos_list[1].y + 5
    elseif num == 2 then
      pos_list[1].y = pos_list[1].y + 7
    elseif num == 3 then
      pos_list[1].y = pos_list[1].y + 8
    end
    local houseCfg = PartCfg:get(houseInfo[num].cfgName or "")
    if houseCfg then
      if num == 3 then
        rotate_list[1].y = -rotate_list[1].y
      end
      createPartHelper(houseCfg, scene, self.map, rotate_list[1], pos_list[1], houseInfo[num].id)
    end
    table.remove(pos_list, 1)
    table.remove(rotate_list, 1)
    if #pos_list < 1 then
      print("end")
      LuaTimer:cancel(fpsTimer)
    end
  end, 0, 5000)
end
local playernum = 1
local CreateTimer
local propinit_flag = true
local prop_list = {}
GMItem["g2052\229\183\165\229\133\183/\230\156\141\229\138\161\229\153\168\229\136\155\229\187\186npc"] = GM:inputStr(function(self, value)
  if propinit_flag then
    local path = Root.Instance():getGamePath():gsub("\\", "/") .. "config/props.csv"
    local file = io.open(path, "r")
    if file then
      local line = file:read()
      line = file:read()
      line = file:read()
      while line do
        local prop = Lib.splitString(line, "\t")
        local propName, name
        if 8 <= #prop then
          if prop[5] == "1" then
            propName = Lib.splitString(prop[8], ":")
            table.insert(prop_list, propName[2])
          else
            propName = Lib.splitString(prop[7], ":")
            table.insert(prop_list, propName[2])
          end
        end
        line = file:read()
      end
    end
    file:close()
    propinit_flag = false
  end
  value = tonumber(value)
  local LuaTimer = T(Lib, "LuaTimer")
  local pet_list = {
    "g2052_pet_1.actor",
    "g2052_pet_2.actor",
    "g2052_pet_3.actor",
    "g2052_pet_4.actor",
    "g2052_baby_01.actor",
    "g2052_baby_02.actor",
    "g2052_baby_03.actor",
    "g2052_baby_04.actor",
    "g2052_baby_05.actor",
    "g2052_baby_06.actor"
  }
  local posList = {}
  local pos1 = Lib.v3(68.792549, 26.051031, -165.385223)
  local pos2 = Lib.v3(146.104843, 25.99851, -166.609787)
  local pos3 = Lib.v3(66.477791, 26.049648, -18.900978)
  local pos4 = Lib.v3(148.003586, 26.701738, -13.211572)
  local birthpos = Lib.v3(105.668861, 26.07543, -108.712448)
  table.insert(posList, pos1)
  table.insert(posList, pos2)
  table.insert(posList, pos3)
  table.insert(posList, pos4)
  local num = 1
  CreateTimer = LuaTimer:schedule(function()
    if num >= value then
      LuaTimer:cancel(CreateTimer)
    end
    num = num + 1
    local player = EntityServer.Create({
      cfgName = "myplugin/player1",
      map = self.map,
      pos = birthpos,
      ry = 90,
      rp = 0,
      name = "player" .. playernum
    })
    
    function Player:getActorNameBySex(sex)
      if sex == 2 then
        return "g2052_girl.actor"
      else
        return "g2052_boy.actor"
      end
    end
    
    local sexnum = math.random(2)
    player:changeActor(self:getActorNameBySex(sexnum))
    local petPos = Lib.v3(player:getPosition().x + 2, player:getPosition().y, player:getPosition().z)
    local pet = EntityServer.Create({
      cfgName = "myplugin/pet_06",
      map = player.map,
      pos = petPos,
      name = "pet" .. playernum
    })
    local petnum = math.random(#pet_list)
    pet:changeActor(pet_list[petnum])
    local localNum = math.random(#posList)
    player:enableAIControl(true)
    player:startAI()
    local playerAI = player:getAIControl()
    local NPCTimer = LuaTimer:schedule(function()
      local changeSkinData = {
        clothes_tops = math.random(5),
        custom_bag = math.random(5),
        custom_hair = math.random(5),
        custom_hat = math.random(5),
        custom_shoes = math.random(5),
        clothes_pants = math.random(5),
        gun = prop_list[math.random(#prop_list)]
      }
      local scaleNum = math.random(7, 11) / 10
      player:setShapeScale(scaleNum)
      player:changeSkin(changeSkinData)
      local NPCTargetNum = math.random(#posList)
      if NPCTargetNum == localNum then
        NPCTargetNum = math.random(#posList)
      end
      localNum = NPCTargetNum
      playerAI:setTargetPos(posList[NPCTargetNum], true)
    end, 1000, 10000)
    pet:enableAIControl(true)
    pet:startAI()
    local petAI = pet:getAIControl()
    local petTargetPos = pet:getPosition()
    local PetTimer = LuaTimer:schedule(function()
      petAI:setTargetPos(petTargetPos, true)
      petTargetPos = player:getPosition()
    end, 2000, 500)
    playernum = playernum + 1
  end, 1000, 2000)
end)
local meshTimer
GMItem["g2052\229\183\165\229\133\183/\230\163\128\230\159\165mesh\229\146\140effect"] = function(self)
  local list = {}
  local LuaTimer = T(Lib, "LuaTimer")
  local partMesh_list = {}
  local partEffect_list = {}
  local path = Root.Instance():getGamePath():gsub("\\", "/") .. "plugin/myplugin/part"
  for entry in lfs.dir(path) do
    table.insert(list, entry)
  end
  table.remove(list, 1)
  table.remove(list, 1)
  for k, v in pairs(list) do
    local filePath = Root.Instance():getGamePath():gsub("\\", "/") .. "plugin/myplugin/part/" .. v .. "/setting.json"
    local file = io.open(filePath, "r")
    if file then
      local line = file:read()
      while line do
        local fileName = Lib.splitString(line, "\"")
        for k, v in pairs(fileName) do
          if v == "mesh" then
            table.insert(partMesh_list, fileName[k + 2])
          end
          if v == "effectFilePath" then
            table.insert(partEffect_list, fileName[k + 2])
          end
        end
        line = file:read()
      end
    end
    file:close()
  end
  
  local function readFile(path, fileList, type)
    for entry in lfs.dir(path) do
      if entry ~= "." and entry ~= ".." then
        readFile(path .. "/" .. entry, fileList, type)
      end
      local fileName = Lib.splitString(entry, ".")
      if 2 <= #fileName and fileName[#fileName] == type then
        table.insert(fileList, entry)
      end
    end
  end
  
  local assetMesh_list = {}
  local meshPath = Root.Instance():getGamePath():gsub("\\", "/") .. "asset"
  readFile(meshPath, assetMesh_list, "mesh")
  local assetEffect_list = {}
  local effectPath = Root.Instance():getGamePath():gsub("\\", "/") .. "asset/effect"
  readFile(effectPath, assetEffect_list, "effect")
  for k, v in pairs(partMesh_list) do
    local s = Lib.splitString(v, "/")
    local meshName = s[#s]
    for kk, vv in pairs(assetMesh_list) do
      if meshName == vv then
        break
      end
      if kk == #assetMesh_list and meshName ~= "," then
        Lib.logError("Missing file:" .. meshName)
      end
    end
  end
  for k, v in pairs(partEffect_list) do
    local s = Lib.splitString(v, "/")
    local effectName = s[#s]
    for kk, vv in pairs(assetEffect_list) do
      if effectName == vv then
        break
      end
      if kk == #assetEffect_list and effectName ~= "," then
        Lib.logError("Missing file:" .. effectName)
      end
    end
  end
end
return GMItem
