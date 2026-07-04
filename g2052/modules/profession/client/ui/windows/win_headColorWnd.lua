local WinHeadColorWnd = M

function WinHeadColorWnd:init()
  WinBase.init(self, "HeadColorWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinHeadColorWnd:initUI()
  self.imgPanel = self:child("HeadColorWnd-Panel")
  self.txtTitle = self:child("HeadColorWnd-title")
  self.btnClose = self:child("HeadColorWnd-Close")
  self.lytContentPanel = self:child("HeadColorWnd-ContentPanel")
  self.btnConfirm = self:child("HeadColorWnd-Confirm")
  self.btnCancel = self:child("HeadColorWnd-Cancel")
  self.editEditPanel = self:child("HeadColorWnd-EditPanel")
  self.editEditPanel:SetProperty("MaxTextLength", 100)
  self.txtTipsText = self:child("HeadColorWnd-TipsText")
  self.txtTipsText:SetVisible(false)
  self.txtTipsText:SetText(Lang:toText("g2052.gui.click.input.click"))
  self.gvColorList = UIMgr:new_widget("grid_view")
  self.lytContentPanel:AddChildWindow(self.gvColorList)
  self.gvColorList:SethScorllMoveAble(true)
  self.gvColorList:SetvScorllMoveAble(false)
  self.gvColorList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvColorList:InitConfig(0, 0, 1)
  self.colorCells = {}
  self.btnConfirm:SetText(Lang:toText("g2052.gui.confirm"))
  self.btnCancel:SetText(Lang:toText("g2052.gui.cancel"))
  self:updateColoristShow()
end

function WinHeadColorWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    if self.headEditType == Define.HeadEditType.Name then
      UI:getWnd("professionWnd"):setNameContent(self.curContentText)
      UI:getWnd("professionWnd"):setNameColor(self.curContentColor)
      UI:getWnd("professionWnd"):updatePlayerHeadViewShow()
      Me:setNameContent(self.curContentText)
      Me:setNameColor(self.curContentColor)
    elseif self.headEditType == Define.HeadEditType.Introduce then
      UI:getWnd("professionWnd"):setIntroduceContent(self.curContentText)
      UI:getWnd("professionWnd"):setIntroduceColor(self.curContentColor)
      UI:getWnd("professionWnd"):updatePlayerHeadViewShow()
      Me:setIntroduceContent(self.curContentText)
      Me:setIntroduceColor(self.curContentColor)
    elseif self.headEditType == Define.HeadEditType.BillboardData then
      Me:setBillboardInfo(self.curContentText)
      Me:setBillboardColor(self.curContentColor)
      Plugins.CallTargetPluginFunc("report", "report", "item_write", nil, Me)
    elseif self.headEditType == Define.HeadEditType.ShopCarName then
      Me:setShopCarName(self.curContentText)
      Me:setShopCarNameColor(self.curContentColor)
    end
    if self.inputCallback then
      self.inputCallback(self.curContentText, self.curContentColor)
    end
    self:onHide()
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.editEditPanel, UIEvent.EventEditTextInput, function()
    local inputText = self.editEditPanel:GetPropertyString("Text", "")
    self:dealInputContent(inputText)
  end)
  self:subscribe(self.editEditPanel, UIEvent.EventWindowTouchDown, function()
    self:updateTipsShow(true)
  end)
  self:subscribe(self.editEditPanel, UIEvent.EventWindowTouchUp, function()
    self:updateTipsShow()
  end)
end

function WinHeadColorWnd:subscribeEvent()
end

