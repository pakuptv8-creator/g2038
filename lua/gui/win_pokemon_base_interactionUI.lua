local teamMgr = require("script_client.team.team_mgr")
local playerPkMgr = require("script_client.team.playerPk_mgr")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local M = _ENV.M

function M:init()
  WinBase.init(self, "pokemon_base_interactionUI.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytBaseInteractionUIPanel = self:child("base_interactionUI-panel")
  self.imgBaseInteractionUIBg = self:child("base_interactionUI-bg")
  self.imgBaseInteractionUIBg2 = self:child("base_interactionUI-bg2")
  self.lytBaseInteractionUIHeadPanel = self:child("base_interactionUI-head-panel")
  self.imgBaseInteractionUIHeadIcon = self:child("base_interactionUI-head-icon")
  self.imgBaseInteractionUIHeadFrame = self:child("base_interactionUI-head-frame")
  self.txtBaseInteractionUINameTxt = self:child("base_interactionUI-name-txt")
  self.txtBaseInteractionUILevelTxt = self:child("base_interactionUI-level-txt")
  self.imgBaseInteractionUIChatUI = self:child("base_interactionUI-chatUI")
  self.btnBaseInteractionUIChatBtn = self:child("base_interactionUI-chatBtn")
  self.imgBaseInteractionUIChatIcon = self:child("base_interactionUI-chatIcon")
  self.txtBaseInteractionUIChatTxt = self:child("base_interactionUI-chat-txt")
  self.imgBaseInteractionUIInfoUI = self:child("base_interactionUI-infoUI")
  self.btnBaseInteractionUIInfoBtn = self:child("base_interactionUI-infoBtn")
  self.imgBaseInteractionUIInfoIcon = self:child("base_interactionUI-infoIcon")
  self.txtBaseInteractionUIInfoTxt = self:child("base_interactionUI-info-txt")
  self.imgBaseInteractionUITeamUI = self:child("base_interactionUI-teamUI")
  self.btnBaseInteractionUITeamBtn = self:child("base_interactionUI-teamBtn")
  self.imgBaseInteractionUITeamIcon = self:child("base_interactionUI-teamIcon")
  self.txtBaseInteractionUITeamTxt = self:child("base_interactionUI-team-txt")
  self.imgBaseInteractionUIPkUI = self:child("base_interactionUI-pkUI")
  self.btnBaseInteractionUIPkBtn = self:child("base_interactionUI-pkBtn")
  self.imgBaseInteractionUIPkIcon = self:child("base_interactionUI-pkIcon")
  self.txtBaseInteractionUIPkTxt = self:child("base_interactionUI-pk-txt")
  self.imgBaseInteractionUISwapUI = self:child("base_interactionUI-swapUI")
  self.btnBaseInteractionUISwapBtn = self:child("base_interactionUI-swapBtn")
  self.imgBaseInteractionUISwapIcon = self:child("base_interactionUI-swapIcon")
  self.txtBaseInteractionUISwapTxt = self:child("base_interactionUI-swap-txt")
  self.imgBaseInteractionUIFriendUI = self:child("base_interactionUI-friendUI")
  self.btnBaseInteractionUIFriendBtn = self:child("base_interactionUI-friendBtn")
  self.imgBaseInteractionUIFriendIcon = self:child("base_interactionUI-friendIcon")
  self.txtBaseInteractionUIFriendTxt = self:child("base_interactionUI-friend-txt")
  self.imgBaseInteractionUIDissolutionUI = self:child("base_interactionUI-dissolutionUI")
  self.btnBaseInteractionUIDissolutionBtn = self:child("base_interactionUI-dissolutionBtn")
  self.imgBaseInteractionUIDissolutionIcon = self:child("base_interactionUI-dissolutionIcon")
  self.txtBaseInteractionUIDissolutionTxt = self:child("base_interactionUI-dissolution-txt")
  self.txtBaseInteractionUIChatTxt:SetText(Lang:toText("gui_interactionUI_chat"))
  self.txtBaseInteractionUIInfoTxt:SetText(Lang:toText("gui_interactionUI_info"))
  self.txtBaseInteractionUITeamTxt:SetText(Lang:toText("gui_interactionUI_team"))
  self.txtBaseInteractionUIPkTxt:SetText(Lang:toText("gui_interactionUI_pk"))
  self.txtBaseInteractionUISwapTxt:SetText(Lang:toText("gui_interactionUI_swap"))
  self.txtBaseInteractionUIFriendTxt:SetText(Lang:toText("gui_interactionUI_add_friend"))
  self.txtBaseInteractionUIDissolutionTxt:SetText(Lang:toText("gui_interactionUI_dissolution"))
end

local function getPlayerLevelStr(player)
  local playerLevel = player:getPlayerLevel()
  if playerLevel <= 10 then
    return "1_10"
  elseif playerLevel <= 15 then
    return "11_15"
  elseif playerLevel <= 20 then
    return "16_20"
  elseif playerLevel <= 25 then
    return "21_25"
  elseif playerLevel <= 30 then
    return "26_30"
  elseif playerLevel <= 35 then
    return "31_35"
  elseif playerLevel <= 40 then
    return "36_40"
  elseif playerLevel <= 50 then
    return "41_50"
  elseif playerLevel <= 60 then
    return "51_60"
  else
    return "60up"
  end
end

function M:initEvent()
  self:subscribe(self.lytBaseInteractionUIPanel, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUIChatBtn, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("interaction_information", "chat_" .. getPlayerLevelStr(Me))
    if self:clickPlayerIsOnline() then
      self:onHide()
      return
    end
    local target = World.CurWorld:getEntity(self.targetObjID)
    Lib.emitEvent(Event.EVENT_OPEN_PRIVATE_CHAT, target.platformUserId, self.targetObjID, target.name)
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUIInfoBtn, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("interaction_information", "information_" .. getPlayerLevelStr(Me))
    if self:clickPlayerIsOnline() then
      self:onHide()
      return
    end
    UI:getWnd("pokemonOthersPlayer"):onShow(true, self.targetObjID)
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUITeamBtn, UIEvent.EventButtonClick, function()
    if self.teamState == 2 then
      Me:gameBehaviorReport("interaction_information", "team_" .. getPlayerLevelStr(Me))
      if self:clickPlayerIsTooFar() then
        self:onHide()
        return
      end
      local target = World.CurWorld:getEntity(self.targetObjID)
      teamMgr:requestJoinTeam(Me, target)
    elseif self.teamState == 1 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_tips"), 60)
    elseif self.teamState == 0 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_function_not_open"), 60)
    end
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUIDissolutionBtn, UIEvent.EventButtonClick, function()
    if self.teamState == 2 then
      if self:clickPlayerIsTooFar() then
        self:onHide()
        return
      end
      teamMgr:requestLeaveTeam(Me)
    elseif self.teamState == 1 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_tips"), 60)
    elseif self.teamState == 0 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_function_not_open"), 60)
    end
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUIPkBtn, UIEvent.EventButtonClick, function()
    if self.pkState == 2 then
      Me:gameBehaviorReport("interaction_information", "pk_" .. getPlayerLevelStr(Me))
      if self:clickPlayerIsTooFar() then
        self:onHide()
        return
      end
      playerPkMgr:requestPkBattle(self.targetObjID)
    elseif self.pkState == 1 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_tips"), 60)
    elseif self.pkState == 0 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_function_not_open"), 60)
    end
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUISwapBtn, UIEvent.EventButtonClick, function()
    if self.swapState == 2 then
      Me:gameBehaviorReport("interaction_information", "bussiness_" .. getPlayerLevelStr(Me))
      if self:clickPlayerIsTooFar() then
        self:onHide()
        return
      end
      Me.swapLockMap = Me.swapLockMap or {}
      if Me.swapLockMap[self.targetObjID] then
        local endTime = Me.swapLockMap[self.targetObjID] + World.cfg.swapLimitTime
        Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText("gui.swap.apply.limit"), endTime - os.time()), 60)
        return
      end
      Me:sendPlayerAction(Define.PLAYER_ACTION.SWAP, self.targetObjID, function()
        UI:openWnd("pokemonSwapApply", "wait", self.targetObjID)
      end)
    elseif self.swapState == 1 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_tips"), 60)
    elseif self.swapState == 0 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_function_not_open"), 60)
    end
    self:onHide()
  end)
  self:subscribe(self.btnBaseInteractionUIFriendBtn, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("interaction_information", "add_" .. getPlayerLevelStr(Me))
    if self:clickPlayerIsOnline() then
      self:onHide()
      return
    end
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.function.not.open"
    }, function()
    end)
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView(targetObjID)
  self.targetObjID = targetObjID
  self:updateClickPlayerInfo()
