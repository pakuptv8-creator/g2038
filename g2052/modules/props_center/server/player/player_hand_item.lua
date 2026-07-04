local PropsConfig = T(Config, "PropsConfig")
local InteractEventConfig = T(Config, "InteractEventConfig")
local Player = _ENV.Player
local setting = require("common.setting")
local PartCfg = setting:mod("part")

local function createPart(cfg, entity)
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(entity.map.obj)
  local part = Instance.Create(cfg.class)
  part:setSize(cfg.properties.scale)
  for k, v in pairs(cfg.properties or {}) do
    part:setProperty(k, v)
  end
  part:setParent(scene:getRoot())
  return part
end

function Player:cancelThrowProp()
  if self:data("main").throwObj and self:data("main").throwObj:isValid() then
    self:data("main").throwObj:destroy()
    self:data("main").throwObj = nil
  end
  if World.cfg.isUseClientFootBall then
    WorldServer.BroadcastPacket({
      pid = "CancelClientThrowProp",
      objID = self.objID
    })
  end
end

function Player:onUseThrowObjProp(prop)
  self:cancelThrowProp()
  local itemId = prop.itemId
  local itemInfo = PropsConfig:getCfgById(itemId)
  if World.cfg.isUseClientFootBall and itemInfo and itemInfo.isThrowObj == Define.ThrowObjType.Football then
    WorldServer.BroadcastPacket({
      pid = "createClientFootball",
      objID = self.objID,
      cfgName = itemInfo.throwCfgName,
      throwPos = itemInfo.throwPos
    })
    return
  end
  local index
  local handBagsInfo = self:getHandbagsInfo()
  for _, v in pairs(handBagsInfo) do
    if v.itemId == itemId and v.inUse == true then
      index = v.index
      break
    end
  end
  if itemInfo.isThrowObj > 0 and (itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem or itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex and index == itemInfo.throwActionIndex) and itemInfo.throwCfgName ~= "" then
    local throwPos = itemInfo.throwPos
    local dis = throwPos[1] or 0
    local offset = Lib.v3(throwPos[2] or 0, throwPos[3] or 0, throwPos[4] or 0)
    if itemInfo.throwCfgType == "entity" then
      local cfgName = itemInfo.throwCfgName
      if cfgName ~= "" then
        local pos = self:getFrontPos(dis, true, false) + offset
        local params = {
          cfgName = cfgName,
          map = self.map,
          pos = pos,
          ry = self:getRotationYaw()
        }
        local entity = EntityServer.Create(params)
        if entity then
          local cfg = entity:cfg()
          if cfg and cfg.rideOnImmediately and cfg.rideOnImmediately == true then
            if 0 >= itemInfo.rideOnPlayerIndex then
              local oldPartId = self:getInteractionPartID()
              if oldPartId ~= "" then
                self:doStopPlayerFurniture()
                local pos2 = self:getFrontPos(dis, true, false) + offset
                entity:setPosition(pos2)
              end
              self:removeUsingVehicle()
            end
            if self:isCatchAsRobber() then
              self:setCatchAsRobber(false)
            end
            if 0 < itemInfo.rideOnPlayerIndex then
              self:sendPacket({
                pid = "UpdateUseTrolley",
                inUse = true
              })
              entity:rideOn(self, nil, itemInfo.rideOnPlayerIndex)
            else
              self:rideOn(entity, nil, 1)
            end
            self:data("main").throwEntity = entity
          end
          Plugins.CallTargetPluginFunc("garbage_collector", "register", "entity", entity.objID, self.platformUserId)
        end
      end
    elseif itemInfo.throwCfgType == "part" then
      local cfg = PartCfg:get(itemInfo.throwCfgName)
      if not cfg then
        return
      end
      local manager = World.CurWorld:getSceneManager()
      local scene = manager:getOrCreateScene(self.map.obj)
      local part = Instance.newInstance(cfg, self.map)
      if part then
        part:setParent(scene:getRoot())
        local pos = self:getFrontPos(dis, true, false) + offset
        part:setPosition(pos)
        self:data("main").throwObj = part
      end
    end
  end
end

function Player:onUseHandItem(useProp)
  if not useProp then
    return
  end
  self:onUseThrowObjProp(useProp)
end

