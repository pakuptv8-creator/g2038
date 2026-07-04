local handles = T(Player, "PackageHandlers")
local DramaServerHelper = T(Lib, "DramaServerHelper")
local cjson = require("cjson")
local gameId = Server.CurServer:getGameId()

function handles:RequestCreateOneDrama(packet)
  if self.onRequestCreateDrama then
    return
  end
  self.onRequestCreateDrama = true
  DramaManager:createDrama(self, packet.dramaInfo, function(isSuccess)
    local packet = {
      pid = "ResponseCreateDrama",
      isSuccess = isSuccess
    }
    self:sendPacket(packet)
    if isSuccess then
      Plugins.CallTargetPluginFunc("report", "report", "script_create_back", nil, self)
    end
    self.onRequestCreateDrama = false
  end)
end

function handles:RequestAmendOneDrama(packet)
  DramaServerHelper:RequestAmendAllDrama(packet.dramaInfo)
end

function handles:RequestDramaThumbUpPlayer(packet)
  if DramaServerHelper:checkIsCanThumbUp(self.platformUserId, packet.targetUserId) then
    AsyncProcess.ThumbUpOthersPlayer(function(isSuccess, data)
      if isSuccess then
        DramaServerHelper:updateThumbUpInfo(self.platformUserId, packet.targetUserId)
      end
      local packet = {
        pid = "ResponseThumbUpPlayer",
        isSuccess = isSuccess,
        targetUserId = packet.targetUserId
      }
      self:sendPacket(packet)
    end, self.platformUserId, packet.targetUserId)
  else
    local packet = {
      pid = "ResponseThumbUpPlayer",
      isSuccess = false,
      targetUserId = packet.targetUserId
    }
    self:sendPacket(packet)
    return
  end
end

function handles:RequestLeaveDrama(packet)
  self:crossServerLogin(self.platformUserId)
end

function handles:RequestDissolveDrama(packet)
  if self.onRequestDissolveDrama then
    return
  end
  self.onRequestDissolveDrama = true
  DramaManager:securityEntrances("amendDramaStatus", Define.DramaStatus.Dissolve, function(isSuccess)
    if isSuccess then
      self:crossServerLogin(self.platformUserId)
    end
    self.onRequestDissolveDrama = false
  end)
end

function handles:RequestJoinDrama(packet)
  if self.onRequestJoinDrama then
    return
  end
  self.onRequestJoinDrama = true
  DramaManager:requestJoinDrama(self, packet.id, function(isSuccess)
    local packet = {
      pid = "ResponseJoinDrama",
      isSuccess = isSuccess
    }
    self:sendPacket(packet)
    if isSuccess then
      Plugins.CallTargetPluginFunc("report", "report", "script_join_back", nil, self)
    end
    self.onRequestJoinDrama = false
  end, packet.channel)
end

function handles:clickLickC2S(packet)
  local dramaInf = DramaServerHelper.curDramaCache
  if self.platformUserId == dramaInf.userId then
    return
  end
  local likeCount = packet.count
  if likeCount then
    if Lib.isGameDrama() and DramaManager:isGiveALikeFirstTime(self.platformUserId) then
      Plugins.CallTargetPluginFunc("report", "report", "script_like", nil, self)
    end
    DramaManager:securityEntrances("giveALike", likeCount, self.platformUserId)
  end
end

function handles:recordSelectRoleFailC2S(packet)
  if not DramaServerHelper.selectRoleFailCounter then
    DramaServerHelper.selectRoleFailCounter = 0
  end
  DramaServerHelper.selectRoleFailCounter = DramaServerHelper.selectRoleFailCounter + 1
  if DramaServerHelper.curDramaCache then
  end
end
