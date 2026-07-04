local WinGM = M

function WinGM:init()
  WinBase.init(self, "GM.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinGM:initUI()
  self:addGM()
end

function WinGM:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_GM_BTN, function()
    self:addGM(true)
  end)
end

function WinGM:subscribeEvent()
end

function WinGM:addGM(isMust)
  if self.btn then
    return
  end
  if not World.gameCfg.gm and not isMust then
    return
  end
  local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "Button_GM")
  btn:SetNormalImage("set:add_sub.json image:add")
  btn:SetPushedImage("set:add_sub.json image:add")
  btn:SetArea({0.5, 0}, {0, 0}, {0, 30}, {0, 30})
  self:root():AddChildWindow(btn)
  self:subscribe(btn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end)
  self.btn = btn
end

function WinGM:onHide()
  UI:closeWnd("gm")
end

function WinGM:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("gm")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGM:onOpen()
  self:subscribeEvent()
end

function WinGM:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinGM
