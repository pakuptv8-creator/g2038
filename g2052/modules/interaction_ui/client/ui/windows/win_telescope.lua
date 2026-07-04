local WinTelescope = M

function WinTelescope:init()
  WinBase.init(self, "Telescope.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTelescope:initUI()
  self.imgImage = self:child("Telescope-Image")
end

function WinTelescope:initEvent()
  Lib.subscribeEvent(Event.EVENT_UPDATE_TELESCOPE_UI, function(isOpen)
    self:onShow(isOpen)
  end)
end

function WinTelescope:subscribeEvent()
end

function WinTelescope:initView()
end

function WinTelescope:onHide()
  UI:closeWnd("telescope")
end

function WinTelescope:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("telescope")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTelescope:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinTelescope:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinTelescope
