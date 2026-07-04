local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local AdvertisementPoolConfig = T(Config, "AdvertisementPoolConfig")
local AdvertisementScenePointConfig = T(Config, "AdvertisementScenePointConfig")
local AdvertisementScenePartConfig = T(Config, "AdvertisementScenePartConfig")
local LuaTimer = T(Lib, "LuaTimer")
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local CarConfig = T(Config, "CarConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local PetConfig = T(Config, "PetConfig")

function AdvertisementModuleHelper:init()
  self.isLogin = false
  self.isWaitWatchResult = false
  self.sceneParts = {}
end

function AdvertisementModuleHelper:onPlayerLogin(player)
  if World.isClient then
    if player.objID ~= Me.objID then
      return
    end
    self.isLogin = true
    Me:setDailyLoginData(os.time())
    self:initSceneAdvertisement(Me)
  else
    self:updateDrawCountData(player)
  end
end

function AdvertisementModuleHelper:openAdvertisementMain(check)
  if not World.isClient or not self.isLogin then
    return
  end
  if Me and Me.isValid and Me:isValid() then
    if check then
      if not AdvertisementModuleHelper:checkCanOpenWnd() then
        return
      end
      Me:setOpenWndData(os.time())
    end
    UI:openWnd("g2052AdvertisementMain")
  end
end

function AdvertisementModuleHelper:drawReawrds(player, drawList)
  if drawList == nil or #drawList == 0 then
    Lib.logError("Error: Draw list is empty!")
    return nil
  end
  local rewardList = {}
  local len = #drawList
  local drawCount = 3
  if len == 1 then
    for i = 1, drawCount do
      rewardList[#rewardList + 1] = drawList[1]
    end
  else
    local lockSlotData = player:getLockSlotData()
    local lockSlotIdCount = {}
    if lockSlotData and next(lockSlotData) then
      for slot, id in pairs(lockSlotData) do
        lockSlotIdCount[id] = (lockSlotIdCount[id] or 0) + 1
      end
    end
    local totalWeight = 0
    local weightList = {}
    for i = 1, len do
      local id = drawList[i].id
      local weight = drawList[i].weight
      if lockSlotIdCount and lockSlotIdCount[id] then
        if lockSlotIdCount[id] == 1 then
          weight = weight * 2
        elseif lockSlotIdCount[id] == 2 then
          weight = weight * 5
        end
      end
      totalWeight = totalWeight + weight
      weightList[#weightList + 1] = totalWeight
    end
    for i = 1, drawCount do
      if lockSlotData and lockSlotData[i] then
        local rewardCfg = AdvertisementPoolConfig:getCfgById(lockSlotData[i])
        rewardList[#rewardList + 1] = rewardCfg
      else
        local rand = math.random(1, totalWeight)
        local index = len
        for j = 1, len do
          if rand <= weightList[j] then
            index = j
            break
          end
        end
        rewardList[#rewardList + 1] = drawList[index] or drawList[1]
      end
    end
  end
  return rewardList
end

function AdvertisementModuleHelper:getDrawList(player, notCheckUnlock)
  local drawList = {}
  local rewardList = AdvertisementPoolConfig:getAllCfgs()
  local len = #rewardList
  for i = 1, #rewardList do
    local rewardCfg = rewardList[i]
    local itemType = rewardCfg.itemType
    local itemId = rewardCfg.itemId
    if notCheckUnlock or not player:checkBusinessItemUnlock(itemType, itemId) then
      drawList[#drawList + 1] = rewardCfg
    end
  end
  return drawList
end

function AdvertisementModuleHelper:checkCanDraw(player)
  local drawCountData = player:getDrawCountData()
  if not drawCountData or not drawCountData.ts then
    return true
  end
  if World.isClient then
    return drawCountData.count > 0
  else
    local nowTime = os.time()
    local ts = drawCountData.ts
    if not Lib.isSameDay(ts, nowTime) or drawCountData.count > 0 then
      return true
    end
  end
  return false
end

function AdvertisementModuleHelper:checkCanLockSlot(player)
  local lockSlotData = player:getLockSlotData()
  if lockSlotData and next(lockSlotData) then
    local count = 0
    for k, v in pairs(lockSlotData) do
      count = count + 1
    end
    return count < 2
  end
  return true
end

function AdvertisementModuleHelper:checkCanOpenWnd()
  if Me and Me.isValid and Me:isValid() then
    local openWndData = Me:getOpenWndData()
    local nowTime = os.time()
    if openWndData and Lib.isSameDay(openWndData, nowTime) then
      return false
    end
    local dailyLoginData = Me:getDailyLoginData()
    if not dailyLoginData or nowTime - dailyLoginData < 60 then
      return false
    end
    return true
  end
  return false
end

function AdvertisementModuleHelper:costDrawCount(player)
  if World.isClient then
    return false
  end
  local drawCountData = player:getDrawCountData() or {}
  local nowTime = os.time()
  local ts = drawCountData.ts
  if ts and 0 < ts and Lib.isSameDay(ts, nowTime) then
    local count = drawCountData.count
    if not count or count <= 0 then
      return false
    end
    drawCountData.count = count - 1
  else
    drawCountData.count = Define.ADVERTISEMENT_DAILY_DRAW_COUNT - 1
  end
  drawCountData.ts = nowTime
  player:setDrawCountData(drawCountData)
  return true
end

function AdvertisementModuleHelper:updateDrawCountData(player)
  if World.isClient then
    return
  end
  local drawCountData = player:getDrawCountData() or {}
  local nowTime = os.time()
  if not drawCountData.ts or not Lib.isSameDay(nowTime, drawCountData.ts) then
    drawCountData.ts = nowTime
    drawCountData.count = Define.ADVERTISEMENT_DAILY_DRAW_COUNT
    player:setDrawCountData(drawCountData)
  end
end

function AdvertisementModuleHelper:doDrawReward(player)
  if World.isClient then
    if Me and Me.isValid and Me:isValid() then
      if not self:checkCanDraw(Me) then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.advertisement.draw.out.of.count"))
        return
      end
      if Me:requestWatchAd(Define.AdvertisingType.AdvertisementDraw) then
        self.isWaitWatchResult = true
      end
    end
  else
    local stateCode = -1
    local rewardIds
    if self:costDrawCount(player) then
      local drawList = self:getDrawList(player)
      local rewardList = self:drawReawrds(player, drawList)
      player:setLockSlotData({})
      if rewardList and 0 < #rewardList then
        local rewardCounts = {}
        local freeItemData = player:getFreeItemData() or {}
        rewardIds = {}
        stateCode = 0
        for i = 1, #rewardList do
          local id = rewardList[i].id
          rewardCounts[id] = (rewardCounts[id] or 0) + 1
        end
        for i = 1, #rewardList do
          local rewardCfg = rewardList[i]
          local id = rewardList[i].id
          local itemType = rewardCfg.itemType
          local itemId = rewardCfg.itemId
          local itemCount = rewardCfg.itemCount
          if rewardCounts[id] then
            if rewardCounts[id] == 2 then
              itemCount = itemCount * 2
            elseif rewardCounts[id] == 3 then
              itemCount = itemCount * 5
            end
          end
          local typeItems = freeItemData[itemType] or {}
          typeItems[itemId] = (typeItems[itemId] or 0) + itemCount
          freeItemData[itemType] = typeItems
          rewardIds[#rewardIds + 1] = id
        end
        player:setFreeItemData(freeItemData)
      else
        stateCode = 2
      end
    else
      stateCode = 1
    end
    player:sendPacket({
      pid = Define.ADVERTISEMENT_PID.Draw,
      objID = player.objID,
      state_code = stateCode,
      reward_ids = rewardIds
    })
  end
end

function AdvertisementModuleHelper:doLockSlot(lockSlot, lockId, player)
  if World.isClient then
    if Me and Me.isValid and Me:isValid() then
      local lockSlotData = Me:getLockSlotData()
      if lockSlotData and lockSlotData[lockSlot] then
        return
      end
      if not self:checkCanLockSlot(Me) then
        return
      end
      if Me:requestWatchAd(Define.AdvertisingType.AdvertisementLockSlot, tostring(lockSlot) .. "|" .. tostring(lockId)) then
        self.isWaitWatchResult = true
      end
    end
  else
    local stateCode = -1
    if lockSlot and lockId then
      local lockSlotData = player:getLockSlotData() or {}
      lockSlotData[lockSlot] = lockId
      player:setLockSlotData(lockSlotData)
      stateCode = 0
    else
      stateCode = 1
    end
    player:sendPacket({
      pid = Define.ADVERTISEMENT_PID.LockSlot,
      objID = player.objID,
      state_code = stateCode,
      lock_slot = lockSlot,
      lock_id = lockId
    })
  end
end

function AdvertisementModuleHelper:onDrawReward(stateCode, rewwardIds)
  self.isWaitWatchResult = false
  if stateCode == 0 then
    Me:setDrawItemData(rewwardIds or {})
  else
    local tip
    if stateCode == 1 then
      tip = Lang:toText("g2052.gui.advertisement.draw.out.of.count")
    elseif stateCode == 2 then
      tip = Lang:toText("g2052.gui.advertisement.draw.reward.all.gain")
    elseif stateCode == -1 then
    end
    if tip then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tip)
    end
  end
  Lib.emitEvent(Event.EVENT_ADVERTISEMENT_MODULE_ON_DRAW_RESULT, stateCode, rewwardIds)
end

function AdvertisementModuleHelper:onLockSlot(stateCode, lockSlot, lockId)
  self.isWaitWatchResult = false
  if stateCode ~= 0 then
    local tip
    if stateCode == 1 then
      tip = Lang:toText("g2052.gui.advertisement.lock.slot.fail")
    end
    if tip then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tip)
    end
  end
  Lib.emitEvent(Event.EVENT_ADVERTISEMENT_MODULE_ON_LOCK_RESULT, stateCode, lockSlot, lockId)
end

function AdvertisementModuleHelper:getFreeItemCount(player, itemType, itemId)
  local freeItemData = player:getFreeItemData()
  if freeItemData and freeItemData[itemType] then
    return freeItemData[itemType][itemId] or 0
  end
  return 0
end

function AdvertisementModuleHelper:costFreeItem(player, itemType, itemId)
  if World.isClient then
    return
  end
  local freeItemData = player:getFreeItemData()
  if freeItemData and freeItemData[itemType] and freeItemData[itemType][itemId] then
    local count = freeItemData[itemType][itemId]
    freeItemData[itemType][itemId] = count - 1
    player:setFreeItemData(freeItemData)
  end
end

function AdvertisementModuleHelper:initSceneAdvertisement(player)
  if not (World.isClient and World.cfg.advertisement_moduleSetting) or not World.cfg.advertisement_moduleSetting.openSceneAdvertisement then
    return
  end
  local sceneParts = {}
  local sceneTypePoints = {}
  local allParts = AdvertisementScenePartConfig:getAllCfgs()
  if allParts and next(allParts) then
    for k, v in pairs(allParts) do
      local itemType = v.itemType
      local itemId = v.itemId
      if not player:checkBusinessItemUnlock(itemType, itemId) then
        sceneParts[#sceneParts + 1] = v
      end
    end
  end
  local typeList = {
    Define.BUSINESS_ITEM_TYPE.Dress,
    Define.BUSINESS_ITEM_TYPE.Pet,
    Define.BUSINESS_ITEM_TYPE.Car
  }
  for i, v in ipairs(typeList) do
    sceneTypePoints[v] = AdvertisementScenePointConfig:getTypeCfgs(v)
  end
  local len = math.min(#sceneParts, Define.ADVERTISEMENT_SCENE_PART_COUNT)
  if 0 < len then
    local this = self
    for i = 1, len do
      local randPart = math.random(1, #sceneParts)
      local scenePartCfg = sceneParts[randPart]
      table.remove(sceneParts, randPart)
      local itemType = scenePartCfg.itemType
      local scenePoints = sceneTypePoints[itemType]
      if scenePoints and 0 < #scenePoints then
        do
          local partId = scenePartCfg.id
          local itemId = scenePartCfg.itemId
          local randPoint = math.random(1, #scenePoints)
          local scenePointCfg = scenePoints[randPoint]
          local pointId = scenePointCfg.id
          table.remove(scenePoints, randPoint)
          local point = scenePointCfg.point
          local yaw = scenePointCfg.yaw
          local partPos = Lib.v3(point.x, point.y + scenePartCfg.offsetY, point.z)
          local btnPos = Lib.v3(point.x, point.y + scenePartCfg.btnOffsetY, point.z)
          LuaTimer:scheduleTimer(function()
            local scenePart = this:createSceneAdvertisementPart(itemType, itemId, partPos)
            if scenePart then
              local btnPart = this:createSceneAdvertisementButton(partId, btnPos)
              this.sceneParts[partId] = {
                partId = partId,
                pointId = pointId,
                part = scenePart,
                btnPart = btnPart
              }
            end
          end, 200, 1)
        end
      end
    end
  end
end

function AdvertisementModuleHelper:printSceneAdvertisementPart()
  if not World.isClient then
    return
  end
  local init_list = {}
  if self.sceneParts and next(self.sceneParts) then
    for k, v in pairs(self.sceneParts) do
      init_list[#init_list + 1] = {
        pointId = v.pointId,
        partId = v.partId
      }
    end
  end
  if init_list and 0 < #init_list then
    Lib.logDebug("scene advertisement init_list:", Lib.v2s(init_list))
  else
    Lib.logDebug("scene advertisement init_list: null")
  end
end

function AdvertisementModuleHelper:createSceneAdvertisementPart(itemType, itemId, partPos, yaw)
  if not World.isClient then
    return
  end
  yaw = yaw or 0
  if itemType == Define.BUSINESS_ITEM_TYPE.Dress then
    local cfgName = Me:checkSex() == 1 and "myplugin/player_model" or "myplugin/player_model_girl"
    local playerEntity = EntityClient.CreateClientEntity({
      cfgName = cfgName,
      map = Me.map,
      pos = partPos,
      ry = yaw,
      name = ""
    })
    if playerEntity then
      playerEntity:playClientAction("idle", -1)
      playerEntity:setAlwaysAction("idle")
      playerEntity:setRotationYaw(yaw)
      local skinCfg = AppearanceConfig:getCfgById(itemId)
      local skinData = skinCfg and skinCfg.parts or nil
      local conflictParts = skinCfg and skinCfg.conflictParts or nil
      local conflictOriginal = skinCfg and skinCfg.conflictOriginal or nil
      if skinData and next(skinData) then
        local mySkin = Lib.copyTable1(skinData)
        if conflictParts and next(conflictParts) then
          for k, v in pairs(conflictParts) do
            mySkin[v] = "0"
          end
        end
        if conflictOriginal and next(conflictOriginal) then
          for k, v in pairs(conflictOriginal) do
            mySkin[v] = "0"
          end
        end
        playerEntity:applySkinPart(mySkin)
      else
        Lib.logError("invalid skinData, id:", tostring(itemId))
      end
    else
      Lib.logError("invalid player entity!")
    end
    return playerEntity
  elseif itemType == Define.BUSINESS_ITEM_TYPE.Pet then
    local petCfg = PetConfig:getCfgById(itemId)
    if not (petCfg and petCfg.actorName) or petCfg.actorName == "" then
      Lib.logError("invalid petCfg, id:", tostring(itemId))
      return
    end
    local petEntity = EntityClient.CreateClientEntity({
      cfgName = "myplugin/pet_model",
      map = Me.map,
      pos = partPos,
      ry = yaw,
      name = ""
    })
    if petEntity then
      petEntity:changeActor(petCfg.actorName)
      petEntity:playClientAction("idle", -1)
      petEntity:setAlwaysAction("idle")
      petEntity:setRotationYaw(yaw)
    else
      Lib.logError("invalid pet entity!")
    end
    return petEntity
  elseif itemType == Define.BUSINESS_ITEM_TYPE.Car then
    local carCfg = CarConfig:getCfgById(itemId)
    if not (carCfg and carCfg.throwCfgName) or carCfg.throwCfgName == "" then
      Lib.logError("invalid carCfg, id:", tostring(itemId))
      return
    end
    local carPart
    if carCfg.carType == Define.VEHICLE_TYPE.Primary then
      local params = {
        cfgName = carCfg.throwCfgName,
        map = Me.map,
        pos = partPos,
        ry = yaw,
        name = ""
      }
      carPart = EntityClient.CreateClientEntity(params)
      if carPart then
        carPart:setProp("gravity", 0)
        carPart:setProp("collision", "false")
        carPart:setRotationYaw(yaw)
      end
    elseif carCfg.carType == Define.VEHICLE_TYPE.Advanced then
      local cfg = PartCfg:get(carCfg.throwCfgName)
      if not cfg then
        Lib.logError("invalid plugin cfg, name:", tostring(carCfg.throwCfgName))
        return
      end
      local manager = World.CurWorld:getSceneManager()
      local scene = manager:getOrCreateScene(Me.map.obj)
      carPart = Instance.newInstance(cfg, Me.map)
      if carPart then
        local rotation = Lib.v3(0, yaw, 0)
        carPart:setParent(scene:getRoot())
        carPart:setProperty("useCollide", "false")
        carPart:setProperty("useGravity", "false")
        carPart:setPosition(partPos)
        carPart:setRotation(rotation)
        if carCfg.defaultColor then
          self:changeCarColor(carPart, carCfg.defaultColor)
        end
      end
    end
    if not carPart then
      Lib.logError("invalid car obj! id:", tostring(itemId))
    end
    return carPart
  else
    Lib.logError("invalid itemType:", tostring(itemType))
  end
end

function AdvertisementModuleHelper:changeCarColor(node, defaultColor)
  local scriptName = node:getScriptName()
  if (scriptName == "Part" or scriptName == "MeshPart") and node:getName() == "colorchange" then
    node:setColor(defaultColor)
  end
  local allChild = node:getAllChild()
  if allChild and next(allChild) then
    for k, v in pairs(allChild) do
      self:changeCarColor(v, defaultColor)
    end
  end
end

function AdvertisementModuleHelper:createSceneAdvertisementButton(partId, btnPos)
  local cfg = PartCfg:get("myplugin/scene_advertisemenet")
  if not cfg then
    Lib.logError("invalid plugin cfg, name:myplugin/scene_advertisemenet")
    return
  end
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(Me.map.obj)
  local btnPart = Instance.newInstance(cfg, Me.map)
  if btnPart then
    btnPart:setParent(scene:getRoot())
    btnPart:setPosition(btnPos)
    btnPart.___scene_part_id = partId
  end
  return btnPart
end

function AdvertisementModuleHelper:doOnSceneAdvertisemenetClick(partId, player)
  if World.isClient then
    if Me:requestWatchAd(Define.AdvertisingType.AdvertisementScene, tostring(partId)) then
      self.isWaitWatchResult = true
    end
  else
    local scenePartCfg = AdvertisementScenePartConfig:getCfgById(partId)
    local stateCode = -1
    if scenePartCfg then
      stateCode = 0
      local freeItemData = player:getFreeItemData() or {}
      local itemType = scenePartCfg.itemType
      local itemId = scenePartCfg.itemId
      local itemCount = scenePartCfg.itemCount
      local typeItems = freeItemData[itemType] or {}
      typeItems[itemId] = (typeItems[itemId] or 0) + itemCount
      freeItemData[itemType] = typeItems
      player:setFreeItemData(freeItemData)
    end
    player:sendPacket({
      pid = Define.ADVERTISEMENT_PID.SceneClick,
      objID = player.objID,
      state_code = stateCode,
      part_id = partId
    })
  end
end

function AdvertisementModuleHelper:onSceneAdvertisemenetClick(stateCode, partId)
  self.isWaitWatchResult = false
  local tip
  if stateCode == 0 then
    if self.sceneParts[partId] then
      local scenePart = self.sceneParts[partId]
      self.sceneParts[partId] = nil
      local part = scenePart.part
      local btnPart = scenePart.btnPart
      if part and part:isValid() then
        part:destroy()
      end
      if btnPart and btnPart:isValid() then
        btnPart:destroy()
      end
    end
    local scenePartCfg = AdvertisementScenePartConfig:getCfgById(partId)
    if scenePartCfg then
      local itemList = {}
      itemList[#itemList + 1] = {
        itemId = scenePartCfg.itemId,
        itemCount = scenePartCfg.itemCount,
        itemType = scenePartCfg.itemType
      }
      UI:openWnd("g2052AdvertisementRewardCommon", itemList)
    end
  else
    tip = Lang:toText("g2052.gui.advertisement.draw.fail")
  end
  if tip then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tip)
  end
end

AdvertisementModuleHelper:init()
return AdvertisementModuleHelper
