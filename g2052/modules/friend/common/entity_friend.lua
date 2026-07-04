local ValueDef = T(Entity, "ValueDef")
ValueDef.friendList = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.readRequestList = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.firstInit = {
  false,
  true,
  true,
  false,
  true,
  true
}
local Entity = _ENV.Entity

function Entity:setReadRequestList(readList)
  self:setValue("readRequestList", readList)
end

function Entity:getReadRequestList()
  return self:getValue("readRequestList")
end

function Entity:setFriends(friends)
  self:setValue("friendList", friends)
end

function Entity:getFriends()
  return self:getValue("friendList")
end

function Entity:isFriend(userId)
  local friends = self:getValue("friendList")
  if friends[tostring(userId)] then
    return true
  end
  return false
end

function Entity:setFirstInit(status)
  self:setValue("firstInit", status)
end

function Entity:getFirstInit()
  return self:getValue("firstInit")
end
