local TenderingSignManager = T(Lib, "TenderingSignManager")
local TenderingPublicManager = T(Lib, "TenderingPublicManager")
local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
local handles = T(Player, "PackageHandlers")

function handles:UpdateTenderingLandInfo(packet)
  local params = packet.params
  TenderingSignManager:updateTenderingLandInfo(params)
  TenderingPublicManager:updateTenderingLandInfo(params)
end

function handles:SCPushClientSocialAward(packet)
  TenderClientAwardManager:updateClientSocialAward(packet.socialData)
end

function handles:SCPushClientBuildAward(packet)
  TenderClientAwardManager:updateClientBuildAward(packet.buildAwardData)
end

function handles:SCPushUpdateMayorStatueName(packet)
  self:onUpdateMayorStatueUI(true, packet.objID, packet.name)
end

function handles:SCPushRemoveMayorStatueUI(packet)
  self:onUpdateMayorStatueUI(false)
end
