local BattleStateDeBuff = Lib.class("BattleStateDeBuff", require("script_server.battle.state.battle_state"))
local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")

local function processPushData2Queue(self, entity)
  if not entity and not entity:isValid() then
    return
  end
  local tbRoundBuff = entity.pokemon and entity.pokemon:getLongRoundEffectbuffList() or {}
  for key, v in pairs(tbRoundBuff) do
    if v.trigger == Define.SkillTriggerType.roundEnd then
      self.battleField.battleActionQueue:push(BattleActionCmdFactory.create({
        caster = entity,
        target = nil,
        type = Define.BATTLE_ACTION.DEBUFF,
        param = {
          skilleffectId = v.skilleffectId,
          key = key,
          tagetId = entity.objID,
          buffCfg = v.buffCfg,
          addTime = v.addTime,
          round = v.round
        }
      }))
    end
  end
  local addSkillEffcts = entity and entity:isValid() and entity:getAddSkillEffects() or {}
  for key, effect in pairs(addSkillEffcts) do
    if effect.trigger == Define.SkillTriggerType.roundEnd then
      self.battleField.battleActionQueue:push(BattleActionCmdFactory.create({
        caster = entity,
        target = nil,
        type = Define.BATTLE_ACTION.DEBUFF,
        param = {
          skilleffectId = effect.skilleffectId,
          key = key,
          tagetId = entity.objID,
          buffCfg = effect.buffCfg,
          addTime = effect.addTime,
          round = effect.round
        }
      }))
    end
  end
end

function BattleStateDeBuff:enter()
  Lib.logDebug("BattleStateDeBuff:enter")
  for i, enemy in pairs(self.battleField:getEnemyDataList()) do
    processPushData2Queue(self, enemy)
  end
  for i, player in pairs(self.battleField.playerList) do
    local entity = player:getBattlePet()
    processPushData2Queue(self, entity)
    player:setStateReady(true)
  end
  for i, npc in pairs(self.battleField.hostList) do
    if npc and npc:isValid() then
      local entity = npc:getBattlePet()
      if entity and entity:isValid() then
        processPushData2Queue(self, entity)
      end
    end
  end
  self.battleField:sortBattleActionQueue()
end

local function broadcastRoundChange(self)
  for i, player in pairs(self.battleField.playerList) do
    player:sendPacket({
      pid = "battleRoundChange"
    })
  end
  Lib.emitEvent(Event.EVENT_BATTLE_ROUND_CHANGE, self.battleField.entityList or {})
end

function BattleStateDeBuff:update(tick)
  if not self.battleField:checkStateReady() then
    return
  end
  if self.battleField.battleActionQueue:empty() then
    if self.battleField:checkBattleEnd() then
      self.battleField:changeBattleState("End")
      return
    end
    if self.battleField:checkPetValid() then
      self.battleField:changeBattleState("WaitCommand")
    else
      self.battleField:autoReplacePet()
    end
  end
end

function BattleStateDeBuff:leave()
  Lib.logDebug("BattleStateDeBuff:leave")
  self.battleField:setAllStateReady(false)
  self.battleField.rounds = self.battleField.rounds + 1
  broadcastRoundChange(self)
end

function BattleStateDeBuff:notifyStateReady(player, packet)
end

return BattleStateDeBuff
