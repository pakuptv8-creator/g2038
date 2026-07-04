local WinDramaTemplateEdit = M
local DramaClientHelper = T(Lib, "DramaClientHelper")
local DramaTemplateConfig = T(Config, "DramaTemplateConfig")
local modCount = 2

function WinDramaTemplateEdit:init()
  WinBase.init(self, "DramaTemplateEdit.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaTemplateEdit:initUI()
  self.lytMainPanel = self:child("DramaTemplateEdit-MainPanel")
  self.imgTopBg = self:child("DramaTemplateEdit-TopBg")
  self.txtTitleText = self:child("DramaTemplateEdit-TitleText")
  self.imgContentBg = self:child("DramaTemplateEdit-ContentBg")
  self.btnCloseBtn = self:child("DramaTemplateEdit-CloseBtn")
  self.btnEnterBtn = self:child("DramaTemplateEdit-EnterBtn")
  self.btnChangeBtn = self:child("DramaTemplateEdit-ChangeBtn")
  self.txtDescText = self:child("DramaTemplateEdit-DescText")
  self.editDescEdit = self:child("DramaTemplateEdit-DescEdit")
  self.imgDescPen = self:child("DramaTemplateEdit-DescPen")
  self.lytCoverPanel = self:child("DramaTemplateEdit-CoverPanel")
  self.lytDotPanel = self:child("DramaTemplateEdit-DotPanel")
  self.imgDotIcon1 = self:child("DramaTemplateEdit-DotIcon1")
  self.imgDotSelect1 = self:child("DramaTemplateEdit-DotSelect1")
  self.imgDotIcon2 = self:child("DramaTemplateEdit-DotIcon2")
  self.imgDotSelect2 = self:child("DramaTemplateEdit-DotSelect2")
  self.lytNamePanel = self:child("DramaTemplateEdit-NamePanel")
  self.txtNameTitle = self:child("DramaTemplateEdit-NameTitle")
  self.imgNameBg = self:child("DramaTemplateEdit-NameBg")
  self.txtNameText = self:child("DramaTemplateEdit-NameText")
  self.imgNamePen = self:child("DramaTemplateEdit-NamePen")
  self.editNameEdit = self:child("DramaTemplateEdit-NameEdit")
  self.imgNumIcon = self:child("DramaTemplateEdit-NumIcon")
  self.imgNumBg = self:child("DramaTemplateEdit-NumBg")
  self.txtNumText = self:child("DramaTemplateEdit-NumText")
  self.imgNumShow = self:child("DramaTemplateEdit-NumShow")
  self.lytNumList = self:child("DramaTemplateEdit-NumList")
  self.imgModIcon2 = self:child("DramaTemplateEdit-ModIcon2")
  self.imgModIcon1 = self:child("DramaTemplateEdit-ModIcon1")
  self.lytMaskPanel = self:child("DramaTemplateEdit-MaskPanel")
  self.lytMaskPanel:SetVisible(false)
  self.coverPageWidth = 465
  self.modInfo = {}
  self.imgModKey = {}
  self.txtModName = {}
  self.lytModList = {}
  self.modListView = {}
  self.modGridView = {}
  for i = 1, modCount do
    self.imgModKey[i] = self:child("DramaTemplateEdit-ModKey" .. i)
    self.txtModName[i] = self:child("DramaTemplateEdit-ModName" .. i)
    self.lytModList[i] = self:child("DramaTemplateEdit-ModList" .. i)
    self.lytModList[i]:SetVisible(false)
    self:initModGridView(i)
  end
  self.lytNumList:SetVisible(false)
  self:initNumGridView()
  self.coverGridView = UIMgr:new_widget("grid_view")
  self.lytCoverPanel:AddChildWindow(self.coverGridView)
  self.coverGridView:SethScorllMoveAble(true)
  self.coverGridView:SetvScorllMoveAble(false)
  self.coverGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.coverGridView:InitConfig(0, 0, 1)
  self.coverCells = {}
  self.txtTitleText:SetText(Lang:toText("g2052.gui.drama.mine"))
  self.btnEnterBtn:SetText(Lang:toText("g2052.gui.drama.create"))
  self.btnChangeBtn:SetText(Lang:toText("g2052.gui.drama.amend"))
  self.dramaInfo = {}
end

function WinDramaTemplateEdit:initModGridView(index)
  local params = {
    xDis = 0,
    yDis = 5,
    xCellNum = 1,
    widgetWidth = 177,
    widgetHeight = 40,
    widgetJson = "DramaTemplateModItem.json",
    widgetName = "dramaTemplateModItem",
    gvParent = self.lytModList[index],
    dataList = DramaTemplateConfig:getAllCfgs(false, true),
    cellSelectedCb = function(data, dx, dy, idx)
      self.modList[index] = data.id
      self.lytModList[index]:SetVisible(false)
      self:initModCoverShow()
    end
  }
  self.modListView[index] = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.modGridView[index] = self.modListView[index]:getGridView()
  self.modGridView[index]:SetMoveAble(true)
  self.modGridView[index]:SetvScorllMoveAble(true)
  self.modGridView[index]:SetAutoColumnCount(false)
end

function WinDramaTemplateEdit:initNumGridView()
  local dataList = {}
  for i = World.cfg.dramaSetting.roleMinCount, World.cfg.dramaSetting.roleMaxCount do
    table.insert(dataList, i)
  end
  local params = {
    xDis = 0,
    yDis = 5,
    xCellNum = 1,
    widgetWidth = 162,
    widgetHeight = 40,
    widgetJson = "DramaTemplateNumItem.json",
    widgetName = "dramaTemplateNumItem",
    gvParent = self.lytNumList,
    dataList = dataList,
    cellSelectedCb = function(data, dx, dy, idx)
      self.lytNumList:SetVisible(false)
      self:updatePlayerNum(data)
    end
  }
  self.numListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.numGridView = self.numListView:getGridView()
  self.numGridView:SetMoveAble(true)
  self.numGridView:SetvScorllMoveAble(true)
  self.numGridView:SetAutoColumnCount(false)
end

function WinDramaTemplateEdit:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnEnterBtn, UIEvent.EventButtonClick, function()
    if self:isEditCustomMod() and not self.isChangeTitle then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.drama.title.tips"))
      return
    end
    self.dramaInfo.modList = {}
    for key, val in pairs(self.modInfo) do
      table.insert(self.dramaInfo.modList, val.id)
    end
    Me:requestCreateOneDrama(self.dramaInfo)
    self.dramaInfo = {}
    self:onHide()
  end)
  self:subscribe(self.btnChangeBtn, UIEvent.EventButtonClick, function()
    if self.initData then
      if self.lastAmendTime then
        local passTime = os.time() - self.lastAmendTime
        local remainTime = World.cfg.dramaSetting.amendCDTime - passTime
        if 0 < remainTime then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText({
            "g2052.gui.house.create.cd",
            remainTime
          }))
          return
        end
      end
      Me:requestAmendOneDrama(self.dramaInfo)
      self.lastAmendTime = os.time()
      self.initData = nil
      self.dramaInfo = {}
    end
    self:onHide()
  end)
  self:subscribe(self.coverGridView, UIEvent.EventWindowTouchDown, function()
    self.touchStartOffset = self.coverGridView:GetScrollOffset()
  end)
  self:subscribe(self.imgNumBg, UIEvent.EventWindowClick, function()
    self:closeAllListPanel()
    if self.lytNumList:IsVisible() then
      self:closeAllListPanel()
    else
      self.lytNumList:SetVisible(true)
      self.lytMaskPanel:SetVisible(true)
    end
  end)
  for key, val in pairs(self.imgModKey) do
    self:subscribe(self.imgModKey[key], UIEvent.EventWindowClick, function()
      if self.initData then
        return
      end
      if self.lytModList[key]:IsVisible() then
        self:closeAllListPanel()
        return
      end
      self:closeAllListPanel()
      self.lytModList[key]:SetVisible(true)
      self.lytMaskPanel:SetVisible(true)
    end)
  end
  self:subscribe(self.editNameEdit, UIEvent.EventEditTextInput, function()
    self:closeAllListPanel()
    local inputText = self.editNameEdit:GetPropertyString("Text", "")
    self.dramaInfo.scriptName = self:getOneShortContent(inputText, true)
    self:updateContentShow()
    self.isChangeTitle = true
  end)
  self:subscribe(self.editNameEdit, UIEvent.EventWindowTouchDown, function()
    self:closeAllListPanel()
  end)
  self:subscribe(self.editNameEdit, UIEvent.EventWindowTouchUp, function()
    self:closeAllListPanel()
  end)
  self:subscribe(self.editDescEdit, UIEvent.EventWindowTouchDown, function()
    self.firstIntoDescInput = true
    self:closeAllListPanel()
  end)
  self:subscribe(self.editDescEdit, UIEvent.EventEditTextInput, function()
    self:closeAllListPanel()
    if self.firstIntoDescInput then
      self.editDescEdit:SetProperty("Text", Lang:toText(self.dramaInfo.summary))
      self.txtDescText:SetText("")
      self.firstIntoDescInput = false
    else
      local text = self.editDescEdit:GetPropertyString("Text", "") or ""
      if text ~= "" then
        self.dramaInfo.summary = self:getOneShortContent(text, false)
      end
      self.firstIntoDescInput = false
      self.editDescEdit:SetProperty("Text", "")
      self:updateContentShow()
    end
  end)
  self:subscribe(self.editDescEdit, UIEvent.EventWindowTouchUp, function()
    self:closeAllListPanel()
    self.editDescEdit:SetProperty("Text", "")
  end)
  self:subscribe(self.editDescEdit, UIEvent.EventMotionRelease, function()
    self:closeAllListPanel()
    self.editDescEdit:SetProperty("Text", "")
    self:updateContentShow()
    self.firstIntoDescInput = false
  end)
  self:subscribe(self.lytMaskPanel, UIEvent.EventWindowClick, function()
    self:closeAllListPanel()
  end)
  self:subscribe(self.imgNamePen, UIEvent.EventWindowClick, function()
    self:closeAllListPanel()
    self.editNameEdit:OpenKeyboard()
  end)
  self:subscribe(self.imgDescPen, UIEvent.EventWindowClick, function()
    self:closeAllListPanel()
    self.editDescEdit:OpenKeyboard()
  end)
