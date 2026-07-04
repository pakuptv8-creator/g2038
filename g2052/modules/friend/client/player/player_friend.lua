local Player = _ENV.Player

function Player:tryInitFriends()
  if not self.loadFriends or not self.loadDef then
    return
  end
  self:initFriends()
end

function Player:initFriends()
  local friends = FriendManager.friends
  local friendMap = {}
  for _, id in pairs(friends) do
    friendMap[tostring(id)] = true
  end
  self.initFriends = true
  UI:getWnd("friend")
  if self:getFirstInit() then
    self:setFirstInit(false)
    self:setFriends(friendMap)
  else
    self:updateFriends(friendMap)
  end
end

function Player:updateFriends(data)
  if not self.initFriends then
    return
  end
  local curFriend = Me:getFriends()
  local newFriends = {}
  local new = 0
  for id, status in pairs(data) do
    if not curFriend[tostring(id)] then
      new = new + 1
      newFriends[tostring(id)] = true
    end
  end
  if 0 < new then
    Lib.emitEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, Define.FriendTabType.Friend, new)
  end
  self:setFriends(data)
  return newFriends
end

function Player:checkUserIDIsFriend(userId)
  local isFriend = Plugins.CallTargetPluginFunc("platform_chat", "checkPlayerIsMyChatFriend", tonumber(userId))
  if not isFriend then
    local curFriend = Me:getFriends()
    return curFriend[tostring(userId)]
  end
  return isFriend
end

function Player:addReadRequest(data)
  local readList = self:getReadRequestList()
  if data and 0 < #data then
    local needUpdate = false
    for _, userId in pairs(data) do
      if not readList[userId] then
        readList[userId] = true
        needUpdate = true
      end
    end
    if needUpdate then
      self:setReadRequestList(readList)
    end
  end
end

function Player:removeReadRequest(data)
  local readList = self:getReadRequestList()
  if data and 0 < #data then
    local needUpdate = false
    for _, userId in pairs(data) do
      if readList[userId] then
        readList[userId] = nil
        needUpdate = true
      end
    end
    if needUpdate then
      self:setReadRequestList(readList)
    end
  end
end
