local WinGearShift = M

function WinGearShift:init()
  WinBase.init(self, "GearShift.json")
  self:initUI()
  self:initEvent()
end

function WinGearShift:initUI()
  self.btnClose = self:child("GearShift-Content-TopBar-BtnClose")
  self.btnSub = self:child("GearShift-sub")
  self.btnAdd = self:child("GearShift-add")
  self.txtNum = self:child("GearShift-num")
  self.txtTitle = self:child("GearShift-Content-TopBar-Title")
  self.txtTitle:SetText(Lang:toText("g2052.gui.vehicle.gearshift"))
end

function WinGearShift:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnAdd, UIEvent.EventButtonClick, function()
    self:addGear(true)
  end)
  self:subscribe(self.btnSub, UIEvent.EventButtonClick, function()
    self:addGear(false)
  end)
end

local function getControl(inst)
  local count = inst:getChildrenCount()
  for i = 0, count - 1 do
    local n = inst:getChildAt(i)
    if n:getName() == "controller" then
      return n
    end
  end
end

function WinGearShift:tryAddGear(add)
  local gear = self.car.gear + (add and 1 or -1)
  if gear <= 0 or gear > #self.car.gears then
    return
  end
  self.car.gear = gear
  local control = getControl(self.car)
  control:setProperty("speedMax", self.car.gears[gear])
  local reportData = {car_gear = gear}
  Plugins.CallTargetPluginFunc("report", "report", "car_speedchange", reportData, Me)
end

function WinGearShift:addGear(add)
  self:tryAddGear(add)
  self.txtNum:SetText(tostring(self.car.gear))
end

function WinGearShift:onOpen(car)
  self.car = car
  self.txtNum:SetText(tostring(self.car.gear))
  self.openWndTime = os.time()
end

function WinGearShift:onClose()
  local reportData = {
    stay_speed_main_time = os.time() - self.openWndTime
  }
  Plugins.CallTargetPluginFunc("report", "report", "car_speeduiclick", reportData, Me)
end

return WinGearShift
