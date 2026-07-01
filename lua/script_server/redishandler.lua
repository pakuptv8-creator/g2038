local cjson = require("cjson")
local strfmt = string.format
local tconcat = table.concat
local tostring = _ENV.tostring
local type = _ENV.type
local traceback = _ENV.traceback
local RedisHandler = L("RedisHandler", {})

function RedisHandler:init()
  local baseUrl = Server.CurServer:getDataServiceURL()
  Lib.logDebug("baseUrl = ", baseUrl)
  local secondBaseUrl = Server.CurServer:getDataServiceSecondURL()
  self.enable = baseUrl ~= ""
  self.getZScoreUrl = baseUrl .. "/api/v1/game/rank"
  self.postZIncrByUrl = baseUrl .. "/api/v1/game/rank"
  self.setZExpireUrl = baseUrl .. "/api/v1/game/rank/expire"
  self.getZRangeUrl = baseUrl .. "/api/v1/game/rank/list"
  self.getZCardUrl = baseUrl .. "/api/v1/game/rank/length"
  self.incCounterUrl = baseUrl .. "/api/v1/game/rank/inc-counter"
  self.resetCounterUrl = baseUrl .. "/api/v1/game/rank/reset-counter"
  self.postZIncrBySecondUrl = secondBaseUrl .. "/api/v1/game/rank"
  self.setZExpireSecondUrl = secondBaseUrl .. "/api/v1/game/rank/expire"
  self.ZIncrByQueue = {}
  self.ZExpireQueue = {}
  self.sendingZIncrBy = false
  self.sendingZExpire = false
  self.sendZIncrByTime = 0
  self.sendZExpireTime = 0
  self.HGetAllUrl = baseUrl .. "/api/v1/game/qualifying/rank/list"
  self.HGetUrl = baseUrl .. "/api/v1/game/qualifying/rank"
  self.HMSetUrl = baseUrl .. "/api/v1/game/qualifying/rank"
  self.HSetUrl = baseUrl .. "/api/v1/game/qualifying/rank/add"
  self.HDelUrl = baseUrl .. "/api/v1/game/qualifying/rank"
  self.HExpireUrl = baseUrl .. "/api/v1/game/qualifying/rank/expire"
  self.HExpireQueue = {}
  self.sendingHExpire = false
  self.sendHExpireTime = 0
  if self.enable then
    self.checkPostTimer = World.Timer(200, self.checkPostData, self)
  end
  print("RedisHandler init", self.enable)
end

function RedisHandler:checkPostData()
  self:trySendZIncBy()
  self:trySendZExpire()
  self:trySendHExpire()
  return true
end

function RedisHandler:trySendZIncBy(immediately)
  local cacheCount = #self.ZIncrByQueue
  local canSend = immediately or not self.sendingZIncrBy and 0 < cacheCount and (3 <= cacheCount or os.time() - self.sendZIncrByTime > 200)
  if canSend then
    local ok, msg = xpcall(self.sendZIncrByData, traceback, self)
    if not ok then
      perror("RedisHandler sendZIncrByData error", msg)
    end
  end
end

function RedisHandler:trySendZExpire(immediately)
  local cacheCount = #self.ZExpireQueue
  local canSend = immediately or not self.sendingZExpire and 0 < cacheCount and (3 <= cacheCount or os.time() - self.sendZExpireTime > 200)
  if canSend then
    local ok, msg = xpcall(self.sendZExpireData, traceback, self)
    if not ok then
      perror("RedisHandler sendZExpireData error", msg)
    end
  end
end

function RedisHandler:hasCachedData()
  return next(self.ZIncrByQueue) ~= nil or next(self.ZExpireQueue) ~= nil
end

function RedisHandler:ZExpireat(setName, timeStamp)
  if not self.enable then
    return
  end
  local queue = self.ZExpireQueue
  queue[#queue + 1] = {
    setName = setName,
    key = tostring(timeStamp),
    value = 0,
    rank = -1
  }
  self:trySendZExpire()
end

function RedisHandler:ZIncrBy(setName, key, value, immediately)
  if not self.enable then
    return
  end
  local queue = self.ZIncrByQueue
  queue[#queue + 1] = {
    setName = setName,
    key = key,
    value = value,
    rank = 0
  }
  self:trySendZIncBy(immediately)
end

function RedisHandler:ZAdd(setName, key, value)
  if not self.enable then
    return
  end
  local queue = self.ZIncrByQueue
  queue[#queue + 1] = {
    setName = setName,
    key = key,
    value = value,
    rank = 1
  }
end

function RedisHandler:ZRemove(setName, key, immediately)
  if not self.enable then
    return
  end
  local queue = self.ZIncrByQueue
  queue[#queue + 1] = {
    setName = setName,
    key = key,
    value = 0,
    rank = 1
  }
  self:trySendZIncBy(immediately)
