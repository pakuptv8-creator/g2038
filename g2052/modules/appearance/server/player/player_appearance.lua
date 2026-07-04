local Player = _ENV.Player
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local DyeingStatusMgr = T(Lib, "DyeingStatusMgr")
local AppearanceConfig = T(Config, "AppearanceConfig")

local function getAngele(yaw)
  local angle = yaw / 180 * math.pi
  return math.floor(angle * 100000) / 100000
end

function Player:getNewWithShapeScale(pos, yaw, initOffset)
  local shapeOffset = initOffset or Lib.v3(0, 0, 0)
  local shapeScale = self:getShapeScale()
  if DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    if self.getGiantShape then
      shapeScale = self:getGiantShape()
    end
  elseif self.getShapeScale then
    shapeScale = self:getShapeScale()
  end
  local resultPos = Lib.copy(pos)
  if shapeScale then
    if 2 <= shapeScale then
      return resultPos
    end
    local delta = shapeScale - 1
    if delta ~= 0 then
      local initBoundBox = self:getInitBoundBox()
      local curBoundBox = self:getBoundingBox()
      if curBoundBox then
        if 0 < delta then
          local offsetX = (curBoundBox[3].x - curBoundBox[2].x - initBoundBox.x) / 2 + shapeOffset.x
          local offsetY = curBoundBox[3].y - curBoundBox[2].y - initBoundBox.y + shapeOffset.y
          local offsetZ = (curBoundBox[3].z - curBoundBox[2].z - initBoundBox.z) / 2 + shapeOffset.z
          local yaw = getAngele(yaw)
          local changeX = offsetX * math.cos(yaw) - offsetZ * math.sin(yaw)
          local changeZ = offsetZ * math.cos(yaw) + offsetX * math.sin(yaw)
          resultPos.y = resultPos.y - offsetY / 2 * delta
          resultPos.x = resultPos.x - changeX / 2 * delta
          resultPos.z = resultPos.z - changeZ / 2 * delta
        else
          local offsetX = curBoundBox[3].x - curBoundBox[2].x - initBoundBox.x + shapeOffset.x
          local offsetY = curBoundBox[3].y - curBoundBox[2].y - initBoundBox.y + shapeOffset.y
          local offsetZ = curBoundBox[3].z - curBoundBox[2].z - initBoundBox.z + shapeOffset.z
          local yaw = getAngele(yaw)
          local changeX = offsetX * math.cos(yaw) - offsetZ * math.sin(yaw)
          local changeZ = offsetZ * math.cos(yaw) + offsetX * math.sin(yaw)
          resultPos.y = resultPos.y + offsetY * delta
          resultPos.x = resultPos.x + changeX * delta
          resultPos.z = resultPos.z + changeZ * delta
        end
      end
    end
  end
  return resultPos
end

function Player:checkAppearanceUnlock(data)
  local canUse = false
  if data.lockState == 0 and data.needBuy == 0 then
    canUse = true
  elseif data.lockState == Define.UNLOCK_TYPE.BIDDING then
    canUse = Plugins.CallTargetPluginFunc("tendering_land", "getTenderingDressCanUseById", self.platformUserId, data.id)
  elseif data.lockState == Define.UNLOCK_TYPE.VIP then
    canUse = Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", self.platformUserId, Define.PRIVILEGE_TYPE.VIP)
  end
  canUse = canUse or self:checkActivityDressIsUnlock(data.id)
  if canUse then
    return true
  elseif data.needBuy and 0 < data.needBuy then
    local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(Define.BUSINESS_ITEM_TYPE.Dress, data.id)
    if goodsCfg then
      local businessData = self:getBusinessData()
      return businessData[goodsCfg.goodsId]
    end
  end
  return canUse
end

function Player:checkPetUnlock(data)
  local canUse = false
  if data.lockState == 0 and data.needBuy == 0 then
    canUse = true
  elseif data.lockState == Define.UNLOCK_TYPE.BIDDING then
    canUse = Plugins.CallTargetPluginFunc("tendering_land", "getTenderingPetCanUseById", self.platformUserId, data.id)
  elseif data.lockState == Define.UNLOCK_TYPE.VIP then
    canUse = Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", self.platformUserId, Define.PRIVILEGE_TYPE.VIP)
  elseif data.lockState == Define.UNLOCK_TYPE.PEAK_DAY then
    canUse = self:isPetReceived(data.id)
  end
  canUse = canUse or self:checkActivityPetIsUnlock(data.id)
  if canUse then
    return true
  elseif data.needBuy and 0 < data.needBuy then
    if self:getSubscribeGameState() then
      local subscribe_vipSetting = World.cfg.subscribe_vipSetting
      for _, petId in pairs(subscribe_vipSetting.subscribePetIdList) do
        if petId == data.id then
          return true
        end
      end
    end
    local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(Define.BUSINESS_ITEM_TYPE.Pet, data.id)
    if goodsCfg then
      local businessData = self:getBusinessData()
      return businessData[goodsCfg.goodsId]
    end
  end
  return canUse
