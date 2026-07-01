local LuaTimer = T(Lib, "LuaTimer")
local teamMgr = require("script_client.team.team_mgr")

function M:init()
  WinBase.init(self, "PokemonRequestTeamDialog.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonRequestTeamDialogContent = self:child("PokemonRequestTeamDialog-Content")
  self.btnPokemonRequestPkDialogBtnClose = self:child("PokemonRequestPkDialog-BtnClose")
  self.txtPokemonRequestPkDialogTitle = self:child("PokemonRequestPkDialog-Title")
  self.txtPokemonRequestPkDialogNameText = self:child("PokemonRequestPkDialog-nameText")
  self.txtPokemonRequestPkDialogInviteTxt = self:child("PokemonRequestPkDialog-inviteTxt")
  self.btnPokemonRequestPkDialogBtnRefuse = self:child("PokemonRequestPkDialog-BtnRefuse")
  self.txtPokemonRequestTeamDialogRefuseTxt = self:child("PokemonRequestTeamDialog-refuseTxt")
  self.btnPokemonRequestPkDialogBtnConfirm = self:child("PokemonRequestPkDialog-BtnConfirm")
  self.txtPokemonRequestTeamDialogConfirmTxt = self:child("PokemonRequestTeamDialog-confirmTxt")
  self.txtPokemonRequestPkDialogTitle:SetText(Lang:toText("gui_team_dialog_title"))
  self.txtPokemonRequestTeamDialogConfirmTxt:SetText(Lang:toText("gui_btn_agree_title"))
  self.txtPokemonRequestTeamDialogRefuseTxt:SetText(Lang:toText("gui_btn_refuse_title"))
end

function M:initEvent()
  self:subscribe(self.btnPokemonRequestPkDialogBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPokemonRequestPkDialogBtnRefuse, UIEvent.EventButtonClick, function()
    local from = World.CurWorld:getEntity(self.fromID)
    if not from or not from:isValid() then
      Client.ShowTip(1, Lang:toText("gui_player_offline"), 60)
      self:onHide()
      return
    end
    teamMgr:agreeOrRefuseJoinTeam(from, Me, false)
    self:onHide()
  end)
  self:subscribe(self.btnPokemonRequestPkDialogBtnConfirm, UIEvent.EventButtonClick, function()
    if self:clickPlayerIsTooFar() then
      return
    end
    local from = World.CurWorld:getEntity(self.fromID)
    if not from or not from:isValid() then
      Client.ShowTip(1, Lang:toText("gui_player_offline"), 60)
      self:onHide()
      return
    end
    teamMgr:agreeOrRefuseJoinTeam(from, Me, true)
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:clickPlayerIsTooFar()
  local target = World.CurWorld:getEntity(self.fromID)
  if not target or not target:isValid() then
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

function M:initView(fromID)
  self.fromID = fromID
  local from = World.CurWorld:getEntity(self.fromID)
  if not from or not from:isValid() then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 60)
    return
  end
  local nameStr = from.name .. "(Lv." .. from:getPlayerLevel() .. ")"
  self.txtPokemonRequestPkDialogNameText:SetText(nameStr)
  self.txtPokemonRequestPkDialogInviteTxt:SetText(Lang:toText("gui_request_join_team"))
  self.txtPokemonRequestTeamDialogRefuseTxt:SetText(Lang:toText("gui_btn_refuse_title") .. "(" .. World.cfg.pkDialogRefuseTime .. ")")
  self:showDownTime()
end

function M:showDownTime()
  if self.downTimer then
    LuaTimer:cancel(self.downTimer)
    self.downTimer = nil
  end
  local remainTime = World.cfg.pkDialogRefuseTime
  self.downTimer = LuaTimer:scheduleTimer(function()
    self.txtPokemonRequestTeamDialogRefuseTxt:SetText(Lang:toText("gui_btn_refuse_title") .. "(" .. remainTime .. ")")
    if remainTime <= 0 then
      self:onHide()
      LuaTimer:cancel(self.downTimer)
      self.downTimer = nil
    end
    remainTime = remainTime - 1
  end, 1000, -1)
end

function M:onHide()
  UI:closeWnd("pokemonRequestTeamDialog")
end

function M:onShow(isShow, fromID)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonRequestTeamDialog", fromID)
    else
      self:initView(fromID)
    end
  else
    self:onHide()
  end
end

function M:onOpen(fromID)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(fromID)
  self:root():SetAlwaysOnTop(false)
  UI:getWnd("pokemonRequestTeamDialog"):root():SetLevel(50)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.downTimer then
    LuaTimer:cancel(self.downTimer)
    self.downTimer = nil
  end
end

return M
