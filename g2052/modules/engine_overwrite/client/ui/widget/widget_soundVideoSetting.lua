local widget_base = require("ui.widget.widget_base")
local WidgetSoundVideoSetting = Lib.derive(widget_base)

function WidgetSoundVideoSetting:init()
  widget_base.init(self, "G2052VideoSoundSetting.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetSoundVideoSetting:initUI()
  self.voiceSettingCheckBox = self:child("G2052VideoSoundSetting-VoiceSettingCheckBox")
  self.voiceSettingCheckBox:SetChecked(Me:getIsAutoPlayVoice())
  self.soundSettingMusicBar = self:child("G2052VideoSoundSetting-SoundSettingMusicBar")
  self:child("G2052VideoSoundSetting-VoiceSettingTitleText"):SetText(Lang:toText("g2052.gui.setting.voiceSetting"))
  self:child("G2052VideoSoundSetting-VoiceSettingText"):SetText(Lang:toText("ui.chat.autoplay"))
  self:child("G2052VideoSoundSetting-VideoSettingTitleText"):SetText(Lang:toText("setting.audioAndVideoSetting.videoTab"))
  self:child("G2052VideoSoundSetting-videoSettingLevel_0"):SetText(Lang:toText("setting.audioAndVideoSetting.lowQuality"))
  self:child("G2052VideoSoundSetting-videoSettingLevel_1"):SetText(Lang:toText("setting.audioAndVideoSetting.midQuality"))
  self:child("G2052VideoSoundSetting-videoSettingLevel_2"):SetText(Lang:toText("setting.audioAndVideoSetting.highQuality"))
  self:child("G2052VideoSoundSetting-SoundSettingTitleText"):SetText(Lang:toText("gui.setting.volume"))
  self:child("G2052VideoSoundSetting-FarClipTitleText"):SetText(Lang:toText("g2052.gui.setting.FarClipSetting"))
  self:child("G2052VideoSoundSetting-FarClipLevel_0"):SetText(Lang:toText("g2052.gui.setting.FarClipSetting.low"))
  self:child("G2052VideoSoundSetting-FarClipLevel_1"):SetText(Lang:toText("g2052.gui.setting.FarClipSetting.mid"))
  self:child("G2052VideoSoundSetting-FarClipLevel_2"):SetText(Lang:toText("g2052.gui.setting.FarClipSetting.high"))
end

function WidgetSoundVideoSetting:initEvent()
  self:subscribe(self.voiceSettingCheckBox, UIEvent.EventCheckStateChanged, function()
    Me:setIsAutoPlayVoice(self.voiceSettingCheckBox:GetChecked())
  end)
  local defaultSettings = Clientsetting.getSetting()
  local saveQualityLevel = 0
  local qualityPanel = self:child("G2052VideoSoundSetting-VideoSettingLow")
  for level = 0, 2 do
    local checkBox = qualityPanel:child("G2052VideoSoundSetting-videoSettingLevel_" .. level)
    if level == saveQualityLevel then
      checkBox:SetSelected(true)
    end
    self:subscribe(checkBox, UIEvent.EventRadioStateChanged, function(button)
      if button:IsSelected() then
        self:gameSettingSetQualityLevel(level)
      end
    end)
  end
  local saveFarClipLevel = Me:getFarClipLevel()
  print("+++++++++++++++++++ WidgetSoundVideoSetting:initEvent(), saveFarClipLevel =", saveFarClipLevel)
  local farClipPanel = self:child("G2052VideoSoundSetting-FarClipLow")
  for level = 0, 2 do
    local checkBox = farClipPanel:child("G2052VideoSoundSetting-FarClipLevel_" .. level)
    if level == saveFarClipLevel then
      checkBox:SetSelected(true)
    end
    self:subscribe(checkBox, UIEvent.EventRadioStateChanged, function(button)
      if button:IsSelected() then
        self:gameSettingSetFarClipLevel(level)
      end
    end)
  end
  self:initSliderEvent(self.soundSettingMusicBar, defaultSettings.volume, Clientsetting.refreshVolume)
  Lib.subscribeEvent(Event.EVENT_CHANGE_FAR_CLIP, function(value)
    for level = 0, 2 do
      local checkBox = farClipPanel:child("G2052VideoSoundSetting-FarClipLevel_" .. level)
      if level == value then
        checkBox:SetSelected(true)
      end
    end
  end)
end

function WidgetSoundVideoSetting:initSliderEvent(slider, defaultVal, handler)
  slider:SetProgress(defaultVal)
  
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
  
  self:subscribe(slider, UIEvent.EventWindowTouchDown, update)
  self:subscribe(slider, UIEvent.EventWindowTouchMove, update)
  self:subscribe(slider, UIEvent.EventWindowTouchUp, update)
  self:subscribe(slider, UIEvent.EventMotionRelease, update)
end

function WidgetSoundVideoSetting:gameSettingSetQualityLevel(level)
  print(">>>>>>>>>>>>>>>>>>>>>>>> WidgetSoundVideoSetting:gameSettingSetQualityLevel ", level)
  Blockman.instance.gameSettings:setCurQualityLevel(level)
  Clientsetting.refreshSaveQualityLeve(level)
end

function WidgetSoundVideoSetting:gameSettingSetFarClipLevel(level)
  print(">>>>>>>>>>>>>>>> gameSettingSetFarClipLevel() ", level)
  CameraManager.Instance():getMainCamera():setFarClip(Me:getFarClipValue(level))
  Me:setFarClipLevel(level)
end

function WidgetSoundVideoSetting:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetSoundVideoSetting
