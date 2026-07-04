local WinLimitedTimeGoldWheel = M
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeGoldWheelConfig = T(Config, "LimitedTimeGoldWheelConfig")
local LimitedTimeGoldWheelAwardsConfig = T(Config, "LimitedTimeGoldWheelAwardsConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local rotationAngle = {
  0,
  60,
  120,
  180,
  240,
  300
}

function WinLimitedTimeGoldWheel:init()
  WinBase.init(self, "LimitedTimeGoldWheel.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeGoldWheel:initData()
  self.awards = LimitedTimeGiftItemConfig:getAllCfgs()
end

function WinLimitedTimeGoldWheel:initUI()
  self.btnHelp = self:child("LimitedTimeGoldWheel-help")
  self.txtTitle = self:child("LimitedTimeGoldWheel-title")
  self.imgWheel = self:child("LimitedTimeGoldWheel-wheel")
  self.imgWheelFace = self:child("LimitedTimeGoldWheel-wheel_face")
  self.imgHighlight = self:child("LimitedTimeGoldWheel-highlight")
  self.btnPay = self:child("LimitedTimeGoldWheel-pay")
  self:child("LimitedTimeGoldWheel-go"):SetText("GO")
  self.imgCurrency1 = self:child("LimitedTimeGoldWheel-currency1")
  self.txtCurrencyNum1 = self:child("LimitedTimeGoldWheel-currency_num1")
  self.txtCurrencyNum2 = self:child("LimitedTimeGoldWheel-currency_num2")
  self.imgCurrency = self:child("LimitedTimeGoldWheel-currency")
  self.txtCurrencyNum = self:child("LimitedTimeGoldWheel-currency_num")
  self.txtCountDown = self:child("LimitedTimeGoldWheel-count_down")
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.gold.wheel.title"))
  self:initItemList()
end

function WinLimitedTimeGoldWheel:initItemList()
  self.ratioItem = {}
  for i = 1, 6 do
    self.ratioItem[i] = UIMgr:new_widget("limitedTimeGoldWheelCell")
    local itemPos = self:getPosByAngleAndRadius(rotationAngle[i], 188)
    self.ratioItem[i]:SetArea({
      0,
      itemPos.x
    }, {
      0,
      itemPos.y
    }, {0, 89}, {0, 89})
    self.imgWheelFace:AddChildWindow(self.ratioItem[i])
  end
end

function WinLimitedTimeGoldWheel:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.gold.wheel.help"
    })
  end)
  self:subscribe(self.btnPay, UIEvent.EventButtonClick, function()
    if not (self.params and self.cfg) or not self.pond then
      return
    end
    local params = {}
    params.id = self.params.id
    params.price = self.isDiscount and self.cfg.dailyDeals or self.cfg.price
    Me:playLimitedTimeGoldWheel(params)
  end)
end

function WinLimitedTimeGoldWheel:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GET_LIMITED_TIME_GOLD_WHEEL_RESULT, function(addition)
    self.addition = addition
    self:startWheel(addition)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_FIRST_PURCHASE_DATA, function()
    self:updatePurchaseInfo()
  end)
end

function WinLimitedTimeGoldWheel:getPosByAngleAndRadius(angle, radius, offset)
  local offset = offset and offset * -1 or 0
  local yaw = angle + offset
  local value = math.rad(yaw)
  local s = math.sin(value)
  local c = math.cos(value)
  return Lib.v3(s, c, 0) * radius * -1
end

function WinLimitedTimeGoldWheel:initView()
  self:updateView()
  self.imgHighlight:SetVisible(false)
end

