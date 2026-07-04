local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["mod_editor/\231\188\150\232\190\145\229\153\168"] = function()
  Interface.onAppActionTrigger(24)
end
GMItem["mod_editor/\232\189\172"] = function()
  print("pre------------", Me:getRotation())
  print("objId = ", Me.objID)
end
GMItem["mod_editor/\230\184\184\230\136\143"] = GM:inputStr(function(self, value)
  CGame.instance:resetGameAddr(Me.platformUserId, value, "", "", "")
end, function(self)
end)
GMItem["mod_editor/\230\137\147\229\188\128MOD\231\149\140\233\157\162"] = function()
  Plugins.CallTargetPluginFunc("mod_editor", "openModEditorWnd", "modMain", true)
end
