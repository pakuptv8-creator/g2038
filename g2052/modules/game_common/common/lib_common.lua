function Lib.getInstanceAllChild(node, nodeList, filterType, childName, isParent)
  local count = node:getChildrenCount()
  
  local class = node.className
  local ability = Define.CLASS_ABILITY[class]
  local type = filterType
  if ability and Bitwise64.And(ability, type) > 0 or false then
    if childName then
      if childName == node.name then
        table.insert(nodeList, node)
      end
    elseif not isParent then
      table.insert(nodeList, node)
    end
  end
  for i = 0, count - 1 do
    local n = node:getChildAt(i)
    Lib.getInstanceAllChild(n, nodeList, filterType, childName)
  end
end

function Lib.getOneDecalTypeChildren(target)
  local count = target:getChildrenCount()
  local decal
  for i = 0, count - 1 do
    local n = target:getChildAt(i)
    if n and n.className == "Decal" then
      decal = n
      break
    end
  end
  return decal
end

function Lib.getInitEffectPart(target)
  local count = target:getChildrenCount()
  local decal
  for i = 0, count - 1 do
    local n = target:getChildAt(i)
    if n and n.className == "EffectPart" then
      decal = n
      break
    end
  end
  return decal
end

function Lib.cloneNewPart(part, map, newInfo, destroyOld)
  if not part or not part:isValid() then
    return
  end
  local cfg = {}
  cfg.class = part.className
  cfg.properties = part.properties
  cfg.properties.id = nil
  if newInfo then
    for key, v in pairs(newInfo) do
      cfg.properties[key] = v
    end
  end
  local parent = part:getParent()
  local channels = part.channels
  local curChannel = part.curChannel
  local defaultImg = part.defaultImg
  if destroyOld then
    part:destroy()
  end
  local newPart = Instance.newInstance(cfg, map)
  if newPart then
    newPart:setParent(parent)
    newPart.channels = channels
    newPart.curChannel = curChannel
    newPart.defaultImg = defaultImg
    parent.screenId = newPart:getInstanceID()
    return newPart
  end
end

function Lib.correctMoveDistance(rotation, distance)
  local q1 = Quaternion.fromEulerAngle(rotation.x, rotation.y, rotation.z)
  return q1 * distance
end

function Lib.createV3ByString(string, splitStr)
  local sep = splitStr or "#"
  local posInfo = Lib.splitString(string, sep)
  return Lib.v3(tonumber(posInfo[1] or 0), tonumber(posInfo[2] or 0), tonumber(posInfo[3] or 0))
end

function Lib.createStringByV3(v3)
  if type(v3) ~= "table" then
    return "0#0#0"
  end
  return v3.x .. "#" .. v3.y .. "#" .. v3.z
end

function Lib.getTextColor(str)
  if not str then
    return
  end
  local newstr = string.gsub(str, "#", "")
  local colorlist = {}
  local index = 1
  while index < string.len(newstr) do
    local tempstr = string.sub(newstr, index, index + 1)
    table.insert(colorlist, tonumber(tempstr, 16))
    index = index + 2
  end
  return {
    (colorlist[1] or 0) / 255,
    (colorlist[2] or 0) / 255,
    (colorlist[3] or 0) / 255,
    1
  }
end

function Lib.getStringColor(color)
  if type(color) ~= "table" then
    return
  end
  return string.format("r:%s g:%s b:%s", color.r or 0, color.g or 0, color.b or 0)
end

function Lib.changeCfgStringColor(str)
  local color = {}
  for k, v in string.gmatch(str, "(%a+):([%g]+)") do
    color[k] = tonumber(v)
  end
  return {
    color.r or 0,
    color.g or 0,
    color.b or 0,
    color.a or 0
  }
end

function Lib.changeCfgStringCoord(str)
  if not str then
    return Lib.v3(0, 0, 0)
  end
  local coord = {}
  for k, v in string.gmatch(str, "(%a+):([%g]+)") do
    coord[k] = tonumber(v)
  end
  return Lib.v3(coord.x or 0, coord.y or 0, coord.z or 0)
end

function Lib.partRotate(part, tracks, time)
  if tracks and type(tracks) ~= "table" then
    return
  end
  if part.rotateTimer then
    part.rotateTimer()
    part.rotateTimer = nil
    if part.initInfo then
      part:setPosition(part.initInfo.pos)
      part:setRotation(part.initInfo.rotation)
    end
  end
  part.rotateCount = 1
  part.initInfo = {
    pos = part:getPosition(),
    rotation = part:getRotation()
  }
  part.rotateTimer = World.Timer(1, function()
    if not part or not part:isValid() then
      part.rotateTimer = nil
      return
    end
    local isFinish = false
    local track = tracks[part.rotateCount] or {}
    if track.pos then
      part:setPosition(track.pos)
    end
    if track.rotation then
      part:setRotation(track.rotation)
    end
    if part.rotateCount >= time then
      isFinish = true
      part.rotateTimer = nil
    end
    part.rotateCount = part.rotateCount + 1
    return isFinish
  end)
end

function Lib.createPartHelper(cfg, scene, map, targetRotation, targetPos)
  if not (cfg and scene) or not map then
    return
  end
  local inst = Instance.newInstance(cfg, map)
  if inst then
    inst:setPosition(targetPos)
    inst:setRotation(targetRotation)
    inst:setParent(scene:getRoot())
  else
    return
  end
  return inst
end

function Lib.getRotateTrack(angle, axis, base, initRotation, time)
  local pos = base * -1
  local q1 = Quaternion.fromEulerAngle(initRotation.x, initRotation.y, initRotation.z)
  local curPos = q1 * pos
  local track = {}
  for i = 1, time do
    local newRotation = initRotation + axis * (angle / time) * i
    local q2 = Quaternion.fromEulerAngle(newRotation.x, newRotation.y, newRotation.z)
    local newPos = q2 * pos
    track[i] = {
      newRotation = newRotation,
      offsetPos = newPos - curPos
    }
  end
  return track
end

function Lib.isIntersected(aabb1, aabb2)
  if aabb1[3].x <= aabb2[2].x then
    return false
  elseif aabb1[3].y <= aabb2[2].y then
    return false
  elseif aabb1[3].z <= aabb2[2].z then
    return false
  end
  if aabb1[2].x >= aabb2[3].x then
    return false
  elseif aabb1[2].y >= aabb2[3].y then
    return false
  elseif aabb1[2].z >= aabb2[3].z then
    return false
  end
  return true
end

function Lib.isGameDrama()
  local gameMode = Game.GetGameMode()
  return gameMode == "script"
end

function Lib.toNewThousandthString(value)
  assert(tonumber(value), value)
  local str = tostring(math.floor(tonumber(value)))
  if str:len() < 5 then
    return str
  end
  if str:len() >= 5 then
    str = tostring(math.floor(tonumber(str) / 1000) .. "k")
  end
  str = str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  if str:sub(1, 1) == "," then
    str = str:sub(2)
  end
  return str
end

function Lib.findingParentNodeByName(node, parentName)
  if not node or not node:isValid() then
    return
  end
  if node.name == parentName then
    return node
  end
  local parent = node:getParent()
  return Lib.findingParentNodeByName(parent, parentName)
end
