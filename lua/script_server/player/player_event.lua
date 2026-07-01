local playerEventEngineHandler = L("playerEventEngineHandler", player_event)
local handles = T(Player, "PackageHandlers")
local beforeEvents = {}
local afterEvents = {}
local hideEngineHandler = {}

function player_event(player, event, ...)
  local func = beforeEvents[event]
  if func then
    func(player, ...)
  end
  if not hideEngineHandler[event] then
    playerEventEngineHandler(player, event, ...)
  end
  local func = afterEvents[event]
  if func then
    func(player, ...)
  end
end

function beforeEvents:logout()
  Lib.logDebug("before events logout")
  if self.battleField then
    self:notifyStateReady({
      type = Define.READY_TYPE.CATCH
    })
    if self.battleField then
      self.battleField:leave(self, true)
    end
    self:removePlayerMirror()
  end
  local curFollowPetId = tostring(self:getCurFollowPetId())
  if curFollowPetId ~= "0" then
    self:removeFollowPetEntity(false, curFollowPetId)
  end
  if not self:isReadyCloseResult() then
    self:setReadyCloseResult(true)
  end
  handles.quitSwap(self, {
    code = Define.SWAP_END_CODE.CANCEL
  })
  Lib.reportTalk(self)
end

function afterEvents:logout()
  Lib.logDebug("after events logout", self.isHosting)
  if not self.isHosting then
    for _, pokemon in pairs(self:getBattlePokemon() or {}) do
      pokemon:onDestroy()
    end
  end
  for _, pokemon in pairs(self:getPacketPokemon() or {}) do
    pokemon:onDestroy()
  end
  for _, pokemon in pairs(self:getCapturePokemon() or {}) do
    pokemon:onDestroy()
  end
end
