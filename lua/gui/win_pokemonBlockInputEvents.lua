local recordTimerCallback

function M:init()
  WinBase.init(self, "PokemonBlockInputEvents.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
end

function M:initWnd()
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonBlockInputEvents _root event : EventWindowClick", self._root, UIEvent.EventWindowClick, function(window, dx, dy)
    Lib.logInfo("click block input events")
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBlockInputEvents Lib event : EVENT_OPEN_BLOCK_INPUT", Event.EVENT_OPEN_BLOCK_INPUT, function(value)
    if not UI:isOpen("pokemonBlockInputEvents") then
      self.onShow()
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBlockInputEvents Lib event : EVENT_HIDE_BLOCK_INPUT", Event.EVENT_HIDE_BLOCK_INPUT, function(value)
    if UI:isOpen("pokemonBlockInputEvents") then
      self.onHide()
    end
  end)
end

function M:onShow()
  UI:openWnd("pokemonBlockInputEvents")
end

function M:onHide()
  UI:closeWnd("pokemonBlockInputEvents")
end

function M:onOpen()
  self.clickCount = 5
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
end

function M:onClose()
end

return M
