local LuaTimer = T(Lib, "LuaTimer")
local playerPkMgr = require("script_client.team.playerPk_mgr")
local M = _ENV.M

function M:init()
  WinBase.init(self, "PokemonRequestPkDialog.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonRequestPkDialogContent = self:child("PokemonRequestPkDialog-Content")
  self.btnPokemonRequestPkDialogBtnClose = self:child("PokemonRequestPkDialog-BtnClose")
  self.txtPokemonRequestPkDialogTitle = self:child("PokemonRequestPkDialog-Title")
  self.imgPokemonRequestPkDialogVsIcon = self:child("PokemonRequestPkDialog-vsIcon")
  self.txtPokemonRequestPkDialogText = self:child("PokemonRequestPkDialog-Text")
  self.btnPokemonRequestPkDialogBtnRefuse = self:child("PokemonRequestPkDialog-BtnRefuse")
  self.txtPokemonRequestPkDialogRefuseTxt = self:child("PokemonRequestPkDialog-refuseTxt")
  self.btnPokemonRequestPkDialogBtnConfirm = self:child("PokemonRequestPkDialog-BtnConfirm")
  self.txtPokemonRequestPkDialogConfirmTxt = self:child("PokemonRequestPkDialog-confirmTxt")
  self.imgPokemonRequestPkDialogChallengerIcon = self:child("PokemonRequestPkDialog-ChallengerIcon")
  self.txtPokemonRequestPkDialogChallengerTxt = self:child("PokemonRequestPkDialog-ChallengerTxt")
  self.lytPokemonRequestPkDialogCPlayerPanel1 = self:child("PokemonRequestPkDialog-cPlayerPanel1")
  self.imgPokemonRequestPkDialogCPlayerIcon1 = self:child("PokemonRequestPkDialog-cPlayerIcon1")
  self.imgPokemonRequestPkDialogCPlayerFrame1 = self:child("PokemonRequestPkDialog-cPlayerFrame1")
  self.txtPokemonRequestPkDialogCPlayerLv1 = self:child("PokemonRequestPkDialog-cPlayerLv1")
  self.txtPokemonRequestPkDialogCPlayerName1 = self:child("PokemonRequestPkDialog-cPlayerName1")
  self.lytPokemonRequestPkDialogCPlayerPanel2 = self:child("PokemonRequestPkDialog-cPlayerPanel2")
  self.imgPokemonRequestPkDialogCPlayerIcon2 = self:child("PokemonRequestPkDialog-cPlayerIcon2")
  self.imgPokemonRequestPkDialogCPlayerFrame2 = self:child("PokemonRequestPkDialog-cPlayerFrame2")
  self.txtPokemonRequestPkDialogCPlayerLv2 = self:child("PokemonRequestPkDialog-cPlayerLv2")
  self.txtPokemonRequestPkDialogCPlayerName2 = self:child("PokemonRequestPkDialog-cPlayerName2")
  self.lytPokemonRequestPkDialogCPlayerPanel3 = self:child("PokemonRequestPkDialog-cPlayerPanel3")
  self.imgPokemonRequestPkDialogCPlayerIcon3 = self:child("PokemonRequestPkDialog-cPlayerIcon3")
  self.imgPokemonRequestPkDialogCPlayerFrame3 = self:child("PokemonRequestPkDialog-cPlayerFrame3")
  self.txtPokemonRequestPkDialogCPlayerLv3 = self:child("PokemonRequestPkDialog-cPlayerLv3")
  self.txtPokemonRequestPkDialogCPlayerName3 = self:child("PokemonRequestPkDialog-cPlayerName3")
  self.lytPokemonRequestPkDialogCPlayerPanel4 = self:child("PokemonRequestPkDialog-cPlayerPanel4")
  self.imgPokemonRequestPkDialogCPlayerIcon4 = self:child("PokemonRequestPkDialog-cPlayerIcon4")
  self.imgPokemonRequestPkDialogCPlayerFrame4 = self:child("PokemonRequestPkDialog-cPlayerFrame4")
  self.txtPokemonRequestPkDialogCPlayerLv4 = self:child("PokemonRequestPkDialog-cPlayerLv4")
  self.txtPokemonRequestPkDialogCPlayerName4 = self:child("PokemonRequestPkDialog-cPlayerName4")
  self.txtPokemonRequestPkDialogTitle:SetText(Lang:toText("gui_pk_dialog_title"))
  self.txtPokemonRequestPkDialogChallengerTxt:SetText(Lang:toText("gui_pk_dialog_from_title"))
  self.txtPokemonRequestPkDialogConfirmTxt:SetText(Lang:toText("gui_btn_agree_title"))
  self.txtPokemonRequestPkDialogRefuseTxt:SetText(Lang:toText("gui_btn_refuse_title"))
  self.initPlayerPosX1 = self.lytPokemonRequestPkDialogCPlayerPanel1:GetXPosition()
  self.initPlayerPosX3 = self.lytPokemonRequestPkDialogCPlayerPanel3:GetXPosition()
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytPokemonRequestPkDialogContent, 880, 477)
end

