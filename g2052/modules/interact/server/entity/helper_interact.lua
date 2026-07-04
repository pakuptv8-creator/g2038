local Interact = T(World, "Interact")
local GameStatusValue = T(Game, "GameStatusValue")
local EntityHelper = T(Lib, "EntityHelper")

function Interact.buff(target, value, from, add)
  if type(value) == "table" then
    if value.useCsv then
      value = {
        name = value[1],
        time = tonumber(value[2]),
        isFrom = value[3] == "TRUE" or value[3] == "true"
      }
    end
  elseif type(value) == "string" then
    value = {name = value}
  end
  local buffTarget = target
  if value.isFrom then
    buffTarget = from
  end
  if buffTarget and buffTarget:isValid() then
    if add then
      buffTarget:addBuff(value.name, value.time)
    else
      buffTarget:removeTypeBuff("fullName", value)
    end
  end
  return true
end

function Interact.create_entity(target, params, from, notDisable, extraParams)
  if params.useCsv then
    local posArr = Lib.split(params[2], ",")
    params = {
      name = params[1],
      pos = Lib.v3(posArr[1], posArr[2], posArr[3]),
      yaw = tonumber(params[3]),
      lifeTime = tonumber(params[4])
    }
    if extraParams and type(extraParams) == "table" then
      for key, value in pairs(params) do
        for k, v in pairs(extraParams) do
          if key == k then
            params[key] = v
          end
        end
      end
    end
  end
  local map = target and target.map
  map = map or from and from.map
  local entity = EntityServer.Create({
    cfgName = params.name,
    map = map,
    pos = params.pos,
    ry = params.yaw,
    name = "",
    owner = from
  })
  if params.lifeTime > 0 then
    World.Timer(params.lifeTime, function()
      if entity:isValid() then
        entity:destroy()
      end
    end)
  end
  return true
end

function Interact.incr_game_status(target, params, from)
  if params.useCsv then
    params = {
      key = params[1],
      value = tonumber(params[2]) or 1
    }
  end
  if not params.key then
    return false
  end
  if not GameStatusValue[params.key] then
    GameStatusValue[params.key] = 0
  end
  local add = params.value or 1
  GameStatusValue[params.key] = GameStatusValue[params.key] + add
  return true
end

function Interact.remove_entity(target, params, from)
  local entityList = {}
  if World.isClient then
    entityList = World.CurWorld:getAllEntity()
  else
    local map = target and target.map
    map = map or from and from.map
    entityList = map.objects
  end
  if params.useCsv then
    params = {
      remove_entity = params[1]
    }
  end
  local needRemoveEntities = {}
  for _, obj in pairs(entityList) do
    if obj:cfg().fullName == params.remove_entity then
      table.insert(needRemoveEntities, obj)
    end
  end
  if not next(needRemoveEntities) then
    return false
  end
  for _, entity in pairs(needRemoveEntities) do
    entity:destroy()
  end
  return true
end

function Interact.replace_entity(target, params, from)
  if params.useCsv then
    params = {
      base = params[1],
      replace = params[2],
      time = tonumber(params[3])
    }
  end
  local base_path = params.base
  local replace_path = params.replace
  local time = params.time
  local needReplaceEntities = {}
  for _, obj in pairs(target.map.objects) do
    if obj:cfg().fullName == base_path then
      table.insert(needReplaceEntities, obj)
    end
  end
  if not next(needReplaceEntities) then
    return false
  end
  local replaceList = EntityHelper:replaceEntity(needReplaceEntities, replace_path)
  if time and 0 < time then
    local timer = World.Timer(time, function()
      EntityHelper:replaceEntity(replaceList, base_path)
    end)
  end
  return true
end

