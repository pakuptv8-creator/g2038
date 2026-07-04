local WinDramaTemplateInfo = M
local DramaClientHelper = T(Lib, "DramaClientHelper")
local DramaTemplateConfig = T(Config, "DramaTemplateConfig")

function WinDramaTemplateInfo:init()
  WinBase.init(self, "DramaTemplateInfo.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaTemplateInfo:initUI()
  self.lytMainPanel = self:child("DramaTemplateInfo-MainPanel")
  self.imgTopBg = self:child("DramaTemplateInfo-TopBg")
  self.txtTitleText = self:child("DramaTemplateInfo-TitleText")
  self.imgContentBg = self:child("DramaTemplateInfo-ContentBg")
  self.btnCloseBtn = self:child("DramaTemplateInfo-CloseBtn")
  self.btnEnterBtn = self:child("DramaTemplateInfo-EnterBtn")
  self.txtDescText = self:child("DramaTemplateInfo-DescText")
  self.lytCoverPanel = self:child("DramaTemplateInfo-CoverPanel")
  self.lytDotPanel = self:child("DramaTemplateInfo-DotPanel")
  self.imgDotIcon1 = self:child("DramaTemplateInfo-DotIcon1")
  self.imgDotSelect1 = self:child("DramaTemplateInfo-DotSelect1")
  self.imgDotIcon2 = self:child("DramaTemplateInfo-DotIcon2")
  self.imgDotSelect2 = self:child("DramaTemplateInfo-DotSelect2")
  self.lytNamePanel = self:child("DramaTemplateInfo-NamePanel")
  self.txtNameText = self:child("DramaTemplateInfo-NameText")
  self.imgNumIcon = self:child("DramaTemplateInfo-NumIcon")
  self.txtNumText = self:child("DramaTemplateInfo-NumText")
  self.txtPlayerName = self:child("DramaTemplateInfo-PlayerName")
  self.imgTemplateBgList = {}
  self.imgTemplateBgList[1] = self:child("DramaTemplateInfo-TemplateBg_1")
  self.imgTemplateBgList[2] = self:child("DramaTemplateInfo-TemplateBg_2")
  self.txtTemplateNameList = {}
  self.txtTemplateNameList[1] = self:child("DramaTemplateInfo-TemplateName_1")
  self.txtTemplateNameList[2] = self:child("DramaTemplateInfo-TemplateName_2")
  self.coverPageWidth = 465
  self.coverGridView = UIMgr:new_widget("grid_view")
  self.lytCoverPanel:AddChildWindow(self.coverGridView)
  self.coverGridView:SethScorllMoveAble(true)
  self.coverGridView:SetvScorllMoveAble(false)
  self.coverGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.coverGridView:InitConfig(0, 0, 1)
  self.coverCells = {}
  self.btnEnterBtn:SetText(Lang:toText("g2052.gui.drama.join"))
end

function WinDramaTemplateInfo:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnEnterBtn, UIEvent.EventButtonClick, function()
    if not self.data or not self.data.id then
      return
    end
    Me:requestJoinDrama(self.data.id)
    self:onHide()
  end)
  self:subscribe(self.coverGridView, UIEvent.EventWindowTouchDown, function()
    self.touchStartOffset = self.coverGridView:GetScrollOffset()
  end)
end

function WinDramaTemplateInfo:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_DETAIL_INFO, function(id, data)
    if self.data.id == id then
      self:updateViewInfo(data)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_WND_INFO, function()
    Me:requestDramaDetailInfo(self.data.id)
  end)
end

function WinDramaTemplateInfo:initView(data)
  self.data = data
  if DramaClientHelper.curDramaInfo and DramaClientHelper.curDramaInfo.id == self.data.id then
    self.btnEnterBtn:SetVisible(false)
  else
    self.btnEnterBtn:SetVisible(true)
  end
  if data and data.id then
    self:updateViewInfo()
    Me:requestDramaDetailInfo(self.data.id)
  end
end

function WinDramaTemplateInfo:updateViewInfo()
  self.txtNameText:SetText(Lang:toText(self.data.scriptName))
  self.txtDescText:SetText(Lang:toText(self.data.summary))
  self.txtNumText:SetText(self.data.currentNumber .. "/" .. self.data.maxNumber)
  self.txtPlayerName:SetText(self.data.nickName or "")
  self.txtTitleText:SetText(Lang:toText({
    "g2052.gui.drama.detail.title1",
    self.data.nickName or ""
  }))
  if not self.data.modList then
    self.data.modList = DramaClientHelper:dealScriptDataToModList(self.data.scriptData)
  end
  self:initModCoverShow(self.data.modList or {})
  self:startAutoRefreshTimer()
end

