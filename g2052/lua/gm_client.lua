local GMItem = GM:createGMItem()
GM.setItemsShowPriorityMap("g2052", 998)
GM.setItemsShowPriorityMap("g2052\229\183\165\229\133\183", 999)
GMItem["template/client"] = function(self)
end
local isOpenFly = false
GMItem["template/\233\163\158\232\161\140"] = function(self)
  isOpenFly = not isOpenFly
  self:setFlyMode(isOpenFly and 1 or 0)
end
GMItem["template/\229\133\179\233\151\173\233\129\174\231\189\169"] = function(self)
  UI:getWnd("gameMain").lytDarknessBg:SetVisible(false)
end
GMItem["template/\230\181\139\232\175\149"] = function(self)
end
GMItem["template/BGM"] = function(self)
  Skill.Cast("myplugin/skill_shotgun_reload")
end

local function createPart(position, shapeType, sizeScale, propertyList)
  local part
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(Me.map.obj)
  manager:setCurScene(scene)
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

GMItem["template/\233\155\182\228\187\182\232\189\189\229\133\183"] = function(self)
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(Player.CurPlayer.map.obj)
  local effectNode = EffectNode.Load("g2052_smoke.effect")
  effectNode:start()
  effectNode:setLocalPosition(Me:getPosition())
  effectNode:setWorldScale(Lib.v3(5, 5, 5))
  Me:addChild(effectNode)
end
local show_anchor = true
local idinit_flag = true
local materialAlpha_list = {}
GMItem["g2052\229\183\165\229\133\183/\230\152\190\231\164\186\230\156\170\233\148\154\229\174\154"] = function()
  local t = 1
  show_anchor = not show_anchor
  
  local function foreachNode(node)
    local scriptName = node:getScriptName()
    if scriptName == "Part" or scriptName == "MeshPart" then
      if idinit_flag then
        table.insert(materialAlpha_list, node.materialAlpha)
      end
      if not show_anchor then
        node.materialAlpha = node.useAnchor == false and 1 or 0
      else
        node.materialAlpha = materialAlpha_list[t]
        t = t + 1
      end
    end
    for k, v in pairs(node:getAllChild()) do
      foreachNode(v)
    end
  end
  
  local sceneManager = World.CurWorld:getSceneManager()
  for index, scene in ipairs(sceneManager:getAllScene()) do
    foreachNode(scene:getRoot())
  end
  idinit_flag = false
end
local init_flag = true
GMItem["g2052\229\183\165\229\133\183/\230\152\190\231\164\186\232\167\166\229\143\145\228\189\147"] = function()
  local debugDraw = DebugDraw.instance
  if init_flag then
    if not debugDraw:isEnabled() then
      debugDraw:setEnabled(true)
    end
    local trigger_list = {}
    local path = Root.Instance():getGamePath():gsub("\\", "/") .. "config/interact_events.csv"
    local file = io.open(path, "r")
    if file then
      local line = file:read()
      while line do
        local id = Lib.splitString(line, "\t")
        table.insert(trigger_list, id[1])
        line = file:read()
      end
    end
    file:close()
    debugDraw.addEntry("SwitchName", function()
      local self = Me
      local position = self:getEyePos()
      local scale = Vector3.new(15, 15, 15)
      local minPoint = position - scale
      local maxPoint = position + scale
      local touchParts = self.map:getTouchParts(minPoint, maxPoint)
      for i = 1, #touchParts do
        local partname = touchParts[i].name
        for j = 1, #trigger_list do
          if partname == trigger_list[j] then
            local AABB = touchParts[i]:getWorldAABB()
            local min = AABB[2]
            local max = AABB[3]
            debugDraw:drawAABB(min, max, 4278190335)
            break
          end
        end
      end
    end)
    debugDraw:setSwitchNameEnabled(false)
    init_flag = false
  end
  debugDraw:setSwitchNameEnabled(not debugDraw:isSwitchNameEnabled())
end

