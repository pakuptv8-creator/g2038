local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local WeatherCtrl = T(Lib, "WeatherCtrl")
local curWeatherIndex = 1
GMItem["g2052\229\183\165\229\133\183/\229\136\135\230\141\162\229\164\169\230\176\148"] = function(self)
  curWeatherIndex = curWeatherIndex + 1
  if 8 < curWeatherIndex then
    curWeatherIndex = 1
  end
  WeatherCtrl:switchWeather(curWeatherIndex, self.map.name)
end
