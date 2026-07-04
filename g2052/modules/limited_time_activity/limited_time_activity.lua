require("common.lib_limited_time_activity")
require("common.entity_limited_time_activity")
require("common.event_limited_time_activity")
require("common.config.limited_time_activity_config")
require("common.config.limited_time_gift_combined_config")
require("common.config.limited_time_gift_signal_config")
require("common.config.limited_time_gift_item_config")
require("common.config.must_win_lottery_config")
require("common.config.must_win_lottery_award_config")
require("common.define_limited_time_activity")
Lib.declare("LimitedTimeActivityGameMgr", {})
require("common.limited_time_activity_game_mgr")
require("common.config.limited_time_month_gift_config")
require("common.config.limited_time_week_gift_config")
require("common.config.limited_time_draw_config")
require("common.config.limited_time_draw_awards_config")
require("common.config.limited_time_discount_gift_config")
require("common.config.limited_time_card_config")
require("common.config.limited_time_optional_gift_config")
require("common.config.limited_time_gold_wheel_config")
require("common.config.limited_time_gold_wheel_awards_config")
require("common.config.limited_time_rounds_config")
require("common.config.heart_warming_gift_config")
require("common.config.heart_warming_task_config")
if World.isClient then
  require("client.player.player_limited_time_activity")
  require("client.player.packet_limited_time_activity")
  require("client.entity.entity_limited_time_activity")
  require("client.entity.entity_value_func_limited_time_activity")
  require("client.gm_limited_time_activity")
  require("client.limited_time_client_helper")
else
  Lib.declare("LimitedTimeActivityMgr", {})
  require("server.player.player_limited_time_activity")
  require("server.player.packet_limited_time_activity")
  require("server.entity.entity_limited_time_activity")
  require("server.limited_time_activity_mgr")
  require("server.gm_limited_time_activity")
end
local handlers = {}
if World.isClient then
  local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
  
  function handlers.openLimitTimeCombinedWnd()
    if not LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT) then
      return
    end
    UI:openWnd("limitTimeCombination")
    GameAnalytics.NewDesign("limited_giftpack_click", {})
  end
  
  function handlers.openLimitTimeSignalWnd()
    if not LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT) then
      return
    end
    UI:openWnd("limitTimeSignalWnd")
    GameAnalytics.NewDesign("limited_giftpack_click", {})
  end
  
  function handlers.openLimitTimeActivityWnd()
    UI:openWnd("limitedTimeActivityWnd")
  end
else
  function handlers.ENTITY_ENTER(context)
    local entity = context.obj1
    
    if not entity or not entity:isValid() then
      return
    end
    if entity.isPlayer then
      LimitedTimeActivityMgr:syncActivityToPlayer(entity)
      LimitedTimeActivityMgr:checkWeekMonthRounds(entity)
      LimitedTimeActivityMgr:checkPlayerIsNextDayLogin(entity)
      LimitedTimeActivityMgr:checkHeartWarmData(entity)
      entity:grantLimitedTimeCardAward()
    end
  end
  
  function handlers.updateHeartWarmTaskProgress(player, taskType)
    LimitedTimeActivityMgr:updateHeartWarmTaskProgress(player, taskType)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
