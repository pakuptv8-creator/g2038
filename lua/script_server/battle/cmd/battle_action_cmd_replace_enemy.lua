local BattleActionCmdReplaceEnemy = Lib.class("BattleActionCmdReplaceEnemy", require("script_server.battle.cmd.battle_action_cmd"))
local LuaTimer = T(Lib, "LuaTimer")
local PokemonManager = require("script_server.pokemon.pokemon_manager")

function BattleActionCmdReplaceEnemy:execute(battleField)
  Lib.logDebug("BattleActionCmdReplaceEnemy:execute", self.param.bpIndex)
  if not (self.caster and self.caster:isValid()) or not self.caster:canBattle() then
    battleField:setAllStateReady(true)
    return
  end
  local pokemon
  for _, battlePetId in ipairs(self.caster:getValue("battlePetList") or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    if battlePet and battlePet:getCurHp() > 0 then
      pokemon = battlePet
      break
    end
  end
  if not pokemon then
    Lib.logError("BattleActionCmdReplaceEnemy execute not pokemon!!!")
    battleField:setAllStateReady(true)
    return
  end
  battleField:doThrowBall(self.param.bpIndex - 3, pokemon)
  LuaTimer:cancel(self.caster.enemyReplaceTimer)
  self.caster.enemyReplaceTimer = LuaTimer:schedule(function()
    if battleField:isValid() then
      battleField:enemyReplaceFinish(self.param.posIndex, self.param.queueIndex, pokemon, self.caster)
    end
  end, 1650)
end

return BattleActionCmdReplaceEnemy