local function checkCanUse(player, itemInfo, curIndex)
  local function isInHelicopter()
    if player.rideOnId and player.rideOnId > 0 then
      local target = World.CurWorld:getEntity(player.rideOnId)
      
      if target and target:cfg().isAircraft == true then
        return true
      end
    end
    return false
  end
  
  local index = curIndex + 1
  if (player:isSwimming() or isInHelicopter()) and itemInfo.throwCfgType == "entity" and (itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex and index == itemInfo.throwActionIndex or itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem) then
    return false
  end
  if isInHelicopter() and itemInfo.isThrowObj == Define.Prop.ThrowObj.Football then
    return false
  end
  return true
end

function Player:useHandItem(params, initBuff)
  local slot = params.slot
  local handbagsInfo = self:getHandbagsInfo()
  if handbagsInfo[slot] then
    local itemId = handbagsInfo[slot].itemId
    local itemInfo = PropsConfig:getCfgById(itemId)
    if itemInfo and not handbagsInfo[slot].inUse then
      local canUse = checkCanUse(self, itemInfo, 0)
      if not canUse then
        return
      end
      local inUseProp = self:getInUseProp()
      if inUseProp then
        self:cancelHandItem({
          inUseProp.itemId
        })
      end
      local buffIndex = initBuff or 1
      if itemInfo.buffs and itemInfo.buffs[buffIndex] then
        self:addBuff(itemInfo.buffs[buffIndex])
      end
      self:selectHandItem(slot, buffIndex)
      if not self.useItemBeginTime then
        self.useItemBeginTime = {}
      end
      self.useItemBeginTime[itemId] = os.time()
      self:onUseHandItem(handbagsInfo[slot])
      self:addOneItemCount()
      if not self.isFirstUseItem then
        Plugins.CallTargetPluginFunc("report", "report", "first_item", nil, self)
        self.isFirstUseItem = true
      end
      local shopBasketInfo = self:getShopBasketInfo()
      if shopBasketInfo[itemId] and shopBasketInfo[itemId].parts and next(shopBasketInfo[itemId].parts) then
        self:changeSkinPart(shopBasketInfo[itemId].parts)
      end
    end
  end
end

function Player:handItemStyleSwitch()
  local inUseItem
  local handBagsInfo = self:getHandbagsInfo()
  for k, v in pairs(handBagsInfo) do
    if v.inUse == true then
      inUseItem = handBagsInfo[k]
      break
    end
  end
  if inUseItem then
    local itemInfo = PropsConfig:getCfgById(inUseItem.itemId)
    local buffs = itemInfo.buffs
    if not buffs then
      return
    end
    local curIndex = inUseItem.index
    local canSwitch = checkCanUse(self, itemInfo, curIndex)
    if not canSwitch then
      return
    end
    local buff = self:getTypeBuff("fullName", buffs[curIndex])
    self:removeBuff(buff)
    local targetIndex = curIndex + 1
    if buffs[targetIndex] then
      self:addBuff(buffs[targetIndex])
      inUseItem.index = targetIndex
    else
      self:addBuff(buffs[1])
      inUseItem.index = 1
    end
    self:setHandbagsInfo(handBagsInfo)
    if itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex then
      self:onUseHandItem(inUseItem)
    end
  end
end

function Player:removeHandItem(params)
  local handbagsInfo = self:getHandbagsInfo()
  local slot = params.slot
  local itemId = params.itemId
  if not itemId and slot then
    local targetItem = handbagsInfo[slot]
    if not targetItem then
      return
    end
    itemId = targetItem.itemId
  end
  self:cancelHandItem(params)
  self:removeHandItemDataById(itemId)
end

function Player:removeAllHandItem()
  local handBagsInfo = self:getHandbagsInfo()
  for _, info in pairs(handBagsInfo or {}) do
    self:removeHandItem({
      itemId = info.itemId
    })
  end
end

function Player:onCancelHandItem(prop)
  if not prop then
    return
  end
  local cfg = PropsConfig:getCfgById(prop.itemId)
  if cfg and cfg.isThrowObj > 0 and cfg.throwTrigger == Define.ThrowObjTrigger.useItem and cfg.throwCfgName ~= "" then
    self:cancelThrowProp()
  end
  Plugins.CallTargetPluginFunc("report", "report", "item_use", nil, self)
end

function Player:cancelHandItem(params)
  local handbagsInfo = self:getHandbagsInfo()
  local slot = params.slot
  local itemId = params.itemId
  local inUseItem = self:getInUseProp()
  if not inUseItem then
    if itemId then
      inUseItem = self:getHandBagItemByItemId(itemId)
    elseif not itemId and slot then
      inUseItem = handbagsInfo[slot]
    end
  end
  if not inUseItem or inUseItem.inUse ~= true then
    return
  end
  itemId = inUseItem.itemId
  if inUseItem and inUseItem.itemId == itemId then
    self:removeHandItemBuff()
  end
  self:onCancelHandItem(inUseItem)
  self:setHandItemInUseById(itemId, false)
