local WinPartContentEdit = M

function WinPartContentEdit:init()
  WinBase.init(self, "PartContentEdit.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPartContentEdit:initUI()
  self.lytContentPanel = self:child("PartContentEdit-ContentPanel")
  self.imgContentBg = self:child("PartContentEdit-ContentBg")
  self.txtTitleText = self:child("PartContentEdit-TitleText")
  self.lytColorPanel = self:child("PartContentEdit-ColorPanel")
  self.btnClose = self:child("PartContentEdit-Close")
  self.lytItemPanel1 = self:child("PartContentEdit-ItemPanel1")
  self.imgItemBg1 = self:child("PartContentEdit-itemBg1")
  self.imgItemSelect1 = self:child("PartContentEdit-itemSelect1")
  self.txtTitleStr1 = self:child("PartContentEdit-TitleStr1")
  self.lytItemPanel2 = self:child("PartContentEdit-ItemPanel2")
  self.imgItemBg2 = self:child("PartContentEdit-itemBg2")
  self.imgItemSelect2 = self:child("PartContentEdit-itemSelect2")
  self.txtTitleStr2 = self:child("PartContentEdit-TitleStr2")
  self.editEditContent = self:child("PartContentEdit-EditContent")
  self.txtEditText = self:child("PartContentEdit-EditText")
  self.txtEditText:SetText("")
  self.btnConfirmBtn = self:child("PartContentEdit-ConfirmBtn")
  self.txtConfirmTxt = self:child("PartContentEdit-ConfirmTxt")
  
  local function colorBackFunc(selectColor)
    self:updateColorSelect(selectColor)
  end
  
  self.colorPalette = UIMgr:new_widget("colorPaletteWidget", colorBackFunc)
  self.colorPalette:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytColorPanel:AddChildWindow(self.colorPalette)
  self.txtConfirmTxt:SetText(Lang:toText("g2052.gui.confirm"))
  self.txtTitleText:SetText(Lang:toText("g2052.gui.part.content.title"))
  self.txtTitleStr2:SetText(Lang:toText("g2052.gui.part.content.bottom_title"))
  self.txtTitleStr1:SetText(Lang:toText("g2052.gui.part.content.top_title"))
end

function WinPartContentEdit:initEvent()
  self:subscribe(self.btnConfirmBtn, UIEvent.EventButtonClick, function()
    if self.haveChange then
      local packet = {
        pid = "RequestChangePartContent",
        mapName = self.mapName,
        partId = self.info.partId,
        contentTxt = self.sendDescText,
        signName = Me:getNameContent(),
        signColor = Lib.getTextColor(Me:getNameColor()),
        bgColor = self.bgColor,
        contentColor = self.contentColor
      }
      Me:sendPacket(packet)
    end
    self:onHide()
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytItemPanel1, UIEvent.EventWindowClick, function()
    self.curSelectId = 1
    self:updateItemSelectShow()
  end)
  self:subscribe(self.lytItemPanel2, UIEvent.EventWindowClick, function()
    self.curSelectId = 2
    self:updateItemSelectShow()
  end)
  self:subscribe(self.editEditContent, UIEvent.EventEditTextInput, function()
    self.sendDescText = string.format(self.editEditContent:GetPropertyString("Text", ""))
    self.txtEditText:SetText(self.sendDescText)
    self.editEditContent:SetProperty("Text", "")
    self.firstIntoDescUp = false
    self.haveChange = true
  end)
  self:subscribe(self.editEditContent, UIEvent.EventWindowTouchUp, function()
    if self.firstIntoDescUp then
      self.editEditContent:SetProperty("Text", self.sendDescText)
      self.firstIntoDescUp = false
    else
      self.editEditContent:SetProperty("Text", "")
      self.firstIntoDescUp = true
    end
  end)
  self:subscribe(self.editEditContent, UIEvent.EventMotionRelease, function()
    self.editEditContent:SetProperty("Text", "")
    self.firstIntoDescUp = true
  end)
end

function WinPartContentEdit:subscribeEvent()
end

function WinPartContentEdit:updateColorSelect(selectColor)
  if self.curSelectId == 1 then
    self.bgColor = selectColor
  else
    self.contentColor = selectColor
  end
  self:updateItemColor()
  self.haveChange = true
end

function WinPartContentEdit:updateItemSelectShow()
  if self.curSelectId == 1 then
    self.imgItemSelect2:SetVisible(false)
    self.imgItemSelect1:SetVisible(true)
  else
    self.imgItemSelect1:SetVisible(false)
    self.imgItemSelect2:SetVisible(true)
  end
end

function WinPartContentEdit:updateItemColor()
  self.imgItemBg1:SetDrawColor(self.bgColor)
  self.imgItemBg2:SetDrawColor(self.contentColor)
  self.txtEditText:SetTextColor(self.contentColor)
end

function WinPartContentEdit:initView(uiParams, mapName)
  self.mapName = mapName
  self.info = uiParams.info
  self.haveChange = false
  self.curSelectId = 2
  self:updateItemSelectShow()
  self.bgColor = self.info.bgColor
  self.contentColor = self.info.contentColor
  self:updateItemColor()
  self.editEditContent:SetProperty("Text", "")
  self.sendDescText = Lang:toText(self.info.contentTxt)
  self.txtEditText:SetText(self.sendDescText)
  self.txtEditText:SetTextColor(self.contentColor)
  self.txtEditText:SetVisible(true)
  self.firstIntoDescUp = true
end

function WinPartContentEdit:onHide()
  UI:closeWnd("partContentEdit")
end

function WinPartContentEdit:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("partContentEdit")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPartContentEdit:onOpen(uiParams, mapName)
  self:initView(uiParams, mapName)
  self:subscribeEvent()
end

function WinPartContentEdit:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinPartContentEdit
