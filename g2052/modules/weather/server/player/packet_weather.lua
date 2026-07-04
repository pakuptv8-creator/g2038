local InteractionHelper = T(Lib, "InteractionHelper")
local WeatherCtrl = T(Lib, "WeatherCtrl")
local handles = T(Player, "PackageHandlers")

function handles:addBadWeatherBuffer(packet)
  self:addBuff(packet.buffer, packet.duration)
end

function handles:doBadWeatherAction(packet)
  InteractionHelper:doDanceAction(self, packet.actionId, packet.actionId > 0)
end

function handles:switchWeatherByPlayer(packet)
  WeatherCtrl:SwitchByPlayer(self, packet.index)
end

function handles:QuickUseItem(packet)
  self:onOperationBag({
    id = packet.item
  })
end