local function getFrameInfo()
  local function addPath(dict, value)
    if value == nil then
      return
    end
    local num = dict[value]
    if num == nil then
      dict[value] = 1
    else
      dict[value] = num + 1
    end
  end
  
  local state = Root.Instance():frameState()
  local ret = {
    position = Me:getPosition(),
    curFps = Root.Instance():getFPS(),
    drawCalls = state:getDrawCalls(),
    vertexNum = state:getVertexNum(),
    triangleNum = state:getTriangleNum(),
    jank = PerformanceStatistics.GetJankCount(),
    nodeCount = 0,
    meshs = {},
    effects = {},
    PartClient = 0,
    RegionPartClient = 0,
    ModelClient = 0,
    EffectPartClient = 0,
    MeshPartClient = 0
  }
  local sceneManager = World.CurWorld:getSceneManager()
  for _, scene in pairs(sceneManager:getAllScene()) do
    local nodes = scene:getRenderablesInScreenArea(0, 0, 1, 1, false, true)
    ret.nodeCount = ret.nodeCount + #nodes
    for _, node in pairs(nodes) do
      local className = node.className
      if className == "PartClient" then
        ret.PartClient = ret.PartClient + 1
      elseif className == "RegionPartClient" then
        ret.RegionPartClient = ret.RegionPartClient + 1
      elseif className == "ModelClient" then
        ret.ModelClient = ret.ModelClient + 1
      elseif className == "EffectPartClient" then
        ret.EffectPartClient = ret.EffectPartClient + 1
        addPath(ret.effects, node.effectFilePath)
      elseif className == "MeshPartClient" then
        ret.MeshPartClient = ret.MeshPartClient + 1
        addPath(ret.meshs, node.mesh)
      end
    end
  end
  return ret
end

GMItem["g2052\229\183\165\229\133\183/\229\184\167\228\191\161\230\129\175"] = function()
  local fileName = Root.Instance():getWriteablePath():gsub("\\", "/") .. World.GameName .. "DebugInfo.json"
  
  local function writeToFile(info)
    local cjson = require("cjson")
    local file = io.open(fileName, "a+")
    io.output(file)
    local text = cjson.encode(info)
    text = string.gsub(text, "\\/", "/")
    io.write(text .. ",")
    io.close()
  end
  
  writeToFile(getFrameInfo())
