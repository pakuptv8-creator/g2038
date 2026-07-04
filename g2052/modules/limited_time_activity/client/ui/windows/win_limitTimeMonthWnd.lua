local WinLimitTimeMonthWnd = M
local LimitedTimeMonthGiftConfig = T(Config, "LimitedTimeMonthGiftConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WinLimitTimeMonthWnd:init()
  WinBase.init(self, "LimitTimeMonthWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeMonthWnd:initUI()
  self.lytContentPanel = self:child("LimitTimeMonthWnd-ContentPanel")
  self.btnHelp = self:child("LimitTimeMonthWnd-help")
  self.txtTitle = self:child("LimitTimeMonthWnd-title")
  if not self.txtTitle then
    return
  end
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.month.gift"))
  self:initGiftGirdView()
end

function WinLimitTimeMonthWnd:initGiftGirdView()
  self.goodsGridView = UIMgr:new_widget("grid_view", self.lytContentPanel)
  self.goodsGridView:SetMoveAble(true)
  self.goodsGridView:SetvScorllMoveAble(true)
  self.goodsGridView:SethScorllMoveAble(false)
  self.goodsGridView:InitConfig(60, 0, 3)
  self.goodsGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.goodsGridView:SetAutoColumnCount(false)
  self.goodsAdapter = UIMgr:new_adapter("common", 251, 298, "limitTimeWeekItem", "LimitTimeWeekItem.json")
  self.goodsGridView:invoke("setAdapter", self.goodsAdapter)
end

function WinLimitTimeMonthWnd:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.month.gift.help"
    })
  end)
end

function WinLimitTimeMonthWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_MONTH_BUY, function(data)
    if next(data) then
      for key, val in pairs(self.goodsAdapter.data) do
        self.goodsAdapter.data[key].boughtCounts = data[val.giftKey] or 0
      end
      self.goodsAdapter:notifyDataChange()
    else
      self:initGoodsInfo()
    end
    UI:closeWnd("limitedTimeWeekConfirm")
  end)
end

function WinLimitTimeMonthWnd:initGoodsInfo()
  self.initInfo = true
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT)
  local monthCfg = Lib.copy(LimitedTimeMonthGiftConfig:getCfgByRoundActivityId(self.activityInfo.id, self.activityInfo.curRoundId))
  local showData = {}
  local monthData = Me:getLimitedTimeMonthData()
  for key, val in pairs(monthCfg) do
    local temp = val
    temp.dataType = "month"
    temp.boughtCounts = monthData[val.giftKey] or 0
    table.insert(showData, temp)
  end
  self.goodsAdapter:setData(showData)
end

function WinLimitTimeMonthWnd:initView()
  if not self.initInfo then
    self:initGoodsInfo()
  else
    self.goodsAdapter:notifyDataChange()
  end
end

function WinLimitTimeMonthWnd:onHide()
  UI:closeWnd("limitTimeMonthWnd")
end

function WinLimitTimeMonthWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeMonthWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeMonthWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLimitTimeMonthWnd:onClose()
  UI:closeWnd("limitedTimeWeekConfirm")
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitTimeMonthWnd
