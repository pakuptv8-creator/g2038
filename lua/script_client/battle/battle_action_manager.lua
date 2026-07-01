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
  local wnd = UI:getWnd("battle_dialog")
  wnd:setCloseFunc(function()
    Me:notifyStateReady()
  end)
  if Me.needShowCapture then
    UI:getWnd("pokemonCapture"):onShow()
  end
  if param.mode == Define.BATTLE_MODE.PVE then
    if param.result then
      wnd:showDialogText({
        text = Lang:getMessage("novice_guide_runaway_1"),
        autoCloseTime = 2000
      })
    else
      wnd:showDialogText({
        text = Lang:getMessage("novice_guide_runaway_2"),
        autoCloseTime = 2000
      })
    end
  elseif Me:getCampId() ~= param.campId then
    wnd:showDialogText({
      text = Lang:getMessage("novice_guide_runaway_3"),
      autoCloseTime = 2000
    })
  else
    wnd:showDialogText({
      text = Lang:getMessage("novice_guide_runaway_4"),
      autoCloseTime = 2000
    })
  end
end

return BattleActionManager
