Lib.declare("DramaManager", {})
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local gameMode = Game.GetGameMode()
local gameId = Server.CurServer:getGameId()
local maxGiveLikeCount = World.cfg.maxGiveLikeCount or 10
local sendItToTheMaster = World.cfg.dramaSetting.sendItToTheMaster
local configVersion = World.cfg.dramaSetting.configVersion
local minOnlinePlayerLimits = World.cfg.dramaSetting.minOnlinePlayerLimits or 10
local templateExclusionContent = World.cfg.dramaSetting.templateExclusionContent or {}
local DramaManager = _ENV.DramaManager
local DramaCommonHelper = T(Lib, "DramaCommonHelper")
local DramaServerHelper = T(Lib, "DramaServerHelper")
local DramaTemplateConfig = T(Config, "DramaTemplateConfig")

function DramaManager:init()
  print("---DramaManager:init----", gameMode, gameId)
  if not Lib.isGameDrama() then
    return
  end
  self.giveLikeRecord = {}
  self.curDramaInfo = {}
  self:requestCurDramaInfo()
  World.Timer(1200, function()
    self:checkedPlayerCount()
    return true
  end)
end

function DramaManager:createDrama(player, dramaInfo, callback)
  AsyncProcess.CreateOneNewDrama(function(response, isSuccess)
    if isSuccess then
      player:setJoinDramaTime({
        [player.platformUserId] = os.time()
      })
      player:crossServerLogin(player.platformUserId)
    end
    if callback then
      callback(isSuccess)
    end
  end, player.platformUserId, dramaInfo)
end

function DramaManager:requestJoinDrama(player, scriptId, callback, channel)
  AsyncProcess.GetDramaInfoById(scriptId, function(response, isSuccess)
    local canJoin = false
    if isSuccess then
      local data = response.data
      if data and data.userId and data.currentNumber < data.maxNumber and data.status == Define.DramaStatus.Activated then
        player:setJoinDramaTime({
          [data.userId] = os.time(),
          channel = channel
        })
        player:joinCrossServerLogin(data.userId, scriptId)
        canJoin = true
      end
    end
    if callback then
      callback(canJoin)
    end
  end)
end

function DramaManager:requestCurDramaInfo(needSync)
  AsyncProcess.GetDramaInfoById(gameId, function(response, isSuccess)
    if not isSuccess then
      print("GetDramaInfoById Error: ", response.code)
      return
    end
    print("GetDramaInfoById success: ", gameId, Lib.v2s(response))
    local data = response.data
    if data and not Lib.table_is_empty(data) then
      self.curDramaInfo = data
      self.ownerId = data.userId
      local scriptData = DramaServerHelper:updateCurDramaCache(data)
      self:updateDramaAdornPart(scriptData)
      DramaCommonHelper:initTemplate(self:getDramaModList())
      if needSync then
        self:sendCurDramaInfo()
      else
        self:requestCurDramaLikeCount()
      end
    end
  end)
end

function DramaManager:requestCurDramaLikeCount(giveALikeUserId)
  if self.ownerId then
    AsyncProcess.GetLikesNumByUserID(function(data)
      self.ownerLikeInfo = data
      self:sendCurDramaLikeInfo(nil, giveALikeUserId)
    end, self.ownerId)
  end
end

function DramaManager:getDramaInfo()
  return self.curDramaInfo
end

function DramaManager:getDramaModList()
  local modList = {}
  if self.curDramaInfo and self.curDramaInfo.scriptData then
    modList = DramaCommonHelper:dealScriptDataToModList(self.curDramaInfo.scriptData)
    self.curDramaInfo.modList = modList
  end
  return modList
end

function DramaManager:checkInTemplateMod(templateKey)
  if not Lib.isGameDrama() then
    return false
  end
  local modList = self:getDramaModList()
  for _, key in pairs(modList) do
    if key == templateKey then
      return true
    end
  end
  return false
end

function DramaManager:getsTemplateExclusionContent(type)
  local data = {}
  if not Lib.isGameDrama() then
    return data
  end
  local modList = self:getDramaModList()
  for _, key in pairs(modList) do
    local info = templateExclusionContent[tostring(key)]
    if info and info[tostring(type)] then
      for _, v in pairs(info[tostring(type)]) do
        data[v] = true
      end
    end
  end
  return data
end

