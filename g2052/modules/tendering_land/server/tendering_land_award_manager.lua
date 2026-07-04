local TenderingAwardManager = T(Lib, "TenderingAwardManager")
local roomGameConfig = Server.CurServer:getConfig()
local regionId = roomGameConfig:getRegionId()
local TenderingConfig = T(Config, "TenderingConfig")

function TenderingAwardManager:init()
  self.buildAwardData = {}
  self.socialAwardData = {}
  self:updateTenderingAwardData()
end

function TenderingAwardManager:updateBuildHonorList(data)
  self.buildAwardData = data
  for key, val in pairs(self.buildAwardData) do
    self.buildAwardData[key].regionId = regionId
  end
  self:pushClientBuildAward()
  Plugins.CallPluginFunc("BiddingBuildAwardLoaded", data)
end

function TenderingAwardManager:pushClientBuildAward(player)
  local packet = {
    pid = "SCPushClientBuildAward",
    buildAwardData = self.buildAwardData
  }
  if player and player:isValid() then
    player:sendPacket(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

function TenderingAwardManager:updateSocialHonorList(data)
  if not data then
    return
  end
  self.socialAwardData = {
    bigMayorList = {},
    normalMayor = {}
  }
  for _, info in pairs(data.honoraryMayorCounts or {}) do
    if info.count > World.cfg.tenderAwardSetting.bigMayorCount and data.honoraryMayor and info.userId == data.honoraryMayor.userId then
      self.socialAwardData.bigMayorList[info.userId] = true
    end
  end
  if data and data.honoraryMayor and data.honoraryMayor.userId then
    self.socialAwardData.normalMayor[data.honoraryMayor.userId] = data.honoraryMayor
    self.socialAwardData.normalMayor[data.honoraryMayor.userId].regionId = regionId
  end
  self:pushClientSocialAward()
  if data and data.honoraryMayor and data.honoraryMayor.userId and data.honoraryMayor.userId > 0 then
    local mayorSex = data.honoraryMayor.sex or 1
    self:tryCreateMayorStatue(mayorSex, data.honoraryMayor.nickName)
  else
    self:destroyMayorStatue()
  end
end

function TenderingAwardManager:pushClientSocialAward(player)
  local packet = {
    pid = "SCPushClientSocialAward",
    socialData = self.socialAwardData
  }
  if player and player:isValid() then
    player:sendPacket(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

function TenderingAwardManager:checkTakeDressIsCanUse(userId, dressId)
  local player = Game.GetPlayerByUserId(userId)
  if player and player:isValid() then
    local takeInLandCloth = player:getTakeInLandCloth()
    return takeInLandCloth[dressId]
  end
  return false
end

function TenderingAwardManager:checkDressIsCanUse(userId, dressId)
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

function TenderingAwardManager:getTenderingDressTips(dressId)
  dressId = tonumber(dressId)
  local AppearanceConfig = T(Config, "AppearanceConfig")
  local dressCfg = AppearanceConfig:getCfgById(dressId)
  if dressCfg then
    return dressCfg.lockTips
  end
  return "fail"
end

function TenderingAwardManager:checkTakePetIsCanUse(userId, petId)
  local player = Game.GetPlayerByUserId(userId)
  if player and player:isValid() then
    local takeInLandPet = player:getTakeInLandPet()
    if takeInLandPet[petId] then
      return true
    end
  end
  return false
end

function TenderingAwardManager:getTenderingPetTips(petId)
  petId = tonumber(petId)
  local PetConfig = T(Config, "PetConfig")
  local petCfg = PetConfig:getCfgById(petId)
  if petCfg then
    return petCfg.lockTips
  end
  return "fail"
end

function TenderingAwardManager:checkResetTenderAppearance(userId, curSkin)
  local AppearanceConfig = T(Config, "AppearanceConfig")
  local awardDressList = AppearanceConfig:getAllAwardLockCfg()
  for id, dressCfg in pairs(awardDressList) do
    for key, val in pairs(dressCfg.parts) do
      if curSkin[key] == val then
        if id == World.cfg.tenderAwardSetting.mayorClothes then
          if not self:isNormalMayor(userId) then
            return true
          end
        elseif id == World.cfg.tenderAwardSetting.MPSClothes then
          if not self:isMPSPlayer(userId) then
            return true
          end
        else
          for _, buildInfo in pairs(self.buildAwardData) do
            local cfg = TenderingConfig:getCfgByLandNameAndRegionId(buildInfo.blockId, buildInfo.regionId)
            if cfg then
              if not userId == buildInfo.userId then
                return true
              end
            else
              return true
            end
          end
        end
      end
    end
  end
  return false
end

function TenderingAwardManager:requestWebPassBlockIdList(userId)
  AsyncProcess.GetPlayerTenderingBlockIdList(userId, function(data, userId, regionId)
    self:updateTakeTenderingAward(data, userId, regionId)
  end)
end

function TenderingAwardManager:updateTakeTenderingAward(blockList, userId, regionId)
  local player = Game.GetPlayerByUserId(userId)
  if player and player:isValid() then
    local clothList = {}
    local petList = {}
    for _, blockId in pairs(blockList) do
      local cfg = TenderingConfig:getCfgByLandNameAndRegionId(blockId, regionId)
      if cfg then
        if cfg.takeInCloths and cfg.takeInCloths ~= 0 then
          table.insert(clothList, cfg.takeInCloths)
        end
        if cfg.takeInPet and cfg.takeInPet ~= 0 then
          table.insert(petList, cfg.takeInPet)
        end
      end
    end
    if 0 < #clothList then
      player:addTakeInLandCloths(clothList)
    end
    if 0 < #petList then
      player:addTakeInLandPets(petList)
    end
  end
end

function TenderingAwardManager:isBigMayor(userId)
  if self.socialAwardData and self.socialAwardData.bigMayorList and self.socialAwardData.bigMayorList[userId] then
    return true
  end
  return false
end

function TenderingAwardManager:isNormalMayor(userId)
  if self.socialAwardData and self.socialAwardData.normalMayor and self.socialAwardData.normalMayor[userId] then
    return true
  end
  return false
end

function TenderingAwardManager:isMPSPlayer(userId)
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

function TenderingAwardManager:updateTenderingAwardData()
  if World.cfg.tenderAwardSetting.isIgnoreTenderAward then
    return
  end
  if self.autoRequestTimer then
    self.autoRequestTimer()
    self.autoRequestTimer = nil
  end
  self:requestWebSeasonResult()
  self:requestWebSocialAward()
  if World.cfg.tenderAwardSetting.isAutoRequest then
    self.autoRequestTimer = World.Timer(20 * World.cfg.tenderAwardSetting.AutoTime, function()
      self:requestWebSeasonResult()
      self:requestWebSocialAward()
      return true
    end)
  end
end

function TenderingAwardManager:requestWebSeasonResult()
  AsyncProcess.GetCurSeasonTenderingResult(function(data)
    self:updateBuildHonorList(data)
  end)
end

function TenderingAwardManager:requestWebSocialAward()
  AsyncProcess.GetTenderingSocialAward(function(data)
    self:updateSocialHonorList(data)
  end)
end

function TenderingAwardManager:tryCreateMayorStatue(sex, nickName)
  local mayorSex = sex or 1
  if self.createTimer then
    self.createTimer()
    self.createTimer = nil
  end
  self.createTimer = World.Timer(40, function()
    self:updateMayorStatueInfo(mayorSex, nickName)
    return false
  end)
end

function TenderingAwardManager:updateMayorStatueInfo(mayorSex, nickName)
  if not self.mayorStatue then
    self:createMayorStatue(mayorSex, nickName)
  else
    local actorName = "g2052_girl.actor"
    if mayorSex == 1 then
      actorName = "g2052_boy.actor"
    end
    self.mayorStatue:changeActor(actorName)
    self.mayorStatue:setName("")
    local packet = {
      pid = "SCPushUpdateMayorStatueName",
      name = nickName,
      objID = self.mayorStatue.objID
    }
    WorldServer.BroadcastPacket(packet)
  end
end

function TenderingAwardManager:createMayorStatue(sex, nickName)
  if not self.mayorStatue then
    self.mayorStatue = EntityServer.Create({
      name = "",
      map = World.cfg.tenderAwardSetting.mapName,
      cfgName = sex == 1 and "myplugin/player_npc" or "myplugin/player_npc_girl",
      pos = World.cfg.tenderAwardSetting.position,
      ry = World.cfg.tenderAwardSetting.yaw,
      rp = World.cfg.tenderAwardSetting.pitch
    })
    self.mayorStatue.onGround = true
    local skinDataChange = {}
    local AppearanceConfig = T(Config, "AppearanceConfig")
    local dressCfg = AppearanceConfig:getCfgById(World.cfg.tenderAwardSetting.mayorClothes)
    for key, val in pairs(dressCfg.parts) do
      skinDataChange[key] = val
    end
    local skinData = self.mayorStatue:parseNewSkinData(skinDataChange)
    self.mayorStatue:changeSkin(skinData)
    self.mayorStatue:setShapeScale(World.cfg.tenderAwardSetting.statueScale)
  end
end

function TenderingAwardManager:destroyMayorStatue()
  if self.mayorStatue then
    local packet = {
      pid = "SCPushRemoveMayorStatueUI"
    }
    WorldServer.BroadcastPacket(packet)
    self.mayorStatue:destroy()
    self.mayorStatue = nil
  end
end

TenderingAwardManager:init()