end

function RedisHandler:IncCounter(key, callback)
  if not self.enable then
    callback(true, -1)
    return
  end
  local params = {
    {"key", key},
    {"delta", 1}
  }
  AsyncProcess.HttpRequest("POST", self.incCounterUrl, params, function(response)
    local content = cjson.encode(response)
    print("RedisHandler IncCounter response", #content, content:sub(1, 100))
    if response.status_code then
      print("RedisHandler IncCounter response error", key, response.status_code)
      callback(false, response.status_code, -1)
      return
    end
    local success, count = false, -1
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler IncCounter error, lack of field", key, cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler IncCounter error code", key, cjson.encode(response))
    elseif type(data) ~= "number" then
      print("RedisHandler IncCounter error data", key, cjson.encode(response))
    else
      success, count = true, tonumber(data)
    end
    callback(success, count)
  end)
end

function RedisHandler:ResetCounter(keys, callback)
  if not self.enable then
    callback(true, -1)
    return
  end
  Lib.logDebug("RedisHandler:ResetCounter keys = ", keys)
  local params = {
    {"keys", keys}
  }
  AsyncProcess.HttpRequest("POST", self.resetCounterUrl, params, function(response)
    local content = cjson.encode(response)
    print("RedisHandler ResetCounter response", #content, content:sub(1, 100))
    if response.status_code then
      print("RedisHandler ResetCounter response error", key, response.status_code)
      callback(false, -1)
      return
    end
    local success, count = false, -1
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler ResetCounter error, lack of field", key, cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler ResetCounter error code", key, cjson.encode(response))
    elseif type(data) ~= "number" then
      print("RedisHandler ResetCounter error data", key, cjson.encode(response))
    else
      success, count = true, tonumber(data)
    end
    callback(success, count)
  end)
end

function RedisHandler:ZCard(setName, callback)
  print("RedisHandler:ZCard setName = ", setName)
  if not self.enable then
    callback(true, -1, 0)
    return
  end
  local params = {
    {"key", setName},
    {"isNew", "1"}
  }
  AsyncProcess.HttpRequest("GET", self.getZCardUrl, params, function(response)
    if response.status_code then
      print("RedisHandler ZCard response error", setName, response.status_code)
      callback(false, response.status_code, -1)
      return
    end
    local success, count = false, -1
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler ZCard error, lack of field", setName, cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler ZCard error code", setName, cjson.encode(response))
    elseif type(data) ~= "number" then
      print("RedisHandler ZCard error data", setName, key, cjson.encode(response))
    else
      success, count = true, tonumber(data)
    end
    callback(success, count)
  end)
end

function RedisHandler:ZScore(setName, key, callback)
  if not self.enable then
    callback(true, -1, 0)
    return
  end
  local params = {
    {"key", setName},
    {"member", key},
    {"isNew", "1"}
  }
  AsyncProcess.HttpRequest("GET", self.getZScoreUrl, params, function(response)
    local content = cjson.encode(response)
    print("RedisHandler ZScore response", #content, content:sub(1, 100))
    if response.status_code then
      print("RedisHandler ZScore response error", setName, key, response.status_code)
      callback(false, response.status_code, -1)
      return
    end
    local success, score, rank = false, -1, 0
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler ZScore error, lack of field", setName, key, cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler ZScore error code", setName, key, cjson.encode(response))
    elseif not data or type(data) == "table" and not next(data) then
      success, score, rank = true, 0, 0
    elseif not (type(data) == "table" and data.rank) or not data.score then
      print("RedisHandler ZScore error data", setName, key, cjson.encode(response))
    else
      success, score, rank = true, tonumber(data.score), math.floor(tonumber(data.rank))
    end
    callback(success, score, rank)
  end)
end

function RedisHandler:ZRange(setName, start, _end, callback)
  if not self.enable then
    callback(true, "")
    return
  end
  local params = {
    {"key", setName},
    {"start", start},
    {"end", _end},
    {"isNew", "1"}
  }
  AsyncProcess.HttpRequest("GET", self.getZRangeUrl, params, function(response)
    if response.status_code then
      print("RedisHandler ZRange response error", setName, start, _end, response.status_code)
      callback(false, cjson.encode(response))
      return
    end
    local success, ret = false, "has parse error"
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler ZRange error, lack of field", setName, start, _end, cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler ZRange error code", setName, start, _end, cjson.encode(response))
    elseif not data or type(data) == "table" and not next(data) then
      success, ret = true, ""
    elseif type(data) ~= "table" then
      print("RedisHandler ZRange error data", setName, start, _end, cjson.encode(response))
    else
      local list = {}
      for i, v in ipairs(data) do
        if not v.member or not v.score then
          success, list = false, nil
          break
        end
        list[#list + 1] = strfmt("%s:%s", tostring(v.member), tostring(v.score))
      end
      if list then
        success, ret = true, table.concat(list, "#")
      end
    end
    callback(success, ret)
  end)
