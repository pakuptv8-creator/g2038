local SConnectorDispatch = class("SConnectorDispatch", require("common.i_connector_dispatch"))

function SConnectorDispatch:onMsgReceive(type, targets, data)
  local intercept = self.super.onMsgReceive(self, type, targets, data)
  if intercept then
    return
  end
  local param = {type = type, data = data}
  if #targets == 0 or tostring(targets[1]) == "0" then
    WorldServer.BroadcastPacket({
      pid = "ConnectorMsg",
      data = param
    })
    Lib.emitEvent(Event.EVENT_SERVER_CONNECTOR_MSG, param)
  else
    for _, userId in pairs(targets) do
      local player = Game.GetPlayerByUserId(userId)
      if player and player:isValid() then
        player:sendPacket({
          pid = "ConnectorMsg",
          data = param
        })
      end
    end
  end
end

T(Lib, "ConnectorDispatch", SConnectorDispatch.new())
