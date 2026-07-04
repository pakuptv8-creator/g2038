Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(riderObjId, rideOnId)
  if riderObjId ~= Me.objID then
    return
  end
  local target = World.CurWorld:getEntity(rideOnId)
  if target and target:isValid() and target:cfg().isPet == true then
    Lib.emitEvent(Event.EVENT_PET_RIDE_STATUS_CHANGE, true)
  end
end)
Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_OFF, function(riderObjId, rideOnId)
  if riderObjId ~= Me.objID then
    return
  end
  local target = World.CurWorld:getEntity(rideOnId)
  if target and target:isValid() and target:cfg().isPet == true then
    Lib.emitEvent(Event.EVENT_PET_RIDE_STATUS_CHANGE, false)
  end
end)
local Player = _ENV.Player

function Player:petRename(name, nameColor)
  Me:sendPacket({
    pid = "pet_rename",
    name = name,
    nameColor = nameColor
  })
end

function Player:changePartner(data)
  Me:sendPacket({
    pid = "partner_change",
    id = data.id,
    lockState = data.lockState,
    needBuy = data.needBuy
  })
end

function Player:recoverPartner()
  Me:sendPacket({
    pid = "partner_recover"
  })
end

function Player:isPeakDayActivityCanShow()
  local activityConf = World.cfg.peakDayPetGetActivity
  if not activityConf then
    return false
  end
  local now = os.time()
  local beginTime = activityConf.beginTime
  local dayDuration = activityConf.dayDuration
  local noticeDay = activityConf.noticeDay
  local endTime = beginTime + dayDuration * 86400
  if now >= beginTime - noticeDay * 86400 and now < endTime then
    return true
  end
  return false
end