end

function WinDramaTemplateEdit:subscribeEvent()
end

function WinDramaTemplateEdit:closeAllListPanel()
  self.lytMaskPanel:SetVisible(false)
  self.lytNumList:SetVisible(false)
  self.lytModList[1]:SetVisible(false)
  self.lytModList[2]:SetVisible(false)
end

function WinDramaTemplateEdit:getOneShortContent(inputText, isTitle)
  local content = World.CurWorld:filterWord(inputText)
  local endIndex = Lib.subStringGetTotalIndex(content)
  local maxLen = 10
  if isTitle then
    maxLen = 10
  else
    maxLen = 20
  end
  if isTitle then
    maxLen = World.cfg.dramaSetting.dramaNameMaxLen
  else
    maxLen = World.cfg.dramaSetting.dramaDescMaxLen
  end
  if endIndex > maxLen then
    local content = Lib.subStringUTF8(content, 1, maxLen)
    return content .. "..."
  end
  return content
end

function WinDramaTemplateEdit:initView(initData, modList)
  self.dramaInfo = {}
  self.isChangeTitle = false
  self.lytNumList:SetVisible(false)
  for key, val in pairs(self.imgModKey) do
    self.lytModList[key]:SetVisible(false)
  end
  self.lytMaskPanel:SetVisible(false)
  if initData then
    if not initData.modList then
      initData.modList = DramaClientHelper:dealScriptDataToModList(initData.scriptData)
    end
    self.dramaInfo = Lib.copy(initData)
    self.initData = Lib.copy(initData)
    self.modList = self.initData.modList
  elseif modList then
    self.initData = nil
    self.modList = modList
    self.isCustomMod = 1 < #modList
  end
  self:updateDramaBtnState()
  self:updatePlayerNum(self.dramaInfo.maxNumber or World.cfg.dramaSetting.roleDefaultCount)
  self:initModCoverShow()
