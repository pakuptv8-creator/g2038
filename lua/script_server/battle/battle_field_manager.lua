local BattleFieldManager = L("BattleFieldManager", {})
local uuid = require("common.uuid")
local LuaTimer = T(Lib, "LuaTimer")
local battleFieldList = Lib.newWeakTable()
local tick = 0
local battleFieldMaxTick = 10
local battleFieldTickIndex = 0

function BattleFieldManager:init()
  LuaTimer:cancel(self.updateTimer)
  self.updateTimer = LuaTimer:schedule(function()
    self:update(tick)
    tick = tick + 1
    tick = 1024 < tick and 0 or tick
  end, 0, 50)
end

function BattleFieldManager:create(param)
  if Lib.getTableSize(battleFieldList) >= 1000 then
    Lib.logError("BattleFieldManager create too many!")
    return nil
  end
  local battleFieldMap = {
    [Define.BATTLE_MODE.PVE] = require("script_server.battle.battle_field_pve"),
    [Define.BATTLE_MODE.NPC] = require("script_server.battle.battle_field_npc"),
    [Define.BATTLE_MODE.PVP] = require("script_server.battle.battle_field_pvp")
  }
  local class = battleFieldMap[param.mode]
  if not class then
    return nil
  end
  local uid = uuid()
  local bf = class.new(param, uid)
  bf.tickIndex = battleFieldTickIndex
  battleFieldTickIndex = (battleFieldTickIndex + 1) % battleFieldMaxTick
  battleFieldList[uid] = bf
  Lib.logInfo("BattleFieldManager:create", class.__name, bf.tickIndex)
  return bf
end

function BattleFieldManager:update(t)
  for uid, battleField in pairs(battleFieldList) do
    if t % battleFieldMaxTick == battleField.tickIndex then
      battleField:update(t)
    end
  end
end

function BattleFieldManager:getBattleFieldList()
  return battleFieldList
end

function BattleFieldManager:remove(uid)
  battleFieldList[uid] = nil
end

return BattleFieldManager