end

function Player:cancelAllHandItem()
  local inUseItem = self:getInUseProp()
  if inUseItem and inUseItem.itemId > 0 then
    self:cancelHandItem({
      itemId = inUseItem.itemId
    })
  end
end

function Player:removeHandItemBuff(inUseItem)
  inUseItem = inUseItem or self:getInUseProp()
  if inUseItem then
    local itemInfo = PropsConfig:getCfgById(inUseItem.itemId)
    local buffs = itemInfo.buffs or {}
    local curIndex = inUseItem.index
    local buff = self:getTypeBuff("fullName", buffs[curIndex])
    self:removeBuff(buff)
    self:clearPropDynamicPart(inUseItem.itemId)
  end
end

function Player:addHandItem(itemId)
  itemId = tonumber(itemId)
  local item = PropsConfig:getCfgById(itemId)
  if item then
    self:addHandbagsInfo(itemId)
  end
end

function Player:removeInUseHandItem()
  local inUseProp = self:getInUseProp()
  if not inUseProp then
    return
  end
  self:removeHandItem({
    itemId = inUseProp.itemId
  })
end

function Player:onOperationBag(params)
  local inUseItem = self:getInUseProp()
  if params and params.id then
    local isRemove = self:operationHandbagsInfo(params.id)
    if not isRemove then
      local index = self:getHandBagIndexByItemId(params.id)
      if index then
        self:useHandItem({slot = index})
      end
    end
  end
end

local function randomDropItem(poolCfg)
  local pool = {}
  for i, val in pairs(poolCfg) do
    local item = {
      itemId = val.itemId,
      weight = val.weight
    }
    table.insert(pool, item)
  end
  local item = Lib.randomItemByWeight(1, pool, false)
  if item and item[1] then
    return item[1].itemId
  end
  return 0
end

function Player:dealPickPropPool(params)
  local propPool = Lib.splitString(params, ";")
  local propsPoolList = {}
  for key, val in pairs(propPool) do
    local temp = Lib.splitString(val, "#", true)
    propsPoolList[key] = {}
    propsPoolList[key].itemId = tonumber(temp[1])
    propsPoolList[key].weight = tonumber(temp[2]) or 1
  end
  return randomDropItem(propsPoolList)
end

function Player:onPickProp(type, target, params)
  if params then
    if params[2] and tonumber(params[2]) == 1 then
      local PartManagerHelper = T(Lib, "PartManagerHelper")
      PartManagerHelper:doDestroyPart(target)
    end
    local itemId = self:dealPickPropPool(params[1])
    if self:canHandleShoppingBasket(itemId) then
      self:doHandleShoppingBasket(itemId)
      return
    end
    local buffIndex = tonumber(params[3]) or 1
    self:addHandItemAndUse(itemId, buffIndex)
  end
end

function Player:isAddIntoShoppingBasket(itemId)
  local hasPartKey = false
  local cfg = PropsConfig:getCfgById(itemId)
  local dynamicPart = cfg.dynamicPart
  local inUseProp = self:getInUseProp()
  if not inUseProp then
    return false
  end
  local curDynamicInfo = dynamicPart[inUseProp.itemId]
  if not curDynamicInfo then
    return false
  end
  local shopBasketInfo = self:getShopBasketInfo()
  if not shopBasketInfo[curDynamicInfo.inUsePropId] then
    return false
  end
  if cfg and curDynamicInfo then
    for k, v in pairs(curDynamicInfo.part) do
      if shopBasketInfo[curDynamicInfo.inUsePropId].parts[k] ~= nil then
        hasPartKey = true
        break
      end
    end
  end
  return shopBasketInfo[curDynamicInfo.inUsePropId].ids[itemId] == nil and not hasPartKey
end

