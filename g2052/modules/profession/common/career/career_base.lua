local CareerBase = Lib.class("CareerBase")
local ProfessionConfig = T(Config, "ProfessionConfig")

function CareerBase:ctor(professionId)
  self:init(professionId)
  self:initBaseEvent()
  self:initSpecialEvent()
end

function CareerBase:init(professionId)
  self.type = professionId or Define.CareerType.Base
end

function CareerBase:initBaseEvent()
  self._allEvent = {}
end

function CareerBase:initSpecialEvent()
end

function CareerBase:getCareerHeadIcon(professionId)
  if professionId == Define.CareerType.Base then
    return ""
  else
    local professionCfg = ProfessionConfig:getCfgById(professionId)
    if professionCfg then
      return professionCfg.sceneIcon
    else
      return ""
    end
  end
end

function CareerBase:getCareerUIIcon(professionId)
  if professionId == Define.CareerType.Base then
    return ""
  else
    local professionCfg = ProfessionConfig:getCfgById(professionId)
    if professionCfg then
      return professionCfg.normalIcon
    else
      return ""
    end
  end
end

function CareerBase:destroy()
  self:onDestroy()
end

function CareerBase:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return CareerBase
