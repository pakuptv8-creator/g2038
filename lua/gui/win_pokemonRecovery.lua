local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonRecovery.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.canHide = false
  self.curProgress = 0
  self.delta = 1 / (World.cfg.recoveryAnimationTime * 10)
end

function M:initWnd()
  self.stTitle = self:child("PokemonRecovery-Title")
  self.btnClose = self:child("PokemonRecovery-BtnClose")
  self.siProgressBG = self:child("PokemonRecovery-ProgressBG")
  self.stTitle = self:child("PokemonRecovery-Title")
  self.pbIndicator = self:child("PokemonRecovery-ProgressIndicator")
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.canHide == true then
      self:onHide()
    end
  end)
end

function M:onShow()
  UI:openWnd("pokemonRecovery")
  Me:playSoundByKey("cure_sound")
end

function M:onHide()
  Me:sendPacket({pid = "resetInNpc", value = 0})
  UI:closeWnd("pokemonRecovery")
end

function M:onOpen()
  self.stTitle:SetText(Lang:toText("recovering"))
  self.btnClose:SetVisible(false)
  self.pbIndicator:SetVisible(true)
  self.siProgressBG:SetImage("set:pokemon_npc.json image:npc_interaction_recovering")
  self.pbIndicator:SetProgress(0)
  self.progressTimer = LuaTimer:scheduleTimer(function()
    self.curProgress = self.curProgress + self.delta
    self.pbIndicator:SetProgress(self.curProgress)
  end, 100, World.cfg.recoveryAnimationTime * 10)
  self.recoveryTimer = LuaTimer:schedule(function()
    self:finishRecovery()
  end, World.cfg.recoveryAnimationTime * 1000)
end

function M:onClose()
  self.canHide = false
  self.curProgress = 0
  self.delta = 0.05
  if self.closeTimer then
    LuaTimer:cancel(self.closeTimer)
    self.closeTimer = nil
  end
  if self.recoveryTimer then
    LuaTimer:cancel(self.recoveryTimer)
    self.recoveryTimer = nil
  end
  if self.progressTimer then
    LuaTimer:cancel(self.progressTimer)
    self.progressTimer = nil
  end
end

function M:finishRecovery()
  self.canHide = true
  self.stTitle:SetText(Lang:toText("recovered"))
  self.btnClose:SetVisible(true)
  self.pbIndicator:SetVisible(false)
  self.siProgressBG:SetImage("set:pokemon_npc.json image:npc_interaction_recoverfull")
  self.closeTimer = LuaTimer:schedule(function()
    self:onHide()
  end, 2000)
end

return M
