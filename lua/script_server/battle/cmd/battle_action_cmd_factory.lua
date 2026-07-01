local BattleActionCmdFactory = L("BattleActionCmdFactory", {})

function BattleActionCmdFactory.create(param)
  local map = {
    [Define.BATTLE_ACTION.NONE] = require("script_server.battle.cmd.battle_action_cmd_none"),
    [Define.BATTLE_ACTION.SKILL] = require("script_server.battle.cmd.battle_action_cmd_skill"),
    [Define.BATTLE_ACTION.RUNAWAY] = require("script_server.battle.cmd.battle_action_cmd_runaway"),
    [Define.BATTLE_ACTION.RUNAWAY_ENEMY] = require("script_server.battle.cmd.battle_action_cmd_runaway_enemy"),
    [Define.BATTLE_ACTION.REPLACE] = require("script_server.battle.cmd.battle_action_cmd_replace"),
    [Define.BATTLE_ACTION.BALL] = require("script_server.battle.cmd.battle_action_cmd_ball"),
    [Define.BATTLE_ACTION.ITEM] = require("script_server.battle.cmd.battle_action_cmd_item"),
    [Define.BATTLE_ACTION.FEATURE] = require("script_server.battle.cmd.battle_action_cmd_feature"),
    [Define.BATTLE_ACTION.DEBUFF] = require("script_server.battle.cmd.battle_action_cmd_debuff"),
    [Define.BATTLE_ACTION.REPLACE_ENEMY] = require("script_server.battle.cmd.battle_action_cmd_replace_enemy"),
    [Define.BATTLE_ACTION.REPLACE_HOST] = require("script_server.battle.cmd.battle_action_cmd_replace_host")
  }
  local class = map[param.type]
  if not class then
    return nil
  end
  return class.new(param)
end

return BattleActionCmdFactory
