local IVoicePackData = require("common.data.i_voice_pack_data")
local SVoicePackData = class("SVoicePackData", IVoicePackData)
local GameReport = T(Game, "Report")

function SVoicePackData:initData()
  AsyncProcess.GetPlayerVoicePackData(self.player.platformUserId, function(voiceData)
    self.voices = Lib.splitString(voiceData or "", ",", true)
    self:syncData()
  end)
end

function SVoicePackData:addVoicePack(id)
  if not IVoicePackData.addVoicePack(self, id) then
    return
  end
  GameReport:report("kol_voice_gain", {voice_id = id}, self.player)
  self:saveData()
  self:syncData()
end

function SVoicePackData:removeVoicePack(id)
  if not IVoicePackData.removeVoicePack(self, id) then
    return
  end
  self:saveData()
  self:syncData()
end

function SVoicePackData:saveData()
  local voiceData = table.concat(self.voices, ",")
  AsyncProcess.SetPlayerVoicePackData(self.player.platformUserId, voiceData)
end

function SVoicePackData:syncData()
  self.player:sendPacket({
    pid = "SyncVoicePackData",
    voices = self.voices
  })
end

return SVoicePackData
