local WinDramaCreateWnd = M
local DramaCoverConfig = T(Config, "DramaCoverConfig")

function WinDramaCreateWnd:init()
  WinBase.init(self, "DramaCreateWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaCreateWnd:initUI()
  self.lytContentPanel = self:child("DramaCreateWnd-ContentPanel")
  self.lytCenterPanel = self:child("DramaCreateWnd-CenterPanel")
  self.imgTopBg = self:child("DramaCreateWnd-TopBg")
  self.lytHeadPanel = self:child("DramaCreateWnd-HeadPanel")
  self.imgHeadIcon = self:child("DramaCreateWnd-HeadIcon")
  self.imgHeadFrame = self:child("DramaCreateWnd-HeadFrame")
  self.imgLikeBg = self:child("DramaCreateWnd-LikeBg")
  self.txtLikesNum = self:child("DramaCreateWnd-LikesNum")
  self.txtMasterName = self:child("DramaCreateWnd-MasterName")
  self.lytPlayerPanel = self:child("DramaCreateWnd-PlayerPanel")
  self.imgPlayerIcon = self:child("DramaCreateWnd-PlayerIcon")
  self.txtPlayerNum = self:child("DramaCreateWnd-PlayerNum")
  self.txtDramaName = self:child("DramaCreateWnd-DramaName")
  self.txtDramaDesc = self:child("DramaCreateWnd-DramaDesc")
  self.lytBottomPanel = self:child("DramaCreateWnd-BottomPanel")
  self.lytEditorPanel = self:child("DramaCreateWnd-EditorPanel")
  self.imgPen = self:child("DramaCreateWnd-Pen")
  self.btnRecentBtn = self:child("DramaCreateWnd-RecentBtn")
  self.lytTitlePanel = self:child("DramaCreateWnd-TitlePanel")
  self.btnClose = self:child("DramaCreateWnd-Close")
  self.txtTitleText = self:child("DramaCreateWnd-TitleText")
  self.btnCreateBtn = self:child("DramaCreateWnd-CreateBtn")
  self.btnAmendBtn = self:child("DramaCreateWnd-AmendBtn")
  self.txtTitleText:SetText(Lang:toText("g2052.gui.drama.mine"))
  self.btnCreateBtn:SetText(Lang:toText("g2052.gui.drama.create"))
  self.btnRecentBtn:SetText(Lang:toText("g2052.gui.drama.recent"))
  self.btnAmendBtn:SetText(Lang:toText("g2052.gui.drama.amend"))
  self.roleKeyID = 0
  self:initRoleAdapter()
  self.dramaInfo = {}
end

function WinDramaCreateWnd:initRoleAdapter()
  local params = {
    xDis = 21,
    yDis = 14,
    xCellNum = 2,
    widgetWidth = 213,
    widgetHeight = 128,
    widgetJson = "DramaCreateItem.json",
    widgetName = "dramaCreateItem",
    gvParent = self.lytBottomPanel,
    dataList = {}
  }
  self.roleListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.roleGridView = self.roleListView:getGridView()
  self.roleGridView:SetMoveAble(true)
  self.roleGridView:SetvScorllMoveAble(true)
  self.roleGridView:SetAutoColumnCount(false)
  self.roleAdapter = self.roleListView:getAdapter()
end

function WinDramaCreateWnd:initEvent()
  self:subscribe(self.btnRecentBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("dramaHistory")
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self.dramaInfo.roleList = self.roleAdapter.data
    self:onHide()
  end)
  self:subscribe(self.btnCreateBtn, UIEvent.EventButtonClick, function()
    self.dramaInfo.roleList = {}
    for key, val in pairs(self.roleAdapter.data) do
      if not val.isAddIcon then
        table.insert(self.dramaInfo.roleList, val)
      end
    end
    Me:requestCreateOneDrama(self.dramaInfo)
    self.dramaInfo = {}
    if self.changeTitleDesc then
      Plugins.CallTargetPluginFunc("report", "report", "script_msgchange", nil, Me)
    end
    if self.changeItemDesc then
      Plugins.CallTargetPluginFunc("report", "report", "script_characterchange", nil, Me)
    end
    self:onHide()
  end)
  self:subscribe(self.btnAmendBtn, UIEvent.EventButtonClick, function()
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
      self.dramaInfo.roleList = {}
      for key, val in pairs(self.roleAdapter.data) do
        if not val.isAddIcon then
          val.isAddIcon = nil
          table.insert(self.dramaInfo.roleList, val)
        end
      end
      self.dramaInfo.changeItemDesc = self.changeItemDesc
      self.dramaInfo.changeItemNum = self.changeItemNum
      Me:requestAmendOneDrama(self.dramaInfo)
      self.lastAmendTime = os.time()
      self.initData = nil
      self.dramaInfo = {}
      if self.changeTitleDesc then
        Plugins.CallTargetPluginFunc("report", "report", "script_msgchange", nil, Me)
      end
      if self.changeItemDesc then
        Plugins.CallTargetPluginFunc("report", "report", "script_characterchange", nil, Me)
      end
    end
    self:onHide()
  end)
  self:subscribe(self.imgTopBg, UIEvent.EventWindowClick, function()
    UI:openWnd("dramaSelectCover")
  end)
  self:subscribe(self.txtDramaName, UIEvent.EventWindowClick, function()
    local function backFunc(titleText, descText)
      self.dramaInfo.scriptName = titleText
      
      self.dramaInfo.summary = descText
      self:updateContentShow()
    end
    
    UI:getWnd("dramaEditorWnd"):onShow(true, "drama", self.dramaInfo.scriptName, self.dramaInfo.summary, backFunc)
  end)
  self:subscribe(self.lytEditorPanel, UIEvent.EventWindowClick, function()
    local function backFunc(titleText, descText)
      self.dramaInfo.scriptName = titleText
      
      self.dramaInfo.summary = descText
      self.changeTitleDesc = true
      self:updateContentShow()
    end
    
    UI:getWnd("dramaEditorWnd"):onShow(true, "drama", self.dramaInfo.scriptName, self.dramaInfo.summary, backFunc)
  end)
end

function WinDramaCreateWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_CREATE_ITEM, function(oType, index)
    self.changeItemNum = true
    self:updateRoleItemShow(oType, index)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_ROLE_ITEM_NAME, function(index, titleText, descText)
    self.changeItemDesc = true
    if self.roleAdapter.data[index] then
      self.roleAdapter.data[index].roleName = titleText
      self.roleAdapter.data[index].roleDesc = descText
      self.roleAdapter:notifyDataChange(index)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_SELECT_COVER, function(coverId)
    self:updateCoverShow(coverId)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_LIKES_NUM, function(data)
    if data.userId == Me.platformUserId then
      self:updateLikeNumShow(data.likes)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_CREATE_INFO, function(info)
    self.dramaInfo = info
    self.changeItemNum = true
    self.changeItemDesc = true
    self:updateViewShow()
  end)
