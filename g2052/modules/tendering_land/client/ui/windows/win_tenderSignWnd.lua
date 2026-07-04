local WinTenderSignWnd = M
local TenderingConfig = T(Config, "TenderingConfig")
local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
local BiddingConfig = T(Config, "BiddingConfig")

function WinTenderSignWnd:init()
  WinBase.init(self, "TenderSignWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTenderSignWnd:initUI()
  self.imgLandPanel = self:child("TenderSignWnd-LandPanel")
  self.txtLandTitle = self:child("TenderSignWnd-LandTitle")
  self.lytLandLine1 = self:child("TenderSignWnd-LandLine1")
  self.btnLandTipBtn = self:child("TenderSignWnd-LandTipBtn")
  self.lytLandContent = self:child("TenderSignWnd-LandContent")
  self.imgPostPanel = self:child("TenderSignWnd-PostPanel")
  self.txtPostTitle = self:child("TenderSignWnd-PostTitle")
  self.btnPostTipBtn = self:child("TenderSignWnd-PostTipBtn")
  self.lytPostContent = self:child("TenderSignWnd-PostContent")
  self.txtNoneLand = self:child("TenderSignWnd-NoneLand")
  self.txtNoneLand:SetVisible(false)
  self.btnCloseBtn = self:child("TenderSignWnd-CloseBtn")
  self.txtSignTitle = self:child("TenderSignWnd-SignTitle")
  self.lytContent = self:child("TenderSignWnd-Content")
  self:initLandAdapter()
  self:initPostAdapter()
  self.txtSignTitle:SetText(Lang:toText("g2052.gui.tendering.sign.sign_title"))
  self.txtLandTitle:SetText(Lang:toText("g2052.gui.tendering.sign.land_title"))
  self.txtPostTitle:SetText(Lang:toText("g2052.gui.tendering.sign.post_title"))
  self.txtNoneLand:SetText(Lang:toText("g2052.gui.common.not_release"))
end

function WinTenderSignWnd:initLandAdapter()
  local params = {
    xDis = 0,
    yDis = 14,
    xCellNum = 1,
    widgetWidth = 370,
    widgetHeight = 246,
    widgetJson = "TenderSignLand.json",
    widgetName = "tenderSignLand",
    gvParent = self.lytLandContent,
    dataList = {}
  }
  self.landListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.landListView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(true)
  self.landAdapter = self.landListView:getAdapter()
end

function WinTenderSignWnd:initPostAdapter()
  self.postGridView = UIMgr:new_widget("grid_view")
  self.lytPostContent:AddChildWindow(self.postGridView)
  self.postGridView:SetMoveAble(true)
  self.postGridView:SethScorllMoveAble(false)
  self.postGridView:SetvScorllMoveAble(true)
  self.postGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.postGridView:InitConfig(0, 10, 1)
  self.postCells = {}
end

function WinTenderSignWnd:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnLandTipBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("tenderSignTips"):onShow(true, "g2052.gui.tendering.sign.land_tips")
  end)
  self:subscribe(self.btnPostTipBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("tenderSignTips"):onShow(true, "g2052.gui.tendering.sign.post_tips")
  end)
end

function WinTenderSignWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_TENDERING_INFO, function()
    self:updatePostInfoView()
  end)
end

function WinTenderSignWnd:initView()
  self:updatePostInfoView()
  self:updateAllTimeLine()
end

function WinTenderSignWnd:updateLandInfoView()
  if not self.initLandView then
    self.landAdapter:clearItems()
    self.landListView:getGridView():ResetPos()
    local regionId = TenderClientAwardManager:getClientRegionId()
    local landCfg = TenderingConfig:getCfgByRegionId(regionId)
    local showLand = {}
    if self.allTimeLine then
      for key, val in pairs(landCfg) do
        local landName = val.landName
        if self.allTimeLine[landName] then
          local temp = Lib.copyTable1(val)
          temp.timeLineInfo = self.allTimeLine[landName]
          table.insert(showLand, temp)
        end
      end
    end
    table.sort(showLand, function(a, b)
      return a.id > b.id
    end)
    self.landAdapter:setData(showLand)
    self.txtNoneLand:SetVisible(#showLand <= 0)
  else
    for key, val in pairs(self.landAdapter.data) do
      self.landAdapter.data[key].timeLineInfo = self.allTimeLine[val.landName] or {}
    end
    self.landAdapter:notifyDataChange()
  end
end

function WinTenderSignWnd:updatePostInfoView()
  local buildData = {}
  if TenderClientAwardManager.socialAwardData and TenderClientAwardManager.socialAwardData.normalMayor and next(TenderClientAwardManager.socialAwardData.normalMayor) then
    for key, val in pairs(TenderClientAwardManager.buildAwardData) do
      if TenderClientAwardManager.socialAwardData.normalMayor then
        if not TenderClientAwardManager.socialAwardData.normalMayor[val.userId] then
          table.insert(buildData, val)
        end
      else
        table.insert(buildData, val)
      end
    end
    if not self.initPostView then
      self.initPostView = true
      self.postCells[1] = UIMgr:new_widget("tenderSignMayor")
      self.postGridView:AddItem(self.postCells[1])
      local count = math.ceil(#buildData / 2)
      for index = 1, count do
        if not self.postCells[index + 1] then
          self.postCells[index + 1] = UIMgr:new_widget("tenderSignMPS")
          self.postGridView:AddItem(self.postCells[index + 1])
          self.postCells[index + 1]:invoke("updateSecondShow", true)
          if index == count and count * 2 > #buildData then
            self.postCells[index + 1]:invoke("updateSecondShow", false)
          end
        end
      end
    end
  elseif not self.initPostView then
    self.initPostView = true
    local regionId = TenderClientAwardManager:getClientRegionId()
    local landCfg = TenderingConfig:getCfgByRegionId(regionId)
    if not landCfg then
      return
    end
    self.postCells[1] = UIMgr:new_widget("tenderSignMayor")
    self.postGridView:AddItem(self.postCells[1])
    local count = math.ceil((#landCfg - 1) / 2)
    for index = 1, count do
      if not self.postCells[index + 1] then
        self.postCells[index + 1] = UIMgr:new_widget("tenderSignMPS")
        self.postGridView:AddItem(self.postCells[index + 1])
        self.postCells[index + 1]:invoke("updateSecondShow", true)
        if index == count and count * 2 > #landCfg - 1 then
          self.postCells[index + 1]:invoke("updateSecondShow", false)
        end
      end
    end
  end
  for index, val in pairs(self.postCells) do
    if index == 1 then
      self.postCells[index]:invoke("updatePostInfo", TenderClientAwardManager.socialAwardData)
    else
      local num = (index - 1) * 2 - 1
      self.postCells[index]:invoke("updatePostInfo", buildData[num], buildData[num + 1])
    end
  end
end

function WinTenderSignWnd:updateAllTimeLine()
  BiddingConfig:getAllTimeLine(function(allTimeLine)
    self.allTimeLine = allTimeLine
    self:updateLandInfoView()
  end)
end

function WinTenderSignWnd:onHide()
  UI:closeWnd("tenderSignWnd")
end

function WinTenderSignWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("tenderSignWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTenderSignWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinTenderSignWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinTenderSignWnd
