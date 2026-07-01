local BattleActionCmdReplaceHost = Lib.class("BattleActionCmdReplaceHost", require("script_server.battle.cmd.battle_action_cmd"))
local PokemonManager = require("script_server.pokemon.pokemon_manager")

function BattleActionCmdReplaceHost:execute(battleField)
  Lib.logDebug("BattleActionCmdReplaceHost:execute")
  local pokemon
  for _, battlePetId in pairs(self.caster:getValue("battlePetList") or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    if battlePet and battlePet:getCurHp() > 0 then
      pokemon = battlePet
      break
    end
  end
  if not pokemon then
    Lib.logError("BattleActionCmdReplaceHost:execute not pokemon!!!")
    battleField:setAllStateReady(true)
    return false
  end
  battleField:createPet(self.caster, pokemon, true)
  battleField:doThrowBall(self.caster:getBpIndex(), pokemon, self.caster)
  return true
end

return BattleActionCmdReplaceHost
