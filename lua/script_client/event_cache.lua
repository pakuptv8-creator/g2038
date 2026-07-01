local eventCache = {}

local function useEvent(event)
  if eventCache[event] ~= nil then
    return
  end
  local queue = {}
  eventCache[event] = {
    queue = queue,
    unsubscribe = Lib.subscribeEvent(event, function(...)
      table.insert(queue, {
        ...
      })
    end)
  }
end

local function subscribeEvent(event, callback)
  World.LightTimer(nil, 1, function()
    local cache = eventCache[event]
    if cache ~= nil then
      for _, params in ipairs(cache.queue) do
        callback(table.unpack(params))
      end
      cache.unsubscribe()
      eventCache[event] = nil
    end
    Lib.subscribeEvent(event, callback)
  end)
end

useEvent(Event.EVENT_FORCE_GUIDE)
useEvent(Event.EVENT_CHANGE_CURRENCY)
useEvent(Event.EVENT_UPDATE_SHOP_BUY_INFO)
useEvent(Event.EVENT_PLAYER_LEVEL_UP)
useEvent(Event.EVENT_POKEMON_DATA_CHANGE)
useEvent(Event.EVENT_UPDATE_SPRAY_TIME)
useEvent(Event.EVENT_UPDATE_TRIGGER_GIFT_INFO)
useEvent(Event.EVENT_MAP_SETICON)
return subscribeEvent
