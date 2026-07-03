local BattleActionManager = L("BattleActionManager", {})
local queue = require("common.stl.queue")

function BattleActionManager:init()
  self.battleActionQueue = queue.new()
  self.co = coroutine.create(function()
    while true do
      if not self.battleActionQueue:empty() then
        local packet = self.battleActionQueue:front()
        self.battleActionQueue:pop()
        self:process(packet)
      end
      coroutine.yield()
    end
  end)
end

function BattleActionManager:resume()
  Lib.logDebug("BattleActionManager resume")
  return coroutine.resume(self.co)
end

function BattleActionManager:addBattleAction(packet)
  self.battleActionQueue:push(packet)
end

function BattleActionManager:process(packet)
  local param = packet.param
  if param.type == Define.BATTLE_ACTION.RUNAWAY then
    self:processRunaway(param)
  end
end

function BattleActionManager:processRunaway(param)
  Lib.logDebug("BattleActionManager:processRunaway", param.result)
  Me:notifyStateReady()
  if Me.needShowCapture then
    UI:getWnd("pokemonCapture"):onShow()
  end
end

return BattleActionManager