end

function M:updateClickPlayerInfo()
  local target = World.CurWorld:getEntity(self.targetObjID)
  self.targetUserId = target.platformUserId
  AsyncProcess.GetUserDetail(target.platformUserId, function(data)
    if data and data.picUrl and #data.picUrl > 0 then
      self.imgBaseInteractionUIHeadIcon:SetImageUrl(data.picUrl)
    end
  end)
  self.txtBaseInteractionUILevelTxt:SetText("Lv." .. target:getPlayerLevel())
  self.txtBaseInteractionUINameTxt:SetText(target.name or target.nickName or "")
  self:updateInteractionBtnShow(target)
end

function M:updateInteractionBtnShow(target)
  local level = tonumber(target:getPlayerLevel())
  local unlockMod = UI:getWnd("pokemonMain").unlockMod
  unlockMod = unlockMod or PlayerExpConfig:getUnlockModByLv(Me:getPlayerLevel())
  if unlockMod then
    self.teamState = 0
    if unlockMod[Define.MODULE_TYPE.INTERACTION_UI_TEAM] and PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.INTERACTION_UI_TEAM, level) then
      if Me:isJoinTeam() then
        if Me:getMyTeamMateId() == target.objID then
          self.teamState = 2
          self.imgBaseInteractionUITeamUI:SetVisible(false)
          self.imgBaseInteractionUIDissolutionUI:SetVisible(true)
        else
          self.teamState = 1
          self.imgBaseInteractionUITeamUI:SetVisible(true)
          self.imgBaseInteractionUIDissolutionUI:SetVisible(false)
        end
      else
        self.teamState = 2
        self.imgBaseInteractionUITeamUI:SetVisible(true)
        self.imgBaseInteractionUIDissolutionUI:SetVisible(false)
      end
    else
      self.teamState = 0
      self.imgBaseInteractionUITeamUI:SetVisible(true)
      self.imgBaseInteractionUIDissolutionUI:SetVisible(false)
    end
    self.btnBaseInteractionUITeamBtn:SetEnabled(true)
    self.btnBaseInteractionUITeamBtn:SetTouchable(true)
    self.btnBaseInteractionUIDissolutionBtn:SetEnabled(true)
    self.btnBaseInteractionUIDissolutionBtn:SetTouchable(true)
    if self.teamState == 2 then
      self.btnBaseInteractionUITeamBtn:setProgram("NORMAL")
      self.btnBaseInteractionUIDissolutionBtn:setProgram("NORMAL")
    else
      self.btnBaseInteractionUITeamBtn:setProgram("GRAY")
      self.btnBaseInteractionUIDissolutionBtn:setProgram("GRAY")
    end
    self.pkState = 0
    if unlockMod[Define.MODULE_TYPE.INTERACTION_UI_PK] and PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.INTERACTION_UI_PK, level) then
      if Me:isJoinTeam() then
        if Me:isTeamCaptain() then
          if target:isJoinTeam() and target:isTeamCaptain() then
            self.pkState = 2
          else
            self.pkState = 1
          end
        else
          self.pkState = 1
        end
      elseif target:isJoinTeam() then
        self.pkState = 1
      else
        self.pkState = 2
      end
    else
      self.pkState = 0
    end
    self.btnBaseInteractionUIPkBtn:SetEnabled(true)
    self.btnBaseInteractionUIPkBtn:SetTouchable(true)
    if self.pkState == 2 then
      self.btnBaseInteractionUIPkBtn:setProgram("NORMAL")
    else
      self.btnBaseInteractionUIPkBtn:setProgram("GRAY")
    end
    self.swapState = 0
    if unlockMod[Define.MODULE_TYPE.INTERACTION_UI_SWAP] and PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.INTERACTION_UI_SWAP, level) then
      if Me:isJoinTeam() then
        if Me:isTeamCaptain() then
          if target:isJoinTeam() and target:isTeamCaptain() or target:getMyTeamMateId() == Me.objID or not target:isJoinTeam() then
            self.swapState = 2
          else
            self.swapState = 1
          end
        elseif Me:getMyTeamMateId() == target.objID then
          self.swapState = 2
        else
          self.swapState = 1
        end
      elseif target:isJoinTeam() and target:isTeamCaptain() or not target:isJoinTeam() then
        self.swapState = 2
      else
        self.swapState = 1
      end
    else
      self.swapState = 0
    end
    self.btnBaseInteractionUISwapBtn:setEnabled(true)
    self.btnBaseInteractionUISwapBtn:SetTouchable(true)
    if self.swapState == 2 then
      self.btnBaseInteractionUISwapBtn:setProgram("NORMAL")
    else
      self.btnBaseInteractionUISwapBtn:setProgram("GRAY")
    end
    self.btnBaseInteractionUIFriendBtn:setProgram("GRAY")
  end
