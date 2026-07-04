local GMItem = GM:createGMItem()
GMItem["APP\230\180\187\229\138\168/\230\183\187\229\138\160\229\190\189\231\171\160"] = function(self)
  Plugins.CallTargetPluginFunc("vf_app_activity", "addGameBadge", self)
end
GMItem["APP\230\180\187\229\138\168/\229\136\160\233\153\164\229\190\189\231\171\160"] = function(self)
  Plugins.CallTargetPluginFunc("vf_app_activity", "removeGameBadge", self)
end