end

function Player:checkCarUnlock(data)
  local canUse = false
  if data.lockState == 0 and data.needPrivilege == 0 and data.needBuy == 0 then
    canUse = true
  elseif data.lockState == Define.UNLOCK_TYPE.VIP or data.needPrivilege == Define.PRIVILEGE_TYPE.VIP then
    canUse = Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", self.platformUserId, Define.PRIVILEGE_TYPE.VIP)
  end
  canUse = canUse or self:checkActivityCarIsUnlock(data.id)
  if canUse then
    return true
  elseif data.needBuy and 0 < data.needBuy then
    local subscribeVipStage = self:getSubscribeVipStage()
    if subscribeVipStage == Define.SubscribeVIPStage.Normal or subscribeVipStage == Define.SubscribeVIPStage.Height then
      local subscribe_vipSetting = World.cfg.subscribe_vipSetting
      for _, carId in pairs(subscribe_vipSetting.normalVipCarIdList) do
        if carId == data.id then
          return true
        end
      end
    end
    local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(Define.BUSINESS_ITEM_TYPE.Car, data.id)
    if goodsCfg then
      local businessData = self:getBusinessData()
      return businessData[goodsCfg.goodsId]
    end
  end
  return canUse
end

function Player:checkHouseUnlock(data)
  local canUse = false
  if data.lockState == 0 and data.isLock == 0 and data.needPrivilege == 0 and data.needBuy == 0 then
    canUse = true
  elseif data.lockState == Define.UNLOCK_TYPE.VIP or data.needPrivilege == Define.PRIVILEGE_TYPE.VIP then
    canUse = Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", self.platformUserId, Define.PRIVILEGE_TYPE.VIP)
  end
  canUse = canUse or self:checkActivityHouseIsUnlock(data.id)
  if canUse then
    return true
  elseif data.needBuy and 0 < data.needBuy then
    local subscribeVipStage = self:getSubscribeVipStage()
    if subscribeVipStage == Define.SubscribeVIPStage.Height then
      local subscribe_vipSetting = World.cfg.subscribe_vipSetting
      for _, houseId in pairs(subscribe_vipSetting.heightVipHouseIdList) do
        if houseId == data.id then
          return true
        end
      end
    end
    local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(Define.BUSINESS_ITEM_TYPE.House, data.id)
    if goodsCfg then
      local businessData = self:getBusinessData()
      return businessData[goodsCfg.goodsId]
    end
  end
  return canUse
end

