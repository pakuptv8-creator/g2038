require("common.entity_mod_editor")
require("common.event_mod_editor")
require("common.define_mod_editor")
if World.isClient then
  require("client.player.player_mod_editor")
  require("client.player.packet_mod_editor")
  require("client.entity.entity_mod_editor")
  require("client.entity.entity_value_func_mod_editor")
  require("client.async_process.async_process_mod")
  require("client.async_process.mod_async_proxy")
  require("client.gate_mod_editor")
  require("client.gm_mod_editor")
  require("client.mod_report_proxy")
  require("client.mod_editor_lib")
else
  require("server.player.player_mod_editor")
  require("server.player.packet_mod_editor")
  require("server.entity.entity_mod_editor")
  require("server.gate_mod_editor")
  require("server.gm_mod_editor")
end
local handlers = {}

function handlers.openModEditorWnd(wndName, isShow)
  UI:getWnd(wndName):onShow(isShow)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
