local IScene = require("common.engine.engine_scene")
local IWorld = require("common.engine.engine_world")
local IInstance = require("common.engine.engine_instance")
local ConfigManager = T(MobileEditor, "ConfigManager")
local cjson = require("cjson")
local M = {}

function M:downButton(button)
end

function M:upButton(button)
end

function M:clamp(value, min, max)
  if value <= min then
    return min
  end
  if max <= value then
    return max
  end
  return value
end

function M:logicPosToScreenPos(dx, dy)
  if not dx or not dy then
    return 0, 0
  end
  local gui = GUISystem.instance
  local sw, sh = gui:GetScreenWidth(), gui:GetScreenHeight()
  local lw, lh = gui:GetLogicWidth(), gui:GetLogicHeight()
  local x, y = dx / lw * sw, dy / lh * sh
  local root = Root.Instance()
  if root:isFixedAspect() then
    local dh = math.ceil(root:getRealHeight()) - math.ceil(sh)
    y = y - (0 < dh and dh * 0.5 or dh)
  end
  return x, y
end

function M:getPlacePos(hitPos, sideNormal, size)
  local offset, pos
  if math.abs(sideNormal.x) == 1.0 then
    offset = tonumber(size.x)
    if sideNormal.x < 0 then
      offset = -offset
    end
    pos = Lib.v3(hitPos.x + offset * 0.5, hitPos.y, hitPos.z)
  elseif math.abs(sideNormal.y) == 1.0 then
    offset = tonumber(size.y)
    if 0 > sideNormal.y then
      offset = -offset
    end
    pos = Lib.v3(hitPos.x, hitPos.y + offset * 0.5, hitPos.z)
  elseif math.abs(sideNormal.z) == 1.0 then
    offset = tonumber(size.z)
    if 0 > sideNormal.z then
      offset = -offset
    end
    pos = Lib.v3(hitPos.x, hitPos.y, hitPos.z + offset * 0.5)
  end
  return pos
end

function M:parseProperties(content, key)
  local list = Lib.splitString(content, " ")
  local offset = Lib.splitString(list[key], ":")
  return offset[2]
end

function M:rgbaToHex(argb)
  local hexadecimal = "0X"
  for key, value in pairs(argb) do
    local hex = ""
    while 0 < value do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub("0123456789ABCDEF", index, index) .. hex
    end
    if string.len(hex) == 0 then
      hex = "00"
    elseif string.len(hex) == 1 then
      hex = "0" .. hex
    end
    hexadecimal = hexadecimal .. hex
  end
  return hexadecimal
end

function M:ColorConversion(color)
  local hex_color_tb = {
    a = "00",
    r = "00",
    b = "00",
    g = "00"
  }
  for k, v in pairs(color) do
    local length = 0
    if hex_color_tb[k] ~= nil then
      length = string.len(string.sub(string.format("%#x", v), 3))
    end
    if length == 1 then
      hex_color_tb[k] = "0" .. string.sub(string.format("%#x", v), 3)
    elseif length == 2 then
      hex_color_tb[k] = string.sub(string.format("%#x", v), 3)
    else
      hex_color_tb[k] = "00"
    end
  end
  return hex_color_tb.a .. hex_color_tb.r .. hex_color_tb.g .. hex_color_tb.b
end

function M:getNodeType(class)
  if class == "Part" then
    return Define.NODE_TYPE.PART
  elseif class == "PartOperation" then
    return Define.NODE_TYPE.PARTOPERATION
  elseif class == "Model" then
    return Define.NODE_TYPE.MODEL
  elseif class == "MeshPart" then
    return Define.NODE_TYPE.MESHPART
  elseif class == "RegionPart" then
    return Define.NODE_TYPE.REGIONPART
  end
end

function M:getAllChildrenAsTable(object)
  local config = {}
  config.class = IInstance:getClassName(object)
  local properties = {}
  object:getAllPropertiesAsTable(properties)
  config.properties = properties
  config.attributes = Lib.copy(object.attributes)
  config.size = object:getSize()
  if object:isA("Part") or object:isA("PartOperation") or object:isA("MeshPart") then
  elseif object:isA("Model") then
    config.children = {}
    for i = 1, object:getChildrenCount() do
      local child = object:getChildAt(i - 1)
      if child then
        local data = self:getAllChildrenAsTable(child)
        table.insert(config.children, data)
      end
    end
  end
  return config
