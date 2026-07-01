local NPCConfig = T(Config, "NPCConfig")
local GymConfig = T(Config, "GymConfig")
local Player = _ENV.Player

function Player:showDialog(packet)
  self.npcId = packet.npcId
  self.actionId = packet.actionId
  self.reasonId = packet.reasonId
  self.targetId = packet.objID
  self.dialogType = packet.type
  self.dialogId = packet.dialogId
  local target = World.CurWorld:getEntity(self.targetId)
  if target then
    Lib.emitEvent(Event.EVENT_SHOW_DIALOG, packet.type, packet.dialogId, packet.objID)
  else
    self.isShowDialog = true
  end
end

function Player:resetDialog()
  self.npcId = -1
  self.actionId = -1
  self.reasonId = -1
  self.targetId = -1
  self.dialogType = -1
  self.dialogId = -1
end

function Player:initDialogEvent()
  Lib.subscribeEvent(Event.EVENT_FINISH_PRE_BATTLE_ANIMATION, function()
    Lib.logInfo("on EVENT_FINISH_PRE_BATTLE_ANIMATION self.actionId = ", self.actionId)
    if self.actionId == Define.NPC_ACTION_TYPE.ENTERBATTLE then
      local packet = {
        pid = "npcEnterBattle",
        npcId = self.npcId,
        objId = self.targetId
      }
      Lib.logDebug("dialog npcEnterBattle packet = ", Lib.v2s(packet))
      Me:sendPacket(packet)
      self:resetDialog()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    if self.targetId == objID and self.isShowDialog == true then
      self.isShowDialog = false
      Lib.emitEvent(Event.EVENT_SHOW_DIALOG, self.dialogType, self.dialogId, self.targetId)
    end
  end)
end

function Player:onDialogContinue()
  if self.actionId == Define.NPC_ACTION_TYPE.DONOTHING then
    Me:sendPacket({
      pid = "kickForceObstacle"
    })
    Me:sendPacket({pid = "resetInNpc", value = 0})
    Lib.emitEvent(Event.EVENT_RESUME_BLOCK)
  end
end

function Player:onDialogCancel()
  if self.npcId ~= -1 then
    Me:gameBehaviorReport("npc_no", self.npcId)
  end
  if self.actionId == Define.NPC_ACTION_TYPE.ENTERBATTLE or self.actionId == Define.NPC_ACTION_TYPE.TELEGRAPH then
    Me:sendPacket({
      pid = "kickForceObstacle"
    })
    Me:sendPacket({pid = "resetInNpc", value = 0})
  elseif self.actionId == Define.NPC_ACTION_TYPE.RECOVERY then
    Me:sendPacket({pid = "resetInNpc", value = 0})
  end
  Lib.emitEvent(Event.EVENT_RESUME_BLOCK)
  self:resetDialog()
end

function Player:onDialogConfirm()
  if self.npcId ~= -1 then
    Me:gameBehaviorReport("npc_yes", self.npcId)
  end
  if self.actionId == Define.NPC_ACTION_TYPE.RECOVERY then
    local packet = {
      pid = "recoveryAllByDoctor"
    }
    Me:sendPacket(packet)
    Lib.emitEvent(Event.EVENT_RESUME_BLOCK)
    self:resetDialog()
  elseif self.actionId == Define.NPC_ACTION_TYPE.TELEGRAPH then
    local npc_config = NPCConfig:getNPCById(self.npcId)
    if npc_config then
      if #npc_config.trans_gyms > 0 then
        Lib.logDebug("trans_gyms = ", Lib.v2s(npc_config.trans_gyms))
        UI:getWnd("pokemonTelegraph"):onShow(npc_config.trans_gyms)
      else
        local regionId = 0
        local curGymId = Me:getCurGym()
        if curGymId ~= 0 then
          local gym_config = GymConfig:getGymById(curGymId)
          if gym_config then
            regionId = gym_config.out_region_id
          end
        end
        Lib.emitEvent(Event.EVENT_OPEN_MINI_MAP)
        Me:sendPacket({
          pid = "TelegraphToRegion",
          regionId = regionId,
          gymId = 0
        })
        Lib.emitEvent(Event.EVENT_RESUME_BLOCK)
        self:resetDialog()
      end
    end
  elseif self.actionId == Define.NPC_ACTION_TYPE.ENTERBATTLE then
    local npc_config = NPCConfig:getNPCById(self.npcId)
    if npc_config and npc_config.gym_id ~= 0 and npc_config.is_pvp == 1 then
      Lib.logDebug("is pvp npc")
      UI:getWnd("pokemonPvP"):onShow(self.npcId, self.targetId)
    else
      Me:sendPacket({
        pid = "canEnterBattle",
        npcId = self.npcId
      })
    end
    Lib.emitEvent(Event.EVENT_RESUME_BLOCK)
  end
end

function Player:canEnterBattle(npcId, reason_id)
  if reason_id == Define.DIALOG_REASON.TEAM then
    Lib.logDebug("canEnterBattle reason_id = ", reason_id)
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_enter_battle_fail"), 60)
    Me:sendPacket({
      pid = "kickForceObstacle"
    })
    Me:sendPacket({pid = "resetInNpc", value = 0})
    UI:getWnd("battle_pre_animation"):onHide()
    self:resetDialog()
  elseif reason_id == Define.DIALOG_REASON.RACENOTMATCH then
    Me:sendPacket({pid = "resetInNpc", value = 0})
  elseif reason_id == Define.DIALOG_REASON.NORMAL then
    Me:inPreBattleCloseInteractionWnd()
    UI:getWnd("battle_pre_animation"):onShow(true, {
      meetType = Define.MEET_PKM_TYPE.AREA_NPC_PKM,
      rareID = -1
    })
  end
end