function Player:addItemToShoppingBasket(itemId)
  if not self:isAddIntoShoppingBasket(itemId) then
    return
  end
  local cfg = PropsConfig:getCfgById(itemId)
  if not cfg then
    return
  end
  local dynamicPart = cfg.dynamicPart
  if not dynamicPart then
    return
  end
  local inUseProp = self:getInUseProp()
  if not inUseProp then
    return false
  end
  local curDynamicInfo = dynamicPart[inUseProp.itemId]
  if not curDynamicInfo then
    return false
  end
  local shopBasketInfo = self:getShopBasketInfo()
  for k, v in pairs(curDynamicInfo.part) do
    shopBasketInfo[curDynamicInfo.inUsePropId].parts[k] = v
  end
  shopBasketInfo[curDynamicInfo.inUsePropId].ids[itemId] = true
  self:changeSkinPart(curDynamicInfo.part)
  self:setShopBasketInfo(shopBasketInfo)
  Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.props.loading_success")
end

function Player:canHandleShoppingBasket(itemId)
  local inUseProp = self:getInUseProp()
  if not inUseProp then
    return false
  end
  local cfg = PropsConfig:getCfgById(itemId)
  if not cfg then
    return
  end
  local dynamicPart = cfg.dynamicPart
  if not dynamicPart then
    return false
  end
  for basketId, val in pairs(dynamicPart) do
    if basketId == inUseProp.itemId then
      self:addOneBasketInfo(val.inUsePropId)
      return true
    end
  end
  return false
end

function Player:doHandleShoppingBasket(itemId)
  if self:isAddIntoShoppingBasket(itemId) then
    self:addItemToShoppingBasket(itemId)
  else
    self:removeItemFromShoppingBasket(itemId)
  end
end

function Player:removeItemFromShoppingBasket(itemId)
  local cfg = PropsConfig:getCfgById(itemId)
  if not cfg then
    return
  end
  local inUseProp = self:getInUseProp()
  if not inUseProp then
    return false
  end
  local dynamicPart = cfg.dynamicPart
  local tmp = {}
  local curDynamicInfo = dynamicPart[inUseProp.itemId]
  if not curDynamicInfo then
    return false
  end
  local shopBasketInfo = self:getShopBasketInfo()
  if not shopBasketInfo[curDynamicInfo.inUsePropId] then
    return
  end
  if not shopBasketInfo[curDynamicInfo.inUsePropId].ids[itemId] then
    return
  end
  if cfg and curDynamicInfo then
    for k, _ in pairs(curDynamicInfo.part) do
      tmp[k] = ""
      shopBasketInfo[curDynamicInfo.inUsePropId].parts[k] = nil
    end
  end
  self:changeSkinPart(tmp)
  shopBasketInfo[curDynamicInfo.inUsePropId].ids[itemId] = nil
  self:setShopBasketInfo(shopBasketInfo)
  Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.props.unload_success")
end

function Player:clearPropDynamicPart(itemId)
  local shopBasketInfo = self:getShopBasketInfo()
  if not shopBasketInfo[itemId] then
    return
  end
  local tmp = {}
  for k, _ in pairs(shopBasketInfo[itemId].parts) do
    tmp[k] = ""
  end
  self:changeSkinPart(tmp)
end

function Player:addHandItemAndUse(itemId, buffIndex)
  if itemId then
    self:addHandItem(itemId)
    local index = self:getHandBagIndexByItemId(itemId)
    if index then
      self:useHandItem({slot = index}, buffIndex)
    end
  end
end

function Player:onReceiveProp(itemId)
  local inUseProp = self:getInUseProp()
  if inUseProp and inUseProp.itemId == itemId then
    Lib.logDebug("onReceiveProp: has in use")
    Plugins.CallTargetPluginFunc("report", "report", "item_get", nil, self)
    return
  end
  local index = self:getHandBagIndexByItemId(itemId)
  if index then
    Lib.logDebug("onReceiveProp: has in hand bag")
    self:useHandItem({slot = index})
    Plugins.CallTargetPluginFunc("report", "report", "item_get", nil, self)
    return
  end
  self:onOperationBag({id = itemId})
  Plugins.CallTargetPluginFunc("report", "report", "item_get", nil, self)
end

function Player:onSendProp(itemId, targetUserId)
  Plugins.CallTargetPluginFunc("report", "report", "item_give", nil, self)
  self:cancelHandItem({itemId = itemId})
  if not self.heartWarmGiftSend then
    self.heartWarmGiftSend = {}
  end
  if not self.heartWarmGiftSend[targetUserId] then
    Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", self, Define.HEART_WARM_TASK_TYPE.GIFT_OTHERS)
    self.heartWarmGiftSend[targetUserId] = true
  end
end

function Player:checkItemIdTimeCanPlace(itemId)
  if not self.useItemBeginTime then
    self.useItemBeginTime = {}
    return false
  end
  if self.useItemBeginTime[itemId] then
    return os.time() - 1 >= self.useItemBeginTime[itemId]
  end
  return false
