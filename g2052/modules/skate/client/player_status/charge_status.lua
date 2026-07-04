local BaseStatus = require("client.player_status.base_status")
local ChargeStatus = class("ChargeStatus", BaseStatus)

function ChargeStatus:onEnter()
  Lib.logWarning("ChargeStatus onEnter")
end

function ChargeStatus:onExit()
  Lib.logWarning("ChargeStatus onExit")
end

return ChargeStatus
