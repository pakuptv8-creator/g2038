local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["interact/\230\181\139\232\175\149\228\186\164\228\186\146\230\149\136\230\158\156"] = GM:inputStr(function(self, value)
  Plugins.CallTargetPluginFunc("interact", "diy", {value}, nil, Me)
end)
