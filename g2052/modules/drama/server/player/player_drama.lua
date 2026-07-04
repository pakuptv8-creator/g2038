local Player = _ENV.Player
local cjson = require("cjson")
local gameId = Server.CurServer:getGameId()
local GiantHamburgerHelper = T(Lib, "GiantHamburgerHelper")
local PlayerDBMgr = T(Lib, "PlayerDBMgr")

function Player:joinCrossServerLogin(targetUserId, targetGameId)
  PlayerDBMgr.SaveImmediate(self)
  local attributes
  if targetGameId then
    attributes = "{\"targetGameId\": \"" .. targetGameId .. "\"}"
  end
  self:sendGotoOtherGame(targetUserId, World.GameName, "", attributes or "")
end

function Player:onGiantHamburger(type, part, params)
  self:playOneOnceAction(World.cfg.dramaSetting.giantSetting.hamburgerAction, Define.ActionMapPriority.giantPriority)
  GiantHamburgerHelper:removeOneHamburger(part:getInstanceID())
  T(Lib, "MessageNoticeManager"):broadcastNotice(17, self.name)
  World.Timer(World.cfg.dramaSetting.giantSetting.hamburgerDelayTime, function()
    if self and self:isValid() then
      self:addGiantHamburger(1)
    end
  end)
end
