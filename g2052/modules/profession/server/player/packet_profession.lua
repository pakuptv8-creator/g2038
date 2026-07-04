local handles = T(Player, "PackageHandlers")
local ProfessionalHelper = T(Lib, "ProfessionalHelper")
local MessageNoticeManager = T(Lib, "MessageNoticeManager")

function handles:CSUpdateProfession(packet)
  local professionId = tonumber(packet.professionId) or 0
  self:setProfessionId(professionId)
  if 0 < professionId then
    if not self.firstSetProfessionId then
      local defaultData = {job_id = professionId}
      Plugins.CallTargetPluginFunc("report", "report", "first_job", defaultData, self)
      self.firstSetProfessionId = true
    end
    Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", self, Define.HEART_WARM_TASK_TYPE.PROFESSION)
  end
end

function handles:RequestAllPlayerCareer(packet)
  local careerData = {}
  local players = Game.GetAllPlayers()
  for _, player in pairs(players) do
    if player.platformUserId ~= self.platformUserId then
      local professionId = player:getProfessionId()
      if careerData[professionId] then
        careerData[professionId] = careerData[professionId] + 1
      else
        careerData[professionId] = 1
      end
    end
  end
  self:sendPacket({
    pid = "SyncAllCareerData",
    careerData = careerData
  })
end

function handles:RequestCallOneCareer(packet)
  local haveCall = false
  local callData = {}
  local callInfo = {
    fromObjID = self.objID,
    professionId = packet.professionId
  }
  local players = Game.GetAllPlayers()
  local receiverList = {}
  for _, player in pairs(players) do
    local professionId = player:getProfessionId()
    if professionId == packet.professionId and player.objID ~= self.objID then
      callInfo.pid = "SyncReceiveCareerCall"
      player:sendPacket(callInfo)
      table.insert(callData, player.platformUserId)
      haveCall = true
      table.insert(receiverList, player)
    end
  end
  if next(receiverList) ~= nil then
    local msgId = Define.MessageNoticeType.SOMEONE_NEED_HELP
    local checkCD = self:checkSendMessageNoticeCD(msgId)
    if checkCD then
      MessageNoticeManager:pushMessageNotice(msgId, receiverList, tostring(self.name))
      self:sendMessageNoticeCDRecord(msgId)
    end
  end
  if haveCall then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.phone.career_success_tips")
    callInfo.pid = "SyncSendCallSuccess"
    self:sendPacket(callInfo)
    ProfessionalHelper:updateSendCallData(self.objID, packet.professionId, callData)
    local defaultData = {
      job_id = self:getProfessionId()
    }
    Plugins.CallTargetPluginFunc("report", "report", "phone_call", defaultData, self)
  end
end

function handles:GetPlayerServerMapAndPos(packet)
  local result = {}
  for _, objId in pairs(packet.outsideList) do
    local entity = World.CurWorld:getEntity(objId)
    if entity and entity:isValid() then
      result[objId] = {
        pos = entity:getPosition(),
        mapName = entity.map.name
      }
    end
  end
  return result
end
