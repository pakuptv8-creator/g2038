local self = AsyncProcess
local strfmt = string.format
local cjson = require("cjson")

local function GetLanguage()
  return World.Lang or "en_US"
end

local function GetParentGameId()
  return World.cfg.modParentGameId or Lib.getG2052MainGameId()
end

local function GetMainUserId()
  return Me.platformUserId
end

function AsyncProcess.GetRecommendGameList(callback, pageNo, pageSize)
  local url = strfmt("%s/game/api/v1/sub/game/recommend", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local userId = GetMainUserId()
  local language = GetLanguage()
  local params = {
    {
      "language",
      tostring(language)
    },
    {
      "parentGameId",
      tostring(parentGameId)
    },
    {"userId", userId},
    {"pageNo", pageNo},
    {"pageSize", pageSize}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    callback(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.GetModTopEventList(callback)
  local url = strfmt("%s/game/api/v1/sub/game/banner", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {
      "language",
      tostring(language)
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    callback(response, isSuccess)
  end, {}, true)
end

function AsyncProcess.GetModGameDetailInfo(callback, subGameId, parentGameId)
  local url = strfmt("%s/game/api/v1/sub/game/%s", self.ClientHttpHost, subGameId)
  parentGameId = parentGameId or GetParentGameId()
  local language = GetLanguage()
  local params = {
    {
      "language",
      tostring(language)
    },
    {
      "parentGameId",
      tostring(parentGameId)
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    callback(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.AddModFollowPlayer(targetId, callback)
  local url = strfmt("%s/game/api/v1/sub/game/follow/add", self.ClientHttpHost)
  local params = {
    {"targetId", targetId}
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AddModFollowPlayer Error: ", response.code)
      return
    end
    response.data = response.data or {}
    response.data.targetId = response.data.targetId or targetId
    callback(response.data)
  end, {}, true)
end

function AsyncProcess.RemoveModFollowPlayer(targetId, callback)
  local url = strfmt("%s/game/api/v1/sub/game/follow/del", self.ClientHttpHost)
  local params = {
    {"targetId", targetId}
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("RemoveModFollowPlayer Error: ", response.code)
      return
    end
    response.data = response.data or {}
    response.data.targetId = response.data.targetId or targetId
    callback(response.data)
  end, {}, true)
end

function AsyncProcess.GetModFollowRelation(targetIds, callback)
  local url = strfmt("%s/game/api/v1/sub/game/follow/relation/get", self.ClientHttpHost)
  local params = {
    {
      "targetIds",
      table.concat(targetIds, ",")
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetModFollowRelation Error: ", response.code)
      return
    end
    callback(response.data)
  end, {}, true)
end

function AsyncProcess.ModMapReport(cb, gameId, reportType, reportSubType, detail)
  local url = strfmt("%s/game/api/v1/sub/game/report/add", self.ClientHttpHost)
  local body = {
    detail = detail,
    reportType = reportType,
    gameId = gameId,
    reportSubType = reportSubType
  }
  local params = {}
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body)
end

function AsyncProcess.GetModFollowPlayerList(pageNo, callback)
  local url = strfmt("%s/game/api/v1/sub/game/follow/list/get", self.ClientHttpHost)
  local params = {
    {"pageNo", pageNo},
    {
      "parentGameId",
      World.cfg.modParentGameId or World.GameName
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetModFollowPlayerList Error: ", response.code)
      return
    end
    callback(response.data)
  end, {}, true)
end

function AsyncProcess.GetModFollowPlayerMapList(callback, pageNo, pageSize)
  local url = strfmt("%s/game/api/v1/sub/game/follow/game/list", self.ClientHttpHost, World.cfg.modParentGameId or World.GameName)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {
      "language",
      tostring(language)
    },
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    callback(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetMyModGameList(callback, pageNo, pageSize)
  local url = strfmt("%s/game/api/v1/sub/game/my", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local userId = GetMainUserId()
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {"userId", userId},
    {"pageNo", pageNo},
    {"pageSize", pageSize}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    callback(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.AddModMapRelay(cb, gameId, content)
  local url = strfmt("%s/game/api/v1/sub/game/comment/add", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {"language", language},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {content = content, gameId = gameId}
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.GetSearchModGameList(cb, keyword, pageNo, pageSize)
  local parentGameId = GetParentGameId()
  local url = strfmt("%s/game/api/v1/sub/game/search", self.ClientHttpHost)
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {"keyword", keyword},
    {"pageNo", pageNo},
    {"pageSize", pageSize}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.GetModCommentList(cb, gameId, pageNo, pageSize)
  local url = strfmt("%s/game/api/v1/sub/game/comment/list", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local params = {
    {"gameId", gameId},
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetModTopComment(cb, gameId)
  local url = strfmt("%s/game/api/v1/sub/game/comment/hot", self.ClientHttpHost, World.cfg.modParentGameId or World.GameName)
  local parentGameId = GetParentGameId()
  local params = {
    {"gameId", gameId},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.SetModCommentLike(cb, gameId, commentId, isLike)
  local type = isLike and 1 or -1
  local url = strfmt("%s/game/api/v1/sub/game/comment/like/add", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {
    type = type,
    gameId = gameId,
    commentId = commentId
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    response.data = response.data or {}
    response.data.gameId = response.data.gameId or gameId
    response.data.commentId = response.data.commentId or commentId
    cb(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.GetModSearchHot(cb)
  local url = strfmt("%s/game/api/v1/sub/game/search/keyword", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {"language", language},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.GetModLikeList(cb, gameId, pageNo, pageSize)
  local url = strfmt("%s/game/api/v1/sub/game/game/like/list", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local params = {
    {"gameId", gameId},
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetModPlayList(cb, gameId, pageNo, pageSize)
  local url = strfmt("%s/game/api/v1/sub/game/game/experience/list", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local params = {
    {"gameId", gameId},
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, {}, false)
end

function AsyncProcess.SetModLike(cb, gameId, isLike)
  local type = isLike and 1 or -1
  local url = strfmt("%s/game/api/v1/sub/game/game/like/add", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {type = type, gameId = gameId}
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    response.data = response.data or {}
    response.data.gameId = response.data.gameId or gameId
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetAuthorInfo(cb, targetUserId, authorId)
  if not targetUserId and not authorId then
    return
  end
  local url = strfmt("%s/game/api/v1/sub/game/author/info", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {"language", language}
  }
  if targetUserId then
    table.insert(params, {
      "targetUserId",
      targetUserId
    })
  else
    table.insert(params, {"authorId", authorId})
  end
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetAuthorMods(cb, authorId, pageNo, pageSize)
  pageSize = pageSize or Define.ModAuthorPageSize
  local url = strfmt("%s/game/api/v1/sub/game/author/game/list", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {"authorId", authorId},
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {"language", language}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetFriendsMods(cb, pageNo, pageSize)
  pageSize = pageSize or Define.ModFriendsPageSize
  local url = strfmt("%s/game/api/v1/sub/game/friend/game/list", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {
      "userId",
      Me.platformUserId
    },
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {"language", language}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetTopicMods(cb, pageNo, pageSize)
  pageSize = pageSize or Define.ModMainTopicPageSize
  local url = strfmt("%s/game/api/v1/sub/game/topic/and/game/page", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {
      "parentGameId",
      parentGameId
    },
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {"language", language}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetTopicDetailsMods(cb, topicId, pageNo, pageSize)
  pageSize = pageSize or Define.ModDetailTopicPageSize
  local url = strfmt("%s/game/api/v1/sub/game/topic/game/page", self.ClientHttpHost)
  local language = GetLanguage()
  local params = {
    {"topicId", topicId},
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {"language", language}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetModRank(cb, type, pageNo, pageSize)
  pageSize = pageSize or Define.ModDetailTopicPageSize
  local url = strfmt("%s/game/api/v1/sub/game/getUserLikeRank", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local params = {
    {"type", type},
    {"pageNo", pageNo},
    {"pageSize", pageSize},
    {
      "parentGameId",
      parentGameId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetModImageUrlByType(cb, type)
  local url = strfmt("%s/game/api/v1/sub/game/craftAndAdsImageUrl", self.ClientHttpHost)
  local parentGameId = GetParentGameId()
  local language = GetLanguage()
  local params = {
    {"type", type},
    {
      "parentGameId",
      parentGameId
    },
    {"language", language}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetModImageUrlByType Error: ", response.code)
      return
    end
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.GetTopicTitleInfo(cb, id)
  local url = strfmt("%s/game/api/v1/sub/game/topic/info", self.ClientHttpHost)
  local language = GetLanguage()
  local params = {
    {"language", language},
    {"topicId", id}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    cb(response, isSuccess, url, params, body)
  end, body, false)
end

function AsyncProcess.AddModExperience(cb, gameId)
  local url = strfmt("%s/game/api/v1/sub/game/game/experience/add", self.ClientHttpHost)
  local language = GetLanguage()
  local parentGameId = GetParentGameId()
  local params = {
    {"language", language},
    {
      "parentGameId",
      parentGameId
    },
    {"gameId", gameId}
  }
  local body = {}
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    response.data = response.data or {}
    response.data.gameId = response.data.gameId or gameId
    cb(response, isSuccess, url, params, body)
  end, body, false)
end
