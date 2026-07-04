local ProfessionalHelper = T(Lib, "ProfessionalHelper")
local CareerBase = require("common.career.career_base")
local CareerPolice = require("common.career.career_police")
local CareerRobber = require("common.career.career_robber")
local SoundConfig = T(Config, "SoundConfig")

function ProfessionalHelper:init()
  self.professionClass = {}
  self.professionClass[Define.CareerType.Base] = CareerBase.new(Define.CareerType.Base)
  self.professionClass[Define.CareerType.Police] = CareerPolice.new(Define.CareerType.Police)
  self.professionClass[Define.CareerType.Robber] = CareerRobber.new(Define.CareerType.Robber)
  self.receiveCallInfo = {}
  self.sendCallInfo = {}
end

if World.isClient then
  function ProfessionalHelper:getHeadProfessionIcon(professionId)
    if self.professionClass[professionId] then
      return self.professionClass[professionId]:getCareerHeadIcon(professionId)
    else
      return self.professionClass[Define.CareerType.Base]:getCareerHeadIcon(professionId)
    end
  end
  
  function ProfessionalHelper:updateReceiveCallData(fromObjID, professionId)
    if Me.isIgnorePhoneCall then
      return
    end
    if not self.receiveCallInfo[fromObjID] then
      self.receiveCallInfo[fromObjID] = {}
    end
    self.receiveCallInfo[fromObjID].professionId = professionId
    self.receiveCallInfo[fromObjID].receiveTime = os.time()
    self.receiveCallInfo[fromObjID].closeRangeTime = nil
    self.receiveCallInfo[fromObjID].needRemove = false
    UI:getWnd("phoneCallWnd"):onShow(true)
    self:playCallSoundByKey(World.cfg.phoneProfession.rSoundKey, World.cfg.phoneProfession.rSoundTime * 20, fromObjID)
    self:checkCallDisTimer()
    self:updateCallPlayerDisShow()
  end
  
  function ProfessionalHelper:checkCallDisTimer()
    if Me:data("main").callPhoneTimer then
      return
    end
    Me:data("main").callPhoneTimer = Me:lightTimer("callPhoneTimer check distance", 10, function()
      self:updateCallPlayerDisShow()
      return true
    end)
  end
  
  function ProfessionalHelper:updateCallPlayerDisShow()
    if not next(self.receiveCallInfo) then
      Me:data("main").callPhoneTimer()
      Me:data("main").callPhoneTimer = nil
      return
    end
    for fromObjID, val in pairs(self.receiveCallInfo) do
      if self.receiveCallInfo[fromObjID] and self.receiveCallInfo[fromObjID].closeRangeTime and os.time() - self.receiveCallInfo[fromObjID].closeRangeTime > World.cfg.phoneProfession.closeCallerTime then
        self.receiveCallInfo[fromObjID].needRemove = true
      end
      if self.receiveCallInfo[fromObjID] and self.receiveCallInfo[fromObjID].receiveTime and os.time() - self.receiveCallInfo[fromObjID].receiveTime > World.cfg.phoneProfession.callTopTime then
        self.receiveCallInfo[fromObjID].needRemove = true
      end
      local entity = World.CurWorld:getEntity(fromObjID)
      if entity and entity:isValid() then
        local distance = math.floor(Me:distance(entity) * 100) / 100
        self.receiveCallInfo[fromObjID].distance = distance
        if distance <= World.cfg.phoneProfession.closeCallerDis and not self.receiveCallInfo[fromObjID].closeRangeTime then
          self.receiveCallInfo[fromObjID].closeRangeTime = os.time()
          local defaultData = {
            job_id = Me:getProfessionId()
          }
          Plugins.CallTargetPluginFunc("report", "report", "phone_call_respond", defaultData, Me)
        end
      end
      self:updateCallPlayerEffect(fromObjID)
    end
  end
  
  function ProfessionalHelper:updateCallPlayerEffect(fromObjID)
    local objId = fromObjID
    if not self.receiveCallInfo[objId] then
      return
    end
    if self.receiveCallInfo[objId].needRemove then
      self.receiveCallInfo[objId] = nil
      Lib.emitEvent(Event.EVENT_UPDATE_PHONE_CALL_ICON, objId, false)
      return
    elseif not self.receiveCallInfo[objId].phoneEffectName then
      self.receiveCallInfo[objId].phoneEffectName = true
      Lib.emitEvent(Event.EVENT_UPDATE_PHONE_CALL_ICON, objId, true)
    end
  end
  
  function ProfessionalHelper:resetMyReceiveCall(professionId)
    for fromObjID, val in pairs(self.receiveCallInfo) do
      if val.professionId ~= professionId then
        self.receiveCallInfo[fromObjID].needRemove = true
        if self.curCallFromObjId == fromObjID then
          self:stopCallSoundByKey()
        end
      end
    end
  end
  
  function ProfessionalHelper:playCallSoundByKey(key, time, fromObjID)
    self:stopCallSoundByKey()
    self.curCallFromObjId = fromObjID
    local soundInfo = SoundConfig:getSound(key)
    if key and soundInfo then
      self.curCallSid = Me:playSound(soundInfo)
    end
    if time then
      self.callSoundTimer = World.Timer(time, function()
        Me:stopSound(self.curCallSid)
        self.curCallSid = nil
        self.callSoundTimer = nil
        self.curCallFromObjId = nil
      end)
    end
  end
  
  function ProfessionalHelper:stopCallSoundByKey()
    self.curCallFromObjId = nil
    if self.curCallSid then
      Me:stopSound(self.curCallSid)
      self.curCallSid = nil
    end
    if self.callSoundTimer then
      self.callSoundTimer()
      self.callSoundTimer = nil
    end
  end
  
  function ProfessionalHelper:cleanOneCareerCall(fromObjID)
    if self.receiveCallInfo[fromObjID] then
      self.receiveCallInfo[fromObjID].needRemove = true
      if self.curCallFromObjId == fromObjID then
        self:stopCallSoundByKey()
      end
    end
  end
else
  function ProfessionalHelper:updateSendCallData(fromObjID, professionId, callData)
    if not self.sendCallInfo[fromObjID] then
      self.sendCallInfo[fromObjID] = {}
    end
    self.sendCallInfo[fromObjID][professionId] = callData
  end
  
  function ProfessionalHelper:removeSendCallData(fromObjID)
    if not self.sendCallInfo[fromObjID] then
      return
    end
    for professionId, callData in pairs(self.sendCallInfo[fromObjID]) do
      for _, userId in pairs(callData) do
        local player = Game.GetPlayerByUserId(userId)
        if player and player:isValid() then
          local packet = {
            pid = "SyncCleanOneCareerCall",
            fromObjID = fromObjID
          }
          player:sendPacket(packet)
        end
      end
    end
    self.sendCallInfo[fromObjID] = nil
  end
end
ProfessionalHelper:init()
