local BattleActionCmdReplace = Lib.class("BattleActionCmdReplace", require("script_server.battle.cmd.battle_action_cmd"))
local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")

function BattleActionCmdReplace:execute(battleField)
  if not self.caster or not self.caster:isValid() then
    battleField:setAllStateReady(true)
    return
  end
  if not self.param and self.caster:getRandomBattlePokemon() then
    self.param = self.caster:getRandomBattlePokemon().objId
  end
  local battlePet = self.caster:getBattlePet()
  local battlePokemonObjId = self.caster:getBattlePokemonObjId()
  if not battlePet or not battlePokemonObjId then
    battleField:setAllStateReady(true)
    return
  end
  if battlePokemonObjId == self.param then
    Lib.logError("BattleActionCmdReplace execute is same pokemon!", self.caster.name, self.param)
    battleField:setAllStateReady(true)
    return
  end
  Lib.logDebug("BattleActionCmdReplace:execute", self.param)
  local pokemon = self.caster:getPokemon(self.param)
  if not pokemon then
    battleField:setAllStateReady(true)
    return false
  end
  if battlePet:isValid() then
    battlePet:destroy()
  end
  local pet = battleField:createPet(self.caster, pokemon, true)
  battleField.battleActionQueue:push(BattleActionCmdFactory.create({
    caster = pet,
    target = nil,
    type = Define.BATTLE_ACTION.FEATURE
  }))
  battleField:sortBattleActionQueue()
  battleField:doThrowBall(self.caster:getBpIndex(), pokemon)
  return true
end

return BattleActionCmdReplace
