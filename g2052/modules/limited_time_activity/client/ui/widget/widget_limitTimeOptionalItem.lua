local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeOptionalItem = Lib.derive(widget_base)

function WidgetLimitTimeOptionalItem:init()
  widget_base.init(self, "LimitTimeOptionalItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeOptionalItem:initUI()
  self.imgBG = self:child("LimitTimeOptionalItem-BG")
  self.lytContentPanel = self:child("LimitTimeOptionalItem-ContentPanel")
  self.txtNameText = self:child("LimitTimeOptionalItem-NameText")
  self.imgDiaIcon = self:child("LimitTimeOptionalItem-DiaIcon")
  self.txtFinalPrice = self:child("LimitTimeOptionalItem-finalPrice")
  self.txtLimitText = self:child("LimitTimeOptionalItem-LimitText")
  self.txtLimitDayText = self:child("LimitTimeOptionalItem-LimitDayText")
  self.lytItemPanel = self:child("LimitTimeOptionalItem-ItemPanel")
  self.btnBuyBtn = self:child("LimitTimeOptionalItem-BuyBtn")
  self.txtBuyText = self:child("LimitTimeOptionalItem-BuyText")
  self.btnCustomBtn = self:child("LimitTimeOptionalItem-CustomBtn")
  self.txtCustomText = self:child("LimitTimeOptionalItem-CustomText")
  self.imgSoulMask = self:child("LimitTimeOptionalItem-SoulMask")
  self.imgSoulIcon = self:child("LimitTimeOptionalItem-SoulIcon")
  self.txtSoulText = self:child("LimitTimeOptionalItem-SoulText")
  self.txtSoulText:SetText(Lang:toText("gui.limit.time.activity.soul.out"))
  self.txtBuyText:SetText(Lang:toText("gui.limit.time.activity.optional.buy"))
  self.txtCustomText:SetText(Lang:toText("gui.limit.time.activity.optional.custom"))
  self.giftCells = {}
  for i = 1, 4 do
    self.giftCells[i] = UIMgr:new_widget("limitTimeOptionalCell")
    self.giftCells[i]:SetXPosition({
      0,
      (i - 1) * 104
    })
    self.giftCells[i]:SetYPosition({0, 0})
    self.lytItemPanel:AddChildWindow(self.giftCells[i])
  end
end

function WidgetLimitTimeOptionalItem:initEvent()
  self:subscribe(self.btnBuyBtn, UIEvent.EventButtonClick, function()
    local data = Lib.copy(self.data)
    for key, val in pairs(self.customList) do
      table.insert(data.giftContent, val)
    end
    UI:openWnd("limitedTimeConfirmCommon", Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT, data)
  end)
  self:subscribe(self.btnCustomBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("limitTimeOptionalCustomWnd", false, self.data.id, 1)
  end)
end

function WidgetLimitTimeOptionalItem:onDataChanged(data)
  self.data = data
  self.customList = Me:getLimitedTimeOptionalKeyData(self.data.giftKey)
  self.boughtCounts = Me:getLimitedTimeOptionalBuy()[self.data.giftKey] or 0
  self.txtNameText:SetText(Lang:toText(data.giftName or ""))
  self.txtFinalPrice:SetText(Lang:toText(data.finalPrice))
  if 0 < data.limitDayNum then
    self.imgBG:SetImage("set:limit_time_optional_gift.json image:img_0_gift_pack")
    self.txtFinalPrice:SetTextColor({
      0.9019607843137255,
      0.7764705882352941,
      0.49019607843137253,
      1
    })
    local remainCounts = data.limitCounts - self.boughtCounts
    remainCounts = data.limitDayNum - self.boughtCounts
    self.txtLimitDayText:SetVisible(true)
    self.txtLimitText:SetVisible(false)
    if 0 < remainCounts then
      self:stopDownTimer()
      self.imgSoulMask:SetVisible(false)
      if #self.customList >= self.data.optionalNum then
        self.btnCustomBtn:SetVisible(false)
        self.btnBuyBtn:SetVisible(true)
        self.btnBuyBtn:SetEnabled(true)
        self.btnBuyBtn:SetTouchable(true)
      else
        self.btnCustomBtn:SetVisible(true)
        self.btnBuyBtn:SetVisible(false)
      end
      self.txtLimitDayText:SetText(Lang:toText({
        "gui.limit.time.activity.day.limit.counts",
        remainCounts
      }))
    else
      self.imgSoulMask:SetVisible(false)
      self.btnCustomBtn:SetVisible(false)
      self.btnBuyBtn:SetVisible(true)
      self.btnBuyBtn:SetEnabled(false)
      self.btnBuyBtn:SetTouchable(false)
      self:startDownTimer()
    end
  else
    self.imgBG:SetImage("set:limit_time_optional_gift.json image:img_0_gift_pack02")
    self.txtFinalPrice:SetTextColor({
      0.43137254901960786,
      0.4392156862745098,
      0.5882352941176471,
      1
    })
    self:stopDownTimer()
    self.txtLimitDayText:SetVisible(false)
    local remainCounts = data.limitCounts - self.boughtCounts
    self.txtLimitText:SetText(Lang:toText({
      "gui.limit.time.activity.limit.counts",
      remainCounts
    }))
    if 0 < remainCounts then
      self.imgSoulMask:SetVisible(false)
      self.txtLimitText:SetVisible(true)
      if #self.customList >= self.data.optionalNum then
        self.btnCustomBtn:SetVisible(false)
        self.btnBuyBtn:SetVisible(true)
        self.btnBuyBtn:SetEnabled(true)
        self.btnBuyBtn:SetTouchable(true)
      else
        self.btnCustomBtn:SetVisible(true)
        self.btnBuyBtn:SetVisible(false)
      end
    else
      self.imgSoulMask:SetVisible(true)
      self.btnBuyBtn:SetVisible(false)
      self.btnCustomBtn:SetVisible(false)
      self.txtLimitText:SetVisible(false)
    end
  end
  self:updateItemListShow()
end

function WidgetLimitTimeOptionalItem:startDownTimer()
  self:stopDownTimer()
  local curTime = os.time()
  self.downRemainTime = Lib.getDayEndTime(curTime) - curTime
  local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(self.downRemainTime))
  self.txtLimitDayText:SetText(text)
  self.downTimer = World.Timer(20, function()
    self.downRemainTime = self.downRemainTime - 1
    local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(self.downRemainTime))
    self.txtLimitDayText:SetText(text)
    if self.downRemainTime <= 0 then
      self:stopDownTimer()
      return false
    end
    return true
  end)
end

function WidgetLimitTimeOptionalItem:stopDownTimer()
  if self.downTimer then
    self.downTimer()
    self.downTimer = nil
  end
end

function WidgetLimitTimeOptionalItem:updateItemListShow()
  local num1 = #self.data.giftContent
  local counts = num1 + self.data.optionalNum
  for index = 1, 4 do
    if index > counts then
      self.giftCells[index]:SetVisible(false)
    else
      self.giftCells[index]:SetVisible(true)
      if index <= num1 then
        self.giftCells[index]:invoke("updateGoodsInfo", true, self.data.giftContent[index])
      else
        self.giftCells[index]:invoke("updateGoodsInfo", false, self.customList[index - num1], self.data.id, index - num1)
      end
    end
  end
end

function WidgetLimitTimeOptionalItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:stopDownTimer()
  for index = 1, 4 do
    if self.lytItemPanel then
      self.lytItemPanel:RemoveChildWindow1(self.giftCells[index])
      GUIWindowManager.instance:DestroyGUIWindow(self.giftCells[index])
    end
  end
  self.giftCells = {}
end

return WidgetLimitTimeOptionalItem
