local cjson = require("cjson")
local self = AsyncProcess
local strfmt = string.format
local roomGameConfig = Server.CurServer:getConfig()
local regionId = roomGameConfig:getRegionId()
local gameId = Server.CurServer:getGameId()
local engine_version = EngineVersionSetting:getEngineVersion()
local DramaCommonHelper = T(Lib, "DramaCommonHelper")
local amendMapKey = {
  scriptName = true,
  summary = true,
  maxNumber = true,
  currentNumber = true,
  scriptData = true
}
local configVersion = World.cfg.dramaSetting.configVersion

function AsyncProcess.CreateOneNewDrama(callback, userId, dramaInfo)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts", self.ServerHttpHost, World.GameName)
  local params = {}
  local body = {
    currentNumber = 0,
    maxNumber = dramaInfo.maxNumber,
    engineVersion = engine_version,
    configVersion = configVersion,
    regionId = regionId,
    scriptData = DramaCommonHelper:dealModListToScriptData(dramaInfo.modList),
    scriptName = dramaInfo.scriptName or "",
    scriptPic = dramaInfo.scriptPic or "",
    status = Define.DramaStatus.Inactive,
    summary = dramaInfo.summary or "",
    userId = userId
  }
  self.HttpRequest("POST", url, params, callback, body, true)
end

function AsyncProcess.AmendDramaDetailInfo(callback, id, paramsMap)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts", self.ServerHttpHost, World.GameName)
  local params = {
    {
      "id",
      tostring(id)
    }
  }
  local body = {}
  for key, v in pairs(paramsMap) do
    if amendMapKey[key] and v then
      body[key] = v
    end
  end
  self.HttpRequest("PUT", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AmendDramaDetailInfo Error: ", response.code)
      return
    end
    if callback then
      callback(response.data)
    end
  end, body, true)
end

function AsyncProcess.EntryDrama(scriptId, userId, callback)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts/entry", self.ServerHttpHost, World.GameName)
  local params = {}
  local body = {
    memberId = userId,
    scriptId = tostring(scriptId)
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("EntryDrama Error: ", response.code)
      if callback then
        callback(false)
      end
      return
    end
    if callback then
      callback(true, response.data)
    end
  end, body, true)
end

function AsyncProcess.ExitDrama(scriptId, userId, callback)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts/exit", self.ServerHttpHost, World.GameName)
  local params = {
    {"userId", userId},
    {
      "scriptId",
      tostring(scriptId)
    }
  }
  local body = {}
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("ExitDrama Error: ", response.code)
      return
    end
    if callback then
      callback(response.data)
    end
  end, body, true)
end

function AsyncProcess.AmendDramaStatus(scriptId, status, callback)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts/status", self.ServerHttpHost, World.GameName)
  local params = {
    {"status", status},
    {
      "id",
      tostring(scriptId)
    }
  }
  local body = {}
  self.HttpRequest("PUT", url, params, callback, body, true)
end

function AsyncProcess.GetDramaInfoById(id, callback)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts", self.ServerHttpHost, World.GameName)
  local params = {
    {"scriptId", id}
  }
  local body = {}
  self.HttpRequest("GET", url, params, callback, body, true)
end

function AsyncProcess.GiveALike(data, callback)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts/like/script", self.ServerHttpHost, World.GameName)
  local params = {}
  local body = {
    likeCount = data.likeCount,
    regionId = tostring(regionId),
    scriptId = gameId,
    targetId = data.targetId,
    userId = data.userId,
    engineVersion = engine_version,
    configVersion = configVersion
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if callback then
      callback(isSuccess, response)
    end
  end, body)
end

function AsyncProcess.GetLikesNumByUserID(callback, userId)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts/like/user", self.ServerHttpHost, World.GameName)
  local params = {
    {"userId", userId},
    {
      "regionId",
      tostring(regionId)
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetLikesNumByUserID Error: ", response.code)
      return
    end
    if callback then
      callback(response.data)
    end
  end, body, true)
end

function AsyncProcess.ThumbUpOthersPlayer(callback, userId, targetId)
  local url = strfmt("%s/gameaide/api/v1/inner/%s/scripts/like/user", self.ServerHttpHost, World.GameName)
  local params = {}
  local body = {
    userId = userId,
    targetId = targetId,
    regionId = tostring(regionId),
    configVersion = configVersion,
    engineVersion = engine_version
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("ThumbUpOthersPlayer Error: ", response.code)
      callback(false)
      return
    end
    if callback then
      callback(true)
    end
  end, body, true)
end