end
local debugTimer, fpsTimer
GMItem["g2052\229\183\165\229\133\183/\230\148\182\233\155\134\229\156\186\230\153\175\228\191\161\230\129\175"] = function()
  local LuaTimer = T(Lib, "LuaTimer")
  local fileName = Root.Instance():getWriteablePath():gsub("\\", "/") .. World.GameName .. "DebugInfo.json"
  
  local function entityInput(state)
    Me:setActorHide(state)
    Blockman.Instance():control().enable = not state
    Blockman.Instance().gameSettings:setLockSlideScreen(state)
  end
  
  local function moveTo(transform)
    Me:setPos(transform.pos)
    Blockman.Instance():changeCameraView({
      x = 0,
      y = 0,
      z = 0
    }, transform.yaw, transform.pitch, 5, 0)
    print("goto:" .. transform.pos.x .. "," .. transform.pos.y .. "," .. transform.pos.z, "yaw:" .. transform.yaw)
  end
  
  local function closeTimer()
    if fpsTimer or debugTimer then
      LuaTimer:cancel(fpsTimer)
      LuaTimer:cancel(debugTimer)
      fpsTimer = nil
      debugTimer = nil
    end
  end
  
  local function analyse(array)
    local ret = {
      min = array[1],
      max = array[1],
      average = 0
    }
    for _, v in pairs(array) do
      ret.min = math.min(v, ret.min)
      ret.max = math.max(v, ret.max)
      ret.average = ret.average + v
    end
    if ret.average == 0 or #array == 0 then
      ret.average = 0
    else
      ret.average = ret.average / #array
    end
    return ret
  end
  
  local function getTransforms(width, height)
    local tmp = {
      xCount = width / 20,
      y = 30,
      zCount = height / 20,
      xOffset = width / 2,
      zOffset = height / 2
    }
    local ret = {}
    for x = 1, tmp.xCount do
      for z = 1, tmp.zCount do
        local pos = Lib.v3(x * 20 - tmp.xOffset, tmp.y, z * 20 - tmp.zOffset)
        table.insert(ret, {
          pos = pos,
          yaw = 0,
          pitch = 0
        })
        table.insert(ret, {
          pos = pos,
          yaw = 90,
          pitch = 0
        })
        table.insert(ret, {
          pos = pos,
          yaw = -90,
          pitch = 0
        })
        table.insert(ret, {
          pos = pos,
          yaw = 180,
          pitch = 0
        })
      end
    end
    return ret
  end
  
  local function writeToFile(info)
    local cjson = require("cjson")
    local file = io.open(fileName, "a+")
    io.output(file)
    print("average:", info.average)
    local text = cjson.encode(info)
    text = string.gsub(text, "\\/", "/")
    io.write(text .. ",")
    io.close()
    if not Lib.fileExists(fileName) then
      closeTimer()
      entityInput(false)
      print("write fail:" .. fileName)
    end
  end
  
  local transforms = getTransforms(500, 500)
  if #transforms == 0 then
    return
  end
  closeTimer()
  Lib.emitEvent(Event.EVENT_CLOSE_GMBOARD)
  entityInput(true)
  moveTo(transforms[1])
  if Lib.fileExists(fileName) then
    os.remove(fileName)
  end
  local fpsArray = {}
  fpsTimer = LuaTimer:schedule(function()
    table.insert(fpsArray, Root.Instance():getFPS())
  end, 0, 100)
  local infos = {}
  local timeCount = 0
  debugTimer = LuaTimer:schedule(function()
    timeCount = timeCount + 1
    local info = {}
    local _fps = analyse(fpsArray)
    info.fpsMin = _fps.min
    info.fpsMax = _fps.max
    info.averagefps = _fps.average
    if 60 <= timeCount then
      info["60-jank"] = math.floor(PerformanceStatistics.GetJankCount() or 0)
      timeCount = 0
    end
    for k, v in pairs(getFrameInfo()) do
      info[k] = v
    end
    writeToFile(info)
    table.insert(infos, info)
    table.remove(transforms, 1)
    if #transforms == 0 then
      closeTimer()
      entityInput(false)
    else
      moveTo(transforms[1])
      fpsArray = {}
    end
  end, 1000, 2500)
