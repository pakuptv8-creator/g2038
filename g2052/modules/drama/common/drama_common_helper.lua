local DramaCommonHelper = T(Lib, "DramaCommonHelper")
local cjson = require("cjson")
local DramaTemplateConfig = T(Config, "DramaTemplateConfig")

function DramaCommonHelper:init()
end

function DramaCommonHelper:dealScriptDataToModList(scriptData)
  local modList = {}
  if scriptData and scriptData ~= "" then
    modList = cjson.decode(scriptData)
  end
  for key, val in pairs(modList) do
    modList[key] = tonumber(val)
  end
  return modList
end

function DramaCommonHelper:dealModListToScriptData(modList)
  local scriptData = cjson.encode(modList or {})
  return scriptData
end

function DramaCommonHelper:initTemplate(modList)
  print("++++++++++++++++++++++++++++++++++++++ DramaCommonHelper:initTemplate(modList) ", Lib.v2s(modList))
  self.curModList = modList
  Lib.emitEvent(Event.EVENT_INIT_DRAMA_TEMPLATE)
end

function DramaCommonHelper:banWeatherSwitch()
  if self.curModList then
    local weather = self:getStaticWeatherId()
    return weather and 0 < weather
  end
  return false
end

function DramaCommonHelper:getStaticWeatherId()
  local weatherId = 0
  local weatherPriority = -1
  if self.curModList then
    for _, v in pairs(self.curModList) do
      local cfg = DramaTemplateConfig:getCfgById(v)
      if cfg and cfg.weather and 0 < cfg.weather and weatherPriority < cfg.priority then
        weatherId = cfg.weather
        weatherPriority = cfg.priority
      end
    end
  end
  return weatherId
end

function DramaCommonHelper:openFog()
  if self.curModList then
    for _, v in pairs(self.curModList) do
      local cfg = DramaTemplateConfig:getCfgById(v)
      if cfg and cfg.openFog and cfg.openFog == 1 then
        return true
      end
    end
  end
  return false
end

DramaCommonHelper:init()
