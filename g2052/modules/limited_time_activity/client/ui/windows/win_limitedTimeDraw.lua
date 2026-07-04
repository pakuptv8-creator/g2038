local WinLimitedTimeDraw = M
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeDrawConfig = T(Config, "LimitedTimeDrawConfig")
local LimitedTimeDrawAwardsConfig = T(Config, "LimitedTimeDrawAwardsConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local PokemonConfig = T(Config, "PokemonConfig")

function WinLimitedTimeDraw:init()
  WinBase.init(self, "LimitedTimeDraw.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeDraw:initData()
end

function WinLimitedTimeDraw:initUI()
  self.imgIcon = self:child("LimitedTimeDraw-icon")
  self.actorActor = self:child("LimitedTimeDraw-actor")
  self.btnHelp = self:child("LimitedTimeDraw-help")
  self:child("LimitedTimeDraw-title"):SetText(Lang:toText("gui.limit.time.activity.draw.title"))
  self.txtTip = self:child("LimitedTimeDraw-tip")
  self.btnPreview = self:child("LimitedTimeDraw-preview")
  self:child("LimitedTimeDraw-previewText"):SetText(Lang:toText("gui.limit.time.activity.draw.preview"))
  self.btnSingle = self:child("LimitedTimeDraw-single")
  self:child("LimitedTimeDraw-single_text"):SetText(Lang:toText("gui.limit.time.activity.draw.single"))
  self.imgSinglePriceBg = self:child("LimitedTimeDraw-single_price_bg")
  self.imgSinglePriceIcon = self:child("LimitedTimeDraw-single_price_icon")
  self.txtSinglePriceNum = self:child("LimitedTimeDraw-single_price_num")
  self.btnTen = self:child("LimitedTimeDraw-ten")
  self:child("LimitedTimeDraw-ten_text"):SetText(Lang:toText("gui.limit.time.activity.draw.ten"))
  self.imgTenPriceBg = self:child("LimitedTimeDraw-ten_price_bg")
  self.imgTenPriceIcon = self:child("LimitedTimeDraw-ten_price_icon")
  self.txtTenPriceNum = self:child("LimitedTimeDraw-ten_price_num")
  self.txtOff = self:child("LimitedTimeDraw-off")
  self.grdGuarantee = self:child("LimitedTimeDraw-guarantee")
  self.imgBigPrize = self:child("LimitedTimeDraw-bigPrize")
  self.imgBigPrizeIcon = self:child("LimitedTimeDraw-bigPrizeIcon")
  self.txtGuaranteeProgress = self:child("LimitedTimeDraw-guaranteeProgress")
  self.imgBigPrizeFrame = self:child("LimitedTimeDraw-bigPrizeFrame")
  self.imgDiscountsPriceIcon = self:child("LimitedTimeDraw-discounts_price_icon")
  self.txtDiscountsPriceNum1 = self:child("LimitedTimeDraw-discounts_price_num1")
  self.txtDiscountsPriceNum2 = self:child("LimitedTimeDraw-discounts_price_num2")
  self.txtDiscountsCountDown = self:child("LimitedTimeDraw-discounts_count_down")
end

function WinLimitedTimeDraw:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.draw.help"
    })
  end)
  self:subscribe(self.btnPreview, UIEvent.EventButtonClick, function()
    if not self.params or not self.cfg then
      return
    end
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.draw.preview",
      type = Define.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.POND,
      pondId = self.cfg.pondId
    })
  end)
  self:subscribe(self.btnSingle, UIEvent.EventButtonClick, function()
    if not self.params or not self.cfg then
      return
    end
    local params = {}
    params.luckyDrawType = Define.LUCKY_DRAW_TYPE.SINGLE
    params.id = self.params.id
    params.price = self.singlePrice or self.cfg.singlePrice
    Me:playLimitedTimeDraw(params)
  end)
  self:subscribe(self.btnTen, UIEvent.EventButtonClick, function()
    if not self.params or not self.cfg then
      return
    end
    local params = {}
    params.luckyDrawType = Define.LUCKY_DRAW_TYPE.TEN
    params.id = self.params.id
    params.price = self.cfg.tenPrice
    Me:playLimitedTimeDraw(params)
  end)
  self:subscribe(self.imgBigPrize, UIEvent.EventWindowClick, function(window, dx, dy)
    if not self.bigPrizeData then
      return
    end
    LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.bigPrizeData, dx, dy)
  end)
end

function WinLimitedTimeDraw:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_DRAW_GUARANTEE_COUNT, function()
    self:updateView()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_FIRST_PURCHASE_DATA, function()
    self:updatePurchaseInfo()
  end)
end

function WinLimitedTimeDraw:initView()
  self.params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW)
  if self.params and self.params.cfgId then
    self.cfg = LimitedTimeDrawConfig:getCfgById(self.params.cfgId)
  end
  self.txtTip:SetText(Lang:toText({
    "gui.limit.time.activity.draw.tip",
    self.cfg.guaranteeCount
  }))
  self.txtTenPriceNum:SetText(self.cfg.tenPrice)
  self.txtSinglePriceNum:SetText(self.cfg.singlePrice)
  self.txtDiscountsPriceNum1:SetText(self.cfg.singlePrice)
  self.txtDiscountsPriceNum2:SetText(self.cfg.dailyDeals)
  self:updateExhibitionView()
  self:updateView()