end

function Player:cancelVehicleItemUse(isExcludeRideOnPlayer)
  local slot, inUseItem
  local handBagsInfo = self:getHandbagsInfo()
  for k, v in pairs(handBagsInfo) do
    if v.inUse == true then
      slot = k
      inUseItem = v
      break
    end
  end
  if slot then
    local itemInfo = PropsConfig:getCfgById(inUseItem.itemId)
    if itemInfo.throwCfgType == "entity" and (itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem or itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex and inUseItem.index == itemInfo.throwActionIndex) then
      if isExcludeRideOnPlayer and itemInfo.rideOnPlayerIndex > 0 then
        return false
      end
      self:cancelHandItem({slot = slot})
      return true
    end
  end
  return false
end

function Player:setGhostDetectorStyle(type, target, params, isBreak)
  if not (target and type and params and params[1] and params[2] and params[3]) or not params[4] then
    print("!!!!!!!!!!!!!!!!!!!!! setGhostDetectorStyle error ,param:", Lib.v2s(params))
    return
  end
  if not self.ghostDetectorOpenStatus then
    self.ghostDetectorOpenStatus = tonumber(params[1])
    self.ghostDetectorCloseStatus = tonumber(params[2])
    self.ghostDetectorOpenCounter = 0
  end
  self:setGhostDetectorStyleByArea(type, target, params, isBreak)
end

function Player:setGhostDetectorStyleByArea(type, target, params, isBreak)
  local isOpen
  if type ~= Define.PART_INTERACT_TYPE.TOUCH_BEGIN and type ~= Define.PART_INTERACT_TYPE.TOUCH_END then
    return
  end
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    isOpen = true
    HouseManager:updatePlayerInGhostDetectorArea(true, target, self)
    if not target:isValid() then
      return
    end
    local nodes = {}
    Lib.getInstanceAllChild(target:getParent(), nodes, Define.ABILITY.AABB, params[4])
    if #nodes < 1 then
      return
    end
    if not nodes[1].isGhostAppear then
      return
    end
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    isOpen = false
    HouseManager:updatePlayerInGhostDetectorArea(false, target, self)
  end
  self:setGhostDetectorStatus(target, tonumber(params[3]), isOpen)
end

function Player:setGhostDetectorStatus(part, itemId, isOpen)
  if not self.ghostDetectorOpenStatus then
    return
  end
  if not isOpen then
    if not part.openGhostDetectorPlayerList or not part.openGhostDetectorPlayerList[self.platformUserId] then
      return
    end
    part.openGhostDetectorPlayerList[self.platformUserId] = nil
    self.ghostDetectorOpenCounter = math.max(0, self.ghostDetectorOpenCounter - 1)
  else
    if not part.openGhostDetectorPlayerList then
      part.openGhostDetectorPlayerList = {}
    end
    part.openGhostDetectorPlayerList[self.platformUserId] = true
    self.ghostDetectorOpenCounter = self.ghostDetectorOpenCounter + 1
  end
  isOpen = self.ghostDetectorOpenCounter >= 1
  local itemIndex = isOpen and self.ghostDetectorOpenStatus or self.ghostDetectorCloseStatus
  self:setUseItemIndex(itemId, itemIndex)
end

function Player:setUseItemIndex(itemId, itemIndex)
  if not itemIndex or not itemId then
    return
  end
  local handBagsInfo = self:getHandbagsInfo()
  local inUseItem = self:getUsingItem(handBagsInfo)
  if inUseItem and inUseItem.itemId == itemId and inUseItem.index ~= itemIndex then
    local itemInfo = PropsConfig:getCfgById(inUseItem.itemId)
    local buffs = itemInfo.buffs
    if not buffs or not buffs[itemIndex] then
      return
    end
    local curIndex = inUseItem.index
    local canSwitch = checkCanUse(self, itemInfo, curIndex)
    if not canSwitch then
      return
    end
    local buff = self:getTypeBuff("fullName", buffs[curIndex])
    self:removeBuff(buff)
    self:addBuff(buffs[itemIndex])
    inUseItem.index = itemIndex
    self:setHandbagsInfo(handBagsInfo)
  end
end

function Player:getUsingItem(handBagsInfo)
  local inUseItem
  for k, v in pairs(handBagsInfo) do
    if v.inUse == true then
      inUseItem = handBagsInfo[k]
      break
    end
  end
  return inUseItem
end
