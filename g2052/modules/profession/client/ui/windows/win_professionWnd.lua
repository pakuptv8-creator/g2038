local WinProfessionWnd = M
local ProfessionConfig = T(Config, "ProfessionConfig")

function WinProfessionWnd:init()
  WinBase.init(self, "ProfessionWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinProfessionWnd:initUI()
  self.lytMask = self:child("ProfessionWnd-mask")
  self.imgPanel = self:child("ProfessionWnd-Panel")
  self.txtTitle = self:child("ProfessionWnd-title")
  self.lytContentPanel = self:child("ProfessionWnd-ContentPanel")
  self.btnClose = self:child("ProfessionWnd-Close")
  self.lytNamePanel = self:child("ProfessionWnd-NamePanel")
  self.imgNameBg = self:child("ProfessionWnd-NameBg")
  self.txtNameText = self:child("ProfessionWnd-NameText")
  self.txtNameTitle = self:child("ProfessionWnd-NameTitle")
  self.btnNamePen = self:child("ProfessionWnd-NamePen")
  self.lytIntroducePanel = self:child("ProfessionWnd-IntroducePanel")
  self.imgIntroduceBg = self:child("ProfessionWnd-IntroduceBg")
  self.txtIntroduceText = self:child("ProfessionWnd-IntroduceText")
  self.txtIntroduceTitle = self:child("ProfessionWnd-IntroduceTitle")
  self.btnIntroducePen = self:child("ProfessionWnd-IntroducePen")
  self.btnCancelPro = self:child("ProfessionWnd-CancelPro")
  self.btnIgnoreCallBtn = self:child("ProfessionWnd-IgnoreCallBtn")
  self.imgIgnoreCallIcon = self:child("ProfessionWnd-IgnoreCallIcon")
  self.imgReceiveCallIcon = self:child("ProfessionWnd-ReceiveCallIcon")
  Me.isIgnorePhoneCall = false
  self:updateIgnoreIconShow()
  self:initAdapter()
  self.txtTitle:SetText(Lang:toText("g2052.gui.profession.main_title"))
  self.txtNameTitle:SetText(Lang:toText("g2052.gui.profession.main_name"))
  self.txtIntroduceTitle:SetText(Lang:toText("g2052.gui.profession.main_introduce"))
end

function WinProfessionWnd:initAdapter()
  local params = {
    xDis = 4,
    yDis = 4,
    xCellNum = 3,
    widgetWidth = 88,
    widgetHeight = 110,
    widgetJson = "ProfessionItem.json",
    widgetName = "professionItem",
    gvParent = self.lytContentPanel,
    dataList = {}
  }
  self.professionListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.professionListView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(true)
  self.professionAdapter = self.professionListView:getAdapter()
end

function WinProfessionWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnIgnoreCallBtn, UIEvent.EventButtonClick, function()
    Me.isIgnorePhoneCall = not Me.isIgnorePhoneCall
    if Me.isIgnorePhoneCall then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.phone.ignore_call")
    end
    self:updateIgnoreIconShow()
  end)
  self:subscribe(self.btnCancelPro, UIEvent.EventButtonClick, function()
    Me:clientSetProfession(Define.CareerType.Base)
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    Me:simulationClickOnScene()
    self:onHide()
  end)
  self:subscribe(self.lytNamePanel, UIEvent.EventWindowClick, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.Name)
  end)
  self:subscribe(self.btnNamePen, UIEvent.EventButtonClick, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.Name)
  end)
  self:subscribe(self.lytIntroducePanel, UIEvent.EventWindowClick, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.Introduce)
  end)
  self:subscribe(self.btnIntroducePen, UIEvent.EventButtonClick, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.Introduce)
  end)
end

function WinProfessionWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PROFESSION_UPDATE_HEAD_NAME, function()
    self:updateNameShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PROFESSION_UPDATE_HEAD_INTRODUCE, function()
    self:updateIntroduceShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PROFESSION_UPDATE_CAREER, function()
    self.professionAdapter:notifyDataChange()
  end)
end

function WinProfessionWnd:initView()
  if not self.initGridView then
    self.initGridView = true
    self.curNameColor = Me:getNameColor() or ""
    self.curNameContent = Me:getNameContent() or ""
    self.curIntroduceColor = Me:getIntroduceColor() or ""
    self.curIntroduceContent = Me:getIntroduceContent() or ""
    self.curProfessionId = Me:getProfessionId() or 0
    local professionCfg = Lib.copy(ProfessionConfig:getAllNormalCfgs())
    self.professionAdapter:clearItems()
    self.professionListView:getGridView():ResetPos()
    local data = {}
    for _, val in pairs(professionCfg) do
      table.insert(data, val)
    end
    self.professionAdapter:setData(data)
  else
    self.professionAdapter:notifyDataChange()
  end
  self:updateNameShow()
  self:updateIntroduceShow()
end

function WinProfessionWnd:getNameColor()
  return self.curNameColor
end

function WinProfessionWnd:setNameColor(value)
  self.curNameColor = value
end

function WinProfessionWnd:getNameContent()
  return self.curNameContent
end

function WinProfessionWnd:setNameContent(value)
  self.curNameContent = value
end

function WinProfessionWnd:getIntroduceColor()
  return self.curIntroduceColor
end

function WinProfessionWnd:setIntroduceColor(value)
  self.curIntroduceColor = value
end

function WinProfessionWnd:getIntroduceContent()
  return self.curIntroduceContent
end

function WinProfessionWnd:setIntroduceContent(value)
  self.curIntroduceContent = value
end

function WinProfessionWnd:getCurProfessionId()
  return self.curProfessionId
end

function WinProfessionWnd:setCurProfessionId(value)
  self.curProfessionId = value
  UI:closeWnd("professionRecommend")
end

function WinProfessionWnd:updatePlayerHeadViewShow()
  Me:updateHeadNameShow(self.curProfessionId, self.curNameContent, self.curNameColor, self.curIntroduceContent, self.curIntroduceColor)
  self:updateNameShow()
  self:updateIntroduceShow()
  self.professionAdapter:notifyDataChange()
end

function WinProfessionWnd:updateNameShow()
  local color = self:getNameColor()
  local text = self:getNameContent()
  if text == "" then
    self.txtNameText:SetText(Lang:toText("g2052.gui.click.input.click"))
  else
    self.txtNameText:SetText(text)
  end
  self.txtNameText:SetTextColor(Lib.getTextColor(color))
end

function WinProfessionWnd:updateIntroduceShow()
  local color = self:getIntroduceColor()
  local text = self:getIntroduceContent()
  if text == "" then
    self.txtIntroduceText:SetText(Lang:toText("g2052.gui.click.input.click"))
  else
    self.txtIntroduceText:SetText(text)
  end
  self.txtIntroduceText:SetTextColor(Lib.getTextColor(color))
end

function WinProfessionWnd:updateIgnoreIconShow()
  if Me.isIgnorePhoneCall then
    self.imgIgnoreCallIcon:SetVisible(true)
    self.imgReceiveCallIcon:SetVisible(false)
  else
    self.imgIgnoreCallIcon:SetVisible(false)
    self.imgReceiveCallIcon:SetVisible(true)
  end
end

function WinProfessionWnd:onHide()
  UI:closeWnd("professionWnd")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinProfessionWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("professionWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinProfessionWnd:onOpen()
  Me:uiMutualExclusion("professionWnd")
  self:initView()
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
  Lib.emitEvent(Event.EVENT_PROFESSION_WIN_OPEN)
end

function WinProfessionWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
  UI:getWnd("professionRecommend"):onHide()
end

return WinProfessionWnd