function WinDramaTemplateInfo:initModCoverShow(modList)
  self.modInfo = {}
  for key, val in pairs(modList) do
    local temp = DramaTemplateConfig:getCfgById(val)
    if temp then
      table.insert(self.modInfo, temp)
    end
  end
  self.totalPage = #self.modInfo
  if self.totalPage > 1 then
    self.lytDotPanel:SetVisible(true)
    self.coverGridView:InitConfig(0, 0, self.totalPage)
    self:updatePointSelectState(1)
    self.coverGridView:SetMoveAble(true)
    self.needAutoMove = true
  else
    self.lytDotPanel:SetVisible(false)
    self.coverGridView:InitConfig(0, 0, 1)
    self.coverGridView:SetMoveAble(false)
  end
  for i, cell in pairs(self.coverCells or {}) do
    if i > self.totalPage then
      self.coverGridView:RemoveItem(cell)
      self.coverCells[i] = nil
    end
  end
  for index, value in ipairs(self.modInfo or {}) do
    if not self.coverCells[index] then
      local cell = UIMgr:new_widget("dramaTemplateCover")
      cell:invoke("updateCoverIcon", value.img)
      self.coverGridView:AddItem(cell)
      self.coverCells[index] = cell
    else
      self.coverCells[index]:invoke("updateCoverIcon", value.img)
    end
  end
  self.coverGridView:ResetPos()
  self:initTemplateName()
end

function WinDramaTemplateInfo:initTemplateName()
  for i, imgTemplate in pairs(self.imgTemplateBgList) do
    local inf = self.modInfo and self.modInfo[i]
    if inf then
      imgTemplate:SetVisible(true)
      local txtName = self.txtTemplateNameList[i]
      if txtName then
        txtName:SetText(Lang:toText(inf.templateName))
      end
    else
      imgTemplate:SetVisible(false)
    end
  end
end

function WinDramaTemplateInfo:updatePointSelectState(curIndex)
  if self.modInfo[curIndex] then
    if curIndex == 1 then
      self.imgDotSelect1:SetVisible(true)
      self.imgDotSelect2:SetVisible(false)
      self.coverGridView:SetScrollOffset(0)
    else
      self.imgDotSelect1:SetVisible(false)
      self.imgDotSelect2:SetVisible(true)
      self.coverGridView:SetScrollOffset(-self.coverPageWidth)
    end
  else
    self.lytDotPanel:SetVisible(false)
    self.coverGridView:SetScrollOffset(0)
  end
  self.curShowPage = curIndex
end

function WinDramaTemplateInfo:startAutoRefreshTimer()
  self:stopAutoRefreshTimer()
  local waitTime = math.floor(World.cfg.dramaSetting.modFreshTime * 20)
  local moveTime = math.floor(World.cfg.dramaSetting.modMoveTime * 20)
  self.refreshPassTime = 0
  self.touchStartOffset = nil
  self.endOffset = nil
  self.startOffset = nil
  self.refreshTimer = World.Timer(1, function()
    self.updatePassTime = self.updatePassTime + 1
    if self.updatePassTime >= World.cfg.dramaSetting.refreshTime * 20 then
      Me:requestDramaDetailInfo(self.data.id)
      self.updatePassTime = 0
    end
    if self.needAutoMove and 1 < self.totalPage then
      self.refreshPassTime = self.refreshPassTime + 1
      if self.touchStartOffset then
        self:checkNextMoveOffset()
      elseif self.endOffset then
        local result = self.startOffset + (self.endOffset - self.startOffset) * self.refreshPassTime / moveTime
        self.coverGridView:SetScrollOffset(math.floor(result))
        if self.refreshPassTime >= moveTime then
          self:moveEndUpdateShowPage()
        end
      elseif self.refreshPassTime >= waitTime then
        self:checkNextMoveOffset()
      end
    end
    return true
  end)
end

function WinDramaTemplateInfo:checkNextMoveOffset()
  self.coverGridView:SetMoveAble(false)
  self.startOffset = self.coverGridView:GetScrollOffset()
  if self.curShowPage == 1 then
    self.endOffset = -self.coverPageWidth
  else
    self.endOffset = 0
  end
  self.refreshPassTime = 0
  self.touchStartOffset = nil
end

function WinDramaTemplateInfo:moveEndUpdateShowPage()
  self.refreshPassTime = 0
  if self.totalPage > 1 then
    self.coverGridView:SetMoveAble(true)
  end
  if self.curShowPage == 1 then
    self:updatePointSelectState(2)
  else
    self:updatePointSelectState(1)
  end
  self.endOffset = nil
  self.startOffset = nil
  self.touchStartOffset = nil
end

function WinDramaTemplateInfo:stopAutoRefreshTimer()
  if self.refreshTimer then
    self.refreshTimer()
    self.refreshTimer = nil
  end
  self.updatePassTime = 0
  self.refreshPassTime = 0
end

function WinDramaTemplateInfo:onHide()
  UI:closeWnd("dramaTemplateInfo")
end

function WinDramaTemplateInfo:onShow(isShow, data)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaTemplateInfo", data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaTemplateInfo:onOpen(data)
  self:initView(data)
  self:subscribeEvent()
end

function WinDramaTemplateInfo:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopAutoRefreshTimer()
end

return WinDramaTemplateInfo