end
require("lfs")
local effectinit_flag = true
local effect_list = {}
local EffectTimer
local showEffect_flag = false
GMItem["g2052\229\183\165\229\133\183/\230\181\139\232\175\149\231\137\185\230\149\136"] = function(self)
  showEffect_flag = not showEffect_flag
  local LuaTimer = T(Lib, "LuaTimer")
  if not showEffect_flag then
    LuaTimer:cancel(EffectTimer)
    return
  end
  if effectinit_flag then
    local path = Root.Instance():getGamePath():gsub("\\", "/") .. "asset/effect"
    for entry in lfs.dir(path) do
      local type = Lib.splitString(entry, "_")
      if 1 < #type then
        table.insert(effect_list, entry)
      end
    end
    effectinit_flag = false
  end
  local manager = World.CurWorld:getSceneManager()
  EffectTimer = LuaTimer:schedule(function()
    local x = math.random(-10, 10)
    local z = math.random(-10, 10)
    local pos = self:getPosition() + Lib.v3(x, 0, z)
    local effect = EffectNode.Load("asset/effect/" .. effect_list[math.random(#effect_list)])
    effect:start()
    effect:setWorldPosition(pos)
  end, 0, 1000)
end
local actionTimer
GMItem["g2052\229\183\165\229\133\183/\230\181\139\232\175\149\229\138\168\228\189\156"] = function(self)
  local action_list = {}
  local path = Root.Instance():getGamePath():gsub("\\", "/") .. "config/dance.csv"
  local file = io.open(path, "r")
  if file then
    local line = file:read()
    file:read()
    file:read()
    file:read()
    while line do
      local list = Lib.splitString(line, "\t")
      local action = list[3]
      table.insert(action_list, action)
      line = file:read()
    end
  end
  file:close()
  local LuaTimer = T(Lib, "LuaTimer")
  local num = 1
  actionTimer = LuaTimer:schedule(function()
    self:updateUpperAction(action_list[num], -1)
    num = num + 1
    if num > #action_list then
      LuaTimer:cancel(actionTimer)
    end
  end, 0, 2000)
end
GMItem["g2052\229\183\165\229\133\183/\229\136\135\230\141\162\232\183\159\233\154\143\233\149\156\229\164\180"] = function()
  local VehicleVirtualCamera = T(Lib, "VehicleVirtualCamera")
  local Cinemachine = T(Lib, "LuaCinemachine")
  if not Me.rideOnInstanceId then
    return
  end
  local vehicleInst = Instance.getByInstanceId(Me.rideOnInstanceId)
  local camera = CameraManager.Instance():getMainCamera()
  local pos_camera = camera:getPosition()
  local pos_vehicle = vehicleInst:getPosition()
  local rot_vehicle = vehicleInst:getWorldQuaternion()
  local virtual_cam = Cinemachine:getCamera("vehicleSideFollow")
  if virtual_cam then
    virtual_cam:setBody({
      type = "HardLockToTarget",
      localspace = true,
      offset = rot_vehicle:conjugated() * (pos_camera - pos_vehicle),
      damping = 0
    })
  end
  VehicleVirtualCamera:changeCameraType("vehicleSideFollow", 0, "vehicleDrag")
end
local mesh_info_loaded = false
local mesh_list = {}
local mesh_info_dic = {}
local max_vert_count = -1

local function getMeshInfoPath()
  return Root.Instance():getGamePath():gsub("\\", "/") .. "../tools/projectNeaten/g2052/mesh_info.csv"
end

local function loadMeshInfo()
  mesh_list = {}
  local path = getMeshInfoPath()
  local file = io.open(path, "r")
  if file then
    file:read()
    local line = file:read()
    while line do
      local mesh = Lib.splitString(line, "\t")
      mesh_list[mesh[12]] = {
        vert_count = tonumber(mesh[5]),
        mem_size = tonumber(mesh[1])
      }
      if mesh_list[mesh[12]].vert_count > max_vert_count then
        max_vert_count = mesh_list[mesh[12]].vert_count
      end
      line = file:read()
    end
    file:close()
    mesh_info_loaded = true
  end
end

local function CreateMeshInfo()
  if PlatformUtil.isPlatformWindows() then
    local file, err = io.open(getMeshInfoPath())
    if file == nil then
      Lib.logInfo("Mesh info file not found. Generating mesh info, please wait...")
      Lib.logInfo("This may take a while.")
      local proj_tool_path = Root.Instance():getGamePath():gsub("\\", "/") .. "../tools/projectNeaten/Tool/projectNeaten.exe"
      local proj_tool = io.open(proj_tool_path, "r")
      if proj_tool then
        os.execute(Root.Instance():getGamePath():gsub("\\", "/") .. "../tools/projectNeaten/Tool/projectNeaten.exe CheckMeshs " .. Root.Instance():getGamePath():gsub("\\", "/"))
        local mv_path = Root.Instance():getGamePath():gsub("\\", "/") .. "../tools/projectNeaten/mesh.csv " .. getMeshInfoPath()
        local del_path = Root.Instance():getGamePath():gsub("\\", "/") .. "../tools/projectNeaten/mesh.json"
        if package.config:sub(1, 1) == "\\" then
          os.execute("move " .. mv_path:gsub("/", "\\"))
          os.execute("del " .. del_path:gsub("/", "\\"))
        else
          os.execute("mv " .. mv_path)
          os.execute("rm " .. del_path)
        end
        Lib.logInfo("Generating mesh info complete.")
      else
        Lib.logInfo("Tool not found, failed to generate mesh info.")
      end
    else
      Lib.logInfo("Mesh info file found.")
      Lib.logInfo("To re-generate mesh info file, simply delete it and it will be auto-generated at the next starting.")
    end
    loadMeshInfo()
  end
end

local function hsvToRgb(h, s, v)
  local hi = math.floor(h / 60)
  local f = h / 60 - hi
  local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
  if hi == 0 then
    return v, t, p
  elseif hi == 1 then
    return q, v, p
  elseif hi == 2 then
    return p, v, t
  elseif hi == 3 then
    return p, q, v
  elseif hi == 4 then
    return t, p, v
  else
    return v, p, q
  end
end

local function hslToRgb(h, s, l)
  if s == 0 then
    return l, l, l
  end
  
  local function hue2rgb(p, q, t)
    if t < 0 then
      t = t + 1
    end
    if 1 < t then
      t = t - 1
    end
    if t < 0.16666666666666666 then
      return p + (q - p) * 6 * t
    elseif t < 0.5 and 0.16666666666666666 <= t then
      return q
    elseif t < 0.6666666666666666 and t <= 0.5 then
      return p + (q - p) * 6 * (0.6666666666666666 - t)
    else
      return p
    end
  end
  
  local q
  if 0.5 < l then
    q = l * (1 + s)
  else
    q = l + s - l * s
  end
  local p = 2 * l - q
  local hk = h / 360
  local r, g, b = hue2rgb(p, q, hk + 0.3333333333333333), hue2rgb(p, q, hk), hue2rgb(p, q, hk - 0.3333333333333333)
  return r, g, b
end

local click_event_registered = false
local old_threshold = -1
local call_index = -1
local colored_nodes = {}
GMItem["g2052\229\183\165\229\133\183/\231\170\129\229\135\186\229\164\154\233\161\182\231\130\185mesh"] = GM:inputNumber(function(self, threshold)
  if not mesh_info_loaded then
    CreateMeshInfo()
  end
  if not click_event_registered or tonumber(threshold) ~= old_threshold then
    if click_event_registered or tonumber(threshold) <= 0 then
      Lib.unsubscribeEvent(Event.EVENT_PART_CLICK, call_index)
      click_event_registered = false
    end
    if tonumber(threshold) > 0 then
      old_threshold = tonumber(threshold)
      local _, _index = Lib.subscribeEvent(Event.EVENT_PART_CLICK, function(part, from)
        if not part or not part:isValid() then
          return
        end
        if not (from and from:isValid()) or not from.isPlayer then
          return
        end
        if part:getScriptName() == "MeshPart" and mesh_list[part.mesh] and mesh_list[part.mesh].vert_count >= tonumber(threshold) then
          local mesh_info = "Mesh path:" .. part.mesh .. " Vert count:" .. mesh_list[part.mesh].vert_count .. " Mem size:" .. mesh_list[part.mesh].mem_size
          Lib.logInfo(mesh_info)
        end
      end)
      click_event_registered = true
      call_index = _index
    end
  end
  local debugDraw = DebugDraw.instance
  if 0 < tonumber(threshold) then
    if not debugDraw:isEnabled() then
      debugDraw:setEnabled(true)
    end
    debugDraw.addEntry("ShowComplexMesh", function()
      local position = Me:getEyePos()
      local scale = Vector3.new(15, 15, 15)
      local minPoint = position - scale
      local maxPoint = position + scale
      local nodes_near = {}
      local sceneManager = World.CurWorld:getSceneManager()
      for _, scene in pairs(sceneManager:getAllScene()) do
        local nodes_s = scene:getPartByRange(minPoint, maxPoint)
        for _, node in pairs(nodes_s) do
          local scriptName = node:getScriptName()
          if scriptName == "MeshPart" then
            nodes_near[node.id] = node
          end
        end
      end
      for _, value in pairs(colored_nodes) do
        if nodes_near[value.id] == nil then
          value:setColor({
            1,
            1,
            1,
            1
          })
          colored_nodes[value.id] = nil
        end
      end
      for _, node in pairs(nodes_near) do
        if mesh_list[node.mesh] then
          local threshold_num = tonumber(threshold)
          if threshold_num <= mesh_list[node.mesh].vert_count then
            if colored_nodes[node.id] == nil then
              local hue = 0
              local saturation = math.min(0.3 + mesh_list[node.mesh].vert_count / max_vert_count * 0.7, 1)
              local r, g, b = hsvToRgb(hue, saturation, 1)
              node:setColor({
                r,
                g,
                b,
                1
              })
              colored_nodes[node.id] = node
            end
          elseif colored_nodes[node.id] then
            node:setColor({
              1,
              1,
              1,
              1
            })
            colored_nodes[node.id] = nil
          end
        end
      end
    end)
    debugDraw:setShowComplexMeshEnabled(true)
  else
    debugDraw:setShowComplexMeshEnabled(false)
    for _, value in pairs(colored_nodes) do
      value:setColor({
        1,
        1,
        1,
        1
      })
      colored_nodes[value.id] = nil
    end
  end
end)
GMItem["g2052\229\183\165\229\133\183/\231\148\187\232\180\168-\228\189\142"] = function()
  Blockman.instance.gameSettings:setCurQualityLevel(0)
end
GMItem["g2052\229\183\165\229\133\183/\231\148\187\232\180\168-\228\184\173"] = function()
  Blockman.instance.gameSettings:setCurQualityLevel(1)
end
GMItem["g2052\229\183\165\229\133\183/\231\148\187\232\180\168-\233\171\152"] = function()
  Blockman.instance.gameSettings:setCurQualityLevel(2)
end
local chunk_wnd_keys = {}
GMItem["g2052\229\183\165\229\133\183/\229\136\134\229\140\186\230\152\190\231\164\186\233\161\182\231\130\185\230\128\187\230\149\176"] = GM:inputNumber(function(self, chunk_size_str)
  if not mesh_info_loaded then
    CreateMeshInfo()
  end
  for _, key in pairs(chunk_wnd_keys) do
    GUISystem.instance:UnbindWorldWindow(key)
  end
  chunk_wnd_keys = {}
  local debugDraw = DebugDraw.instance
  local chunk_size = tonumber(chunk_size_str)
  if chunk_size <= 0 then
    debugDraw:setShowChunkBorderEnabled(false)
    debugDraw:setEnabled(false)
    return
  end
  local mesh_verts_count = {}
  
  local function forEachNode(node)
    local scriptName = node:getScriptName()
    if scriptName == "MeshPart" and mesh_list[node.mesh] then
      local chunk_no_x, chunk_no_z = math.floor(node.position.x / chunk_size), math.floor(node.position.z / chunk_size)
      if mesh_verts_count[chunk_no_x] == nil then
        mesh_verts_count[chunk_no_x] = {}
      end
      if mesh_verts_count[chunk_no_x][chunk_no_z] == nil then
        mesh_verts_count[chunk_no_x][chunk_no_z] = 0
      end
      mesh_verts_count[chunk_no_x][chunk_no_z] = mesh_verts_count[chunk_no_x][chunk_no_z] + mesh_list[node.mesh].vert_count
    end
    for _, value in pairs(node:getAllChild()) do
      forEachNode(value)
    end
  end
  
  local sceneManager = World.CurWorld:getSceneManager()
  for _, scene in pairs(sceneManager:getAllScene()) do
    forEachNode(scene:getRoot())
  end
  local regions = {}
  for key_x, list1 in pairs(mesh_verts_count) do
    for key_z, val in pairs(list1) do
      local str1 = "From x:" .. key_x * chunk_size_str .. "~" .. (key_x + 1) * chunk_size_str .. " z:" .. key_z * chunk_size_str .. "~" .. (key_z + 1) * chunk_size_str
      local str2 = "Sum vert count: " .. val
      local widget1 = UIMgr:new_widget("text", 18, 15, str1, "")
      local widget_key1 = "mesh_vert_count_" .. tostring(key_x) .. "_" .. tostring(key_z) .. "_1"
      widget1:SetScale(Vector3.new(6, 6, 6))
      local widget2 = UIMgr:new_widget("text", 18, 15, str2, "")
      local widget_key2 = "mesh_vert_count_" .. tostring(key_x) .. "_" .. tostring(key_z) .. "_2"
      widget2:SetScale(Vector3.new(6, 6, 6))
      local color = {
        255,
        0,
        0
      }
      if (key_x + key_z) % 2 == 0 then
        color = {
          0,
          255,
          0
        }
      end
      widget1:invoke("SET_TEXT_COLOR", {
        color[1] / 255,
        color[2] / 255,
        color[3] / 255,
        1
      })
      widget2:invoke("SET_TEXT_COLOR", {
        color[1] / 255,
        color[2] / 255,
        color[3] / 255,
        1
      })
      GUISystem.instance:BindWorldWindow(widget_key1, widget1, 7, 1, Vector3.new(0, 0, 0), Vector3.new((key_x + 0.5) * chunk_size_str, 22, (key_z + 0.5) * chunk_size_str), -1)
      GUISystem.instance:BindWorldWindow(widget_key2, widget2, 7, 1, Vector3.new(0, 0, 0), Vector3.new((key_x + 0.5) * chunk_size_str, 20, (key_z + 0.5) * chunk_size_str), -1)
      table.insert(chunk_wnd_keys, widget_key1)
      table.insert(chunk_wnd_keys, widget_key2)
      table.insert(regions, {
        min = Vector3.new(key_x * chunk_size_str + 0.01, 0, key_z * chunk_size_str + 0.01),
        max = Vector3.new((key_x + 1) * chunk_size_str - 0.01, 50, (key_z + 1) * chunk_size_str - 0.01),
        color = color
      })
    end
  end
  if not debugDraw:isEnabled() then
    debugDraw:setEnabled(true)
  end
  debugDraw.addEntry("ShowChunkBorder", function()
    local xz_step, y_step = 10, 10
    for key, region in pairs(regions) do
      local color = Bitwise64.Sl(region.color[1], 24) + Bitwise64.Sl(region.color[2], 16) + Bitwise64.Sl(region.color[3], 8) + 255
      local current_y = region.max.y - y_step
      while current_y >= region.min.y do
        debugDraw:drawLine(Vector3.new(region.min.x, current_y, region.min.z), Vector3.new(region.max.x, current_y, region.min.z), color)
        debugDraw:drawLine(Vector3.new(region.min.x, current_y, region.min.z), Vector3.new(region.min.x, current_y, region.max.z), color)
        debugDraw:drawLine(Vector3.new(region.max.x, current_y, region.max.z), Vector3.new(region.max.x, current_y, region.min.z), color)
        debugDraw:drawLine(Vector3.new(region.max.x, current_y, region.max.z), Vector3.new(region.min.x, current_y, region.max.z), color)
        current_y = current_y - y_step
      end
      local current_x = region.min.x + xz_step
      while current_x <= region.max.x do
        debugDraw:drawLine(Vector3.new(current_x, region.min.y, region.min.z), Vector3.new(current_x, region.max.y, region.min.z), color)
        debugDraw:drawLine(Vector3.new(current_x, region.min.y, region.max.z), Vector3.new(current_x, region.max.y, region.max.z), color)
        current_x = current_x + xz_step
      end
      local current_z = region.min.z + xz_step
      while current_z <= region.max.z do
        debugDraw:drawLine(Vector3.new(region.min.x, region.min.y, current_z), Vector3.new(region.min.x, region.max.y, current_z), color)
        debugDraw:drawLine(Vector3.new(region.max.x, region.min.y, current_z), Vector3.new(region.max.x, region.max.y, current_z), color)
        current_z = current_z + xz_step
      end
    end
  end)
  debugDraw:setShowChunkBorderEnabled(true)
end)
return GMItem
