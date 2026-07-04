local WinLimitTimeDiscountWnd = M
local LimitedTimeDiscountGiftConfig = T(Config, "LimitedTimeDiscountGiftConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WinLimitTimeDiscountWnd:init()
  WinBase.init(self, "LimitTimeDiscountWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeDiscountWnd:initUI()
  self.btnHelp = self:child("LimitTimeDiscountWnd-help")
  self.txtTitle = self:child("LimitTimeDiscountWnd-title")
  self.imgRoleIcon = self:child("LimitTimeDiscountWnd-RoleIcon")
  self.imgTipsBG = self:child("LimitTimeDiscountWnd-TipsBG")
  self.txtTipsText = self:child("LimitTimeDiscountWnd-TipsText")
  self.txtRefreshTip = self:child("LimitTimeDiscountWnd-RefreshTip")
  self.lytContentPanel = self:child("LimitTimeDiscountWnd-ContentPanel")
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.discount.title"))
  self.txtTipsText:SetText(Lang:toText("gui.limit.time.activity.discount.desc"))
  self:initGiftGirdView()
end

function WinLimitTimeDiscountWnd:initGiftGirdView()
  self.goodsGridView = UIMgr:new_widget("grid_view", self.lytContentPanel)
  self.goodsGridView:SetMoveAble(true)
  self.goodsGridView:SetvScorllMoveAble(true)
  self.goodsGridView:SethScorllMoveAble(false)
  self.goodsGridView:InitConfig(33, 4, 4)
  self.goodsGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.goodsGridView:SetAutoColumnCount(false)
  self.goodsAdapter = UIMgr:new_adapter("common", 213, 280, "limitTimeDiscountItem", "LimitTimeDiscountItem.json")
  self.goodsGridView:invoke("setAdapter", self.goodsAdapter)
end

function WinLimitTimeDiscountWnd:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.discount.help"
    })
  end)
end

function WinLimitTimeDiscountWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_DISCOUNT_BUY, function()
    self:updateGoodsInfo()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY, function()
    self:updateGoodsInfo()
  end)
end

function WinLimitTimeDiscountWnd:updateGoodsInfo()
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT)
  if self.activityInfo.updateCount ~= self.lastUpdateCount or self.activityInfo.curRoundId ~= self.curRoundId then
    self.lastUpdateCount = self.activityInfo.updateCount
    self.curRoundId = self.activityInfo.curRoundId
    local discountCfg = Lib.copy(LimitedTimeDiscountGiftConfig:getCfgByRoundActivityId(self.activityInfo.id, self.activityInfo.curRoundId))
    self.goodsAdapter:setData(discountCfg)
  else
    self.goodsAdapter:notifyDataChange()
  end
  UI:closeWnd("limitedTimeConfirmCommon")
end

function WinLimitTimeDiscountWnd:initView()
  self:updateGoodsInfo()
  local curTime = os.time()
  local nextTime = curTime + 86400
  local date = os.date("*t", nextTime)
  local endTime = os.time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = 0
  })
  self.remainTime = endTime - curTime
end

function WinLimitTimeDiscountWnd:updateDownTimeShow()
  if self.remainTime then
    local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(self.remainTime))
    self.txtRefreshTip:SetText(Lang:toText({
      "gui.limit.time.activity.discount.refresh",
      text
    }))
    self.remainTime = self.remainTime - 1
    if self.remainTime == 0 then
      self:updateGoodsInfo()
    end
  end
end

function WinLimitTimeDiscountWnd:onHide()
  UI:closeWnd("limitTimeDiscountWnd")
end

function WinLimitTimeDiscountWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeDiscountWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeDiscountWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLimitTimeDiscountWnd:onClose()
  UI:closeWnd("limitedTimeConfirmCommon")
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self.remainTime = nil
end

return WinLimitTimeDiscountWnd