function DramaManager:sendCurDramaInfo(player)
  if player and player:isValid() then
    player:sendPacket({
      pid = "SyncCurDramaInfo",
      params = self.curDramaInfo
    })
  else
    WorldServer.BroadcastPacket({
      pid = "SyncCurDramaInfo",
      params = self.curDramaInfo
    })
  end
end

function DramaManager:sendCurDramaLikeInfo(player, giveALikeUserId)
  if player and player:isValid() then
    player:sendPacket({
      pid = "SyncCurDramaLikeInfo",
      params = {
        ownerLikeInfo = self.ownerLikeInfo,
        giveLikeRecord = self.giveLikeRecord,
        giveALikeUserId = giveALikeUserId
      }
    })
  else
    WorldServer.BroadcastPacket({
      pid = "SyncCurDramaLikeInfo",
      params = {
        ownerLikeInfo = self.ownerLikeInfo,
        giveLikeRecord = self.giveLikeRecord,
        giveALikeUserId = giveALikeUserId
      }
    })
  end
end

local function getJoinTimeGroup(time)
  local value = os.time() - time
  if value <= 10 then
    return "1_10"
  elseif 10 < value and value <= 20 then
    return "11_20"
  elseif 20 < value and value <= 30 then
    return "21_30"
  elseif 30 < value and value <= 40 then
    return "31_40"
  elseif 40 < value and value <= 50 then
    return "41_50"
  elseif 50 < value and value <= 60 then
    return "51_60"
  elseif 60 < value then
    return "61_infinity"
  end
end

function DramaManager:entryDrama(player)
  player.enterDramaStartTime = os.time()
  local userId = player.platformUserId
  local reportKey = "script_join_success"
  local joinDramaTime = player:getJoinDramaTime()
  local maxNumber = self.curDramaInfo.maxNumber
  local roleList = DramaCommonHelper:dealScriptDataToModList(self.curDramaInfo.scriptData) or {}
  local script_mould = #roleList == 1 and roleList[1] or 0
  if userId == self.ownerId then
    reportKey = "script_create_success"
    self:amendDramaStatus(Define.DramaStatus.Activated, function()
      local content = {
        key = "createAParty",
        userId = player.platformUserId,
        name = player.name or "",
        partyType = script_mould,
        configVersion = configVersion,
        isVip = Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", player.platformUserId, Define.PRIVILEGE_TYPE.VIP),
        partyId = gameId
      }
      AsyncProcess.SendBroadcastMessageMsgSend(nil, content, Define.BROADCAST_SEND_MSG, "game")
    end)
    if joinDramaTime[self.ownerId] then
      Plugins.CallTargetPluginFunc("report", "report", reportKey, {
        script_join_time = getJoinTimeGroup(joinDramaTime[self.ownerId]),
        script_maxplayer = maxNumber,
        script_mould = script_mould
      }, player)
    end
  else
    if sendItToTheMaster then
      local owner = Game.GetPlayerByUserId(self.ownerId)
      if owner and owner:isValid() then
        local pos = owner:getPosition()
        pos.y = pos.y + 1
        player:setMapPos(owner.map, pos, owner:getRotationYaw())
      end
    end
    if joinDramaTime[self.ownerId] then
      Plugins.CallTargetPluginFunc("report", "report", reportKey, {
        script_join_time = getJoinTimeGroup(joinDramaTime[self.ownerId]),
        script_join_type = joinDramaTime.channel and 3 or 1,
        script_maxplayer = maxNumber,
        script_mould = script_mould
      }, player)
    else
      Plugins.CallTargetPluginFunc("report", "report", reportKey, {
        script_join_type = 2,
        script_maxplayer = maxNumber,
        script_mould = script_mould
      }, player)
    end
  end
  AsyncProcess.EntryDrama(gameId, userId, function(isSuccess)
    if isSuccess then
      local player = Game.GetPlayerByUserId(userId)
      if player and player:isValid() then
        local packet = {
          pid = "SyncPlayerJoinSuccess",
          nickName = player.name,
          userId = userId
        }
        WorldServer.BroadcastPacket(packet)
      end
    end
  end)
end

