local PetStatusConfig = T(Config, "PetStatusConfig")
local PetConfig = T(Config, "PetConfig")
local handles = T(Player, "PackageHandlers")

function handles:pet_rename(packet)
  local newName = packet.name
  local newColor = packet.nameColor
  self:setValue(Define.PET_VAR_KEY.PetName, newName)
  self:setValue(Define.PET_VAR_KEY.PetNameColor, newColor)
  local objId = self:getCurCarryPetObjId()
  if objId ~= 0 then
    local entity = World.CurWorld:getEntity(objId)
    if entity then
      local passengers = entity:data("passengers")
      if not next(passengers) then
        local color = "[C=FF" .. newColor .. "]"
        entity:setEntityName(color .. newName)
      end
    end
  end
end

function handles:partner_change(packet)
  local petId = packet.id
  if not petId then
    return
  end
  local is_Ad_free = 0
  if packet.lockState and packet.lockState ~= 0 or packet.needBuy and packet.needBuy ~= 0 then
    local canUse = self:checkPetUnlock(packet)
    if packet.needBuy and packet.needBuy ~= 0 then
      if self:getIsWatchedAd() then
        self:setIsWatchedAd(false)
        canUse = true
        is_Ad_free = 1
      elseif petId and 0 < Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", self, Define.BUSINESS_ITEM_TYPE.Pet, petId) then
        Plugins.CallTargetPluginFunc("advertisement_module", "costFreeItem", self, Define.BUSINESS_ITEM_TYPE.Pet, petId)
        canUse = true
        is_Ad_free = 1
      end
    end
    if not canUse then
      local tipsTxt = Plugins.CallTargetPluginFunc("tendering_land", "getTenderingPetTips", packet.id)
      if tipsTxt and tipsTxt ~= "" then
        Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, tipsTxt)
      end
      return
    end
  end
  self:addNewPet(petId, is_Ad_free)
end

function handles:partner_recover(packet)
  self:removePetFromWorld(true)
end

function handles:petAddPerformanceBuff(packet)
  local objID = packet.objID
  local statusId = packet.statusId
  if not objID or not statusId then
    return
  end
  local pet = World.CurWorld:getEntity(objID)
  if not pet or not pet:isValid() then
    return
  end
  local cfg = PetStatusConfig:getCfgById(statusId)
  if not cfg then
    return
  end
  local buffName = cfg.performanceBuff
  pet:addBuff(buffName)
end

function handles:petRemovePerformanceBuff(packet)
  local objID = packet.objID
  local statusId = packet.statusId
  if not objID or not statusId then
    return
  end
  local pet = World.CurWorld:getEntity(objID)
  if not pet or not pet:isValid() then
    return
  end
  local cfg = PetStatusConfig:getCfgById(statusId)
  if not cfg then
    return
  end
  local buffName = cfg.performanceBuff
  pet:removeTypeBuff("fullName", buffName)
end

function handles:petAddSatisfyBuff(packet)
  local objID = packet.objID
  local statusId = packet.statusId
  if not objID or not statusId then
    return
  end
  local pet = World.CurWorld:getEntity(objID)
  if not pet or not pet:isValid() then
    return
  end
  local cfg = PetStatusConfig:getCfgById(statusId)
  if not cfg then
    return
  end
  local buffName = cfg.interactSatisfyBuff
  local buffDuration = cfg.interactSatisfyBuffDuration or 20
  pet:addBuff(buffName, buffDuration)
end

function handles:reqReceivePeakDayReward(packet)
  local index = packet.index
  if not index then
    return
  end
  local hasReceived = self:hasPeakDayPetReceived()
  if hasReceived then
    return
  end
  local activityConf = World.cfg.peakDayPetGetActivity
  local now = os.time()
  local beginTime = activityConf.beginTime
  local dayDuration = activityConf.dayDuration
  local endTime = beginTime + dayDuration * 86400
  if now < beginTime or now >= endTime then
    return
  end
  local rewardItemIds = activityConf.rewardItemIds
  if not rewardItemIds[index] then
    return
  end
  local rewardItem = rewardItemIds[index]
  local rewardType = rewardItem.rewardType
  local rewardId = tonumber(rewardItem.rewardId)
  if rewardType == "pet" then
    local cfg = PetConfig:getCfgById(rewardId)
    if not cfg then
      return
    end
    if cfg.needReceive == 1 then
      self:setPetReceived(rewardId)
    end
    self:setPeakDayPetReceived()
  end
  local reportData = {
    peakday_get_id = rewardId or 0
  }
  Plugins.CallTargetPluginFunc("report", "report", "peakday_get", reportData, self)
  return true
end

function handles:rideOffFromPet(packet)
  self:rideOffPet()
end

function handles:setPeakDayShowWndDayC2S(packet)
  self:setPeakDayShowWndDay()
end

function handles:petSpeedUp(packet)
  return self:petSpeedUp()
end
