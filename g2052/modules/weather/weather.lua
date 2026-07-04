require("common.define_weather")
require("common.config.weather_config")
if World.isClient then
  require("client.player.packet_weather")
  require("client.gm_weather")
  require("client.weather_mgr")
else
  require("common.weathers.weather_ctrl")
  require("server.player.player_weather")
  require("server.player.packet_weather")
  require("server.gm_weather")
end
local handlers = {}
local WeatherCtrl = T(Lib, "WeatherCtrl")

function handlers.OnPlayerLogin(player)
  WeatherCtrl:sendWeatherInfo(player)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
