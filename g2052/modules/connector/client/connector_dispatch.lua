local CConnectorDispatch = class("CConnectorDispatch", require("common.i_connector_dispatch"))

function CConnectorDispatch:ctor()
  self.super.ctor(self)
end

T(Lib, "ConnectorDispatch", CConnectorDispatch.new())