end

function WinLimitedTimeDraw:updateExhibitionView()
  if not self.params or not self.cfg then
    return
  end
  local awardsModel = self.cfg.awardsModel
  local awardsIcon = self.cfg.awardsIcon
  local bigPrizeInfo = self:getCurPondBigPrizeInfo()
  local isNeedSpecialCell = LimitedTimeActivityGameMgr:addSpecialCell(self.imgBigPrize, self.bigPrizeData, {
    {0, 0},
    {0, -5},
    {0, 90},
    {0, 114}
  })
  if not isNeedSpecialCell then
    self.imgBigPrizeIcon:SetImage(bigPrizeInfo.itemIcon)
    self.imgBigPrizeFrame:SetImage(bigPrizeInfo.itemIconFrame)
  end
  self.actorActor:SetVisible(false)
  self.imgIcon:SetVisible(false)
  if awardsModel then
    self.actorActor:SetVisible(true)
    self.actorActor:SetActor1(awardsModel, "idle")
  elseif awardsIcon then
    self.imgIcon:SetVisible(true)
    self.imgIcon:SetImage(awardsIcon)
  elseif bigPrizeInfo.actorName then
    self.actorActor:SetVisible(true)
    self.actorActor:SetActor1(bigPrizeInfo.actorName, "idle")
    self.actorActor:SetActorScale(bigPrizeInfo.uiScale or 1)
    self.actorActor:SetRotateY(-45)
    self.actorActor:SetProperty("ActorWindowOffset", bigPrizeInfo.uiOffset or "0 0 0")
  else
    self.imgIcon:SetVisible(true)
    self.imgIcon:SetImage(bigPrizeInfo.itemIcon)
  end
end

function WinLimitedTimeDraw:getCurPondBigPrizeInfo()
  self.bigPrizeData = nil
  if not self.params or not self.cfg then
    return
  end
  local pondId = self.cfg.pondId
  local awardPopup = LimitedTimeDrawAwardsConfig:getCfgByPondId(pondId)
  local bigPrize, itemInfo
  for _, v in pairs(awardPopup) do
    if v.isBigPrize then
      bigPrize = v
      break
    end
  end
  local giftContent = bigPrize.giftContent or {}
  local awardId = giftContent[1]
  if awardId then
    local item = LimitedTimeGiftItemConfig:getCfgById(awardId)
    self.bigPrizeData = item
    if item then
      itemInfo = LimitedTimeActivityGameMgr:getItemInfo(item)
    end
  end
  return itemInfo
end

function WinLimitedTimeDraw:updatePurchaseInfo()
  if not self.params or not self.cfg then
    return
  end
  if self.discountsTimer then
    self.discountsTimer()
    self.discountsTimer = nil
  end
  local purchaseData = Me:getFirstPurchaseData()
  local isDiscount = false
  if purchaseData[self.cfg.pondId] then
    isDiscount = os.time() - purchaseData[self.cfg.pondId] > 86400
  else
    isDiscount = true
  end
  self.singlePrice = isDiscount and self.cfg.dailyDeals or self.cfg.singlePrice
  self.txtSinglePriceNum:SetText(self.singlePrice)
  self.imgSinglePriceIcon:SetVisible(not isDiscount)
  self.imgDiscountsPriceIcon:SetVisible(isDiscount)
  self.txtDiscountsCountDown:SetVisible(false)
  if not isDiscount then
    self.discountsTimer = Me:timer(20, function()
      local surplus = purchaseData[self.cfg.pondId] + 86400 - os.time()
      local timeHour, timeMinute, timeSecond = Lib.timeFormatting(surplus)
      local time = timeHour .. ":" .. timeMinute .. ":" .. timeSecond
      self.txtDiscountsCountDown:SetText(time)
      if 0 < surplus then
        self.txtDiscountsCountDown:SetVisible(true)
      else
        self.txtDiscountsCountDown:SetVisible(false)
        self.imgSinglePriceIcon:SetVisible(true)
      end
      return 0 < surplus
    end)
  end
end

function WinLimitedTimeDraw:updateView()
  if not self.params or not self.cfg then
    return
  end
  self:updatePurchaseInfo()
  local LimitedTimeDrawData = Me:getLimitedTimeDrawData()
  local curCount = 0
  local maxCount = self.cfg.guaranteeCount
  if LimitedTimeDrawData[self.params.contentStartTime] then
    curCount = LimitedTimeDrawData[self.params.contentStartTime]
  end
  if maxCount <= curCount then
    curCount = 0
  end
  self.txtGuaranteeProgress:SetText(curCount .. "/" .. maxCount)
  self.grdGuarantee:SetProgress(curCount / maxCount)
end

function WinLimitedTimeDraw:onHide()
  UI:closeWnd("limitedTimeDraw")
end

function WinLimitedTimeDraw:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeDraw")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeDraw:onOpen()
  self:initView()
  self:subscribeEvent()
  GameAnalytics.NewDesign("limited_draw_click", {})
end

function WinLimitedTimeDraw:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.discountsTimer then
    self.discountsTimer()
    self.discountsTimer = nil
  end
end

return WinLimitedTimeDraw