end

function RedisHandler:sendZIncrByData()
  if not self.enable or not next(self.ZIncrByQueue) then
    return
  end
  local list = {}
  for i, data in pairs(self.ZIncrByQueue) do
    list[i] = {
      key = data.setName,
      member = data.key,
      count = data.value,
      add = data.rank == 0
    }
  end
  self.ZIncrByQueue = {}
  self.sendingZIncrBy = true
  local params = {
    {"isNew", "1"}
  }
  local body = cjson.encode(list)
  
  local function sendRequest(tryTimes, url)
    if 3 <= tryTimes then
      if url == self.postZIncrByUrl then
        sendRequest(1, self.postZIncrBySecondUrl)
      else
        perror("RedisHandler sendZIncrByData failed", body)
        self.sendingZIncrBy = false
        self.sendZIncrByTime = os.time()
      end
      return
    end
    AsyncProcess.HttpRequest("POST", url, params, function(response)
      local code = response.status_code or 200
      if code ~= 200 then
        sendRequest(tryTimes + 1, url)
        return
      end
      self.sendingZIncrBy = false
      self.sendZIncrByTime = os.time()
    end, body)
  end
  
  sendRequest(1, self.postZIncrByUrl)
end

function RedisHandler:sendZExpireData()
  if not self.enable or not next(self.ZExpireQueue) then
    return
  end
  local list = {}
  for i, data in pairs(self.ZExpireQueue) do
    list[i] = {
      key = data.setName,
      expireTime = data.key
    }
  end
  self.ZExpireQueue = {}
  self.sendingZExpire = true
  local params = {
    {"isNew", "1"}
  }
  local body = cjson.encode(list)
  
  local function sendRequest(tryTimes, url)
    if 3 <= tryTimes then
      if url == self.setZExpireUrl then
        sendRequest(1, self.setZExpireSecondUrl)
      else
        perror("RedisHandler sendZExpireData failed", body)
        self.sendingZExpire = false
        self.sendZExpireTime = os.time()
      end
      return
    end
    AsyncProcess.HttpRequest("PUT", url, params, function(response)
      local code = response.status_code or 200
      if code ~= 200 then
        sendRequest(tryTimes + 1, url)
        return
      end
      self.sendingZExpire = false
      self.sendZExpireTime = os.time()
    end, body)
  end
  
  sendRequest(1, self.setZExpireUrl)
end