end

function WinDramaCreateWnd:initView(initData)
  self.initData = initData
  self.changeItemDesc = false
  self.changeItemNum = false
  self.changeTitleDesc = false
  self.roleKeyID = 0
  if initData then
    self.dramaInfo = Lib.copy(initData)
    self.initData = Lib.copy(initData)
    self.dramaInfo.initScriptPic = self.dramaInfo.scriptPic
  end
  if Me.userDetailData and Me.userDetailData.picUrl and 0 < #Me.userDetailData.picUrl then
    self.imgHeadIcon:SetImageUrl(Me.userDetailData.picUrl)
  else
    self.imgHeadIcon:SetImage(World.cfg.defaultAvatar)
  end
  self.txtMasterName:SetText("[" .. Me.name .. "]")
  self:updateViewShow()
  self:updateDramaBtnState()
  Me:requestLikesNumByUserID(Me.platformUserId)
end

function WinDramaCreateWnd:updateDramaBtnState()
  if self.initData then
    self.btnCreateBtn:SetVisible(false)
    self.btnAmendBtn:SetVisible(true)
  else
    self.btnCreateBtn:SetVisible(true)
    self.btnAmendBtn:SetVisible(false)
  end
end

function WinDramaCreateWnd:updateViewShow()
  self:updateCoverShow()
  self:updateContentShow()
  self:updateRoleListShow()
  if self.dramaInfo.likes then
    self:updateLikeNumShow(self.dramaInfo.likes)
  end
end

function WinDramaCreateWnd:updateCoverShow(coverId)
  local coverImg = ""
  if coverId and 0 < coverId then
    self.dramaInfo.scriptPic = tostring(coverId)
  end
  local coverCfg = DramaCoverConfig:getCfgById(self.dramaInfo.scriptPic)
  if coverCfg and coverCfg.img then
    coverImg = coverCfg.img
  else
    local coverCfg = DramaCoverConfig:getCfgById(1)
    if coverCfg and coverCfg.img then
      coverImg = coverCfg.img
    end
    self.dramaInfo.scriptPic = "1"
  end
  self.imgTopBg:SetImage(coverImg)
end

function WinDramaCreateWnd:updateLikeNumShow(likes)
  self.txtLikesNum:SetText(Lib.toNewThousandthString(likes))
end

function WinDramaCreateWnd:updateContentShow()
  if self.dramaInfo.scriptName and self.dramaInfo.scriptName ~= "" then
    self.txtDramaName:SetText(self.dramaInfo.scriptName)
  else
    self.dramaInfo.scriptName = Lang:toText({
      "g2052.gui.drama.detail.title1",
      Me.name
    })
    self.txtDramaName:SetText(self.dramaInfo.scriptName)
  end
  if self.dramaInfo.summary and self.dramaInfo.summary ~= "" then
    self.txtDramaDesc:SetText(self.dramaInfo.summary)
  else
    self.dramaInfo.summary = Lang:toText("g2052.gui.drama.drama.desc")
    self.txtDramaDesc:SetText(self.dramaInfo.summary)
  end
end

function WinDramaCreateWnd:updateRoleListShow()
  self.roleAdapter:clearItems()
  if not self.dramaInfo.roleList then
    self.roleKeyID = 0
    for i = 1, World.cfg.dramaSetting.roleDefaultCount do
      self:createOneRoleItem(i)
    end
  else
    self.roleKeyID = -1
    for pos, val in pairs(self.dramaInfo.roleList) do
      self.dramaInfo.roleList[pos].index = pos
      if self.dramaInfo.roleList[pos].roleKey then
        if self.dramaInfo.roleList[pos].roleKey > self.roleKeyID then
          self.roleKeyID = self.dramaInfo.roleList[pos].roleKey
        end
      else
        self.roleKeyID = self.roleKeyID + 1
        self.dramaInfo.roleList[pos].roleKey = self.roleKeyID
      end
    end
    self.roleKeyID = self.roleKeyID + 1
    table.sort(self.dramaInfo.roleList, function(a, b)
      return (a.index or 0) < (b.index or 0)
    end)
    self.roleAdapter:setData(self.dramaInfo.roleList)
  end
  self:checkIsNeedAddItem()
  self:updatePlayerNum()
end

function WinDramaCreateWnd:getRealPlayerNum()
  local maxNumber = 0
  for key, val in pairs(self.roleAdapter.data) do
    if not val.isAddIcon then
      maxNumber = maxNumber + val.roleNum
    end
  end
  return maxNumber
end

function WinDramaCreateWnd:updatePlayerNum()
  local maxNumber = self:getRealPlayerNum()
  self.txtPlayerNum:SetText(maxNumber)
  self.dramaInfo.maxNumber = maxNumber
  self.dramaInfo.currentNumber = self.dramaInfo.currentNumber or 0
end

function WinDramaCreateWnd:updateRoleItemShow(oType, index)
  local realNum = self:getRealPlayerNum()
  if oType == "new" then
    if realNum >= World.cfg.dramaSetting.roleMaxCount then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.drama.role.max")
      return
    end
    self:createOneRoleItem(#self.roleAdapter.data)
  elseif oType == "add" then
    if realNum >= World.cfg.dramaSetting.roleMaxCount then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.drama.role.max")
      return
    end
    self.roleAdapter.data[index].roleNum = self.roleAdapter.data[index].roleNum + 1
    self.roleAdapter:notifyDataChange(index)
  elseif oType == "sub" then
    if realNum <= World.cfg.dramaSetting.roleMinCount then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.drama.role.min")
      return
    end
    self.roleAdapter.data[index].roleNum = self.roleAdapter.data[index].roleNum - 1
    if self.roleAdapter.data[index].roleNum > 0 then
      self.roleAdapter:notifyDataChange(index)
    else
      self.roleAdapter:removePosition(index)
      for key, val in pairs(self.roleAdapter.data) do
        if self.roleAdapter.data[key].roleName == Lang:toText({
          "g2052.gui.drama.role.name",
          self.roleAdapter.data[key].index
        }) then
          self.roleAdapter.data[key].roleName = Lang:toText({
            "g2052.gui.drama.role.name",
            key
          })
        end
        self.roleAdapter.data[key].index = key
      end
      self.roleAdapter:notifyDataChange()
    end
  end
  self:checkIsNeedAddItem()
  self:updatePlayerNum()
end

function WinDramaCreateWnd:createOneRoleItem(position)
  self.roleKeyID = self.roleKeyID + 1
  local temp = {
    isAddIcon = false,
    roleName = Lang:toText({
      "g2052.gui.drama.role.name",
      position
    }),
    roleDesc = "",
    roleNum = 1,
    userIdList = {},
    index = position,
    roleSelects = 0,
    playState = 0,
    roleKey = self.roleKeyID
  }
  self.roleAdapter:addItem(temp, position)
end

function WinDramaCreateWnd:checkIsNeedAddItem()
  local realNum = self:getRealPlayerNum()
  if realNum >= World.cfg.dramaSetting.roleMaxCount then
    if self.roleAdapter.data[#self.roleAdapter.data].isAddIcon then
      self.roleAdapter:removePosition(#self.roleAdapter.data)
    end
  elseif not self.roleAdapter.data[#self.roleAdapter.data].isAddIcon then
    local temp = {isAddIcon = true}
    self.roleAdapter:addItem(temp)
  end
end

function WinDramaCreateWnd:onHide()
  UI:closeWnd("dramaCreateWnd")
end

function WinDramaCreateWnd:onShow(isShow, initData)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaCreateWnd", initData)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaCreateWnd:onOpen(initData)
  self:initView(initData)
  self:subscribeEvent()
  self.openWndTime = os.time()
end

function WinDramaCreateWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.openWndTime and not self.initData then
    local reportData = {
      stay_drama_create_time = os.time() - self.openWndTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "g2052scriptCreate", reportData, Me)
  end
end

return WinDramaCreateWnd
