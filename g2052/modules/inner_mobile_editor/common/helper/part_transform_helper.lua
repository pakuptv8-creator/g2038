local class = require("common.3rd.middleclass.middleclass")
local IScene = require("common.engine.engine_scene")
local IInstance = require("common.engine.engine_instance")
local util = require("common.util.util")
local PartTransformHelper = class("PartTransformHelper")

function PartTransformHelper:initialize()
  Lib.logDebug("PartTransformHelper:initialize")
end

function PartTransformHelper.static.combine(nodes, type)
end

function PartTransformHelper.static.split(nodes)
end

function PartTransformHelper.static.group(nodes)
end

function PartTransformHelper.static.unGroup(nodes)
end

local function inArea(p, floorBound)
  if p.x >= floorBound.min.x and p.y >= floorBound.min.y and p.z >= floorBound.min.z and p.x <= floorBound.max.x and p.y <= floorBound.max.y and p.z <= floorBound.max.z then
    return true
  end
  return false
end

local function testScaleBound(object, extra, aix, size)
  local floorBound = extra.floorBound
  local center = extra.center
  local rotate = extra.rotate
  local xSize = IInstance:size(object).x
  local ySize = IInstance:size(object).y
  local zSize = IInstance:size(object).z
  if aix == "x" then
    xSize = size
  elseif aix == "y" then
    ySize = size
  else
    zSize = size
  end
  local xMin = center.x - xSize / 2
  local xMax = center.x + xSize / 2
  local yMin = center.y - ySize / 2
  local yMax = center.y + ySize / 2
  local zMin = center.z - zSize / 2
  local zMax = center.z + zSize / 2
  local min = center + rotate * (Vector3.fromTable({
    x = xMin,
    y = yMin,
    z = zMin
  }) - center)
  local max = center + rotate * (Vector3.fromTable({
    x = xMax,
    y = yMax,
    z = zMax
  }) - center)
  local vec = {
    Vector3.fromTable({
      x = min.x,
      y = min.y,
      z = min.z
    }),
    Vector3.fromTable({
      x = min.x,
      y = min.y,
      z = max.z
    }),
    Vector3.fromTable({
      x = max.x,
      y = min.y,
      z = max.z
    }),
    Vector3.fromTable({
      x = max.x,
      y = min.y,
      z = min.z
    }),
    Vector3.fromTable({
      x = max.x,
      y = max.y,
      z = max.z
    }),
    Vector3.fromTable({
      x = max.x,
      y = max.y,
      z = min.z
    }),
    Vector3.fromTable({
      x = min.x,
      y = max.y,
      z = min.z
    }),
    Vector3.fromTable({
      x = min.x,
      y = max.y,
      z = max.z
    })
  }
  for _, p in pairs(vec) do
    if not inArea(p, floorBound) then
      return false
    end
  end
  return true
end

local function testScaleAllBound(extra, stretch, scale)
  local bounds = extra.bounds
  local floorBound = extra.floorBound
  if stretch then
    bounds.min.x = bounds.min.x - scale
    bounds.min.y = bounds.min.y - scale
    bounds.min.z = bounds.min.z - scale
    bounds.max.x = bounds.max.x + scale
    bounds.max.y = bounds.max.y + scale
    bounds.max.z = bounds.max.z + scale
    if bounds.min.x >= floorBound.min.x and bounds.min.y >= floorBound.min.y and bounds.min.z >= floorBound.min.z and bounds.max.x <= floorBound.max.x and bounds.max.y <= floorBound.max.y and bounds.max.z <= floorBound.max.z then
      return true
    end
    return false
  end
  return true
end

function PartTransformHelper.static.getScale(objects, aix, offset, stretch, extra)
  local func = extra and extra.func
  local box = IScene:parts_aabb(objects)
  if not box then
    if func then
      func()
    end
    return
  end
  aix = aix == 1 and "x" or aix == 2 and "y" or "z"
  local dist = (offset.x ^ 2 + offset.y ^ 2 + offset.z ^ 2) ^ 0.5
  local diff = stretch and 2 * dist or -2 * dist
  if #objects == 1 and objects[1] and not objects[1]:isA("PartOperation") then
    local object = objects[1]
    local size = IInstance:size(object)[aix] + diff
    if size <= 0.1 then
      if func then
        func()
      end
      return
    end
    if func and not testScaleBound(object, extra, aix, size) then
      func()
      return
    end
    if aix == "x" then
      IInstance:set_size_x(object, size)
    elseif aix == "y" then
      IInstance:set_size_y(object, size)
    else
      IInstance:set_size_z(object, size)
    end
  else
    local size = math.abs(box[3][aix] - box[2][aix])
    if size <= 0.1 and not stretch then
      if func then
        func()
      end
      return
    end
    local scale = (size + diff) / size
    if scale <= 0.05 then
      if func then
        func()
      end
      return
    end
    if func and not testScaleAllBound(extra, stretch, scale) then
      func()
      return
    end
    IScene:scale_parts(objects, {
      x = scale,
      y = scale,
      z = scale
    })
  end
  IScene:move_parts(objects, offset)
  if func then
    func(true)
  end
end

return PartTransformHelper