function M:initEvent()
  self:subscribe(self.btnPokemonRequestPkDialogBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPokemonRequestPkDialogBtnRefuse, UIEvent.EventButtonClick, function()
    playerPkMgr:refusePKRequest(self.fromID)
    self:onHide()
  end)
  self:subscribe(self.btnPokemonRequestPkDialogBtnConfirm, UIEvent.EventButtonClick, function()
    playerPkMgr:agreePKRequest(self.fromID)
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView(fromID)
  self.fromID = fromID
  local from1 = World.CurWorld:getEntity(fromID)
  AsyncProcess.GetUserDetail(from1.platformUserId, function(data)
    if data and data.picUrl and #data.picUrl > 0 then
      self.imgPokemonRequestPkDialogCPlayerIcon1:SetImageUrl(data.picUrl)
    end
  end)
  self.txtPokemonRequestPkDialogCPlayerLv1:SetText("Lv." .. from1:getPlayerLevel())
  self.txtPokemonRequestPkDialogCPlayerName1:SetText(from1.name)
  if from1:isJoinTeam() then
    local from2 = World.CurWorld:getEntity(from1:getMyTeamMateId())
    AsyncProcess.GetUserDetail(from2.platformUserId, function(data)
      if data and data.picUrl and #data.picUrl > 0 then
        self.imgPokemonRequestPkDialogCPlayerIcon2:SetImageUrl(data.picUrl)
      end
    end)
    self.txtPokemonRequestPkDialogCPlayerLv2:SetText("Lv." .. from2:getPlayerLevel())
    self.txtPokemonRequestPkDialogCPlayerName2:SetText(from2.name)
    self.lytPokemonRequestPkDialogCPlayerPanel1:SetXPosition({
      self.initPlayerPosX1[1],
      0
    })
    self.lytPokemonRequestPkDialogCPlayerPanel2:SetVisible(true)
  else
    self.lytPokemonRequestPkDialogCPlayerPanel2:SetVisible(false)
    self.lytPokemonRequestPkDialogCPlayerPanel1:SetXPosition({
      self.initPlayerPosX1[1],
      -78
    })
  end
  AsyncProcess.GetUserDetail(Me.platformUserId, function(data)
    if data and data.picUrl and #data.picUrl > 0 then
      self.imgPokemonRequestPkDialogCPlayerIcon3:SetImageUrl(data.picUrl)
    end
  end)
  self.txtPokemonRequestPkDialogCPlayerLv3:SetText("Lv." .. Me:getPlayerLevel())
  self.txtPokemonRequestPkDialogCPlayerName3:SetText(Me.name)
  if Me:isJoinTeam() then
    local myMate = World.CurWorld:getEntity(Me:getMyTeamMateId())
    AsyncProcess.GetUserDetail(myMate.platformUserId, function(data)
      if data and data.picUrl and #data.picUrl > 0 then
        self.imgPokemonRequestPkDialogCPlayerIcon4:SetImageUrl(data.picUrl)
      end
    end)
    self.txtPokemonRequestPkDialogCPlayerLv4:SetText("Lv." .. myMate:getPlayerLevel())
    self.txtPokemonRequestPkDialogCPlayerName4:SetText(myMate.name)
    self.lytPokemonRequestPkDialogCPlayerPanel3:SetXPosition({
      self.initPlayerPosX3[1],
      0
    })
    self.lytPokemonRequestPkDialogCPlayerPanel4:SetVisible(true)
  else
    self.lytPokemonRequestPkDialogCPlayerPanel4:SetVisible(false)
    self.lytPokemonRequestPkDialogCPlayerPanel3:SetXPosition({
      self.initPlayerPosX3[1],
      78
    })
  end
  self.txtPokemonRequestPkDialogRefuseTxt:SetText(Lang:toText("gui_btn_refuse_title") .. "(" .. World.cfg.pkDialogRefuseTime .. ")")
  self:showDownTime()
end

function M:showDownTime()
  local remainTime = World.cfg.pkDialogRefuseTime
  self.downTimer = LuaTimer:scheduleTimer(function()
    self.txtPokemonRequestPkDialogRefuseTxt:SetText(Lang:toText("gui_btn_refuse_title") .. "(" .. remainTime .. ")")
    if remainTime <= 0 then
      self:onHide()
      LuaTimer:cancel(self.downTimer)
      self.downTimer = nil
    end
    remainTime = remainTime - 1
  end, 1000, -1)
end

function M:onHide()
  UI:closeWnd("pokemonRequestPkDialog")
end

function M:onShow(isShow, fromID)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonRequestPkDialog", fromID)
    end
  else
    self:onHide()
  end
end

function M:onOpen(fromID)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(fromID)
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
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
  Me:sendFinishAction()
end

return M
