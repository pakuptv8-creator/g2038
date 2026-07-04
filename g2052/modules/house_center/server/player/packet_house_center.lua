local handles = T(Player, "PackageHandlers")

function handles:OnOperationHouse(packet)
  return self:onOperationHouse(packet.params)
end

function handles:InformCloseHouseUi()
  self:informCloseHouseUi()
end

function handles:OnApplyHouse(packet)
  return self:onApplyHouse(packet.params)
end

function handles:SwitchLockState(packet)
  HouseManager:SwitchLockState(self)
end

function handles:ControlTheWindow(packet)
  return HouseManager:controlTheWindow(self.platformUserId)
end

function handles:ControlGarageDoor(packet)
  return HouseManager:controlGarageDoor(self)
end

function handles:SetDoorplateText(packet)
  HouseManager:setDoorplateText(self.platformUserId, packet.dec, packet.color)
end

function handles:PlayHouseBgm(packet)
  local key = packet.key
  if key then
    HouseManager:onPlayHouseBgmByKey(self.platformUserId, key)
  end
end

function handles:StopHouseBgm(packet)
  HouseManager:onStopHouseBgmByKey(self.platformUserId)
end

function handles:expandEntityViewDistance(packet)
  local curRecord = self:getMonitorUsingRecord()
  if next(curRecord) == nil then
    self.map:updateAllEntitiesViewDistance(1000)
  end
  self:addMonitorUsingRecord(self.platformUserId)
end

function handles:recoveryEntityViewDistance(packet)
  self:removeFromMonitorUsingRecord()
end

function handles:LeaveHouseArea(packet)
  local curArea = self:getPlayerCurArea()
  if curArea.name == "house_area" then
    Plugins.CallTargetPluginFunc("report", "report", "leave_area", nil, self)
    self:setPlayerCurArea({})
  end
end

function handles:ReconfirmApplyHouse(packet)
  self:reconfirmApplyHouse(packet.params)
end

function handles:RequestDisasterState(packet)
  return HouseManager:getDisasterSelectState(self)
end

function handles:UpdateDisasterState(packet)
  return HouseManager:updateDisasterSelectState(self, packet.disasterId)
end

function handles:reqPaintHouse(packet)
  local info, id = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info and packet.color then
    HouseManager:updateHouseColor(id, packet.color)
  end
end