end

function M:clickPlayerIsTooFar()
  local target = World.CurWorld:getEntity(self.targetObjID)
  if not (target and target:isValid()) or target.platformUserId ~= self.targetUserId then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 40)
    return true
  end
  if Me.map.name ~= target.map.name then
    Client.ShowTip(1, Lang:toText("gui_interactionUI_to_far"), 40)
    return true
  end
  local MePos = Me:getPosition()
  if (Lib.v3(MePos.x, MePos.y, MePos.z) - target:getPosition()):len() > World.cfg.clickPlayerDistance then
    Client.ShowTip(1, Lang:toText("gui_interactionUI_to_far"), 40)
    return true
  end
  return false
end

function M:clickPlayerIsOnline()
  local target = World.CurWorld:getEntity(self.targetObjID)
  if not (target and target:isValid()) or target.platformUserId ~= self.targetUserId then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 40)
    return true
  end
  return false
end

function M:onHide()
  UI:closeWnd("pokemon_base_interactionUI")
end

function M:onShow(isShow, targetObjID)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemon_base_interactionUI", targetObjID)
    else
      self:initView(targetObjID)
    end
  else
    self:onHide()
  end
end

function M:onOpen(targetObjID)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(targetObjID)
  self:root():SetAlwaysOnTop(false)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
