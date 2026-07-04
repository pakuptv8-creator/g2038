local InteractEventConfig = T(Config, "InteractEventConfig")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GM.itemsShowPriorityMap = {
  ["g2052\229\183\165\229\133\183"] = 1001,
  ["\231\179\187\231\187\159"] = 1002
}
GMItem["g2052\229\183\165\229\133\183/\233\155\182\228\187\182\230\140\130\231\130\185\231\188\150\232\190\145\229\153\168"] = function()
  UI:getWnd("partsHangPointEditor"):onShow(true)
end
GMItem["g2052\229\183\165\229\133\183/\233\155\182\228\187\182\231\137\185\230\149\136\231\188\150\232\190\145\229\153\168"] = function()
  UI:getWnd("partRegionEffectEditor"):onShow(true)
end
GMItem["g2052\229\183\165\229\133\183/\233\153\132\232\191\145\233\155\182\228\187\182\229\143\175\231\130\185\229\135\187"] = GM:inputStr(function(self, v)
  local curPos = self:getPosition()
  local range = tonumber(v) or 20
  local offset = Lib.v3(range, range, range)
  local minPos = curPos - offset
  local maxPos = curPos + offset
  local map = self.map
  local parts = map:getTouchParts(minPos, maxPos)
  for _, v in pairs(parts) do
    if v.className == "PartClient" then
      v:setProperty("selectable", "true")
    end
  end
end, function(self)
end)
