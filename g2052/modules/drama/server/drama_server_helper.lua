local DramaServerHelper = T(Lib, "DramaServerHelper")
local cjson = require("cjson")
local gameId = Server.CurServer:getGameId()
local DramaCommonHelper = T(Lib, "DramaCommonHelper")

function DramaServerHelper:init()
  self.thumbUpList = {}
  self.curDramaCache = nil
  self.isDramaAmending = false
  self.isDramaAmendNext = false
end

function DramaServerHelper:resetThumbUpInfo(userId, value)
  self.thumbUpList[userId] = value
end

function DramaServerHelper:checkIsCanThumbUp(fromUserId, targetUserId)
  if self.thumbUpList[fromUserId] then
    return not self.thumbUpList[fromUserId][targetUserId]
  else
    self.thumbUpList[fromUserId] = {}
    return true
  end
end

function DramaServerHelper:updateThumbUpInfo(fromUserId, targetUserId)
  if not self.thumbUpList[fromUserId] then
    self.thumbUpList[fromUserId] = {}
  end
  self.thumbUpList[fromUserId][targetUserId] = true
end

function DramaServerHelper:updateCurDramaCache(data)
  if self.curDramaCache then
    return
  end
  self.curDramaCache = Lib.copy(data)
  self.curDramaCache.modList = DramaCommonHelper:dealScriptDataToModList(self.curDramaCache.scriptData)
  return self.curDramaCache.modList
end

function DramaServerHelper:RequestAmendAllDrama(dramaInfo)
  if not self.curDramaCache then
    return
  end
  local amendTable = {}
  if self.curDramaCache.maxNumber ~= dramaInfo.maxNumber then
    self.curDramaCache.maxNumber = dramaInfo.maxNumber
    amendTable.maxNumber = dramaInfo.maxNumber
  end
  if self.curDramaCache.scriptName ~= dramaInfo.scriptName then
    self.curDramaCache.scriptName = dramaInfo.scriptName
    amendTable.scriptName = dramaInfo.scriptName
  end
  if self.curDramaCache.summary ~= dramaInfo.summary then
    self.curDramaCache.summary = dramaInfo.summary
    amendTable.summary = dramaInfo.summary
  end
  self:RequestWebAmendDrama(amendTable)
end

function DramaServerHelper:RequestWebAmendDrama(dramaInfo)
  local id = gameId
  local paramsMap = {
    maxNumber = dramaInfo.maxNumber,
    scriptName = dramaInfo.scriptName,
    summary = dramaInfo.summary
  }
  self:doWebAmendDrama(id, paramsMap)
end

function DramaServerHelper:doWebAmendDrama(id, paramsMap)
  if not self.curDramaCache then
    return
  end
  if self.isDramaAmending then
    self.isDramaAmendNext = true
    return
  end
  self.isDramaAmending = true
  self.isDramaAmendNext = false
  AsyncProcess.AmendDramaDetailInfo(function(data)
    WorldServer.BroadcastPacket({
      pid = "PushClientUpdateDramaMain"
    })
    if id == gameId then
      DramaManager:securityEntrances("updateCurDramaInfo", data, true)
    end
    self.isDramaAmending = false
    if self.isDramaAmendNext then
      self:RequestWebAmendDrama(self.curDramaCache)
    end
  end, id, paramsMap)
end

DramaServerHelper:init()
