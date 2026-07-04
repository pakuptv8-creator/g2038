local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local TimeLight = T(Lib, "TimeLight")
GMItem["\229\156\176\229\155\190/\230\137\147\229\188\128\228\189\142\231\148\187\232\180\168HDR"] = function()
  EngineSceneManager.Instance():setLowQualityHdr(true)
end
GMItem["\229\156\176\229\155\190/\229\133\179\233\151\173\228\189\142\231\148\187\232\180\168HDR"] = function()
  EngineSceneManager.Instance():setLowQualityHdr(false)
end
GMItem["\229\156\176\229\155\190/\232\174\190\231\189\174HDR Exposure"] = GM:inputStr(function(self, value)
  local exposure = tonumber(value)
  local engineSceneManager = EngineSceneManager.Instance()
  engineSceneManager:setExposure(exposure)
end, function(self)
  local engineSceneManager = EngineSceneManager.Instance()
  return engineSceneManager:getExposure()
end)
GMItem["\229\156\176\229\155\190/\232\174\190\231\189\174HDR Gamma"] = GM:inputStr(function(self, value)
  local gamma = tonumber(value)
  local engineSceneManager = EngineSceneManager.Instance()
  engineSceneManager:setGamma(gamma)
end, function(self)
  local engineSceneManager = EngineSceneManager.Instance()
  return engineSceneManager:getGamma()
end)
