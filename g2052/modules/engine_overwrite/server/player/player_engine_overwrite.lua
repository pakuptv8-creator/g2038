local ChatMsgCacheHelper = T(Lib, "ChatMsgCacheHelper")
local handles = T(Player, "PackageHandlers")

function Player:autoDataExpire()
  local lastLoginTime = self:getLastLoginTime()
  local nowTime = os.time()
  if not Lib.isSameWeek(lastLoginTime, nowTime) then
  end
  if not lastLoginTime or not Lib.isSameDay(lastLoginTime, nowTime) then
  end
  self:updateLastLoginTime()
end

function Player:checkCanSendVoice()
  if not self:checkVoiceMoonEnable() and self:getSoundTimes() < 1 and 1 > self:getFreeSoundTimes() then
    local packet = {
      pid = "ChatSystemMessage",
      msg = "ui.chat.voiceless",
      isLang = true,
      args = table.pack(nil, nil, Define.Page.SYSTEM)
    }
    self:sendChatMsg(packet)
    return false
  end
  return true
end

function Player:sendMessageToSystem(msg1, msg2)
  local packet = {
    pid = "ChatSystemMessage",
    msg = msg1,
    msg2 = msg2,
    args = table.pack(nil, nil, Define.Page.SYSTEM)
  }
  WorldServer.BroadcastPacket(packet)
end

function Player:sendLoginMessageToSystem(msg1, msg2)
  local packet = {
    pid = "ChatSystemMessage",
    msg = msg1,
    msg2 = msg2,
    args = table.pack(nil, nil, Define.Page.SYSTEM)
  }
  self:sendPacket(packet)
end

function handles:BuyVoice(packet)
  if not packet or not packet.idx then
    return
  end
  local VoiceShopConfig = T(Config, "VoiceShopConfig")
  local cnt = VoiceShopConfig:getItemById(packet.idx).cost
  Lib.payMoney(self, 10000 + packet.idx, 0, cnt, function(success)
    self:sendPacket({
      pid = "BuyVoiceResult",
      isSucceed = success
    })
    if success then
      self:resetFreeSoundTimes()
      local reward = VoiceShopConfig:getItemById(packet.idx).num
      if 0 < reward then
        self:addVoiceCnt(reward)
      else
        self:addMoonCard(-reward)
      end
      local defaultData = {
        voice_item = packet.idx
      }
      Plugins.CallTargetPluginFunc("report", "report", "shop_buy_voice", defaultData, self)
    else
      print("BuyVoice fail")
    end
  end, 1, Define.ExchangeItemsReason.BuyVoice or 2)
end

function handles:ChatMessage(packet)
  local msg = packet.msg
  if not msg or utf8.len(msg) > 1000 then
    return
  end
  if packet.voiceTime and not self:checkCanSendVoice() then
    return
  end
  if not packet.voiceTime then
    msg = World.CurWorld:filterWord(packet.msg)
  end
  local type = "msg"
  if packet.voiceTime then
    type = "voice"
  elseif packet.emoji then
    type = "emoji"
  end
  Trigger.CheckTriggers(self:cfg(), "SEND_CHAT_MESSAGE", {
    obj1 = self,
    msg = msg,
    msgType = type
  })
  local dg
  local packet = {
    pid = "ChatMessage",
    fromname = self.name,
    msg = msg,
    voiceTime = packet.voiceTime,
    emoji = packet.emoji or false,
    args = table.pack(self.objID, dg, Define.Page.COMMON, self.platformUserId),
    textVipColor = self:getTextVipColor()
  }
  self:sendChatMsg(packet, true)
  if packet.voiceTime then
    self:updateVoiceCounts()
  end
  self:addConditionAutoCounts(Define.tagConditionType.talk, 1)
  ChatMsgCacheHelper:addOneCommonChatMsg(packet)
end

function handles:sendRenderTickCount(packet)
  self.afps = packet.afps
end

function handles:OnWatchAdResult(packet)
  local code = packet.code
  local context = {
    obj1 = self,
    type = packet.type,
    params = packet.params
  }
  if code == 1 then
    Trigger.CheckTriggers(self:cfg(), "WATCH_AD_FINISHED", context)
  elseif code == 2 then
    Trigger.CheckTriggers(self:cfg(), "WATCH_AD_FAILED", context)
  elseif code == 3 then
    Trigger.CheckTriggers(self:cfg(), "CLOSE_WATCH_AD", context)
  end
  local type = packet.type
  local params = packet.params
  local adsId = ""
  local is_adv_module = false
  if type == Define.AdvertisingType.Car then
    adsId = Define.AdvertisingAdsId.Car
  elseif type == Define.AdvertisingType.Dress then
    adsId = Define.AdvertisingAdsId.Dress
  elseif type == Define.AdvertisingType.Pet then
    adsId = Define.AdvertisingAdsId.Pet
  elseif type == Define.AdvertisingType.House then
    adsId = Define.AdvertisingAdsId.House
  elseif type == Define.AdvertisingType.AdvertisementDraw then
    adsId = Define.AdvertisingAdsId.AdvertisementDraw
    is_adv_module = true
  elseif type == Define.AdvertisingType.AdvertisementLockSlot then
    adsId = Define.AdvertisingAdsId.AdvertisementLockSlot
    is_adv_module = true
  elseif type == Define.AdvertisingType.AdvertisementScene then
    adsId = Define.AdvertisingAdsId.AdvertisementScene
    is_adv_module = true
  end
  if code == 1 then
    if not is_adv_module then
      self:setIsWatchedAd(true)
    end
    local defaultData = {ad_id = adsId}
    Plugins.CallTargetPluginFunc("report", "report", "g2052_vehicle_mAd_success", defaultData, self)
  elseif code == 2 then
    local defaultData = {ad_id = adsId}
    Plugins.CallTargetPluginFunc("report", "report", "g2052_vehicle_mAd_fail", defaultData, self)
  elseif code == 3 then
    local defaultData = {ad_id = adsId}
    Plugins.CallTargetPluginFunc("report", "report", "g2052_vehicle_mAd_suspend", defaultData, self)
  end
  if is_adv_module then
    Plugins.CallTargetPluginFunc("advertisement_module", "onWatchAdResult", context, type, code == 1, params)
  end
  local packet = {
    pid = "SCWatchCarAdResult",
    type = type,
    code = code,
    params = params
  }
  self:sendChatMsg(packet)
end
