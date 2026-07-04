local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local DelegateDic = {}

function ModAsyncProxy:regDelegateRequest(key, req, backEvent, cb, interval)
  if not (key and req and backEvent) or type(req) ~= "function" then
    Lib.logDebug("!!!ModAsyncProxy param is error")
    return
  end
  if DelegateDic[key] ~= nil then
    Lib.logDebug("!!!ModAsyncProxy this key has reg,key: " .. key)
    return
  end
  DelegateDic[key] = {
    key = key,
    req = req,
    event = backEvent,
    lastReqTimeStamp = -1,
    isReq = false,
    interval = interval or 0,
    cb = cb
  }
end

function ModAsyncProxy:unRegDelegateRequest(key)
  if not key then
    return
  end
  DelegateDic[key] = nil
end

function ModAsyncProxy:clear()
  for k, v in pairs(DelegateDic) do
    self:unRegDelegateRequest(k)
  end
end

function ModAsyncProxy:request(key, ...)
  local info = DelegateDic[key]
  if not info then
    Lib.logDebug("this key not register,key:" .. key)
  end
  if info.isReq == true then
    return
  end
  if os.time() - info.lastReqTimeStamp < info.interval then
    return
  end
  self:doRequest(key, ...)
end

function ModAsyncProxy:forceRequest(key, ...)
  self:doRequest(key, ...)
end

function ModAsyncProxy:doRequest(key, ...)
  local info = DelegateDic[key]
  info.isReq = true
  info.lastReqTimeStamp = os.time()
  info.req(function(resp, isSuccess, url, param, body)
    self:onResponse(key, resp, isSuccess, url, param, body)
  end, ...)
end

local function PrintErrorInfo(key, code, url, param, body)
  local errorInfo = {
    key = key,
    code = code,
    url = url,
    param = param,
    body = body
  }
end

function ModAsyncProxy:onResponse(key, resp, isSuccess, url, param, body)
  local info = DelegateDic[key]
  if not info then
    return
  end
  info.isReq = false
  if not isSuccess then
    PrintErrorInfo(key, resp.code, url, param, body)
    return
  end
  resp.data = resp.data or {}
  if info.event then
    Lib.emitEvent(info.event, resp.data)
  end
  if info.cb then
    info.cb(resp.data)
  end
end

function ModAsyncProxy:requestOpenModDetailsUI(gameId, parentGameId, from)
  self.openModDetailsFrom = from
  self.requestOpenModDetailId = gameId
  self:request(self.requestOpenModDetailsKey, gameId, parentGameId)
end

function ModAsyncProxy:requestOpenAuthorInfoUI(userId, authorId)
  self.requestOpenAuthorInfoUserId = userId
  self.requestOpenAuthorInfoAuthorId = authorId
  self:request(self.requestOpenAuthorInfoKey, userId, authorId)
end

function ModAsyncProxy:init()
  self.requestOpenModDetailsKey = "OpenModDetails"
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_DETAIL, function(data)
    if not self.requestOpenModDetailId or self.requestOpenModDetailId ~= data.gameId then
      return
    end
    UI:getWnd("modMapInfo"):onShow(true, data, self.openModDetailsFrom)
  end)
  ModAsyncProxy:regDelegateRequest(self.requestOpenModDetailsKey, AsyncProcess.GetModGameDetailInfo, Event.EVENT_MOD_RESPONSE_MAP_DETAIL)
  self.requestOpenAuthorInfoKey = "OpenAuthorInfo"
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_AUTHOR_INFO, function(data)
    if self.requestOpenAuthorInfoUserId == data.userId or self.requestOpenAuthorInfoAuthorId == data.teamId then
      UI:openWnd("modAuthorInfo", data)
    end
  end)
  ModAsyncProxy:regDelegateRequest(self.requestOpenAuthorInfoKey, AsyncProcess.GetAuthorInfo, Event.EVENT_MOD_RESPONSE_AUTHOR_INFO)
end

function ModAsyncProxy:release()
  ModAsyncProxy:unRegDelegateRequest(self.requestOpenModDetailsKey)
  ModAsyncProxy:unRegDelegateRequest(self.requestOpenAuthorInfoKey)
end

ModAsyncProxy:init()
