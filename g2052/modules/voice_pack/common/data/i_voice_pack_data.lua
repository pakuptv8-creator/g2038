local IVoicePackData = class("IVoicePackData")

function IVoicePackData:ctor(player)
  self.player = player
  self.voices = {}
  self:initData()
end

function IVoicePackData:initData()
end

function IVoicePackData:addVoicePack(id)
  if self:hasVoicePack(id) then
    return false
  end
  table.insert(self.voices, id)
  return true
end

function IVoicePackData:removeVoicePack(id)
  if not self:hasVoicePack(id) then
    return false
  end
  Lib.tableRemove(self.voices, id)
  return true
end

function IVoicePackData:getVoiceList()
  return self.voices
end

function IVoicePackData:hasVoicePack(id)
  return Lib.tableContain(self.voices, id)
end

return IVoicePackData