function WinHeadColorWnd:updateColoristShow()
  local data = World.cfg.professionSetting.CareerNameColor
  if data and type(data) == "table" then
    self.gvColorList:InitConfig(10, 0, #data)
    for index, value in ipairs(data or {}) do
      if not self.colorCells[index] then
        local cell = UIMgr:new_widget("headColorItem")
        cell:invoke("updateInfo", value)
        cell:invoke("updateColorSelectState", false)
        cell:invoke("setClickBackFunc", function(color)
          self:updateCurSelectColor(color)
        end)
        self.gvColorList:AddItem(cell)
        self.colorCells[index] = cell
      end
    end
  end
end

function WinHeadColorWnd:initView(headEditType, inputCallback, initContent, initColor)
  self.headEditType = headEditType
  self.inputCallback = inputCallback
  if self.headEditType == Define.HeadEditType.Name then
    self.txtTitle:SetText(Lang:toText("g2052.gui.profession.color_name"))
    self.curContentText = UI:getWnd("professionWnd"):getNameContent()
    self.curContentColor = UI:getWnd("professionWnd"):getNameColor()
  elseif self.headEditType == Define.HeadEditType.Introduce then
    self.txtTitle:SetText(Lang:toText("g2052.gui.profession.color_introduce"))
    self.curContentText = UI:getWnd("professionWnd"):getIntroduceContent()
    self.curContentColor = UI:getWnd("professionWnd"):getIntroduceColor()
  elseif self.headEditType == Define.HeadEditType.ChildName then
    self.txtTitle:SetText(Lang:toText("g2052.gui.child.edit.name"))
    self.curContentText = Me:getPetName()
    self.curContentColor = Me:getPetNameColor()
  elseif self.headEditType == Define.HeadEditType.BillboardData then
    self.txtTitle:SetText(Lang:toText("g2052.gui.billboard.edit"))
    self.curContentText = Me:getBillboardInfo()
    self.curContentColor = Me:getBillboardColor()
  elseif self.headEditType == Define.HeadEditType.HouseDec then
    self.txtTitle:SetText(Lang:toText("g2052.gui.house.brief.introduction"))
    local houseInfo = Me:getOwnHouseInfo() or {}
    self.curContentText = houseInfo.doorplateText
    self.curContentColor = houseInfo.doorplateTextColor or "FFFFFF"
  elseif self.headEditType == Define.HeadEditType.ShopCarName then
    self.txtTitle:SetText(Lang:toText("g2052.gui.shopcarname.edit"))
    self.curContentText = Me:getShopCarName() or ""
    self.curContentColor = Me:getShopCarNameColor() or "FFFFFF"
  elseif self.headEditType == Define.HeadEditType.PartContent then
    self.txtTitle:SetText(Lang:toText("g2052.gui.part.content.bottom_title"))
    self.curContentText = initContent or ""
    self.curContentColor = initColor or "000000"
  end
  self:updateCurSelectColor(self.curContentColor)
end

function WinHeadColorWnd:updateCurSelectColor(color)
  local data = World.cfg.professionSetting.CareerNameColor
  for index, value in ipairs(data or {}) do
    if self.colorCells[index] then
      if value == color then
        self.colorCells[index]:invoke("updateColorSelectState", true)
      else
        self.colorCells[index]:invoke("updateColorSelectState", false)
      end
    end
  end
  self.curContentColor = color
  self:updateContentShow()
end

function WinHeadColorWnd:updateContentShow()
  self.editEditPanel:SetProperty("Text", self.curContentText)
  if self.curContentColor then
    self.editEditPanel:SetTextColor(Lib.getTextColor(self.curContentColor))
    self.txtTipsText:SetTextColor(Lib.getTextColor(self.curContentColor))
  end
  self:updateTipsShow()
end

function WinHeadColorWnd:updateTipsShow(needHide)
  if needHide then
    self.txtTipsText:SetVisible(false)
  elseif self.curContentText == "" then
    self.txtTipsText:SetVisible(true)
  else
    self.txtTipsText:SetVisible(false)
  end
end

function WinHeadColorWnd:getOneShortContent(content)
  local endIndex = Lib.subStringGetTotalIndex(content)
  local maxLen = 10
  if self.headEditType == Define.HeadEditType.Name then
    maxLen = World.cfg.professionSetting.CareerNameLen or 10
  elseif self.headEditType == Define.HeadEditType.BillboardData then
    maxLen = World.cfg.sceneBillUI.textLen or 10
  elseif self.headEditType == Define.HeadEditType.PartContent then
    maxLen = 100
  else
    maxLen = World.cfg.professionSetting.CareerIntroduceLen or 10
  end
  if endIndex > maxLen then
    local content = Lib.subStringUTF8(content, 1, maxLen)
    return content .. "..."
  end
  return content
end

function WinHeadColorWnd:dealInputContent(inputText)
  local content = World.CurWorld:filterWord(inputText)
  self.curContentText = self:getOneShortContent(content)
  self:updateContentShow()
end

function WinHeadColorWnd:onHide()
  UI:closeWnd("headColorWnd")
end

function WinHeadColorWnd:onShow(isShow, headEditType, inputCallback, initContent, initColor)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("headColorWnd", headEditType, inputCallback, initContent, initColor)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinHeadColorWnd:onOpen(headEditType, inputCallback, initContent, initColor)
  self:initView(headEditType, inputCallback, initContent, initColor)
  self:subscribeEvent()
end

function WinHeadColorWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinHeadColorWnd
