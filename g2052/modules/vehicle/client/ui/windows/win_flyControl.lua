local WinFlyControl = M

function WinFlyControl:init()
  WinBase.init(self, "FlyControl.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinFlyControl:initUI()
  self.imgContainer = self:child("Fly-Controls")
  self.imgFlyUp = self:child("Fly-Up")
  self.imgFlyDown = self:child("Fly-Down")
  self.imgContainer:SetVisible(false)
end

function WinFlyControl:initEvent()
  self:subscribe(self.imgFlyUp, UIEvent.EventWindowTouchDown, function()
    local target = World.CurWorld:getEntity(Me.rideOnId)
    if target then
      if self.isUplifting then
        return
      end
      local isOnGround = target.onGround
      local maxFlyHigh = target:cfg().maxFlyHigh or 50
      if isOnGround then
        if not self.isUplifting then
          self.isUplifting = true
          Me:sendPacket({
            pid = "startHelicopter"
          })
          self.oldGravity = target:cfg().gravity or 0.08
        end
      else
        do
          local pos = target:getPosition()
          if maxFlyHigh > pos.y then
            Me:sendPacket({
              pid = "vehicleAddBuff",
              buffName = "myplugin/aircraft_control_up",
              objId = Me.rideOnId
            })
            if self.riseTimer then
              self.riseTimer()
              self.riseTimer = nil
            end
            self.riseTimer = World.Timer(1, function()
              if target and target:isValid() then
                local curPos = target:getPosition()
                if curPos.y < maxFlyHigh then
                  return true
                else
                  Me:sendPacket({
                    pid = "vehicleRemoveBuff",
                    buffName = "myplugin/aircraft_control_up",
                    objId = Me.rideOnId
                  })
                end
              end
            end)
          end
        end
      end
    end
  end)
  self:subscribe(self.imgFlyUp, UIEvent.EventWindowTouchUp, function()
    local target = World.CurWorld:getEntity(Me.rideOnId)
    if target then
      if self.isUplifting then
        return
      end
      if self.riseTimer then
        self.riseTimer()
        self.riseTimer = nil
      end
      local isOnGround = target.onGround
      if isOnGround then
        return
      end
      Me:sendPacket({
        pid = "vehicleRemoveBuff",
        buffName = "myplugin/aircraft_control_up",
        objId = Me.rideOnId
      })
    end
  end)
  self:subscribe(self.imgFlyDown, UIEvent.EventWindowTouchDown, function()
    local target = World.CurWorld:getEntity(Me.rideOnId)
    if target then
      if self.isUplifting then
        return
      end
      local isOnGround = target.onGround
      if isOnGround then
        return
      end
      Me:sendPacket({
        pid = "vehicleAddBuff",
        buffName = "myplugin/aircraft_control_down",
        objId = Me.rideOnId
      })
      self.fallTimer = World.Timer(1, function()
        local isOnGround = target.onGround
        if isOnGround then
          Me:sendPacket({
            pid = "stopHelicopter",
            objId = Me.rideOnId,
            gravity = self.oldGravity
          })
        else
          return true
        end
      end)
    end
  end)
  self:subscribe(self.imgFlyDown, UIEvent.EventWindowTouchUp, function()
    local target = World.CurWorld:getEntity(Me.rideOnId)
    if target then
      if self.isUplifting then
        return
      end
      local isOnGround = target.onGround
      if isOnGround then
        Me:sendPacket({
          pid = "stopHelicopter",
          objId = Me.rideOnId,
          gravity = self.oldGravity
        })
        return
      end
      Me:sendPacket({
        pid = "vehicleRemoveBuff",
        buffName = "myplugin/aircraft_control_down",
        objId = Me.rideOnId
      })
      if self.fallTimer then
        self.fallTimer()
        self.fallTimer = nil
      end
    end
  end)
end

function WinFlyControl:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(riderObjId, rideOnId)
    self:updateFlyControlView(riderObjId, rideOnId, true)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_OFF, function(riderObjId, rideOnId)
    self:updateFlyControlView(riderObjId, rideOnId, false)
    local target = World.CurWorld:getEntity(rideOnId)
    if target and target:cfg().isAircraft == true and riderObjId == Me.objID then
      if self.riseTimer then
        self.riseTimer()
        self.riseTimer = nil
      end
      local passengers = target:data("passengers")
      if not passengers[1] then
        Me:sendPacket({
          pid = "vehicleRemoveBuff",
          buffName = "myplugin/aircraft_control_up",
          objId = rideOnId
        })
        Me:sendPacket({
          pid = "stopHelicopter",
          objId = rideOnId,
          gravity = self.oldGravity
        })
      end
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HELICOPTER_UP_LIFT_OVER, function()
    self.isUplifting = nil
  end)
end

function WinFlyControl:initView()
end

function WinFlyControl:updateFlyControlView(riderObjId, rideOnId, isShow)
  if riderObjId == Me.objID then
    local target = World.CurWorld:getEntity(rideOnId)
    if target then
      if target:cfg().isAircraft == true then
        local passengers = target:data("passengers")
        local isDriver = true
        for i, v in pairs(passengers) do
          if v == riderObjId and i ~= 1 then
            isDriver = false
          end
        end
        if isDriver then
          self.imgContainer:SetVisible(isShow)
          if not isShow then
            self.isUplifting = nil
          end
        end
      else
        self.imgContainer:SetVisible(false)
        self.isUplifting = nil
      end
    end
  end
end

function WinFlyControl:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinFlyControl:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinFlyControl
