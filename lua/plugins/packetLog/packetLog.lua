local handlers = {}
local cjson = require("cjson")

function World.ClearPacketCount()
end

World.EnablePacketCount(true)

local function doDesign()
  local packetSend = World.ShowPacketCount().send or {}
  local packetMap = {}
  for pid, info in pairs(packetSend) do
    packetMap[pid] = cjson.encode({
      count = info.count,
      tolSize = info.size,
      minSize = info.min,
      maxSize = info.max
    })
  end
  GameAnalytics.NewDesign(0, "packetLog", packetMap)
end

local engine_StopServer = Game.StopServer

function Game.StopServer(message, ...)
  doDesign()
  engine_StopServer(message, ...)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  handlers[name](...)
end
