local PartInteractHelper = T(Lib, "PartInteractHelper")
local PartManagerHelper = T(Lib, "PartManagerHelper")

function PartInteractHelper.onGoldCoinEffect(type, fromPart, targetPart, params)
  if not fromPart or not fromPart:isValid() then
    return
  end
  if not targetPart or not targetPart:isValid() then
    return
  end
  if type == Define.PART_INTERACT_TYPE.PART_TOUCH_PART_BEGIN then
    if not targetPart.properties then
      return
    end
    local targetPartName = targetPart.properties.name
    if not targetPartName then
      return
    end
    local nameList = Lib.splitString(params[4], "#")
    for _, partName in pairs(nameList) do
      if partName == targetPartName then
        PartManagerHelper:updateEffectOnPart(type, fromPart, params)
        return
      end
    end
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
  end
end

local function partSmoothMovement(target, isRestore)
  if not target.operationMoveInfo then
    return
  end
  local distance = target.operationMoveInfo.distance
  local time = target.operationMoveInfo.time
  local scene = target:getScene()
  local nodes = target.operationMoveInfo.nodes
  local offset = distance / time
  if isRestore then
    offset = offset * -1
  end
  local count = 0
  target.partSmoothMovementTimer = World.Timer(1, function()
    for _, v in pairs(nodes or {}) do
      if not v or not v:isValid() then
        return
      end
    end
    scene = target:getScene()
    if scene then
      count = count + 1
      scene.move(nodes, offset, true)
      if count == time then
        target.partSmoothMovementTimer = nil
        return
      end
    end
    return true
  end)
  target.initState = isRestore
end

local function acceleratedChangeMoveState(target, info, isNew)
  for id, v in pairs(info or {}) do
    local part = Instance.getByInstanceId(id)
    if part and part:isValid() then
      if isNew then
        part:setPosition(v.newPos)
      else
        part:setPosition(v.pos)
      end
    end
  end
  target.operationMoveInfo = nil
end

function PartInteractHelper.operationPartMoveLoop(type, target, params)
  if params then
    local pos = target:getPosition()
    local rotation = target:getRotation()
    local distance = Lib.createV3ByString(params[1])
    distance = Lib.correctMoveDistance(rotation, distance)
    local time = tonumber(params[2])
    local pause = tonumber(params[3]) or 1
    if distance and time then
      do
        local count = 0
        local onceDis = distance / time
        local value = 1
        target.loopMoveTime = World.Timer(1, function()
          if not target or not target:isValid() then
            return
          end
          count = count + value
          target:setPosition(pos + count * onceDis)
          if count >= time then
            value = 0
            World.Timer(pause, function()
              value = -1
            end)
          elseif count <= 0 then
            value = 0
            World.Timer(pause, function()
              value = 1
            end)
          end
          return true
        end)
      end
    end
  end
end

function PartInteractHelper.playLimitEffectOnPart(type, target, params)
  PartManagerHelper:playLimitEffectOnPart(type, target, params)
end

function PartInteractHelper.operationPartDoor(type, target, params)
end

function PartInteractHelper.showTVButton(tvPart, btnNames, isShow)
  local parent = tvPart:getParent()
  local nodes = {}
  if parent and parent:isValid() then
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, nil, true)
  end
  for _, btnName in pairs(btnNames) do
    for _, v in pairs(nodes) do
      local isBtn
      if v.name == btnName then
        isBtn = true
      end
      if isBtn then
        local count = v:getChildrenCount()
        for i = 0, count - 1 do
          local n = v:getChildAt(i)
          n.visible = isShow
        end
        break
      end
    end
  end
end