end

function M:parseModelConfig(config, id)
  for i = 1, #config.children do
    local child = config.children[i]
    if child then
      if child.class == "Part" or child.class == "PartOperation" then
        if tostring(child.properties.id) == tostring(id) then
          return child
        end
      elseif child.class == "Model" then
        self:parseModelConfig(child, id)
      end
    end
  end
end

function M:extractModel(object, list)
  for i = 1, object:getChildrenCount() do
    local child = object:getChildAt(i - 1)
    if child then
      if child:isA("Part") or child:isA("PartOperation") or child:isA("MeshPart") then
        table.insert(list, child)
      elseif child:isA("Model") then
        self:extractModel(child, list)
      end
    end
  end
end

function M:filter(nodes, func, includeChildren)
  local function listChildren(object, list)
    local count = object:getChildrenCount()
    
    for i = 1, count do
      local child = object:getChildAt(i - 1)
      if child then
        table.insert(list, child)
      end
      listChildren(child, list)
    end
  end
  
  local list = {}
  for _, node in pairs(nodes) do
    if not func or func(node) then
      table.insert(list, node:getObject())
    end
    if includeChildren then
      listChildren(node:getObject(), list)
    end
  end
  return list
end

function M:parseInstanceId(config)
  if config.properties and config.properties.id then
    config.properties.id = tostring(IWorld:gen_instance_id())
  end
  if config.children and Lib.getTableSize(config.children) > 0 then
    for _, param in ipairs(config.children) do
      self:parseInstanceId(param)
    end
  end
end

function M:getRoot(object, root)
  local parent
  local child = object
  repeat
    if not child or not child:isValid() then
      return
    end
    parent = child:getParent()
    if parent ~= root then
      child = parent
    end
  until parent == root
  return child
end

function M:contains(object, className)
  if object:isA(className) then
    return true
  end
  local contain = false
  for i = 1, object:getChildrenCount() do
    local child = object:getChildAt(i - 1)
    if child then
      if child:getChildrenCount() > 0 then
        if self:contains(child, className) then
          return true
        end
      elseif child:isA(className) then
        contain = true
        break
      end
    end
  end
  return contain
end

function M:setProperty(object, key, value)
  if object:isA("Part") or object:isA("PartOperation") then
    IInstance:set(object, key, value)
  elseif object:isA("Model") then
    for i = 1, object:getChildrenCount() do
      local child = object:getChildAt(i - 1)
      if child then
        self:setProperty(child, key, value)
      end
    end
  end
end

function M:setAttribute(object, key, value)
  if object:isA("Part") or object:isA("PartOperation") then
    object.attributes[key] = value
  elseif object:isA("Model") then
    for i = 1, object:getChildrenCount() do
      local child = object:getChildAt(i - 1)
      if child then
        self:setAttribute(child, key, value)
      end
    end
  end
end

function M:resetColorAttribute(object)
  if object:isA("Part") or object:isA("PartOperation") then
    if object.attributes then
      local color = object.attributes.color
      Lib.logDebug("resetColorAttribute color = ", color)
      IInstance:set(object, "materialColor", color)
    end
  elseif object:isA("Model") then
    for i = 1, object:getChildrenCount() do
      local child = object:getChildAt(i - 1)
      if child then
        self:resetColorAttribute(child)
      end
    end
  end
end

function M:getBound(targets)
  local objects = {}
  for _, target in pairs(targets) do
    if target:getObject() and target:getObject():isValid() then
      table.insert(objects, target:getObject())
    end
  end
  return IScene:parts_bound(objects)
end

function M:getCenter(targets)
  local bound = self:getBound(targets)
  if not bound then
    return
  end
  return {
    x = bound.min.x + (bound.max.x - bound.min.x) / 2,
    y = bound.min.y + (bound.max.y - bound.min.y) / 2,
    z = bound.min.z + (bound.max.z - bound.min.z) / 2
  }
end

function M:round(value)
  value = tonumber(value) or 0
  return math.floor(value + 0.5)
end

function M:snap(val, snap)
  if 0.0 < snap then
    return Lib.v3(snap * self:round(val.x / snap), snap * self:round(val.y / snap), snap * self:round(val.z / snap))
  end
  return val
end

