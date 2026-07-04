local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\152\190\231\164\186\231\187\132\229\144\136\229\133\165\229\143\163"] = function()
  LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(true)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\152\190\231\164\186\231\139\172\231\171\139\229\133\165\229\143\163"] = function()
  LimitedTimeActivityGameMgr:updateSignalLimitBtnShow(true)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\233\153\144\230\151\182\230\180\187\229\138\168\229\133\165\229\143\163"] = function()
  UI:openWnd("limitedTimeActivityWnd")
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\229\136\157\229\167\139\229\140\150\229\133\165\229\143\163\233\133\141\231\189\174"] = function()
  local activityList = {
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY,
      s_tabName = "gui.limit.time.activity.fisherman.gift",
      s_tabJson = "mustWinLottery",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_fisherman01",
      s_textColorLeftTop = "1 0.87 0.63 1",
      s_textColorRightTop = "1 0.87 0.63 1",
      s_textColorLeftBottom = "1 0.73 0.2 1",
      s_textColorRightBottom = "1 0.73 0.2 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT,
      s_tabName = "gui.limit.time.activity.week.gift",
      s_tabJson = "limitTimeWeekWnd",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_gift_packages01",
      s_textColorLeftTop = "1 1 1 1",
      s_textColorRightTop = "1 1 1 1",
      s_textColorLeftBottom = "0.4 0.72 0.99 1",
      s_textColorRightBottom = "0.4 0.72 0.99 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT,
      s_tabName = "gui.limit.time.activity.month.gift",
      s_tabJson = "limitTimeMonthWnd",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_gift_packages02",
      s_textColorLeftTop = "1 1 1 1",
      s_textColorRightTop = "1 1 1 1",
      s_textColorLeftBottom = "0.97 0.64 1 1",
      s_textColorRightBottom = "0.97 0.64 1 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW,
      s_tabName = "gui.limit.time.activity.draw.title",
      s_tabJson = "limitedTimeDraw",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_sweepstakes",
      s_textColorLeftTop = "1 1 1 1",
      s_textColorRightTop = "1 1 1 1",
      s_textColorLeftBottom = "0.890196 0.972549 0.988235 1",
      s_textColorRightBottom = "0.890196 0.972549 0.988235 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT,
      s_tabName = "gui.limit.time.activity.discount.title",
      s_tabJson = "limitTimeDiscountWnd",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_discount",
      s_textColorLeftTop = "1 0.98 0.95 1",
      s_textColorRightTop = "1 0.98 0.95 1",
      s_textColorLeftBottom = "0.99 0.8 0.52 1",
      s_textColorRightBottom = "0.99 0.8 0.52 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD,
      s_tabName = "gui.limit.time.activity.card.title",
      s_tabJson = "limitedTimeCard",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_monthly_card",
      s_textColorLeftTop = "0.97 0.65 0.22 1",
      s_textColorRightTop = "0.97 0.65 0.22 1",
      s_textColorLeftBottom = "0.91 0.50 0.2 1",
      s_textColorRightBottom = "0.91 0.50 0.2 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT,
      s_tabName = "gui.limit.time.activity.optional.title",
      s_tabJson = "limitTimeOptionalWnd",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_gift_pack",
      s_textColorLeftTop = "0.99 0.99 0.98 1",
      s_textColorRightTop = "0.99 0.99 0.98 1",
      s_textColorLeftBottom = "0.92 0.82 0.56 1",
      s_textColorRightBottom = "0.92 0.82 0.56 1"
    },
    {
      n_type = Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL,
      s_tabName = "gui.limit.time.activity.gold.wheel.title",
      s_tabJson = "limitedTimeGoldWheel",
      s_tabBgRes = "set:limited_time_activity.json image:btn_0_turntable00",
      s_textColorLeftTop = "1 1 1 1",
      s_textColorRightTop = "1 1 1 1",
      s_textColorLeftBottom = "0.93 0.82 0.51 1",
      s_textColorRightBottom = "0.93 0.82 0.51 1"
    }
  }
  for _, v in pairs(activityList) do
    LimitedTimeActivityConfig:rewriteCfg(v)
  end
end
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\184\133\231\144\134\230\154\150\229\191\131\230\180\187\229\138\168"] = function()
  local activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Me:sendPacket({
    pid = "GMLimitHeartWarming",
    key = "clean",
    activityId = activityInfo.id
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\154\150\229\191\131\229\188\128\231\172\172\228\186\140\229\164\169"] = function()
  local activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Me:sendPacket({
    pid = "GMLimitHeartWarming",
    key = "day2",
    activityId = activityInfo.id
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\154\150\229\191\131\229\188\128\231\172\172\228\184\137\229\164\169"] = function()
  local activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Me:sendPacket({
    pid = "GMLimitHeartWarming",
    key = "day3",
    activityId = activityInfo.id
  })
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\154\150\229\191\131\231\186\162\231\130\185"] = function()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
end
GMItem["\233\128\154\231\148\168\233\153\144\230\151\182/\230\154\150\229\191\131\229\165\189\229\143\139"] = function()
  local activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Me:sendPacket({
    pid = "GMLimitHeartWarming",
    key = "friend",
    activityId = activityInfo.id
  })
end
