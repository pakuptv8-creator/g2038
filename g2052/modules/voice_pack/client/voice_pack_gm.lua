local GMItem = GM:createGMItem()
local VoicePackConfig = T(Config, "VoicePackConfig")
for _, cfg in pairs(VoicePackConfig:getAllCfgs()) do
  local name = string.format("\232\175\173\233\159\179\229\140\133/\230\146\173\230\148\190\232\175\173\233\159\179%s", cfg.id)
  GMItem[name] = function()
    Plugins.CallTargetPluginFunc("voice_pack", "playVoicePack", Me, cfg.id)
  end
end
GMItem["\232\175\173\233\159\179\229\140\133/\230\137\147\229\188\128\232\175\173\233\159\179\231\149\140\233\157\162"] = function(self)
  UI:openWnd("voice_pack")
end
GMItem["\232\175\173\233\159\179\229\140\133/\229\133\179\233\151\173\232\175\173\233\159\179\231\149\140\233\157\162"] = function(self)
  UI:closeWnd("voice_pack")
end
