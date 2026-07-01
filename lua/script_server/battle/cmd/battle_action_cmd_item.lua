local BattleActionCmdItem = Lib.class("BattleActionCmdItem", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdItem:execute(battleField)
  if self.param and self.param.pets and self.param.item then
    for _, pet in pairs(self.param.pets) do
      pet:useCureItem(self.param.item, self.param.skillId)
    end
    local caster = self.caster.isPlayer and self.caster:getBattlePet() or self.caster
    local effectBuff = self.param.item:cfg().effectBuff
    local deBuffFullName = self.param.item:cfg().deBuffFullName
    local fullName = self.param.item:cfg().fullName
    if caster:isValid() and effectBuff then
      caster.cureItemCfg = self.param.item:cfg()
      if deBuffFullName then
        caster.deBuffFullName = deBuffFullName
      end
      caster:addBuff(effectBuff, self.param.item:cfg().effectBuffTime or 40)
      self.caster:useBagItem(self.param.slot, fullName)
      self.caster:sendPacketToTracking({
        pid = "useItemMessage",
        userName = self.caster.name,
        itemName = self.param.item:cfg().itemName
      }, true)
      return true
    end
    battleField:setAllStateReady(true)
  else
    battleField:setAllStateReady(true)
  end
  return true
end

return BattleActionCmdItem
