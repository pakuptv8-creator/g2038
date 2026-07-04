local WinLimitTimeCombination = M
local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitTimeCombination:init()
  WinBase.init(self, "LimitTimeCombination.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeCombination:initUI()
  self.lytBackBg = self:child("LimitTimeCombination-BackBg")
  self.lytContentPanel = self:child("LimitTimeCombination-ContentPanel")
  self.imgBG = self:child("LimitTimeCombination-BG")
  self.btnCloseBtn = self:child("LimitTimeCombination-CloseBtn")
  self.txtTitleText = self:child("LimitTimeCombination-TitleText")
  self.imgRemainIcon = self:child("LimitTimeCombination-remainIcon")
  self.txtRemainText = self:child("LimitTimeCombination-remainText")
  self.txtOFFText = self:child("LimitTimeCombination-OFFText")
  self.txtPerText = self:child("LimitTimeCombination-PerText")
  self.lytItemPanel = self:child("LimitTimeCombination-ItemPanel")
  self.imgBubbleIcon = self:child("LimitTimeCombination-BubbleIcon")
  self.txtLimitText = self:child("LimitTimeCombination-LimitText")
  self.btnBuyBtn = self:child("LimitTimeCombination-BuyBtn")
  self.imgFinalDiaIcon = self:child("LimitTimeCombination-FinalDiaIcon")
  self.txtFinalPrice = self:child("LimitTimeCombination-FinalPrice")
  self.imgInitDiaIcon = self:child("LimitTimeCombination-InitDiaIcon")
  self.txtInitPrice = self:child("LimitTimeCombination-InitPrice")
  self.imgInitLine = self:child("LimitTimeCombination-InitLine")
  self.lytMaskPanel = self:child("LimitTimeCombination-MaskPanel")
  self.lytMaskPanel:SetVisible(false)
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.lytItemPanel:AddChildWindow(self.gvItemList)
  self.gvItemList:SethScorllMoveAble(true)
  self.gvItemList:SetvScorllMoveAble(false)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:InitConfig(28, 0, 1)
  self.goodsCells = {}
  self.txtOFFText:SetText(Lang:toText("gui.limit.time.combined.off"))
  self.txtLimitText:SetText(Lang:toText({
    "gui.limit.time.combined.limit",
    1
  }))
end

function WinLimitTimeCombination:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnBuyBtn, UIEvent.EventButtonClick, function()
    if not self.activityData then
      return
    end
    if self.isBuying then
      return
    end
    if Lib.checkMoney(Me, 0, self.activityData.finalPrice, true) then
      local params = {
        activityId = self.activityData.activityId,
        id = self.activityData.id
      }
      LimitedTimeActivityGameMgr:clientClickBoughtBtn(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT, params)
    else
      LimitedTimeActivityGameMgr:showBuyFailTip()
    end
  end)
end

function WinLimitTimeCombination:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_COMBINATION_BUY, function(combinedGiftData)
    self:updateBoughtBtnShow(combinedGiftData)
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

function WinLimitTimeCombination:initView()
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
  self.curTime = LimitedTimeActivityGameMgr:getServerTime()
  self.endTime = self.activityInfo.endNumTime or getTimeByArray(self.activityInfo.endTime)
  self:updateActivityGoodsShow()
  self:updateActivityTimeShow()
  self:startDownTimer()
end

function WinLimitTimeCombination:updateBuyingState(value)
  self.isBuying = value
end

function WinLimitTimeCombination:getBuyingState()
  return self.isBuying
end

function WinLimitTimeCombination:updateActivityGoodsShow()
  self.activityData = LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activityInfo.id)
  if not self.activityData then
    return
  end
  if self.activityData.giftName and self.activityData.giftName ~= "" then
    self.txtTitleText:SetText(Lang:toText(self.activityData.giftName))
  else
    self.txtTitleText:SetText(Lang:toText("gui.limit.time.combined.title"))
  end
  self.txtPerText:SetText(self.activityData.percent)
  local combinedGiftData = Me:getCombinedGiftData()
  self:updateBoughtBtnShow(combinedGiftData)
  self:updateGoodsItemShow()
end

function WinLimitTimeCombination:updateBoughtBtnShow(combinedGiftData)
  local giftKey = self.activityData.giftKey
  if combinedGiftData[giftKey] then
    self.btnBuyBtn:SetText(Lang:toText("gui.limit.time.combined.purchased"))
    self.imgInitDiaIcon:SetVisible(false)
    self.imgFinalDiaIcon:SetVisible(false)
    self.btnBuyBtn:SetEnabled(false)
    self.btnBuyBtn:SetTouchable(false)
    local isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
    LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(isOpen)
  else
    self.btnBuyBtn:SetEnabled(true)
    self.btnBuyBtn:SetTouchable(true)
    self.btnBuyBtn:SetText("")
    self.imgInitDiaIcon:SetVisible(true)
    self.imgFinalDiaIcon:SetVisible(true)
    self.txtFinalPrice:SetText(self.activityData.finalPrice)
    self.txtInitPrice:SetText(self.activityData.initPrice)
    local strW = self.txtInitPrice:GetFont():GetStringWidth(self.activityData.initPrice)
    self.imgInitLine:SetWidth({
      0,
      strW + 35
    })
  end
end

function WinLimitTimeCombination:updateGoodsItemShow()
  self.gvItemList:InitConfig(20, 0, #self.activityData.giftContent)
  for i, cell in pairs(self.goodsCells or {}) do
    if i > #self.activityData.giftContent then
      self.gvItemList:RemoveItem(cell)
      self.goodsCells[i] = nil
    end
  end
  local index = 0
  for _, value in pairs(self.activityData.giftContent or {}) do
    local itemInfo = LimitedTimeGiftItemConfig:getCfgById(value)
    if itemInfo then
      index = index + 1
      if not self.goodsCells[index] then
        local cell = UIMgr:new_widget("limitTimeCombinedItem")
        cell:invoke("updateInfo", itemInfo)
        self.gvItemList:AddItem(cell)
        self.goodsCells[index] = cell
      else
        self.goodsCells[index]:invoke("updateInfo", itemInfo)
      end
    end
  end
end

function WinLimitTimeCombination:updateActivityTimeShow()
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

function WinLimitTimeCombination:startDownTimer()
  self:stopDownTimer()
  self.downTimer = World.Timer(20, function()
    self.curTime = self.curTime + 1
    self:updateActivityTimeShow()
    return true
  end)
end

function WinLimitTimeCombination:stopDownTimer()
  if self.downTimer then
    self.downTimer()
    self.downTimer = nil
  end
end

function WinLimitTimeCombination:onHide()
  UI:closeWnd("limitTimeCombination")
end

function WinLimitTimeCombination:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeCombination")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeCombination:onOpen()
  self:initView()
  self:subscribeEvent()
  LimitedTimeActivityGameMgr:updateCombinedLimitBtnRedDot(false)
end

function WinLimitTimeCombination:onClose()
  self:stopDownTimer()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitTimeCombination
