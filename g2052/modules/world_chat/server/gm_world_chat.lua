local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["world_chat/\230\181\139\232\175\149GateWay"] = function(self)
  local data = {
    type = 10005,
    userId = self.platformUserId,
    data = "ttttttTest " .. os.time()
  }
  Lib.logDebug(data)
  Lib.emitEvent(Event.EVENT_CONNECTOR_MSG, data)
end