function M:saveFile(path, data)
  assert(type(data) == "table")
  local ok, content
  if World.isClient and CGame.instance:getPlatformId() == 1 then
    content = Lib.toJson(data)
  else
    ok, content = pcall(cjson.encode, data)
    assert(ok)
  end
  local file = io.open(path, "w+")
  Lib.logDebug("file = ", file)
  file:write(content)
  Lib.logDebug("write content = ", content)
  file:close()
end

function M:getFileContent(path)
  local attr = lfs.attributes(path)
  if not attr then
    return {}
  end
  return Lib.read_json_file(path)
end

function M:updateSetting(key, val)
  local gamePath = Root.Instance():getGamePath()
  local path = string.format("%seditor_setting.json", gamePath)
  Lib.logDebug("updateSetting path = ", path)
  local content = self:getFileContent(path)
  content[key] = val
  Lib.logDebug("updateSetting key and val = ", key, val)
  self:saveFile(path, content)
end

function M:getSign(number)
  if 0 <= number then
    return 1
  else
    return -1
  end
end

function M:signedAngle(from, to, axis)
  from = Vector3.new(from.x or 0, from.y or 0, from.z or 0)
  to = Vector3.new(to.x or 0, to.y or 0, to.z or 0)
  local unsignedAngle = math.deg(Vector3.angle(from, to))
  local cross = from:cross(to)
  local sign = self:getSign(axis.x * cross.x + axis.y * cross.y + axis.z * cross.z)
  return unsignedAngle * sign
end

function M:oppositeSigns(x, y)
  return x ^ y < 0
end

function M:getRayLength()
  return 1000
end

function M:getScreenSpaceCullDistance()
  local quality = Blockman.Instance().gameSettings:getCurQualityLevel()
  if quality == Define.GRAPHICS_QUALITY.LOW then
    return World.cfg.screenSpaceCullStartDis_Low
  else
    return World.cfg.screenSpaceCullStartDis_High
  end
end

function M:screenShot(blockId, func)
  local dir = Root.Instance():getGamePath() .. "screenShot/" .. Me.platformUserId .. "/"
  local path = {
    rectangle = dir .. "block_" .. blockId .. ".png"
  }
  Lib.mkPath(dir)
  Root.Instance():pushScreenShotInfo(path.rectangle, 334, 150)
  World.Timer(2, function()
    if Root.Instance():getScreenShotInfoSize() == 0 then
      if func then
        self:updateSetting("isUseNewScreenShot", true)
        func(path)
      end
      return false
    end
    return true
  end)
end

function M:downloadMapScreenShot(userId, blockId, url, callback)
  local root = Root.Instance():getGamePath() .. "screenShot/" .. userId .. "/"
  local fileName = "block_" .. blockId .. ".png"
  if not Lib.fileExists(root) then
    Lib.mkPath(root)
  end
  AsyncProcess.DownloadFile(url, root .. fileName, function(data)
    if callback then
      callback(data)
    end
  end)
end

function M:uploadMapScreenShot(userId, blockId, filePath, callback)
  local imgName = userId .. "_block_" .. blockId
  AsyncProcess.UploadMapScreenShot(imgName, filePath, "png", false, function(data, isSuccess)
    if callback then
      callback(data, isSuccess)
    end
  end)
end

function M:uploadMap(filePath, callback)
  AsyncProcess.UploadMap(filePath, "json", function(data, isSuccess)
    if callback then
      callback(data, isSuccess)
    end
  end)
end

function M:downloadMap(userId, blockId, url, callback)
  local root = Lib.combinePath(Root.Instance():getGamePath(), "map/" .. userId .. "_map/" .. blockId .. "/")
  if not Lib.fileExists(root) then
    Lib.mkPath(root)
  end
  local fileName = "setting.json"
  AsyncProcess.DownloadFile(url, root .. fileName, function(data)
    if callback then
      callback(data)
    end
  end)
end

function M:pushMapData(blockId, screenShootUrl, mapUrl, updateType, callback)
  AsyncProcess.PushMapData(blockId, screenShootUrl, mapUrl, updateType, function(isSuccess)
    if callback then
      callback(isSuccess)
    end
  end)
end

function M:getMapBlockData(blockId, callback)
  AsyncProcess.GetMapBlockData(blockId, function(data, isSuccess)
    if callback then
      callback(data, isSuccess)
    end
  end)
end

function M:removeFile(path)
  if Lib.fileExists(path) then
    os.remove(path)
  end
end

return M
