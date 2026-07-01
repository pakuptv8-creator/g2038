local M = _ENV.M
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonSwapApply.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonSwapApplyWait = self:child("PokemonSwapApply-Wait")
  self.txtPokemonSwapApplyWaitTitle = self:child("PokemonSwapApply-Wait-Title")
  self.btnPokemonSwapApplyWaitCancel = self:child("PokemonSwapApply-Wait-Cancel")
  self.txtPokemonSwapApplyWaitTip = self:child("PokemonSwapApply-Wait-Tip")
  self.lytPokemonSwapApplyAsk = self:child("PokemonSwapApply-Ask")
  self.txtPokemonSwapApplyAskTitle = self:child("PokemonSwapApply-Ask-Title")
  self.btnPokemonSwapApplyAskCancel = self:child("PokemonSwapApply-Ask-Cancel")
  self.btnPokemonSwapApplyAskSure = self:child("PokemonSwapApply-Ask-Sure")
  self.lytPokemonSwapApplyAskSwitchBg = self:child("PokemonSwapApply-Ask-Switch-Bg")
  self.chkPokemonSwapApplyAskBanSwitch = self:child("PokemonSwapApply-Ask-Ban-Switch")
  self.txtPokemonSwapApplySwitchTip = self:child("PokemonSwapApply-Switch-Tip")
  self.txtPokemonSwapApplyAskTip = self:child("PokemonSwapApply-Ask-Tip")
  self.imgPokemonSwapApplyAskHead = self:child("PokemonSwapApply-Ask-Head")
  self.imgPokemonSwapApplyBorder = self:child("PokemonSwapApply-Border")
  self.txtPokemonSwapApplyAskName = self:child("PokemonSwapApply-Ask-Name")
  self.txtPokemonSwapApplyAskLevel = self:child("PokemonSwapApply-Ask-Level")
  self.txtPokemonSwapApplyWaitTitle:SetText(Lang:toText("gui.swap.wait.title"))
  self.txtPokemonSwapApplySwitchTip:SetText(string.format(Lang:toText("gui.swap.apply.switch.tip"), World.cfg.swapBanTime))
  self.txtPokemonSwapApplyAskTitle:SetText(Lang:toText("gui.swap.apply.title"))
end

function M:initEvent()
  self:subscribe(self.btnPokemonSwapApplyWaitCancel, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "quitSwap",
      code = Define.SWAP_END_CODE.CANCEL
    })
    self:onHide()
  end)
  self:subscribe(self.btnPokemonSwapApplyAskCancel, UIEvent.EventButtonClick, function()
    self:clickRefuse()
  end)
  self:subscribe(self.btnPokemonSwapApplyAskSure, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "applySwap",
      targetId = self.targetId
    }, function(retCode)
      if retCode == 1 then
        Me:showCommonTip(1, Lang:toText("gui_player_offline"), 40)
      end
    end)
  end)
end

function M:subscribeEvent()
end

function M:initView()
  local yourPlayer = World.CurWorld:getEntity(self.targetId)
  local showName = yourPlayer.name or yourPlayer.nickName or ""
  self.txtPokemonSwapApplyAskLevel:SetText("Lv." .. yourPlayer:getPlayerLevel())
  self.txtPokemonSwapApplyAskName:SetText(showName)
  self.txtPokemonSwapApplyAskTip:SetText(string.format(Lang:toText("gui.swap.tip.apply"), showName))
  self.txtPokemonSwapApplyWaitTip:SetText(string.format(Lang:toText("gui.swap.tip.wait"), showName))
  AsyncProcess.GetUserDetail(yourPlayer.platformUserId, function(data)
    if data and data.picUrl and #data.picUrl > 0 then
      self.imgPokemonSwapApplyAskHead:SetImageUrl(data.picUrl)
    end
  end)
end

function M:onHide()
  UI:closeWnd("pokemonSwapApply")
end

function M:onOpen(type, targetId)
  self.targetId = targetId
  self.lytPokemonSwapApplyWait:SetVisible(type == "wait")
  self.lytPokemonSwapApplyAsk:SetVisible(type == "ask")
  self.chkPokemonSwapApplyAskBanSwitch:SetChecked(false)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  if type == "wait" then
    self:startCountDown()
  end
  if type == "ask" then
    self:startAutoCancel()
  end
end

function M:startCountDown()
  self.CountDown = 5
  self.btnPokemonSwapApplyWaitCancel:SetEnabled(self.CountDown == 0)
  self.btnPokemonSwapApplyWaitCancel:SetText(self.CountDown .. "s")
  LuaTimer:cancel(self.timerKey or 0)
  self.timerKey = LuaTimer:scheduleTimer(function()
    self.CountDown = self.CountDown - 1
    self.btnPokemonSwapApplyWaitCancel:SetEnabled(self.CountDown == 0)
    self.btnPokemonSwapApplyWaitCancel:SetText(self.CountDown > 0 and self.CountDown .. "s" or "")
  end, 1000, 5)
end

function M:startAutoCancel()
  self.autoCancelTick = World.cfg.swapAutoCancelTime
  self.btnPokemonSwapApplyAskCancel:SetText(Lang:toText("gui.swap.refuse") .. "(" .. self.autoCancelTick .. ")")
  self.btnPokemonSwapApplyAskSure:SetText(Lang:toText("gui.swap.accept"))
  LuaTimer:cancel(self.timerKeyAuto or 0)
  self.timerKeyAuto = LuaTimer:scheduleTimer(function()
    self.autoCancelTick = self.autoCancelTick - 1
    self.btnPokemonSwapApplyAskCancel:SetText(Lang:toText("gui.swap.refuse") .. "(" .. self.autoCancelTick .. ")")
    if self.autoCancelTick == 0 then
      self:clickRefuse()
    end
  end, 1000, self.autoCancelTick)
end

function M:clickRefuse()
  Me:sendPacket({
    pid = "quitSwap",
    code = Define.SWAP_END_CODE.REFUSE
  })
  if self.chkPokemonSwapApplyAskBanSwitch:GetChecked() then
    Me:sendPacket({pid = "banSwap"})
  end
  self:onHide()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  LuaTimer:cancel(self.timerKey or 0)
  LuaTimer:cancel(self.timerKeyAuto or 0)
end

return M
