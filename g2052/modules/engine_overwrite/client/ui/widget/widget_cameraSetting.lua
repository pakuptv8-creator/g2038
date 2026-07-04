local widget_base = require("ui.widget.widget_base")
local WidgetCameraSetting = Lib.derive(widget_base)

function WidgetCameraSetting:init()
  widget_base.init(self, "G2052CameraSetting.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetCameraSetting:initUI()
  self.viewSettingTextNum = self:child("G2052CameraSetting-ViewSettingTextNum")
  self.viewSettingBar = self:child("G2052CameraSetting-ViewSettingBar")
  self.sensitiveSettingTextNum = self:child("G2052CameraSetting-SensitiveSettingTextNum")
  self.sensitiveSettingBar = self:child("G2052CameraSetting-SensitiveSettingBar")
  self:child("G2052CameraSetting-ViewSettingTitleText"):SetText(Lang:toText("setting.cameraSetting.fovLayout.tab"))
  self:child("G2052CameraSetting-ViewSettingTextCur"):SetText(Lang:toText("setting.cameraSetting.sensitiveLayout.desc"))
  self:child("G2052CameraSetting-ViewSettingTextSmall"):SetText(Lang:toText("setting.cameraSetting.fovLayout.min"))
  self:child("G2052CameraSetting-ViewSettingTextBig"):SetText(Lang:toText("setting.cameraSetting.fovLayout.max"))
  self:child("G2052CameraSetting-SensitiveSettingTitleText"):SetText(Lang:toText("setting.cameraSetting.sensitiveLayout.tab"))
  self:child("G2052CameraSetting-SensitiveSettingTextCur"):SetText(Lang:toText("setting.cameraSetting.sensitiveLayout.desc"))
  self:child("G2052CameraSetting-SensitiveSettingTextSmall"):SetText(Lang:toText("setting.cameraSetting.fovLayout.min"))
  self:child("G2052CameraSetting-SensitiveSettingTextBig"):SetText(Lang:toText("setting.cameraSetting.fovLayout.max"))
  self.isFirstLoading = true
end

function WidgetCameraSetting:initEvent()
  local curSettings = Clientsetting.getSetting()
  self:initSliderEvent(self.viewSettingBar, "viewSettingBar", curSettings.horizon, function(progress)
    local distanceMin = tonumber(World.cfg.cameraDistanceMin or "") or 0.2
    local distanceMax = tonumber(World.cfg.cameraDistanceMax or "") or 200
    local curDis = Blockman.instance:viewerRenderDistance()
    if self.isFirstLoading then
      local p = (curDis - distanceMin) / (distanceMax - distanceMin)
      self.viewSettingBar:SetProgress(p)
      self.viewSettingTextNum:SetText("x" .. string.format("%04.2f", p))
      self.isFirstLoading = false
      return
    end
    local targetDis = distanceMin + progress * (distanceMax - distanceMin)
    Blockman.instance:addCameraDistance(targetDis - curDis)
    self.viewSettingTextNum:SetText("x" .. string.format("%04.2f", progress))
  end)
  local progress = self:savedSensitiveToProgress(curSettings.camera_sensitive)
  self:initSliderEvent(self.sensitiveSettingBar, "sensitiveSettingBar", progress, function(progress)
    Clientsetting.refreshCameraSensitive(progress)
    self.sensitiveSettingTextNum:SetText(string.format("%03.1f", progress))
  end)
end

function WidgetCameraSetting:savedSensitiveToProgress(value)
  local minSize = 0.45
  local maxSize = 1.0
  local result = (value - minSize) / (maxSize - minSize)
  return result
end

function WidgetCameraSetting:initSliderEvent(slider, nameKey, defaultVal, handler)
  slider:SetProgress(defaultVal)
  handler(slider:GetProgress())
  
  local function update()
    local progress = slider:GetProgress()
    if 0.9 < progress then
      progress = 1.0
    elseif progress < 0.1 then
      progress = 0
    end
    if handler then
      handler(progress)
    end
  end
  
  self:lightSubscribe("error!!!!! : CameraSettingBar EventWindowTouchDown " .. nameKey, slider, UIEvent.EventWindowTouchDown, update)
  self:lightSubscribe("error!!!!! : CameraSettingBar EventWindowTouchMove " .. nameKey, slider, UIEvent.EventWindowTouchMove, update)
  self:lightSubscribe("error!!!!! : CameraSettingBar EventWindowTouchUp " .. nameKey, slider, UIEvent.EventWindowTouchUp, update)
  self:lightSubscribe("error!!!!! : CameraSettingBar EventMotionRelease " .. nameKey, slider, UIEvent.EventMotionRelease, update)
end

function WidgetCameraSetting:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetCameraSetting
