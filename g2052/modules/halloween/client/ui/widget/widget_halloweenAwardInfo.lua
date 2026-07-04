local widget_base = require("ui.widget.widget_base")
local WidgetHalloweenAwardInfo = Lib.derive(widget_base)
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")

function WidgetHalloweenAwardInfo:init()
  widget_base.init(self, "HalloweenAwardInfo.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHalloweenAwardInfo:initUI()
  self.imgContentPanel = self:child("HalloweenAwardInfo-ContentPanel")
  self.txtContentStr = self:child("HalloweenAwardInfo-ContentStr")
  self.imgCandyIcon = self:child("HalloweenAwardInfo-CandyIcon")
  self.imgTimePanel = self:child("HalloweenAwardInfo-TimePanel")
  self.txtTimeStr = self:child("HalloweenAwardInfo-TimeStr")
end

function WidgetHalloweenAwardInfo:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HALLOWEEN_CANDY_NUM_UPDATE, function(value)
    self:updatePartUIShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ACTIVITY_CAR_UPDATE, function(value)
    self:updatePartUIShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ACTIVITY_PET_UPDATE, function(value)
    self:updatePartUIShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ACTIVITY_DRESS_UPDATE, function(value)
    self:updatePartUIShow()
  end)
end

function WidgetHalloweenAwardInfo:initPartTipsInfo(cfgInfo, differTime)
  self:stopDownTimer()
  self.cfgInfo = cfgInfo
  local startTime = os.time(self.cfgInfo.startTime)
  local curTime = os.time() + differTime
  self.remainTime = startTime - curTime
  if self.remainTime > 0 then
    self:startDownTimer()
  end
  self:updatePartUIShow()
end

function WidgetHalloweenAwardInfo:updatePartUIShow()
  if not self.cfgInfo or not self.remainTime then
    return
  end
  if HalloweenHelperCommon:isHalloweenDay() then
    self.imgContentPanel:SetVisible(false)
    self.imgTimePanel:SetVisible(false)
    if self.remainTime <= 0 then
      self:stopDownTimer()
      local isHas = false
      self.imgContentPanel:SetVisible(true)
      if self.cfgInfo.awardType == 1 then
        isHas = Me:checkActivityCarIsUnlock(self.cfgInfo.awardId)
      elseif self.cfgInfo.awardType == 2 then
        isHas = Me:checkActivityPetIsUnlock(self.cfgInfo.awardId)
      elseif self.cfgInfo.awardType == 3 then
        isHas = Me:checkActivityDressIsUnlock(self.cfgInfo.awardId)
      end
      if isHas then
        self.imgCandyIcon:SetVisible(false)
        self.txtContentStr:SetText(Lang:toText("g2052.gui.halloween.exchange.success"))
      else
        self.imgCandyIcon:SetVisible(true)
        local num = Me:getHalloweenCandy()
        local text = Lang:toText({
          "g2052.gui.halloween.exchange.condition",
          num,
          self.cfgInfo.costNum
        })
        self.txtContentStr:SetText(text)
        local strW = self.txtContentStr:GetFont():GetStringWidth(text)
        self.imgCandyIcon:SetXPosition({
          0,
          strW / 2 + 20
        })
      end
    else
      self.imgTimePanel:SetVisible(true)
      self.imgCandyIcon:SetVisible(false)
      if self.remainTime >= 86400 then
        local text = Lang:toText({
          "g2052.gui.halloween.start.day",
          math.floor(self.remainTime / 24 / 3600)
        })
        self.txtTimeStr:SetText(text)
      else
        local hours, min, second = Lib.timeFormatting(self.remainTime)
        local timeStr = string.format("%02d:%02d:%02d", hours, min, second)
        local text = Lang:toText({
          "g2052.gui.halloween.start.hour",
          timeStr
        })
        self.txtTimeStr:SetText(text)
      end
    end
  else
    self:stopDownTimer()
    self.imgContentPanel:SetVisible(false)
    self.imgTimePanel:SetVisible(false)
  end
end

function WidgetHalloweenAwardInfo:startDownTimer()
  self.downTimer = World.Timer(20, function()
    self.remainTime = self.remainTime - 1
    self:updatePartUIShow()
    return true
  end)
end

function WidgetHalloweenAwardInfo:stopDownTimer()
  if self.downTimer then
    self.downTimer()
    self.downTimer = nil
  end
end

function WidgetHalloweenAwardInfo:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopDownTimer()
end

return WidgetHalloweenAwardInfo
