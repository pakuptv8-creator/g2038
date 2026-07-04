local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local density = 0.1
GMItem["g2052\229\183\165\229\133\183/\233\155\190\230\176\148+"] = function()
  density = density + 0.1
  print("========density", density)
  local fog = {}
  fog.start = 0
  fog["end"] = 65
  fog.density = density
  fog.color = {
    x = 0.3,
    y = 0.3,
    z = 0.3
  }
  Blockman.instance.gameSettings:setCustomFog(fog.start, fog["end"], fog.density, fog.color, fog.type, fog.min)
  Blockman.instance.gameSettings.hideFog = false
end
GMItem["g2052\229\183\165\229\133\183/\233\155\190\230\176\148-"] = function()
  density = density - 0.1
  print("========density", density)
  local fog = {}
  fog.start = 0
  fog["end"] = 65
  fog.density = density
  fog.color = {
    x = 0.3,
    y = 0.3,
    z = 0.3
  }
  Blockman.instance.gameSettings:setCustomFog(fog.start, fog["end"], fog.density, fog.color, fog.type, fog.min)
  Blockman.instance.gameSettings.hideFog = false
end
GMItem["g2052\229\183\165\229\133\183/\229\188\128\229\133\179timelight"] = function()
  local TimeLight = T(Lib, "TimeLight")
  TimeLight.disabled = not TimeLight.disabled
  print(TimeLight.disabled and "TimeLight\229\183\178\229\133\179\233\151\173" or "TimeLight\229\183\178\229\188\128\229\144\175")
end
