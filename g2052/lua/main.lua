require("common.gm")
if World.isClient then
else
  require("script_server.highlight_data_handler")
end
if PlatformUtil.isPlatformWindows() then
  LogUtil.setMaxMessageSize(102400)
end