end

function WinDramaTemplateEdit:updatePlayerNum(maxNumber)
  self.txtNumText:SetText(maxNumber)
  self.dramaInfo.maxNumber = maxNumber
  self.dramaInfo.currentNumber = self.dramaInfo.currentNumber or 0
end

function WinDramaTemplateEdit:restInitContent()
  if not self.initData then
    if self:isEditCustomMod() then
      self.dramaInfo.scriptName = "g2052.gui.drama.template.name0"
      self.dramaInfo.summary = "g2052.gui.drama.template.desc0"
    else
      self.dramaInfo.scriptName = self.modInfo[1].templateName
      self.dramaInfo.summary = self.modInfo[1].templateDesc
    end
  end
  self:updateContentShow()
end

function WinDramaTemplateEdit:updateContentShow()
  if self.dramaInfo.scriptName and self.dramaInfo.scriptName ~= "" then
    self.editNameEdit:SetProperty("Text", Lang:toText(self.dramaInfo.scriptName))
  else
    self.editNameEdit:SetProperty("Text", Lang:toText("g2052.gui.drama.template.name0"))
  end
  self.txtNameText:SetText("")
  if self.dramaInfo.summary and self.dramaInfo.summary ~= "" then
    self.txtDescText:SetText(Lang:toText(self.dramaInfo.summary))
  else
    self.txtDescText:SetText(Lang:toText("g2052.gui.drama.template.desc0"))
  end
  self.editDescEdit:SetProperty("Text", "")
