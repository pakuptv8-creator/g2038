local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2052\229\183\165\229\133\183/\229\162\158\229\135\143\231\179\150\230\158\156"] = GM:inputStr(function(self, value)
  local amount = tonumber(value) or 0
  self:changeHalloweenCandy(amount)
  self:addCandyDayCount(1, Define.GetCandyType.FindGhost)
  print(">>>>>>>>>>>>>>>>>>>>>>> getHalloweenCandy", self:getHalloweenCandy())
end, function(self)
  return "10"
end)
GMItem["g2052\229\183\165\229\133\183/\232\142\183\229\143\150\231\179\150\230\158\156\232\174\176\229\189\149\230\184\133\233\155\182"] = function(self)
  self:clearCandyDayCountAll()
end
GMItem["g2052\229\183\165\229\133\183/\230\138\147\233\172\188\232\174\176\229\189\149\230\184\133\233\155\182"] = function(self)
  self:clearHalloweenFindGhostRecord()
end
GMItem["g2052\229\183\165\229\133\183/\231\167\187\233\153\164\229\133\145\230\141\162\233\155\182\228\187\182"] = function(self)
  local HalloweenPartHelper = T(Lib, "HalloweenPartHelper")
  HalloweenPartHelper:removeHalloweenPart()
end
GMItem["g2052\229\183\165\229\133\183/\230\184\133\231\169\186\229\133\145\230\141\162\229\165\150\229\138\177"] = function(self)
  self:setValue("activityCar", {})
  self:setValue("activityPet", {})
  self:setValue("activityDress", {})
end
GMItem["g2052\229\183\165\229\133\183/\232\142\183\229\190\151\229\133\145\230\141\162\229\165\150\229\138\177"] = function(self)
  local HalloweenExchangeConfig = T(Config, "HalloweenExchangeConfig")
  local cfgList = HalloweenExchangeConfig:getAllCfgs()
  for key, cfgInfo in pairs(cfgList) do
    if cfgInfo.awardType == 1 then
      self:addActivityCar(cfgInfo.awardId)
    elseif cfgInfo.awardType == 2 then
      self:addActivityPet(cfgInfo.awardId)
    elseif cfgInfo.awardType == 3 then
      self:addActivityDress(cfgInfo.awardId)
    end
  end
end
GMItem["g2052\229\183\165\229\133\183/\230\184\133\231\169\186\229\136\134\228\186\171\232\174\176\229\189\149"] = function(self)
  self:cleanHalloweenCandyDayPlayer()
end
GMItem["g2052\229\183\165\229\133\183/\228\184\135\229\156\163\232\138\130\231\187\147\230\157\159"] = function(self)
  local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
  HalloweenHelperCommon.halloweenOpen = false
  Lib.emitEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, HalloweenHelperCommon:isHalloweenDay())
end
