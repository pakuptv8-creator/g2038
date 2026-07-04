local WinLimitTimeSignalWnd = M
local LimitedTimeGiftSignalConfig = T(Config, "LimitedTimeGiftSignalConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitTimeSignalWnd:init()
  WinBase.init(self, "LimitTimeSignalWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeSignalWnd:initUI()
  self.lytBackBg = self:child("LimitTimeSignalWnd-BackBg")
  self.lytContentPanel = self:child("LimitTimeSignalWnd-ContentPanel")
  self.txtTitleText = self:child("LimitTimeSignalWnd-TitleText")
  self.imgRemainBg = self:child("LimitTimeSignalWnd-remainBg")
  self.imgRemainIcon = self:child("LimitTimeSignalWnd-RemainIcon")
  self.txtRemainText = self:child("LimitTimeSignalWnd-remainText")
  self.lytItemPanel = self:child("LimitTimeSignalWnd-ItemPanel")
  self.btnCloseBtn = self:child("LimitTimeSignalWnd-CloseBtn")
  self.lytMaskPanel = self:child("LimitTimeSignalWnd-MaskPanel")
  self.txtCountTip = self:child("LimitTimeSignalWnd-tip")
  self.txtCountTip:SetVisible(false)
  self.lytMaskPanel:SetVisible(false)
  self:initItemNode()
  self.txtTitleText:SetText(Lang:toText("gui.limit.time.combined.title"))
end

function WinLimitTimeSignalWnd:initItemNode()
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.lytItemPanel:AddChildWindow(self.gvItemList)
  self.gvItemList:SethScorllMoveAble(true)
  self.gvItemList:SetvScorllMoveAble(false)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:InitConfig(16, 0, 1)
  self.itemCells = {}
end

function WinLimitTimeSignalWnd:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinLimitTimeSignalWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_SIGNAL_BUY, function(value)
    if not self.activityData then
      return
    end
    self:updateActivityGoodsShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_BUY_RESULT, function(value)
    self:updateBuyingState(value)
  end)
end

local function getTimeByArray(array)
  return os.time({
    year = array[1] or 0,
    month = array[2] or 0,
    day = array[3] or 0,
    hour = array[4] or 0,
    min = array[5] or 0,
    sec = array[6] or 0
  })
end

function WinLimitTimeSignalWnd:initView()
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT)
  self.curTime = LimitedTimeActivityGameMgr:getServerTime()
  self.endTime = self.activityInfo.endNumTime or getTimeByArray(self.activityInfo.endTime)
  self:initActivityGoodsShow()
  self:updateActivityTimeShow()
  self:startDownTimer()
end

function WinLimitTimeSignalWnd:updateBuyingState(value)
  self.isBuying = value
end

function WinLimitTimeSignalWnd:getBuyingState()
  return self.isBuying
end

function WinLimitTimeSignalWnd:initActivityGoodsShow()
  self.activityData = Lib.copy(LimitedTimeGiftSignalConfig:getCfgByActivityId(self.activityInfo.id))
  self.gvItemList:InitConfig(16, 0, #self.activityData)
  for i, cell in pairs(self.itemCells or {}) do
    if i > #self.activityData then
      self.gvItemList:RemoveItem(cell)
      self.itemCells[i] = nil
    end
  end
  self:updateActivityGoodsShow()
end

function WinLimitTimeSignalWnd:updateActivityGoodsShow()
  local showData = {}
  local signalLimitGiftData = Me:getSignalLimitGiftData()
  for _, data in pairs(self.activityData or {}) do
    if LimitedTimeActivityGameMgr:checkSignalItemCanBought(data, signalLimitGiftData) then
      data.canBuyState = 1
    else
      data.canBuyState = 0
    end
    table.insert(showData, data)
  end
  table.sort(showData, function(a, b)
    if a.canBuyState == b.canBuyState then
      return a.sortId < b.sortId
    else
      return a.canBuyState > b.canBuyState
    end
  end)
  for index, value in ipairs(showData) do
    if not self.itemCells[index] then
      local cell = UIMgr:new_widget("limitTimeSignalItem")
      cell:invoke("updateItemViewShow", value)
      self.gvItemList:AddItem(cell)
      self.itemCells[index] = cell
    else
      self.itemCells[index]:invoke("updateItemViewShow", value)
    end
  end
end

function WinLimitTimeSignalWnd:updateActivityTimeShow()
  local remainTime = self.endTime - self.curTime
  if remainTime < 0 then
    self:onHide()
    return
  end
  local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(remainTime))
  if 86400 < remainTime then
    local day = math.floor(remainTime / 3600 / 24) or 0
    text = day .. "d " .. text
  end
  self.txtRemainText:SetText(text)
end

function WinLimitTimeSignalWnd:startDownTimer()
  self:stopDownTimer()
  self.downTimer = World.Timer(20, function()
    self.curTime = self.curTime + 1
    self:updateActivityTimeShow()
    return true
  end)
end

function WinLimitTimeSignalWnd:stopDownTimer()
  if self.downTimer then
    self.downTimer()
    self.downTimer = nil
  end
end

function WinLimitTimeSignalWnd:onHide()
  UI:closeWnd("limitTimeSignalWnd")
end

function WinLimitTimeSignalWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeSignalWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeSignalWnd:onOpen()
  self:initView()
  self:subscribeEvent()
  LimitedTimeActivityGameMgr:updateSignalLimitBtnRedDot(false)
end

function WinLimitTimeSignalWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopDownTimer()
end

return WinLimitTimeSignalWnd
