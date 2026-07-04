local widget_base = require("ui.widget.widget_base")
local WidgetModMapOperator = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

function WidgetModMapOperator:init()
  widget_base.init(self, "ModMapOperator.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self.reqMapLikeKey = "ModMapOperator_Like"
  self.reqModDetailsKey = "ModMapOperator_GameDetails"
  ModAsyncProxy:regDelegateRequest(self.reqMapLikeKey, AsyncProcess.SetModLike, Event.EVENT_MOD_RESPONSE_MAP_LIKE)
  ModAsyncProxy:regDelegateRequest(self.reqModDetailsKey, AsyncProcess.GetModGameDetailInfo, Event.EVENT_MOD_RESPONSE_MAP_DETAIL)
end

function WidgetModMapOperator:initUI()
  self.btnLike = self:child("ModMapOperator-Like")
  self.btnFollow = self:child("ModMapOperator-Follow")
  self.btnBack = self:child("ModMapOperator-Back")
  self.btnLike:SetVisible(false)
  self.btnFollow:SetVisible(false)
  self.btnFollow:SetText(Lang:toText("g2052.gui.mod_follow.add"))
end

local function GetGameName()
  return Lib.getGameId()
end

function WidgetModMapOperator:getTeamId()
  if not self.data then
    return
  end
  return self.authorInfo.teamId
end

function WidgetModMapOperator:initEvent()
  self:subscribe(self.btnLike, UIEvent.EventButtonClick, function()
    if self:hasGiveLike() then
      return
    end
    ModAsyncProxy:request(self.reqMapLikeKey, GetGameName(), true)
  end)
  self:subscribe(self.btnFollow, UIEvent.EventButtonClick, function()
    if self:hasFollow() then
      return
    end
    Me:addModFocusOnPlayer(self:getTeamId())
  end)
  self:subscribe(self.btnBack, UIEvent.EventButtonClick, function()
    local gameType = Lib.getG2052MainGameId()
    CGame.instance:resetGameAddr(Me.platformUserId, gameType, "", "", "")
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_LIKE, function(data)
    if data.gameId and data.gameId == self.data.gameId then
      self.data.likeNumber = data.gameLikeNumber
      self.data.userLikeType = data.userLikeType
      self:updateLikeBtn()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, function(targetId, followStatus)
    if self.data and self.data.authorInfo.teamId ~= targetId then
      return
    end
    self.data.authorInfo.followStatus = followStatus
    self:updateFollowBtn()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_DETAIL, function(data)
    if not data then
      return
    end
    local gameId = GetGameName()
    if gameId ~= data.gameId then
      return
    end
    self:onResponseGameInfo(data)
  end)
end

function WidgetModMapOperator:getUserId()
  if not self.data then
    return Me.platformUserId
  end
  local isPersonal = self.data.isTeam == Define.Mod.TeamType.User
  local userIdListEle_1 = self.data.userIdList and self.data.userIdList[1]
  if isPersonal then
    return self.data.userId or userIdListEle_1
  else
    return userIdListEle_1 or self.data.userId
  end
end

function WidgetModMapOperator:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetModMapOperator:isMe()
  local userId = self:getUserId()
  return Me.platformUserId == userId
end

function WidgetModMapOperator:reload()
  local gameId = GetGameName()
  ModAsyncProxy:request(self.reqModDetailsKey, gameId)
end

function WidgetModMapOperator:onResponseGameInfo(data)
  self.data = data
  self.authorInfo = data.authorInfo
  Me:isMyModFocusOnPlayer(self.authorInfo.teamId)
  local isMe = self:isMe()
  self.btnLike:SetVisible(not isMe)
  self.btnFollow:SetVisible(not isMe)
  self:updateLikeBtn()
end

function WidgetModMapOperator:hasGiveLike()
  return self.data and self.data.userLikeType == 1
end

function WidgetModMapOperator:hasFollow()
  if self.data and self.data.authorInfo.followStatus then
    local followStatus = self.data.authorInfo.followStatus
    if followStatus == 1 or followStatus == 3 then
      return true
    end
  end
  return false
end

local LikeImg = "set:g2052_mod.json image:btn_9_pagination01"
local UnlikeImg = "set:g2052_mod.json image:btn_9_pagination03"

function WidgetModMapOperator:updateLikeBtn()
  local hasGiveLike = self:hasGiveLike()
  local img = hasGiveLike and LikeImg or UnlikeImg
  self.btnLike:SetNormalImage(img)
  self.btnLike:SetPushedImage(img)
end

local FollowImg = "set:g2052_mod.json image:btn_9_pagination01"
local UnFollowImg = "set:g2052_mod.json image:btn_9_pagination03"

function WidgetModMapOperator:updateFollowBtn()
  local hasGiveLike = self:hasGiveLike()
  local img = hasGiveLike and FollowImg or UnFollowImg
  self.btnFollow:SetNormalImage(img)
  self.btnFollow:SetPushedImage(img)
end

return WidgetModMapOperator