function WinLimitedTimeGoldWheel:updatePurchaseInfo()
  if not self.params or not self.cfg then
    return
  end
  if self.discountsTimer then
    self.discountsTimer()
    self.discountsTimer = nil
  end
  self.txtCurrencyNum1:SetText(self.cfg.price)
  self.txtCurrencyNum2:SetText(self.cfg.dailyDeals)
  self.txtCurrencyNum:SetText(self.cfg.price)
  local purchaseData = Me:getFirstPurchaseData()
  local isDiscount = false
  if purchaseData[self.cfg.pondId] then
    isDiscount = os.time() - purchaseData[self.cfg.pondId] > 86400
  else
    isDiscount = true
  end
  self.imgCurrency1:SetVisible(isDiscount)
  self.imgCurrency:SetVisible(not isDiscount)
  self.txtCountDown:SetVisible(not isDiscount)
  self.isDiscount = isDiscount
  if not isDiscount then
    self.discountsTimer = Me:timer(20, function()
      local surplus = purchaseData[self.cfg.pondId] + 86400 - os.time()
      local timeHour, timeMinute, timeSecond = Lib.timeFormatting(surplus)
      local time = timeHour .. ":" .. timeMinute .. ":" .. timeSecond
      self.txtCountDown:SetText(time)
      if 0 < surplus then
        self.txtCountDown:SetVisible(true)
      else
        self.imgCurrency1:SetVisible(true)
        self.txtCountDown:SetVisible(false)
        self.imgCurrency:SetVisible(false)
      end
      return 0 < surplus
    end)
  end
end

function WinLimitedTimeGoldWheel:updateView()
  self.params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL)
  if self.params then
    local cfg = LimitedTimeGoldWheelConfig:getCfgByActivityId(self.params.id)
    if not cfg or not cfg[1] then
      return
    end
    self.cfg = cfg[1]
    self.pond = LimitedTimeGoldWheelAwardsConfig:getCfgByPondId(self.cfg.pondId)
    self:updatePurchaseInfo()
    for i, v in pairs(self.pond or {}) do
      local itemPos = self:getPosByAngleAndRadius(rotationAngle[v.sortId], self.cfg.radius)
      self.ratioItem[v.sortId]:SetArea({
        0,
        itemPos.x
      }, {
        0,
        itemPos.y
      }, {0, 89}, {0, 89})
      local item = self.awards[v.giftContent[1]] or {}
      item.tag = v.tag
      self.ratioItem[v.sortId]:invoke("updateView", item)
    end
    self.imgWheelFace:SetProperty("Rotate", 0)
  end
end

function WinLimitedTimeGoldWheel:showHighlight(callBack)
  if self.highlightTimer then
    self.highlightTimer()
    self.highlightTimer = nil
    self.imgHighlight:SetVisible(false)
  end
  local count = 10
  self.imgHighlight:SetVisible(true)
  self.highlightTimer = Me:timer(1, function()
    count = count - 1
    local surplus = count % 2
    self.imgHighlight:SetVisible(surplus == 0)
    if count < 1 and callBack then
      callBack()
    end
    return 0 < count
  end)
end

local function directionalConditionJudgment(direction, obey, defy)
  local needAlter = false
  if 0 < direction then
    needAlter = obey
  else
    needAlter = defy
  end
  return needAlter
end

