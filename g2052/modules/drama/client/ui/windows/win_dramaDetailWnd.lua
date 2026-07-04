local WinDramaDetailWnd = M
local DramaClientHelper = T(Lib, "DramaClientHelper")
local DramaCoverConfig = T(Config, "DramaCoverConfig")

function WinDramaDetailWnd:init()
  WinBase.init(self, "DramaDetailWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaDetailWnd:initUI()
  self.lytContentPanel = self:child("DramaDetailWnd-ContentPanel")
  self.lytCenterPanel = self:child("DramaDetailWnd-CenterPanel")
  self.imgTopBg = self:child("DramaDetailWnd-TopBg")
  self.lytHeadPanel = self:child("DramaDetailWnd-HeadPanel")
  self.imgHeadIcon = self:child("DramaDetailWnd-HeadIcon")
  self.imgHeadFrame = self:child("DramaDetailWnd-HeadFrame")
  self.imgLikeBg = self:child("DramaDetailWnd-LikeBg")
  self.txtLikesNum = self:child("DramaDetailWnd-LikesNum")
  self.txtMasterName = self:child("DramaDetailWnd-MasterName")
  self.lytPlayerPanel = self:child("DramaDetailWnd-PlayerPanel")
  self.imgPlayerIcon = self:child("DramaDetailWnd-PlayerIcon")
  self.txtPlayerNum = self:child("DramaDetailWnd-PlayerNum")
  self.txtDramaName = self:child("DramaDetailWnd-DramaName")
  self.txtDramaDesc = self:child("DramaDetailWnd-DramaDesc")
  self.lytBottomPanel = self:child("DramaDetailWnd-BottomPanel")
  self.lytTitlePanel = self:child("DramaDetailWnd-TitlePanel")
  self.btnClose = self:child("DramaDetailWnd-Close")
  self.txtTitleText = self:child("DramaDetailWnd-TitleText")
  self.btnJoinBtn = self:child("DramaDetailWnd-JoinBtn")
  self.btnChangeBtn = self:child("DramaDetailWnd-ChangeBtn")
  self.btnChangeBtn:SetText(Lang:toText("g2052.gui.drama.change.role"))
  self:initAdapter()
end

function WinDramaDetailWnd:initAdapter()
  local params = {
    xDis = 21,
    yDis = 14,
    xCellNum = 2,
    widgetWidth = 213,
    widgetHeight = 128,
    widgetJson = "DramaDetailItem.json",
    widgetName = "dramaDetailItem",
    gvParent = self.lytBottomPanel,
    dataList = {}
  }
  self.roleListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.roleGridView = self.roleListView:getGridView()
  self.roleGridView:SetMoveAble(true)
  self.roleGridView:SetvScorllMoveAble(true)
  self.roleGridView:SetAutoColumnCount(true)
  self.roleAdapter = self.roleListView:getAdapter()
end

function WinDramaDetailWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnJoinBtn, UIEvent.EventButtonClick, function()
    if not self.data or not self.data.id then
      return
    end
    Me:requestJoinDrama(self.data.id)
    self:onHide()
  end)
  self:subscribe(self.btnChangeBtn, UIEvent.EventButtonClick, function()
    if DramaClientHelper.curDramaInfo then
      UI:openWnd("dramaSelectRole", false, DramaClientHelper.curDramaInfo)
    end
  end)
  self:subscribe(self.lytHeadPanel, UIEvent.EventWindowClick, function()
  end)
end

function WinDramaDetailWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_DETAIL_INFO, function(id, data)
    if self.data.id == id then
      self:updateViewInfo(data)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_WND_INFO, function()
    Me:requestDramaDetailInfo(self.data.id)
  end)
end

function WinDramaDetailWnd:initView(data)
  self.data = data
  if DramaClientHelper.curDramaInfo and DramaClientHelper.curDramaInfo.id == self.data.id then
    self.btnChangeBtn:SetVisible(true)
    self.btnJoinBtn:SetVisible(false)
  else
    self.btnChangeBtn:SetVisible(false)
    self.btnJoinBtn:SetVisible(true)
  end
  if data and data.id then
    self:updateViewInfo(data)
    Me:requestDramaDetailInfo(data.id)
  end
end

function WinDramaDetailWnd:updateViewInfo(data)
  self.txtDramaName:SetText(data.scriptName)
  self.txtDramaDesc:SetText(data.summary)
  if data.picUrl and #data.picUrl > 0 then
    self.imgHeadIcon:SetImageUrl(data.picUrl)
  else
    self.imgHeadIcon:SetImage(World.cfg.defaultAvatar)
  end
  self.txtLikesNum:SetText(Lib.toNewThousandthString(data.likes or 0))
  self.txtPlayerNum:SetText(data.currentNumber .. "/" .. data.maxNumber)
  self.txtMasterName:SetText("[" .. (data.nickName or "") .. "]")
  self.txtTitleText:SetText(Lang:toText({
    "g2052.gui.drama.detail.title1",
    data.nickName or ""
  }))
  if not data.roleList then
    data.roleList = DramaClientHelper:dealScriptDataToModList(data.scriptData)
  end
  table.sort(data.roleList, function(a, b)
    return (a.index or 0) < (b.index or 0)
  end)
  self:updateRoleShow(data.roleList)
  self:updateCoverShow(data.scriptPic)
  self:startAutoRefreshTimer()
end

function WinDramaDetailWnd:updateCoverShow(scriptPic)
  local coverCfg = DramaCoverConfig:getCfgById(scriptPic)
  if coverCfg and coverCfg.img then
    self.imgTopBg:SetImage(coverCfg.img)
  else
    self.imgTopBg:SetImage("")
  end
end

function WinDramaDetailWnd:updateRoleShow(roleList)
  table.sort(roleList, function(a, b)
    if a.playState == a.playState then
      return (a.index or 0) < (b.index or 0)
    else
      return a.playState < b.playState
    end
  end)
  self.roleAdapter:setData(roleList)
end

function WinDramaDetailWnd:startAutoRefreshTimer()
  self:stopAutoRefreshTimer()
  self.refreshTimer = World.Timer(20, function()
    self.refreshPassTime = self.refreshPassTime + 1
    if self.refreshPassTime >= World.cfg.dramaSetting.refreshTime then
      Me:requestDramaDetailInfo(self.data.id)
      self.refreshPassTime = 0
    end
    return true
  end)
end

function WinDramaDetailWnd:stopAutoRefreshTimer()
  if self.refreshTimer then
    self.refreshTimer()
    self.refreshTimer = nil
  end
  self.refreshPassTime = 0
end

function WinDramaDetailWnd:onHide()
  UI:closeWnd("dramaDetailWnd")
end

function WinDramaDetailWnd:onShow(isShow, data)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaDetailWnd", data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaDetailWnd:onOpen(data)
  self:initView(data)
  self:subscribeEvent()
end

function WinDramaDetailWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopAutoRefreshTimer()
end

return WinDramaDetailWnd
