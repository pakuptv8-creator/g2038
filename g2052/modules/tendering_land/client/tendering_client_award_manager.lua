local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
local TenderingConfig = T(Config, "TenderingConfig")
local TenderingPublicManager = T(Lib, "TenderingPublicManager")

function TenderClientAwardManager:init()
  self.buildAwardData = {}
  self.socialAwardData = {}
end

function TenderClientAwardManager:updateClientSocialAward(data)
  self.socialAwardData = data
  Lib.emitEvent(Event.EVENT_UPDATE_TENDERING_INFO)
  self:updateHeadPostInfoShow()
end

function TenderClientAwardManager:updateClientBuildAward(data)
  self.buildAwardData = data
  Lib.emitEvent(Event.EVENT_UPDATE_TENDERING_INFO)
  for key, val in pairs(data) do
    TenderingPublicManager:updateSignUIData(val, val.blockId)
  end
  self:updateHeadPostInfoShow()
end

function TenderClientAwardManager:updateClientRegionId(regionId)
  self.regionId = regionId
end

function TenderClientAwardManager:getClientRegionId()
  return self.regionId or 1001
end

function TenderClientAwardManager:updateHeadPostInfoShow()
  local allEntity = World.CurWorld:getAllEntity()
  for _, entity in pairs(allEntity or {}) do
    if entity and entity:isValid() and entity.isPlayer then
      entity:updateShowName()
    end
  end
end

function TenderClientAwardManager:checkTakeDressIsCanUse(userId, dressId)
  local takeInLandCloth = Me:getTakeInLandCloth()
  if takeInLandCloth[dressId] then
    return true
  end
  return false
end

function TenderClientAwardManager:checkDressIsCanUse(userId, dressId)
  dressId = tonumber(dressId) or 0
  if self:checkTakeDressIsCanUse(userId, dressId) then
    return true
  end
  if dressId == World.cfg.tenderAwardSetting.mayorClothes then
    return self:isNormalMayor(userId)
  elseif dressId == World.cfg.tenderAwardSetting.MPSClothes then
    return self:isMPSPlayer(userId)
  else
    for key, val in pairs(self.buildAwardData) do
      local cfg = TenderingConfig:getCfgByLandNameAndRegionId(val.blockId, val.regionId)
      if cfg and dressId == cfg.winClothes then
        if userId == val.userId then
          return true
        end
        return false
      end
    end
  end
  return false
end

function TenderClientAwardManager:getTenderingDressTips(dressId)
  dressId = tonumber(dressId)
  local AppearanceConfig = T(Config, "AppearanceConfig")
  local dressCfg = AppearanceConfig:getCfgById(dressId)
  if dressCfg then
    return dressCfg.lockTips
  end
  return "fail"
end

function TenderClientAwardManager:checkTakePetIsCanUse(userId, petId)
  local takeInLandPet = Me:getTakeInLandPet()
  if takeInLandPet[petId] then
    return true
  end
  return false
end

function TenderClientAwardManager:getTenderingPetTips(petId)
  petId = tonumber(petId)
  local PetConfig = T(Config, "PetConfig")
  local petCfg = PetConfig:getCfgById(petId)
  if petCfg then
    return petCfg.lockTips
  end
  return "fail"
end

function TenderClientAwardManager:getNormalMayorName()
  local name = ""
  if self.socialAwardData and self.socialAwardData.normalMayor then
    for userId, val in pairs(self.socialAwardData.normalMayor) do
      return val.nickName or ""
    end
  end
  return name
end

function TenderClientAwardManager:isBigMayor(userId)
  if self.socialAwardData and self.socialAwardData.bigMayorList and self.socialAwardData.bigMayorList[userId] then
    return true
  end
  return false
end

function TenderClientAwardManager:isNormalMayor(userId)
  if self.socialAwardData and self.socialAwardData.normalMayor and self.socialAwardData.normalMayor[userId] then
    return true
  end
  return false
end

function TenderClientAwardManager:isMPSPlayer(userId)
  if self:isNormalMayor(userId) then
    return false
  end
  for key, val in pairs(self.buildAwardData) do
    if userId == val.userId then
      return true
    end
  end
  return false
end

function TenderClientAwardManager:getTenderingWinPostStr(userId)
  if World.cfg.tenderAwardSetting.isIgnoreTenderAward then
    return false
  end
  if self:isBigMayor(userId) then
    return World.cfg.tenderAwardSetting.bigMayorTxt, World.cfg.tenderAwardSetting.bigMayorColor
  elseif self:isNormalMayor(userId) then
    return World.cfg.tenderAwardSetting.mayorTxt, World.cfg.tenderAwardSetting.mayorColor
  else
    for key, val in pairs(self.buildAwardData) do
      local cfg = TenderingConfig:getCfgByLandNameAndRegionId(val.blockId, val.regionId)
      if cfg and userId == val.userId then
        return cfg.winTxt, cfg.winColor
      end
    end
  end
  return false
end

function TenderClientAwardManager:getTenderDesignationAward(userId, needColor)
  if World.cfg.tenderAwardSetting.isIgnoreTenderAward then
    return ""
  end
  local text = ""
  do return "" end
  if self:isBigMayor(userId) then
    if needColor then
      text = text .. "\226\150\162FF" .. World.cfg.tenderAwardSetting.bigMayorColor .. Lang:toText(World.cfg.tenderAwardSetting.bigMayorTxt) .. " "
    else
      text = text .. Lang:toText(World.cfg.tenderAwardSetting.bigMayorTxt) .. " "
    end
  elseif self:isNormalMayor(userId) then
    if needColor then
      text = text .. "\226\150\162FF" .. World.cfg.tenderAwardSetting.mayorColor .. Lang:toText(World.cfg.tenderAwardSetting.mayorTxt) .. " "
    else
      text = text .. Lang:toText(World.cfg.tenderAwardSetting.mayorTxt) .. " "
    end
  elseif self:isMPSPlayer(userId) then
    if needColor then
      text = text .. "\226\150\162FF" .. World.cfg.tenderAwardSetting.MPSColor .. Lang:toText(World.cfg.tenderAwardSetting.MPSTxt) .. " "
    else
      text = text .. Lang:toText(World.cfg.tenderAwardSetting.MPSTxt) .. " "
    end
  end
  for key, val in pairs(self.buildAwardData) do
    local cfg = TenderingConfig:getCfgByLandNameAndRegionId(val.blockId, val.regionId)
    if cfg and userId == val.userId then
      if needColor then
        text = text .. "\226\150\162FF" .. cfg.winColor .. Lang:toText(cfg.winTxt) .. " "
      else
        text = text .. Lang:toText(cfg.winTxt) .. " "
      end
    end
  end
  return text
end

TenderClientAwardManager:init()
