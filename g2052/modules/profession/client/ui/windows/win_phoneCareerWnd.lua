local WinPhoneCareerWnd = M

function WinPhoneCareerWnd:init()
  WinBase.init(self, "PhoneCareerWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPhoneCareerWnd:initUI()
  self.lytMask = self:child("PhoneCareerWnd-mask")
  self.imgPanel = self:child("PhoneCareerWnd-Panel")
  self.lytContentPanel = self:child("PhoneCareerWnd-ContentPanel")
  self.btnRefreshBtn = self:child("PhoneCareerWnd-RefreshBtn")
  self:initAdapter()
end

function WinPhoneCareerWnd:initAdapter()
  local params = {
    xDis = 8,
    yDis = 10,
    xCellNum = 3,
    widgetWidth = 90,
    widgetHeight = 115,
    widgetJson = "PhoneCareerItem.json",
    widgetName = "phoneCareerItem",
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

function WinPhoneCareerWnd:initEvent()
  self:subscribe(self.btnRefreshBtn, UIEvent.EventButtonClick, function()
    Me:requestAllPlayerCareer()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinPhoneCareerWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_ALL_CAREER_DATA, function(allCareer)
    self:updateViewShow(allCareer)
  end)
end

function WinPhoneCareerWnd:initView()
  Me:requestAllPlayerCareer()
end

function WinPhoneCareerWnd:updateViewShow(data)
  self.professionAdapter:clearItems()
  self.professionListView:getGridView():ResetPos()
  self.professionAdapter:setData(data)
end

function WinPhoneCareerWnd:onHide()
  UI:closeWnd("phoneCareerWnd")
end

function WinPhoneCareerWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("phoneCareerWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPhoneCareerWnd:onOpen()
  self:initView()
  self:subscribeEvent()
  local defaultData = {}
  Plugins.CallTargetPluginFunc("report", "report", "phone_ui_open", defaultData, Me)
end

function WinPhoneCareerWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinPhoneCareerWnd
