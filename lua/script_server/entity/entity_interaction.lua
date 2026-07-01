local NPCConfig = T(Config, "NPCConfig")
local NPCDialogueListConfig = T(Config, "NPCDialogueListConfig")
local EntityServer = _ENV.EntityServer

function EntityServer:interact_with_player(target, cfg)
  if not (target and target:isValid() and self) or not self:isValid() then
    return
  end
  if not target.isPlayer or not self.isPlayer then
    return
  end
  if target:isInBattle() or self:isInBattle() then
    return
  end
  Lib.logDebug("target getIsReturnHome = ", target:getIsReturnHome())
  if target:getIsReturnHome() == true then
    return
  end
  target:sendPacket({
    pid = "OpenPlayerActionDialog",
    objID = self.objID
  })
end

local function getDialogType(actionId)
  local type = Define.DIALOG_TYPE.NONE
  if actionId == Define.NPC_ACTION_TYPE.DONOTHING then
    type = Define.DIALOG_TYPE.NONE
  elseif actionId == Define.NPC_ACTION_TYPE.RECOVERY or actionId == Define.NPC_ACTION_TYPE.ENTERBATTLE or actionId == Define.NPC_ACTION_TYPE.TELEGRAPH then
    type = Define.DIALOG_TYPE.TWO
  end
  return type
end

function EntityServer:interact_with_npc(target, cfg, region)
  if target and target:isValid() and target.isPlayer and target:getValue("battlePreType") == 0 then
    if target:isJoinTeam() and not target:isTeamCaptain() then
      return
    end
    target:setInNpc(1)
    target:setCanPK(0)
    local npcId = cfg.id
    local npc_config = NPCConfig:getNPCById(npcId)
    local action_id = npc_config.action_id
    local reason_id = Define.DIALOG_REASON.NORMAL
    if action_id == Define.NPC_ACTION_TYPE.ENTERBATTLE then
      action_id, reason_id = target:checkEnterBattle(npcId)
    elseif action_id == Define.NPC_ACTION_TYPE.SELECTPOKEMON then
      local battleList = target:getBattlePokemon()
      if 0 < #battleList then
        action_id = Define.NPC_ACTION_TYPE.DONOTHING
      else
        local packet = {
          pid = "showSelectPokemon",
          pokemonId = npc_config.pokemon_list[1]
        }
        target:sendPacket(packet)
        return
      end
    end
    local objID = self.objID
    local dialogue_id = -1
    if action_id == Define.NPC_ACTION_TYPE.ENTERBATTLE or action_id == Define.NPC_ACTION_TYPE.TELEGRAPH or action_id == Define.NPC_ACTION_TYPE.RECOVERY or action_id == Define.NPC_ACTION_TYPE.DONOTHING then
      local dialogue_list_config = NPCDialogueListConfig:getDialogue(npcId, action_id, reason_id)
      if dialogue_list_config then
        dialogue_id = dialogue_list_config.dialogue_id
      end
    end
    if region then
      if action_id == Define.NPC_ACTION_TYPE.ENTERBATTLE or action_id == Define.NPC_ACTION_TYPE.TELEGRAPH then
        target.kickPos = cfg.kickPos
      elseif action_id == Define.NPC_ACTION_TYPE.DONOTHING then
        if target:isJoinTeam() and reason_id ~= Define.DIALOG_REASON.CHALLENGED then
          target.kickPos = cfg.kickPos
        else
          target:setInNpc(0)
          target:setCanPK(1)
          return
        end
      end
    end
    if dialogue_id ~= -1 then
      local type = getDialogType(action_id)
      Lib.logInfo("showDialog type = ", type)
      local packet = {
        pid = "showDialog",
        type = type,
        dialogId = dialogue_id,
        objID = objID,
        npcId = npcId,
        actionId = action_id,
        reasonId = reason_id
      }
      Lib.logDebug("showDialog packet = ", Lib.v2s(packet))
      target:sendPacket(packet)
    end
  end
end
