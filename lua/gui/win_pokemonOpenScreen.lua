local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonOpenScreen.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.canHide = false
end

function M:initWnd()
  self.stTip = self:child("PokemonOpenScreen-Tip")
  self.stTip:SetText(Lang:toText("gui.openscreen.tip"))
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.canHide == true then
      self:onHide()
    end
  end)
end

function M:onShow()
  UI:openWnd("pokemonOpenScreen")
  self.closeTimer = LuaTimer:schedule(function()
    self.canHide = true
  end, 2000)
end

function M:onHide()
  UI:closeWnd("pokemonOpenScreen")
end

function M:onOpen()
  Lib.logDebug("onOpen")
end

function M:onClose()
  Lib.logDebug("onClose")
  self.canHide = false
  if self.closeTimer then
    LuaTimer:cancel(self.closeTimer)
    self.closeTimer = nil
  end
end

return M