function Player:doRoleChangeSkin(packet, onlyReset)
  local skinData = packet.skinData
  local conflictParts = packet.conflictParts or {}
  local conflictOriginal = packet.conflictOriginal or {}
  local isReset = packet.isReset
  local shapeInfo = self:getShapeInfo()
  local changeSkinData, shapeInfoRemove = self:parseNewSkinData(Lib.copyTable1(skinData))
  local isOperateFree = false
  local isOperateAdFree = false
  if packet.lockState and packet.lockState ~= 0 or packet.needBuy and packet.needBuy ~= 0 then
    local canUse = self:checkAppearanceUnlock(packet)
    if packet.needBuy and packet.needBuy ~= 0 and not canUse then
      if self:getIsWatchedAd() then
        canUse = true
        isOperateFree = true
        isOperateAdFree = true
      elseif packet.id and 0 < Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", self, Define.BUSINESS_ITEM_TYPE.Dress, packet.id) then
        canUse = true
        isOperateFree = true
        isOperateAdFree = true
      elseif isReset then
        isOperateFree = true
      end
    end
    if onlyReset then
      isOperateFree = false
      canUse = true
    end
    if not isOperateFree and not canUse then
      for i, _ in pairs(skinData) do
        if shapeInfo[i] then
          shapeInfo[i] = nil
        end
      end
      self:setValue(Define.APPEARANCE_VAR_KEY.ShapeInfo, shapeInfo)
      local tipsTxt = Plugins.CallTargetPluginFunc("tendering_land", "getTenderingDressTips", packet.id)
      if tipsTxt and tipsTxt ~= "" then
        Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, tipsTxt)
      end
      return
    end
  end
  for partName, _ in pairs(skinData) do
    DyeingStatusMgr:delStatus(self, partName)
  end
  local originalSkin = self:getOriginalSkin()
  if not isReset then
    for i, v in pairs(skinData) do
      shapeInfo[i] = v
    end
    if shapeInfoRemove then
      for master, _ in pairs(shapeInfoRemove) do
        shapeInfo[master] = nil
      end
    end
    if next(conflictParts) ~= nil then
      for _, master in pairs(conflictParts) do
        shapeInfo[master] = nil
      end
    end
    self:addDressCountOnce()
    local is_Ad_free = 0
    if isOperateFree and isOperateAdFree then
      if self:getIsWatchedAd() then
        self:setIsWatchedAd(false)
        is_Ad_free = 1
        self:updateFreeAdStartTime(packet.id, os.time())
      elseif packet.id then
        is_Ad_free = 1
        Plugins.CallTargetPluginFunc("advertisement_module", "costFreeItem", self, Define.BUSINESS_ITEM_TYPE.Dress, packet.id)
        self:updateFreeAdStartTime(packet.id, os.time())
      end
    end
    local reportData = {
      appearance_id = packet.id or 0,
      is_Ad_free = is_Ad_free or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "on_appearance", reportData, self)
    if not self.isFirstDress then
      local reportData = {
        appearance_id = packet.id or 0,
        is_Ad_free = is_Ad_free or 0
      }
      Plugins.CallTargetPluginFunc("report", "report", "first_appearance", reportData, self)
      self.isFirstDress = true
    end
    Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", self, Define.HEART_WARM_TASK_TYPE.CHANGE_DRESS)
  else
    if isOperateFree then
      self:updateFreeAdStartTime(packet.id, nil)
    end
    for i, _ in pairs(skinData) do
      if shapeInfo[i] then
        shapeInfo[i] = nil
      end
    end
    local shapeConflict = {}
    for i, v in pairs(shapeInfo) do
      local preConflictParts = AppearanceConfig:getConflictPartsByPart(i, v)
      if preConflictParts and next(preConflictParts) then
        for _, vv in pairs(preConflictParts) do
          shapeConflict[vv] = true
        end
      end
    end
    if next(conflictParts) ~= nil then
      for _, master in pairs(conflictParts) do
        if not shapeConflict[master] then
          changeSkinData[master] = originalSkin[master]
        end
      end
    end
    for _, master in pairs(conflictOriginal) do
      if not changeSkinData[master] or changeSkinData[master] == 0 or changeSkinData[master] == "0" then
        changeSkinData[master] = originalSkin[master]
      end
    end
  end
  self:changeSkin(changeSkinData, nil, packet.opOrder)
  self:setValue(Define.APPEARANCE_VAR_KEY.ShapeInfo, shapeInfo)
end

function Player:updateFreeAdStartTime(dressId, time)
  self:setOneFreeAdStartTime(dressId, time)
  if self.dressAdDownTimer == nil then
    self:startDressAdDownTimer()
  end
end

function Player:startDressAdDownTimer()
  self.dressAdDownTimer = World.Timer(20, function()
    local freeAdStartTime = self:getFreeAdStartTime()
    local hasChange = false
    for dressId, startTime in pairs(freeAdStartTime) do
      if startTime ~= nil then
        local passTime = os.time() - startTime
        local remainTime = Define.FreeAdDressTime - passTime
        if remainTime <= 0 then
          hasChange = true
          freeAdStartTime[dressId] = nil
          self:resetSelectDressSkin(dressId)
        end
      end
    end
    if hasChange then
      self:setFreeAdStartTime(freeAdStartTime)
    end
    return true
  end)
end

function Player:resetSelectDressSkin(dressId)
  local dressCfg = AppearanceConfig:getCfgById(dressId)
  local packet = {
    isReset = true,
    conflictParts = dressCfg.conflictParts,
    conflictOriginal = dressCfg.conflictOriginal,
    id = dressCfg.id,
    lockState = dressCfg.lockState,
    needBuy = dressCfg.needBuy
  }
  local skinData = {}
  local originalSkin = self:getOriginalSkin()
  for key, _ in pairs(dressCfg.parts) do
    skinData[key] = originalSkin[key] or ""
  end
  packet.skinData = skinData
  self:doRoleChangeSkin(packet, true)
end

function Player:stopDressAdDownTimer()
  if self.dressAdDownTimer then
    self.dressAdDownTimer()
    self.dressAdDownTimer = nil
  end
  local freeAdStartTime = self:getFreeAdStartTime()
  for dressId, startTime in pairs(freeAdStartTime) do
    if startTime ~= nil then
      self:resetSelectDressSkin(dressId)
    end
  end
end