function WinLimitedTimeGoldWheel:startWheel(addition)
  local target = addition and addition.item and addition.item.sortId
  if not target or not rotationAngle[target] then
    Me.inPlayLimitedTimeGoldWheel = false
    return
  end
  if self.wheelTimer then
    self.wheelTimer()
    self.wheelTimer = nil
  end
  local aSpeed = self.cfg and self.cfg.aSpeed or 1
  local direction = aSpeed / math.abs(aSpeed)
  local carSpeed = 0
  local maxSpeed = self.cfg and self.cfg.maxSpeed or 30
  local minSpeed = self.cfg and self.cfg.minSpeed or 10
  local timeInOneLap = math.abs(math.floor(360 / maxSpeed))
  local highSpeedRotateCount = timeInOneLap * (self.cfg and self.cfg.highSpeedWhirl or 5)
  local curAngle, slowDownAngle
  local startSlowDown = false
  local condition = false
  self.imgHighlight:SetVisible(false)
  self.wheelTimer = Me:timer(1, function()
    if 0 < highSpeedRotateCount then
      if directionalConditionJudgment(direction, carSpeed < maxSpeed, carSpeed > maxSpeed) then
        carSpeed = carSpeed + aSpeed
      else
        carSpeed = maxSpeed
        highSpeedRotateCount = highSpeedRotateCount - 1
      end
    elseif directionalConditionJudgment(direction, carSpeed > minSpeed, carSpeed < minSpeed) then
      carSpeed = carSpeed - aSpeed
    elseif not startSlowDown then
      carSpeed = minSpeed
    elseif directionalConditionJudgment(direction, carSpeed <= 0, 0 <= carSpeed) then
      carSpeed = direction
    end
    self.curRotateAngle = self.curRotateAngle + carSpeed
    if highSpeedRotateCount <= 0 then
      local num = math.floor(self.curRotateAngle / 360)
      if not curAngle then
        local rotationA = 0 < direction and rotationAngle[target] or 360 - rotationAngle[target]
        curAngle = rotationA * direction + (num + 1 * direction) * 360
      end
      if not slowDownAngle then
        local dis = minSpeed * minSpeed / 2 * direction
        slowDownAngle = curAngle - dis
      end
      if 0 < aSpeed then
        condition = curAngle < self.curRotateAngle
        startSlowDown = slowDownAngle < self.curRotateAngle
      else
        condition = curAngle > self.curRotateAngle
        startSlowDown = slowDownAngle > self.curRotateAngle
      end
      if condition then
        for _, v in pairs(self.pond or {}) do
          local itemPos = self:getPosByAngleAndRadius(rotationAngle[v.sortId], self.cfg.radius, self.curRotateAngle)
          self.ratioItem[v.sortId]:SetArea({
            0,
            itemPos.x
          }, {
            0,
            itemPos.y
          }, {0, 89}, {0, 89})
        end
        self.imgWheelFace:SetProperty("Rotate", self.curRotateAngle)
        self:showHighlight(function()
          UI:openWnd("limitedTimeActivityAwardPopup", addition)
          self.addition = nil
          Me.inPlayLimitedTimeGoldWheel = false
        end)
        return false
      elseif startSlowDown then
        carSpeed = carSpeed - direction
      end
    end
    for i, v in pairs(self.pond or {}) do
      local itemPos = self:getPosByAngleAndRadius(rotationAngle[v.sortId], self.cfg.radius, self.curRotateAngle)
      self.ratioItem[i]:SetArea({
        0,
        itemPos.x
      }, {
        0,
        itemPos.y
      }, {0, 89}, {0, 89})
    end
    self.imgWheelFace:SetProperty("Rotate", self.curRotateAngle)
    return true
  end)
end

function WinLimitedTimeGoldWheel:onHide()
  UI:closeWnd("limitedTimeGoldWheel")
end

function WinLimitedTimeGoldWheel:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeGoldWheel")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeGoldWheel:onOpen()
  self.isOpen = true
  self.curRotateAngle = 0
  self:initView()
  self:subscribeEvent()
  GameAnalytics.NewDesign("turntable_click", {})
end

function WinLimitedTimeGoldWheel:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self.params = nil
  self.cfg = nil
  self.pond = nil
  self.isOpen = false
  if self.wheelTimer then
    self.wheelTimer()
    self.wheelTimer = nil
    if self.addition then
      UI:openWnd("limitedTimeActivityAwardPopup", self.addition)
      self.addition = nil
    end
    Me.inPlayLimitedTimeGoldWheel = false
  end
  if self.highlightTimer then
    self.highlightTimer()
    self.highlightTimer = nil
    self.imgHighlight:SetVisible(false)
    if self.addition then
      UI:openWnd("limitedTimeActivityAwardPopup", self.addition)
      self.addition = nil
    end
    Me.inPlayLimitedTimeGoldWheel = false
  end
  if self.discountsTimer then
    self.discountsTimer()
    self.discountsTimer = nil
  end
end

return WinLimitedTimeGoldWheel