end

function WinDramaTemplateEdit:updateDramaBtnState()
  self:updateModIconShow()
  if self.initData and self.initData.userId == Me.platformUserId then
    self.btnEnterBtn:SetVisible(false)
    self.btnChangeBtn:SetVisible(true)
  else
    self.btnEnterBtn:SetVisible(true)
    self.btnChangeBtn:SetVisible(false)
  end
end

function WinDramaTemplateEdit:updateModIconShow()
  if self.initData then
    self.imgModIcon1:SetVisible(false)
    self.imgModIcon2:SetVisible(false)
  else
    self.imgModIcon1:SetVisible(true)
    self.imgModIcon2:SetVisible(true)
  end
end

function WinDramaTemplateEdit:initModCoverShow()
  self.modInfo = {}
  for _, val in pairs(self.modList) do
    local temp = DramaTemplateConfig:getCfgById(val)
    if temp and not DramaTemplateConfig:isEmptyTemplate(val) then
      table.insert(self.modInfo, temp)
    end
  end
  self.totalPage = #self.modInfo
  if self.totalPage > 1 then
    self.lytDotPanel:SetVisible(true)
    self.coverGridView:InitConfig(0, 0, self.totalPage)
    self:updatePointSelectState(1)
    self.coverGridView:SetMoveAble(true)
    self:startAutoRefreshTimer()
  else
    self.lytDotPanel:SetVisible(false)
    self.coverGridView:InitConfig(0, 0, 1)
    self.coverGridView:SetMoveAble(false)
    self:stopAutoRefreshTimer()
  end
  if self:isEditCustomMod() then
    self.imgModKey[2]:SetVisible(true)
    self.imgModKey[1]:SetYPosition({0, -58})
  else
    self.imgModKey[2]:SetVisible(false)
    self.imgModKey[1]:SetYPosition({0, -8})
  end
  for i, cell in pairs(self.coverCells or {}) do
    if i > self.totalPage then
      self.coverGridView:RemoveItem(cell)
      self.coverCells[i] = nil
    end
  end
  self.coverGridView:ResetPos()
  self:updateModCoverShow()
