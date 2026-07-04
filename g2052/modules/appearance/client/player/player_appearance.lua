local AppearanceConfig = T(Config, "AppearanceConfig")
local RedDotConfig = T(Config, "RedDotConfig")
local cjson = require("cjson")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local Player = _ENV.Player
local KEY_RED_DOT = {
  [11] = RedDotConfig.RD_KEY.HasNewSuits,
  [12] = RedDotConfig.RD_KEY.HasNewTops,
  [13] = RedDotConfig.RD_KEY.HasNewPants,
  [14] = RedDotConfig.RD_KEY.HasNewTopsGirl,
  [15] = RedDotConfig.RD_KEY.HasNewPantsGirl,
  [16] = RedDotConfig.RD_KEY.HasNewShoes,
  [21] = RedDotConfig.RD_KEY.HasNewHat,
  [22] = RedDotConfig.RD_KEY.HasNewHair,
  [23] = RedDotConfig.RD_KEY.HasNewHead,
  [24] = RedDotConfig.RD_KEY.HasNewBag,
  [25] = RedDotConfig.RD_KEY.HasNewWaist,
  [31] = RedDotConfig.RD_KEY.HasNewColor,
  [41] = RedDotConfig.RD_KEY.HasNewExpression
}

function Player:updateAppearanceRedDotStatus()
  local allCfg = AppearanceConfig:getAllCfgs()
  for _, v in ipairs(allCfg) do
    local list = v.list
    for index, vv in pairs(list) do
      local member = vv.member
      local hasNew = false
      for _, conf in ipairs(member) do
        if conf.isNew == 1 then
          hasNew = true
          break
        end
      end
      if KEY_RED_DOT[index] then
        Plugins.CallPluginFunc("resetRedDotState", KEY_RED_DOT[index], hasNew and 1 or 0)
      end
    end
  end
end

function Player:scanDressItemsByIndex(index)
  if KEY_RED_DOT[index] then
    Plugins.CallPluginFunc("resetRedDotState", KEY_RED_DOT[index], 0)
    local setRecord = AppearanceConfig:updateIsNewStatus(index)
    if next(setRecord) ~= nil then
      for _, id in ipairs(setRecord) do
        if self.newAppearanceScanRecord then
          self.newAppearanceScanRecord[tostring(id)] = 1
        end
      end
      self:saveNewAppearanceScanRecord()
    end
  end
end

function Player:loadNewAppearanceScanRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewAppearanceScanRecord-" .. userId .. ".json"
  local file = io.open(path, "r")
  if not file then
    self.newAppearanceScanRecord = {}
    return
  end
  file:close()
  self.newAppearanceScanRecord = Lib.read_json_file(path) or {}
  for id, _ in pairs(self.newAppearanceScanRecord) do
    AppearanceConfig:updateIsNewStatusById(tonumber(id))
  end
end

function Player:saveNewAppearanceScanRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewAppearanceScanRecord-" .. userId .. ".json"
  local file, errmsg = io.open(path, "w")
  if not file then
    print("\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129saveNewAppearanceScanRecord  error \239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129")
    print(errmsg)
    return false
  end
  local ok, content = pcall(cjson.encode, self.newAppearanceScanRecord)
  assert(ok, path)
  file:write(Lib.jsonToFormat(content))
  file:close()
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
      local businessData = Me:getBusinessData()
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
      local businessData = Me:getBusinessData()
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
      local businessData = Me:getBusinessData()
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
      local businessData = Me:getBusinessData()
      return businessData[goodsCfg.goodsId]
    end
  end
  return canUse
end

function Player:changeSkinClient(packet)
  local skinData = packet.skinData
  local conflictParts = packet.conflictParts or {}
  local conflictOriginal = packet.conflictOriginal or {}
  local isReset = packet.isReset
  local shapeInfo = self:getShapeInfoClient()
  local changeSkinData, shapeInfoRemove = self:parseNewSkinDataClient(Lib.copyTable1(skinData))
  if packet.lockState and packet.lockState ~= 0 then
    local canUse = self:checkAppearanceUnlock(packet)
    if packet.needBuy and packet.needBuy ~= 0 and not canUse then
      if self:getIsWatchedAd() then
        canUse = true
      elseif packet.id and 0 < Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", self, Define.BUSINESS_ITEM_TYPE.Dress, packet.id) then
        canUse = true
      end
    end
    if not canUse then
      return
    end
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
  else
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
  local mySkin = Lib.copyTable1(self:data("skins"))
  for k, v in pairs(changeSkinData) do
    mySkin[k] = v
  end
  self:applySkin(mySkin, packet.opOrder)
  self:setShapeInfoClient(shapeInfo)
  Lib.emitEvent(Event.EVENT_APPEARANCE_INFO_UPDATE, shapeInfo)
end

function Player:doResetRoleSkinClient(opOrder)
  local originalSkin = self:getOriginalSkin()
  local oldSkin = Lib.copyTable1(originalSkin)
  if Lib.isSameTable(oldSkin.skin_color or {}, {
    0,
    0,
    0,
    0
  }) then
    oldSkin.skin_color = {
      1,
      1,
      1,
      0
    }
  end
  local skin = Lib.copyTable1(self:data("skins"))
  for master, v in pairs(skin) do
    if not oldSkin[master] then
      oldSkin[master] = ""
    end
  end
  local skinQueue = self.skinQueue
  for _, queue in ipairs(skinQueue or {}) do
    for k, v in pairs(queue.value or {}) do
      oldSkin[k] = v
    end
  end
  local mySkin = Lib.copyTable1(self:data("skins"))
  for k, v in pairs(oldSkin) do
    mySkin[k] = v
  end
  self:applySkin(mySkin, opOrder)
  self:setShapeInfoClient({})
  Lib.emitEvent(Event.EVENT_APPEARANCE_INFO_UPDATE, {})
end

local changeSkinOpOrder = 0

function Player:getChangeSkinOpOrder()
  changeSkinOpOrder = changeSkinOpOrder + 1
  return changeSkinOpOrder
end

local handles = T(Player, "PackageHandlers")

function handles:SkinChange(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if not entity or not entity:isValid() then
    return
  end
  entity:applySkin(packet.skinData, packet.opOrder)
end

function Player:getShapeInfoClient()
  return self.shapeInfoClient or {}
end

function Player:setShapeInfoClient(data)
  if data then
    self.shapeInfoClient = Lib.copy(data)
  end
end