function Interact.force_move(target, params, from)
  if params.useCsv then
    local diffPos = Lib.split(params[3], ",")
    params = {
      canBack = params[1] == "TRUE" or params[1] == "true",
      time = tonumber(params[2]),
      diffPos = Lib.v3(diffPos[1], diffPos[2], diffPos[3]),
      isFrom = params[4] == "TRUE" or params[4] == "true"
    }
  end
  Lib.logDebug("force move", from.platformUserId, params)
  local moveTarget = target
  if params.isFrom then
    moveTarget = from
  end
  if not moveTarget or not moveTarget:isValid() then
    Lib.logError("no target, ignore move")
    return
  end
  if moveTarget.forceTime and World.Now() <= moveTarget.forceTime then
    Lib.logError("target force time error", World.Now(), moveTarget.forceTime)
    return false
  end
  if moveTarget.isMove and params.canBack then
    params.diffPos.x = params.diffPos.x * -1
    params.diffPos.y = params.diffPos.y * -1
    params.diffPos.z = params.diffPos.z * -1
  end
  Lib.logDebug("force move success", from.platformUserId, params)
  local targetPos = moveTarget:getPosition() + params.diffPos
  if moveTarget.isPlayer then
    moveTarget:setForceMoveToAll(targetPos, params.time)
  else
    moveTarget:setForceMove(targetPos, params.time, true)
  end
  moveTarget.isMove = not moveTarget.isMove
  return true
end

function Interact.force_rotate(target, params, from)
  if target.rTimer then
    return false
  end
  if params.useCsv then
    params = {
      canBack = params[1],
      time = tonumber(params[2]),
      yaw = tonumber(params[3])
    }
  end
  if target.isRotate then
    if params.canBack then
      params.yaw = -params.yaw
    else
      return false
    end
  end
  target.isRotate = not target.isRotate
  local duration = 3
  local yawPer = params.yaw / params.time * duration
  local targetYaw = target:getRotationYaw() + params.yaw
  local forceTime = params.time
  target.rTimer = World.Timer(duration, function()
    if not target:isValid() then
      return false
    end
    if forceTime < duration then
      target:setRotationYaw(targetYaw)
      target:syncPosDelay(1)
      target.rTimer = nil
      return false
    end
    target:setRotationYaw(target:getRotationYaw() + yawPer)
    target:syncPosDelay(1)
    forceTime = forceTime - duration
    return true
  end)
  return true
end

function Interact.init_password(target, params, from)
  Plugins.CallTargetPluginFunc("code_select", "initPassword", target, params)
  return true
end

function Interact.progress(target, params, from)
  if params.useCsv then
    params = {
      dt = tonumber(params[1]),
      max = tonumber(params[2]),
      next = Lib.split(params[3], ",")
    }
  end
  local max = params.max
  target.interactList = target.interactList or {}
  if from.isPlayer then
    if target.interactList[from.platformUserId] then
      return false
    end
    target.interactList[from.platformUserId] = true
  end
  target.dt = target.dt or 0
  target.dt = target.dt + params.dt
  if not target.progress_timer then
    target.progress_timer = World.Timer(5, function()
      local count = target.dt * 5
      target.progressNum = target.progressNum or 0
      target.progressNum = target.progressNum + count
      if target.progressNum >= max then
        if params.next then
          Plugins.CallTargetPluginFunc("interact", "diy", params.next, target, target)
        end
        target.progressNum = nil
        target.dt = nil
        target.interactList = nil
        target.progress_timer = nil
        return false
      end
      return true
    end)
  end
  local packet = {
    pid = "showNumProgress",
    max = max,
    curr = target.progressNum or 0,
    dt = target.dt or 0
  }
  for user_id, v in pairs(target.interactList) do
    local player = Game.GetPlayerByUserId(user_id)
    if player and player:isAlivePlayer() then
      player:sendPacket(packet)
    end
  end
  return true
end

function Interact.dynamic_region_buff(target, params, from, add)
  if params.useCsv then
    params = {
      regionKey = params[1],
      buff = params[2]
    }
  end
  local map = target and target.map
  map = map or from and from.map
  local region = map:getRegion(params.regionKey)
  if not region then
    Lib.logError("can't find region, dynamic_region_buff error", Lib.v2s(params))
    return
  end
  region.dynamic_buff = not region.dynamic_buff
  for objID, _ in pairs(region.entityList) do
    local entity = World.CurWorld:getEntity(objID)
    if entity.isPlayer then
      if region.dynamic_buff then
        entity:addBuff(params.buff)
      else
        entity:removeTypeBuff("fullName", params.buff)
      end
    end
  end
end