function DramaManager:exitDrama(userId, player)
  if player and player.enterDramaStartTime then
    local modList = self:getDramaModList()
    local reportData = {
      drama_play_time = os.time() - player.enterDramaStartTime,
      script_mould = #modList == 1 and modList[1] or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "script_playtime", reportData, player)
    self.enterDramaStartTime = nil
  end
  AsyncProcess.ExitDrama(gameId, userId, function()
    self:checkedPlayerCount()
  end)
end

function DramaManager:amendDramaStatus(status, callback)
  local curStatus = self.curDramaInfo.status
  if not curStatus or status <= curStatus then
    return
  end
  AsyncProcess.AmendDramaStatus(gameId, status, function(response, isSuccess)
    if not isSuccess then
      print("AmendDramaStatus Error: ", response.code)
    end
    if callback then
      callback(isSuccess)
    end
  end)
end

function DramaManager:giveALike(likeCount, userId)
  if not self.ownerId then
    return
  end
  if not self.giveLikeRecord[userId] then
    self.giveLikeRecord[userId] = likeCount
  else
    if self.giveLikeRecord[userId] > maxGiveLikeCount then
      return
    end
    self.giveLikeRecord[userId] = self.giveLikeRecord[userId] + likeCount > maxGiveLikeCount and maxGiveLikeCount or self.giveLikeRecord[userId] + likeCount
  end
  local data = {
    likeCount = likeCount,
    userId = userId,
    targetId = self.ownerId
  }
  AsyncProcess.GiveALike(data, function(isSuccess, response)
    if isSuccess then
      self:requestCurDramaLikeCount(userId)
    elseif response.code == 40002 then
    end
  end)
end

function DramaManager:checkedPlayerCount()
  local curPlayerCount = 0
  local isTheHost = false
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() then
      curPlayerCount = curPlayerCount + 1
      if self.ownerId == player.platformUserId then
        isTheHost = true
      end
    end
  end
  if not Lib.table_is_empty(self.curDramaInfo) then
    if self.curDramaInfo.currentNumber ~= curPlayerCount then
      AsyncProcess.AmendDramaDetailInfo(function(data)
        self:updateCurDramaInfo(data)
      end, gameId, {currentNumber = curPlayerCount})
    end
    local curStatus = self.curDramaInfo.status
    if curStatus == Define.DramaStatus.Activated then
      if not isTheHost and curPlayerCount < minOnlinePlayerLimits then
        self:amendDramaStatus(Define.DramaStatus.Dissolve)
      end
    elseif curStatus == Define.DramaStatus.Dissolve and curPlayerCount == 0 then
      self:amendDramaStatus(Define.DramaStatus.End)
    end
  end
end

function DramaManager:updateCurDramaInfo(data, needSync)
  if data and not Lib.table_is_empty(data) then
    self.curDramaInfo = data
    if needSync then
      self:sendCurDramaInfo()
    end
  end
end

function DramaManager:securityEntrances(funName, ...)
  if not Lib.isGameDrama() then
    return
  end
  if self[funName] then
    self[funName](self, ...)
  end
end

function DramaManager:isGiveALikeFirstTime(userId)
  return not self.giveLikeRecord[userId] or self.giveLikeRecord[userId] <= 0
end

function DramaManager:updateDramaAdornPart(scriptData)
  print("--scriptData--", Lib.v2s(scriptData))
  local data = {}
  for _, v in pairs(scriptData) do
    data[v] = true
  end
  if not self.curDramaAdornParts then
    self.curDramaAdornParts = {}
  end
  for id, instanceId in pairs(self.curDramaAdornParts) do
    if not data[id] then
      local ins = Instance.getByInstanceId(instanceId)
      if ins and ins:isValid() then
        ins:destroy()
      end
      self.curDramaAdornParts[id] = nil
    else
      data[id] = nil
    end
  end
  for id, v in pairs(data) do
    if v then
      local info = DramaTemplateConfig:getCfgById(id)
      if info and info.adornPart then
        local adornCfg = PartCfg:get(info.adornPart)
        if not adornCfg then
          Lib.logError("--error-adornCfg-:", info.adornPart)
          return
        end
        local map = World.CurWorld:getOrCreateStaticMap("map001")
        local scene = map:getScene()
        local ins = Instance.newInstance(adornCfg, map)
        if ins then
          local instanceId = ins:getInstanceID()
          self.curDramaAdornParts[id] = instanceId
          ins:setParent(scene:getRoot())
        end
      end
    end
  end
end

DramaManager:init()
return DramaManager
