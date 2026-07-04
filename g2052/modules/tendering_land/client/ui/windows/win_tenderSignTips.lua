local WinTenderSignTips = M

function WinTenderSignTips:init()
  WinBase.init(self, "TenderSignTips.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTenderSignTips:initUI()
  self.imgContent = self:child("TenderSignTips-Content")
  self.imgTopBar = self:child("TenderSignTips-TopBar")
  self.txtTitle = self:child("TenderSignTips-Title")
  self.btnBtnClose = self:child("TenderSignTips-BtnClose")
  self.lytInfoPanel = self:child("TenderSignTips-InfoPanel")
  self.txtDescText = self:child("TenderSignTips-DescText")
  self.txtTitle:SetText(Lang:toText("g2052.gui.tendering.tips"))
  self.gvDescTxt = UIMgr:new_widget("grid_view")
  self.lytInfoPanel:AddChildWindow(self.gvDescTxt)
  self.gvDescTxt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDescTxt:SetAutoColumnCount(false)
  self.gvDescTxt:InitConfig(0, 10, 1)
  self.gvDescTxt:AddItem(self.txtDescText)
end

function WinTenderSignTips:initEvent()
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinTenderSignTips:subscribeEvent()
end

function WinTenderSignTips:initView(content)
  self.txtDescText:SetText(Lang:toText(content))
end

function WinTenderSignTips:onHide()
  UI:closeWnd("tenderSignTips")
end

function WinTenderSignTips:onShow(isShow, content)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("tenderSignTips", content)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTenderSignTips:onOpen(content)
  self:initView(content)
  self:subscribeEvent()
end

function WinTenderSignTips:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinTenderSignTips
