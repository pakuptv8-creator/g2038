local ValueDef = T(Entity, "ValueDef")
ValueDef.lastLoginTime = {
  false,
  false,
  false,
  false,
  0,
  true
}
ValueDef.defaultSkin = {
  false,
  false,
  false,
  false,
  nil,
  false
}
ValueDef.playerActive = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.ownedEasterEgg = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.chatCount = {
  false,
  true,
  true,
  false,
  0,
  false
}
ValueDef.houseCount = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef.itemCount = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef.farClipLevel = {
  false,
  true,
  true,
  false,
  1,
  true
}

function Entity:getLastLoginTime()
  return self:getValue("lastLoginTime")
end

function Entity:updateLastLoginTime()
  self:setValue("lastLoginTime", os.time())
end

function Entity:getDefaultSkin()
  return self:getValue("defaultSkin")
end

function Entity:setDefaultSkin(skins)
  if not skins or not next(skins) then
    return
  end
  self:setValue("defaultSkin", skins)
end

function Entity:recordPlayerActive(time)
  local playerActive = self:getValue("playerActive")
  if playerActive.initialTime then
    local isSameDay = Lib.isSameDay(playerActive.initialTime, time)
    if isSameDay then
      return
    end
    if playerActive.activeType < 30 then
      playerActive.activeType = playerActive.activeType + 1
    else
      return
    end
  else
    playerActive.activeType = 1
  end
  playerActive.initialTime = time
  self:setValue("playerActive", playerActive)
end

function Entity:getPlayerActive()
  return self:getValue("playerActive")
end

function Entity:setOwnedEasterEgg(string)
  local EasterEgg = self:getValue("ownedEasterEgg")
  if EasterEgg[string] then
    return
  end
  EasterEgg[string] = true
  self:setValue("ownedEasterEgg", EasterEgg)
end

function Entity:isOwnedEasterEgg(string)
  local easterEgg = self:getValue("ownedEasterEgg")
  if easterEgg[string] then
    return 0
  end
  return 1
end

function Entity:getChatCount()
  return self:getValue("chatCount")
end

function Entity:addOneChatCount()
  self:setValue("chatCount", self:getChatCount() + 1)
end

function Entity:getHouseCount()
  return self:getValue("houseCount")
end

function Entity:addOneHouseCount()
  self:setValue("houseCount", self:getHouseCount() + 1)
end

function Entity:getItemCount()
  return self:getValue("itemCount")
end

function Entity:addOneItemCount()
  self:setValue("itemCount", self:getItemCount() + 1)
end

function Entity:updateFreeSoundFlag()
  if self:getFreeSoundFlag() < 2 then
    self:setFreeSoundFlag(2)
    if not self:getSoundMoonCardEnable() then
      self:initFreeSoundTimes()
    end
  end
end

function Entity:getFarClipLevel()
  return self:getValue("farClipLevel")
end

function Entity:getFarClipValue(level)
  local cameraFarClip = 140
  local farClipCfg = World.cfg.FarClipValue
  if level and farClipCfg and farClipCfg[level + 1] then
    cameraFarClip = farClipCfg[level + 1]
  end
  return cameraFarClip
end

function Entity:setFarClipLevel(level)
  if level then
    self:setValue("farClipLevel", level)
  end
end