end

function WinDramaTemplateEdit:updateModCoverShow()
  for index, value in ipairs(self.modInfo or {}) do
    if not self.coverCells[index] then
      local cell = UIMgr:new_widget("dramaTemplateCover")
      cell:invoke("updateCoverIcon", value.img)
      self.coverGridView:AddItem(cell)
      self.coverCells[index] = cell
    else
      self.coverCells[index]:invoke("updateCoverIcon", value.img)
    end
    self.lytModList[index]:SetVisible(false)
  end
  for index, value in ipairs(self.modList or {}) do
    local cfg = DramaTemplateConfig:getCfgById(value)
    if cfg then
      self.txtModName[index]:SetText(Lang:toText(cfg.templateName))
    end
  end
  self:restInitContent()
  self:restModGridData()
end

function WinDramaTemplateEdit:restModGridData()
  if self:isEditCustomMod() then
    local remainMods = DramaTemplateConfig:getAllCfgs(false, true, {
      self.modList[1],
      self.modList[2]
    })
    self.modListView[1]:setData(remainMods, -1, nil, true)
    self.modListView[2]:setData(remainMods, -1, nil, true)
    self.imgModIcon1:SetVisible(next(remainMods) ~= nil)
    self.imgModIcon2:SetVisible(next(remainMods) ~= nil)
  else
    self:updateModIconShow()
    local showData = DramaTemplateConfig:getAllCfgs(true, true, {
      self.modList[1]
    })
    self.modListView[1]:setData(showData, -1, nil, true)
  end
end

function WinDramaTemplateEdit:updatePointSelectState(curIndex)
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
  end
  self.curShowPage = curIndex
end

function WinDramaTemplateEdit:startAutoRefreshTimer()
  if self.totalPage <= 1 then
    return
  end
  local waitTime = math.floor(World.cfg.dramaSetting.modFreshTime * 20)
  local moveTime = math.floor(World.cfg.dramaSetting.modMoveTime * 20)
  self.refreshPassTime = 0
  self.touchStartOffset = nil
  self.endOffset = nil
  self.startOffset = nil
  self.autoRefreshTimer = World.Timer(1, function()
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
    return true
  end)
end

function WinDramaTemplateEdit:checkNextMoveOffset()
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

function WinDramaTemplateEdit:moveEndUpdateShowPage()
  self.refreshPassTime = 0
  self.coverGridView:SetMoveAble(true)
  if self.curShowPage == 1 then
    self:updatePointSelectState(2)
  else
    self:updatePointSelectState(1)
  end
  self.endOffset = nil
  self.startOffset = nil
  self.touchStartOffset = nil
end

function WinDramaTemplateEdit:stopAutoRefreshTimer()
  if self.autoRefreshTimer then
    self.autoRefreshTimer()
    self.autoRefreshTimer = nil
  end
  self.refreshPassTime = 0
end

function WinDramaTemplateEdit:isEditCustomMod()
  return self.isCustomMod
end

function WinDramaTemplateEdit:onHide()
  UI:closeWnd("dramaTemplateEdit")
end

function WinDramaTemplateEdit:onShow(isShow, data, modList)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaTemplateEdit", data, modList)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaTemplateEdit:onOpen(data, modList)
  self:initView(data, modList)
  self:subscribeEvent()
end

function WinDramaTemplateEdit:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopAutoRefreshTimer()
end

return WinDramaTemplateEdit