function RedisHandler:HExpireat(key, timeStamp)
  Lib.logDebug("HExpireat key and timeStamp = ", key, timeStamp)
  if not self.enable then
    return
  end
  local queue = self.HExpireQueue
  queue[#queue + 1] = {key = key, expireTime = timeStamp}
  self:trySendHExpire()
end

function RedisHandler:trySendHExpire(immediately)
  local cacheCount = #self.HExpireQueue
  local canSend = immediately or not self.sendingHExpire and 0 < cacheCount and (3 <= cacheCount or os.time() - self.sendHExpireTime > 200)
  if canSend then
    local ok, msg = xpcall(self.sendHExpireData, traceback, self)
    if not ok then
      perror("RedisHandler sendHExpireData error", msg)
    end
  end
end

function RedisHandler:sendHExpireData()
  if not self.enable or not next(self.HExpireQueue) then
    return
  end
  local list = {}
  for i, data in pairs(self.HExpireQueue) do
    list[i] = {
      key = data.key,
      expireTime = data.expireTime
    }
  end
  self.HExpireQueue = {}
  self.sendingHExpire = true
  local params = {}
  local body = cjson.encode(list)
  
  local function sendRequest(tryTimes, url)
    if 3 <= tryTimes then
      perror("RedisHandler sendHExpireData failed", body)
      self.sendingHExpire = false
      self.sendHExpireTime = os.time()
      return
    end
    AsyncProcess.HttpRequest("PUT", url, params, function(response)
      print("RedisHandler send sendHExpireData", cjson.encode(response))
      local code = response.status_code or Define.HTTP_STATUS_CODE.OK
      if code ~= Define.HTTP_STATUS_CODE.OK then
        sendRequest(tryTimes + 1, url)
        return
      end
      self.sendingHExpire = false
      self.sendHExpireTime = os.time()
    end, body)
  end
  
  sendRequest(1, self.HExpireUrl)
end

function RedisHandler:HSet(data, callback)
  if not self.enable then
    callback(false, "")
    return
  end
  local params = {}
  local body = cjson.encode(data)
  Lib.logInfo("HSet body = ", Lib.v2s(body))
  AsyncProcess.HttpRequest("POST", self.HSetUrl, params, function(response)
    print("RedisHandler HSet response", cjson.encode(response))
    local code = response.status_code or Define.HTTP_STATUS_CODE.OK
    if code ~= Define.HTTP_STATUS_CODE.OK then
      callback(false, cjson.encode(response))
      return
    end
    local success, ret = false, "has parse error"
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler HSet error, lack of field", cjson.encode(response))
      success, ret = false, ""
    elseif code ~= 1 then
      print("RedisHandler HSet error code", cjson.encode(response))
    elseif not data or type(data) == "table" and not next(data) then
      success, ret = true, ""
    elseif type(data) ~= "table" then
      print("RedisHandler HSet error data", cjson.encode(response))
    else
      local list = {}
      for i, v in ipairs(data) do
        if not (v.member and v.rank) or not v.score then
          success, list = false, nil
          break
        end
        list[#list + 1] = strfmt("%s:%s:%s", tostring(v.rank), tostring(v.member), tostring(v.score))
      end
      if list then
        success, ret = true, table.concat(list, "#")
      end
    end
    callback(success, ret)
  end, body)
end

function RedisHandler:HMSet(datas, callback)
  Lib.logDebug("hmset datas = ", Lib.v2s(datas, 2))
  if not self.enable then
    callback(false, "")
    return
  end
  local params = {}
  local body = cjson.encode(datas)
  Lib.logDebug("HMSet body = ", Lib.v2s(body))
  AsyncProcess.HttpRequest("POST", self.HMSetUrl, params, function(response)
    print("RedisHandler HMSet response", cjson.encode(response))
    local code = response.status_code or Define.HTTP_STATUS_CODE.OK
    if code ~= Define.HTTP_STATUS_CODE.OK then
      callback(false, cjson.encode(response))
      return
    end
    local success, ret = false, "has parse error"
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler HMSet error, lack of field", cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler HMSet error code", cjson.encode(response))
    elseif not data or type(data) == "table" and not next(data) then
      success, ret = false, ""
    elseif type(data) ~= "table" then
      print("RedisHandler HMSet error data", cjson.encode(response))
    else
      success, ret = true, datas
    end
    callback(success, ret)
  end, body)
end

function RedisHandler:HGetAll(key, callback)
  if not self.enable then
    callback(false, "")
    return
  end
  local params = {
    {"key", key}
  }
  AsyncProcess.HttpRequest("GET", self.HGetAllUrl, params, function(response)
    local content = cjson.encode(response)
    print("RedisHandler HGetAll response", key, #content, content:sub(1, 100))
    if response.status_code then
      print("RedisHandler HGetAll response error", key, response.status_code)
      callback(false, cjson.encode(response))
      return
    end
    local success, ret = false, "has parse error"
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler HGetAll error, lack of field", key, cjson.encode(response))
    elseif code ~= 1 then
      print("RedisHandler HGetAll error code", key, cjson.encode(response))
    elseif not data or type(data) == "table" and not next(data) then
      Lib.logDebug("data is empty")
      success, ret = true, ""
    elseif type(data) ~= "table" then
      print("RedisHandler HGetAll error data", key, cjson.encode(response))
    else
      local list = {}
      for i, v in ipairs(data) do
        if not (v.member and v.rank) or not v.score then
          success, list = false, nil
          break
        end
        list[#list + 1] = strfmt("%s:%s:%s", tostring(v.rank), tostring(v.member), tostring(v.score))
      end
      if list then
        success, ret = true, table.concat(list, "#")
      end
    end
    Lib.logDebug("HGetAll success and ret = ", success, ret)
    callback(success, ret)
  end)
end

function RedisHandler:HGet(key, rank, callback)
  if not self.enable then
    callback(true, "")
    return
  end
  local params = {
    {"key", key},
    {"rank", rank}
  }
  AsyncProcess.HttpRequest("GET", self.HGetUrl, params, function(response)
    local content = cjson.encode(response)
    print("RedisHandler HGet response", key, rank, #content, content:sub(1, 100))
    if response.status_code then
      print("RedisHandler HGet response error", key, response.status_code)
      callback(false, cjson.encode(response))
      return
    end
    local success, ret = false, "has parse error"
    local code, data, message = response.code, response.data, response.message
    if not (code and data) or not message then
      print("RedisHandler HGet error, lack of field", key, cjson.encode(response))
      callback(false, "")
    elseif code ~= 1 then
      print("RedisHandler HGet error code", key, cjson.encode(response))
    elseif not data or type(data) == "table" and not next(data) then
      Lib.logDebug("data is empty")
      success, ret = false, ""
    elseif type(data) ~= "table" then
      print("RedisHandler HGet error data", key, cjson.encode(response))
    else
      success, ret = true, data
    end
    callback(success, ret)
  end)
end

return RedisHandler
