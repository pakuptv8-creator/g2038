local handles = T(Player, "PackageHandlers")
local ProfessionConfig = T(Config, "ProfessionConfig")
local ProfessionalHelper = T(Lib, "ProfessionalHelper")

function handles:SyncAllCareerData(packet)
  local allCareer = Lib.copy(ProfessionConfig:getAllCallCfgs())
  for key, val in pairs(allCareer) do
    allCareer[key].counts = packet.careerData[val.id] or 0
  end
  table.sort(allCareer, function(a, b)
    if a.counts == b.counts then
      return a.sortId < b.sortId
    else
      return a.counts > b.counts
    end
  end)
  Lib.emitEvent(Event.EVENT_UPDATE_ALL_CAREER_DATA, allCareer)
end

function handles:SyncSendCallSuccess(packet)
  ProfessionalHelper:playCallSoundByKey(World.cfg.phoneProfession.sSoundKey, World.cfg.phoneProfession.sSoundTime * 20, packet.fromObjID)
  self:updateCallSelfTopEffect(true)
end

function handles:SyncReceiveCareerCall(packet)
  ProfessionalHelper:updateReceiveCallData(packet.fromObjID, packet.professionId)
end

function handles:SyncCleanOneCareerCall(packet)
  ProfessionalHelper:cleanOneCareerCall(packet.fromObjID)
end
