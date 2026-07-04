require("common.entity_announcement")
require("common.event_announcement")
require("common.config.announcement_config")
require("common.define_announcement")
if World.isClient then
  require("client.player.player_announcement")
  require("client.player.packet_announcement")
  require("client.entity.entity_announcement")
  require("client.entity.entity_value_func_announcement")
  require("client.gate_announcement")
  require("client.gm_announcement")
else
  require("server.player.player_announcement")
  require("server.player.packet_announcement")
  require("server.entity.entity_announcement")
  require("server.gate_announcement")
  require("server.gm_announcement")
end
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    local cfg = World.cfg.announcementSetting
    local needMarket = true
    if cfg.open == true then
      local cfgVision = cfg.vision
      local cfgShowDay = cfg.showDay
      local curVision = entity:getAnnouncementVision()
      if cfgVision > curVision then
        needMarket = false
        entity:sendPacket({
          pid = "popAnnouncementUI",
          objID = entity.objID
        })
        if not cfg.debug then
          entity:setAnnouncementVision(cfgVision)
          if cfgShowDay and 1 < cfgShowDay then
            local nowTime = os.time()
            local curData = entity:getAnnouncementData() or {}
            curData.vision = cfgVision
            curData.endTime = nowTime + cfgShowDay * 86400
            curData.showTime = nowTime
            entity:setAnnouncementData(curData)
          end
        end
      else
        local needShow = false
        if cfgShowDay and 1 < cfgShowDay then
          local nowTime = os.time()
          local curData = entity:getAnnouncementData() or {}
          if not curData.vision or curData.vision ~= cfgVision then
            if not cfg.debug then
              curData.vision = cfgVision
              curData.endTime = nowTime + cfgShowDay * 86400
              curData.showTime = nowTime
              entity:setAnnouncementData(curData)
            end
            needShow = true
          elseif not Lib.isSameDay(curData.showTime, nowTime) and (nowTime < curData.endTime or Lib.isSameDay(curData.endTime, nowTime)) then
            if not cfg.debug then
              curData.showTime = nowTime
              entity:setAnnouncementData(curData)
            end
            needShow = true
          end
        end
        if needShow then
          entity:sendPacket({
            pid = "popAnnouncementUI",
            objID = entity.objID
          })
        end
      end
    end
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
