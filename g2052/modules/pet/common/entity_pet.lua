local ValueDef = T(Entity, "ValueDef")
ValueDef[Define.PET_VAR_KEY.PetData] = {
  false,
  false,
  false,
  false,
  {},
  false
}
ValueDef[Define.PET_VAR_KEY.CurCarryPetId] = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef[Define.PET_VAR_KEY.CurCarryPetObjId] = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef[Define.PET_VAR_KEY.PetName] = {
  false,
  false,
  true,
  false,
  "",
  true
}
ValueDef[Define.PET_VAR_KEY.PetNameColor] = {
  false,
  true,
  true,
  false,
  "FFFFFF",
  true
}
ValueDef[Define.PET_VAR_KEY.PetTime] = {
  false,
  false,
  false,
  false,
  {},
  false
}
ValueDef[Define.PET_VAR_KEY.UsePetCount] = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef[Define.PET_VAR_KEY.PeakDayPetReceived] = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef[Define.PET_VAR_KEY.PetReceived] = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef[Define.PET_VAR_KEY.PeakDayPetReceivedSeason] = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef[Define.PET_VAR_KEY.PeakDayShowWndDay] = {
  false,
  false,
  true,
  false,
  {},
  true
}
local Entity = _ENV.Entity

function Entity:getPetDataByPetId(petId)
  return self:getPetData()[petId]
end

function Entity:getPetData()
  return self:getValue(Define.PET_VAR_KEY.PetData)
end

function Entity:setPetData(id, value)
  local data = {}
  data[id] = value
  self:setValue(Define.PET_VAR_KEY.PetData, data, true)
end

function Entity:getCurCarryPetId()
  return self:getValue(Define.PET_VAR_KEY.CurCarryPetId)
end

function Entity:setCurCarryPetId(petId)
  self:setValue(Define.PET_VAR_KEY.CurCarryPetId, petId)
end

function Entity:getCurCarryPetObjId()
  return self:getValue(Define.PET_VAR_KEY.CurCarryPetObjId)
end

function Entity:setCurCarryPetObjId(petId)
  self:setValue(Define.PET_VAR_KEY.CurCarryPetObjId, petId)
end

function Entity:getPetNameColor()
  return self:getValue(Define.PET_VAR_KEY.PetNameColor)
end

function Entity:getPetName()
  return self:getValue(Define.PET_VAR_KEY.PetName)
end

function Entity:recordPetEnter(petId)
  if not petId then
    return
  end
  local record = self:getValue(Define.PET_VAR_KEY.PetTime)
  for i, _ in pairs(record) do
    if i ~= petId then
      record[i] = nil
    end
  end
  record[petId] = os.time()
  self:setValue(Define.PET_VAR_KEY.PetTime, record)
end

function Entity:getPetRecord()
  return self:getValue(Define.PET_VAR_KEY.PetTime)
end

function Entity:addUsePetCountOnce()
  local count = self:getValue(Define.PET_VAR_KEY.UsePetCount)
  count = count + 1
  self:setValue(Define.PET_VAR_KEY.UsePetCount, count)
end

function Entity:getUsePetCount()
  return self:getValue(Define.PET_VAR_KEY.UsePetCount)
end

function Entity:hasPeakDayPetReceived()
  local activityConf = World.cfg.peakDayPetGetActivity
  if not activityConf or not activityConf.activitySeason then
    Lib.logWarning("Entity:hasPeakDayPetReceived fail,no peak day activity config, check main setting", activityConf, activityConf and activityConf.activitySeason or "")
    return
  end
  local data = self:getValue(Define.PET_VAR_KEY.PeakDayPetReceivedSeason) or {}
  return data[activityConf.activitySeason]
end

function Entity:setPeakDayPetReceived()
  local activityConf = World.cfg.peakDayPetGetActivity
  if not activityConf or not activityConf.activitySeason then
    Lib.logWarning("Entity:setPeakDayPetReceived fail,no peak day activity config, check main setting", activityConf, activityConf and activityConf.activitySeason or "")
    return
  end
  local data = self:getValue(Define.PET_VAR_KEY.PeakDayPetReceivedSeason) or {}
  data[activityConf.activitySeason] = true
  self:setValue(Define.PET_VAR_KEY.PeakDayPetReceivedSeason, data)
end

function Entity:getPetReceived()
  return self:getValue(Define.PET_VAR_KEY.PetReceived)
end

function Entity:setPetReceived(cfgId)
  if not cfgId then
    return
  end
  local petReceived = self:getValue(Define.PET_VAR_KEY.PetReceived)
  petReceived[#petReceived + 1] = cfgId
  self:setValue(Define.PET_VAR_KEY.PetReceived, petReceived)
end

function Entity:isPetReceived(cfgId)
  if not cfgId then
    return false
  end
  local petReceived = self:getValue(Define.PET_VAR_KEY.PetReceived)
  for _, id in ipairs(petReceived) do
    if id == cfgId then
      return true
    end
  end
  return false
end

function Entity:clearPetReceived()
  self:setValue(Define.PET_VAR_KEY.PetReceived, {})
end

function Entity:clearPeakDayPetReceived()
  self:setValue(Define.PET_VAR_KEY.PeakDayPetReceivedSeason, {})
end

function Entity:getPeakDayShowWndDay()
  return self:getValue(Define.PET_VAR_KEY.PeakDayShowWndDay)
end

function Entity:setPeakDayShowWndDay()
  local today = os.date("*t", os.time())
  self:setValue(Define.PET_VAR_KEY.PeakDayShowWndDay, today)
end

function Entity:hasPeakDayShowWndToday()
  local lastShowWndDay = self:getPeakDayShowWndDay()
  if lastShowWndDay and next(lastShowWndDay) ~= nil then
    local today = os.date("*t", os.time())
    if lastShowWndDay.year == today.year and lastShowWndDay.month == today.month and lastShowWndDay.day == today.day then
      return true
    end
  end
  return false
end
