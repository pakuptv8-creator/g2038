local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\148\229\164\171play"] = function(self)
  local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
  local item = LimitedTimeActivityConfig:getCfgById(20001)
  LimitedTimeActivityMgr:playActivity(self, item)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\233\153\144\230\151\182\230\138\189\229\165\150\229\141\149\230\138\189"] = function(self)
  local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
  local item = LimitedTimeActivityConfig:getCfgById(10001)
  LimitedTimeActivityMgr:playActivity(self, item, {
    type = Define.LUCKY_DRAW_TYPE.SINGLE
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\233\153\144\230\151\182\230\138\189\229\165\150\229\141\129\232\191\158"] = function(self)
  local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
  local item = LimitedTimeActivityConfig:getCfgById(10001)
  LimitedTimeActivityMgr:playActivity(self, item, {
    type = Define.LUCKY_DRAW_TYPE.TEN
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\232\180\173\228\185\176\229\145\168\229\141\161"] = function(self)
  local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
  local item = LimitedTimeActivityConfig:getCfgById(80001)
  LimitedTimeActivityMgr:playActivity(self, item, {
    type = Define.LIMITED_TIME_CARD.WEEK
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\232\180\173\228\185\176\230\156\136\229\141\161"] = function(self)
  local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
  local item = LimitedTimeActivityConfig:getCfgById(80001)
  LimitedTimeActivityMgr:playActivity(self, item, {
    type = Define.LIMITED_TIME_CARD.MONTH
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\233\153\144\230\151\182\233\135\145\229\184\129\232\189\172\231\155\152"] = function(self)
  local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
  local item = LimitedTimeActivityConfig:getCfgById(100001)
  LimitedTimeActivityMgr:playActivity(self, item)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\231\169\186\233\153\144\230\151\182\229\141\161"] = function(self)
  self:setLimitedTimeCardData({})
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\233\166\150\230\172\161\232\180\173\228\185\176\228\191\161\230\129\175"] = function(self)
  self:setFirstPurchaseData({})
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\230\184\148\229\164\171\232\142\183\229\190\151"] = function(self)
  self:setMustWinLotteryData({})
  self:setInitialEnterInto({})
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\231\187\132\229\144\136\233\153\144\230\151\182"] = function(self)
  self:setCombinedGiftData({})
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\231\139\172\231\171\139\233\153\144\230\151\182"] = function(self)
  self:setSignalLimitGiftData({})
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\233\135\141\231\189\174\233\153\144\230\151\182\230\138\189\229\165\150\230\172\161\230\149\176"] = function(self)
  self:setLimitedTimeDrawData({})
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\230\175\143\229\145\168"] = function(self)
  self:setLimitedTimeWeekData({})
  self:setLimitedTimeWeekKey(0)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\230\175\143\230\156\136"] = function(self)
  self:setLimitedTimeMonthData({})
  self:setLimitedTimeMonthKey(0)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\230\138\152\230\137\163"] = function(self)
  self:setLimitedTimeDiscountData({})
  self:setLimitedTimeDiscountKey(0)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\233\153\164\232\135\170\233\128\137"] = function(self)
  self:setLimitedTimeOptionalData({})
  self:setLimitedTimeOptionalBuy({})
end
