local WinPartContentView = M

function WinPartContentView:init()
  WinBase.init(self, "PartContentView.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPartContentView:initUI()
  self.imgContentPanel = self:child("PartContentView-ContentPanel")
  self.lytBackPanel = self:child("PartContentView-BackPanel")
  self.txtContentStr = self:child("PartContentView-ContentStr")
  self.txtSignStr = self:child("PartContentView-SignStr")
end

function WinPartContentView:initEvent()
end

function WinPartContentView:subscribeEvent()
end

function WinPartContentView:initView(uiParams)
  self.uiParams = uiParams
  self._root:SetWidth({
    0,
    uiParams.width
  })
  self._root:SetHeight({
    0,
    uiParams.height
  })
  self:updateContentShow(uiParams.info)
end

function WinPartContentView:updateContentShow(info)
  self.info = info
  self.txtContentStr:SetText(Lang:toText(self.info.contentTxt))
  self.txtContentStr:SetTextColor(self.info.contentColor)
  self.txtSignStr:SetText(self.info.signName)
  self.txtSignStr:SetTextColor(self.info.signColor)
  if self.info.bgColor then
    self.lytBackPanel:SetVisible(true)
    self.lytBackPanel:SetBackgroundColor(self.info.bgColor)
  else
    self.lytBackPanel:SetVisible(false)
  end
end

function WinPartContentView:onHide()
  UI:closeWnd("partContentView")
end

function WinPartContentView:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("partContentView")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPartContentView:onOpen(uiParams)
  self:initView(uiParams)
  self:subscribeEvent()
end

function WinPartContentView:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinPartContentView
