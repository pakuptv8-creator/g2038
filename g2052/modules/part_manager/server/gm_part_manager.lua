local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\233\155\182\228\187\182/\233\148\128\230\175\129"] = function(self)
  local partID = self:getInteractionPartID()
  if partID ~= "" then
    local part = Instance.getByInstanceId(partID)
    Plugins.CallTargetPluginFunc("part_manager", "destroyPart", part)
  end
end
GMItem["\233\155\182\228\187\182/\232\190\147\229\133\165\229\143\141\233\135\141\229\138\155"] = GM:inputStr(function(self, value)
  self:setProp("antiGravity", tonumber(value))
end, function(self)
end)
