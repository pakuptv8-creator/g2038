local WinLimitTimeWeekWnd = M
local LimitedTimeWeekGiftConfig = T(Config, "LimitedTimeWeekGiftConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WinLimitTimeWeekWnd:init()
  WinBase.init(self, "LimitTimeWeekWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeWeekWnd:initUI()
  self.lytContentPanel = self:child("LimitTimeWeekWnd-ContentPanel")
  self.btnHelp = self:child("LimitTimeWeekWnd-help")
  self.txtTitle = self:child("LimitTimeWeekWnd-title")
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.week.gift"))
  self:initGiftGirdView()
end

function WinLimitTimeWeekWnd:initGiftGirdView()
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

function WinLimitTimeWeekWnd:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.week.gift.help"
    })
  end)
end

function WinLimitTimeWeekWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_WEEK_BUY, function(data)
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

function WinLimitTimeWeekWnd:initGoodsInfo()
  self.initInfo = true
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT)
  local weekCfg = Lib.copy(LimitedTimeWeekGiftConfig:getCfgByRoundActivityId(self.activityInfo.id, self.activityInfo.curRoundId))
  local showData = {}
  local weekData = Me:getLimitedTimeWeekData()
  for key, val in pairs(weekCfg) do
    local temp = val
    temp.dataType = "week"
    temp.boughtCounts = weekData[val.giftKey] or 0
    table.insert(showData, temp)
  end
  self.goodsAdapter:setData(showData)
end

function WinLimitTimeWeekWnd:initView()
  if not self.initInfo then
    self:initGoodsInfo()
  else
    self.goodsAdapter:notifyDataChange()
  end
end

function WinLimitTimeWeekWnd:onHide()
  UI:closeWnd("limitTimeWeekWnd")
end

function WinLimitTimeWeekWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeWeekWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeWeekWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLimitTimeWeekWnd:onClose()
  UI:closeWnd("limitedTimeWeekConfirm")
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitTimeWeekWnd
