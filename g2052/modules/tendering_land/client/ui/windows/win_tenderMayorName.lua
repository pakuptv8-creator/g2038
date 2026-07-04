local WinTenderMayorName = M

function WinTenderMayorName:init()
  WinBase.init(self, "TenderMayorName.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTenderMayorName:initUI()
  self.txtPlayerName = self:child("TenderMayorName-PlayerName")
end

function WinTenderMayorName:initEvent()
end

function WinTenderMayorName:subscribeEvent()
end

function WinTenderMayorName:initView()
end

function WinTenderMayorName:updateNameInfo(name)
  self.txtPlayerName:SetText(name)
end

function WinTenderMayorName:onHide()
  UI:closeWnd("tenderMayorName")
end

function WinTenderMayorName:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("tenderMayorName")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTenderMayorName:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinTenderMayorName:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinTenderMayorName
