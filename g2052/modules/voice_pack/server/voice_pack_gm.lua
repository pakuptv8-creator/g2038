local GMItem = GM:createGMItem()
local VoicePackConfig = T(Config, "VoicePackConfig")
GMItem["\232\175\173\233\159\179\229\140\133/\232\142\183\229\190\151\230\137\128\230\156\137\232\175\173\233\159\179"] = function(self)
  for _, cfg in pairs(VoicePackConfig:getAllCfgs()) do
    self.voicePackData:addVoicePack(cfg.id)
  end
end
GMItem["\232\175\173\233\159\179\229\140\133/\230\184\133\233\153\164\230\137\128\230\156\137\232\175\173\233\159\179"] = function(self)
  for _, cfg in pairs(VoicePackConfig:getAllCfgs()) do
    self.voicePackData:removeVoicePack(cfg.id)
  end
end
