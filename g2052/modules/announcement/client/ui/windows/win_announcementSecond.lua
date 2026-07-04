local WinAnnouncementSecond = M

function WinAnnouncementSecond:init()
  WinBase.init(self, "AnnouncementSecond.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

local CLScaleTimer

local function LinearInterpolation(a, b, t)
  return a + (b - a) * t
end

local function ClearCLScaleTimer()
  CLScaleTimer()
  CLScaleTimer = nil
end

local function ForceFinishScaleTweenAnim(w)
  ClearCLScaleTimer()
  local scale = 1
  w:SetScale({
    x = scale,
    y = scale,
    z = scale
  })
end

local function StartScaleTweenAnim(w, info, cb)
  local counter = 0
  local peakIndex = 2
  local lastPeakInfo = {
    scale = info.peakInfo[1].scale,
    timeStamp = 0
  }
  if CLScaleTimer ~= nil then
    ClearCLScaleTimer(w)
  end
  
  local function callBack()
    if cb ~= nil then
      cb()
    end
  end
  
  CLScaleTimer = World.LightTimer("announcement scale timer", 1, function()
    local peakInfo = info.peakInfo[peakIndex]
    if not peakInfo then
      callBack()
      return false
    end
    counter = counter + 1
    local timeStamp = peakInfo.timeStamp
    if timeStamp <= lastPeakInfo.timeStamp then
      callBack()
      return false
    end
    local t = (counter - lastPeakInfo.timeStamp) / (timeStamp - lastPeakInfo.timeStamp)
    local scale = LinearInterpolation(lastPeakInfo.scale, peakInfo.scale, t)
    w:SetScale({
      x = scale,
      y = scale,
      z = scale
    })
    if timeStamp <= counter then
      peakIndex = peakIndex + 1
      lastPeakInfo = peakInfo
    end
    return true
  end)
end

local PX = 0
local FillH = 9

local function FillWord(w, s, maxLine)
  w:SetText(s)
  if maxLine <= 1 then
    return
  end
  local ww = w:GetWidth()[2]
  local wh = w:GetHeight()[2]
  local wordHigh = w:GetFont():GetFontHeight()
  local lineNum = Lib.getTextLineNum(s, w, ww)
  local fillLine = maxLine - lineNum
  if fillLine <= 0 then
    return
  end
  for i = 1, fillLine do
    local index = i - 1
    local posY = (lineNum + index + 0.5) * wordHigh
    local posX = PX
    local len = ww - posX
    local widget = UIMgr:new_widget("announcementWordFill")
    w:AddChildWindow(widget)
    widget:SetArea({0, posX}, {0, posY}, {0, len}, {0, FillH})
  end
end

function WinAnnouncementSecond:initUI()
  self.imgMask = self:child("AnnouncementSecond-Mask")
  self.lytContent = self:child("AnnouncementSecond-Content")
  self.imgBG = self:child("AnnouncementSecond-BG")
  self.imgTOP = self:child("AnnouncementSecond-TOP")
  self.imgTimeBg = self:child("AnnouncementSecond-TimeBg")
  self.txtTimeText = self:child("AnnouncementSecond-TimeText")
  self.imgImage1 = self:child("AnnouncementSecond-Image1")
  self.txtText1 = self:child("AnnouncementSecond-Text1")
  self.imgImage2 = self:child("AnnouncementSecond-Image2")
  self.txtText2 = self:child("AnnouncementSecond-Text2")
  self.imgImage3 = self:child("AnnouncementSecond-Image3")
  self.txtText3 = self:child("AnnouncementSecond-Text3")
  self.imgImage4 = self:child("AnnouncementSecond-Image4")
  self.txtText4 = self:child("AnnouncementSecond-Text4")
  self.imgImage5 = self:child("AnnouncementSecond-Image5")
  self.txtText5 = self:child("AnnouncementSecond-Text5")
  self.imgLine3 = self:child("AnnouncementSecond-Line3")
  self.btnClose = self:child("AnnouncementSecond-Close")
  self.imgTopMask1 = self:child("AnnouncementSecond-TopMask1")
  self.imgTopMask2 = self:child("AnnouncementSecond-TopMask2")
  self.imgTopMask3 = self:child("AnnouncementSecond-TopMask3")
  self.txtTimeText:SetText(Lang:toText("g2052.gui.announcement.time"))
  FillWord(self.txtText1, Lang:toText("g2052.gui.announcement.text_1"), 2)
  FillWord(self.txtText2, Lang:toText("g2052.gui.announcement.text_2"), 2)
  FillWord(self.txtText3, Lang:toText("g2052.gui.announcement.text_3"), 1)
  FillWord(self.txtText4, Lang:toText("g2052.gui.announcement.text_4"), 2)
  FillWord(self.txtText5, Lang:toText("g2052.gui.announcement.text_5"), 1)
end

function WinAnnouncementSecond:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinAnnouncementSecond:subscribeEvent()
end

function WinAnnouncementSecond:initView()
  self.btnClose:SetVisible(false)
  self:autoShowCloseBtn()
end

function WinAnnouncementSecond:autoShowCloseBtn()
  local time = World.cfg.announcementSetting.viewTime or 3
  World.Timer(20 * time, function()
    self.btnClose:SetVisible(true)
    return false
  end)
end

function WinAnnouncementSecond:onHide()
  UI:closeWnd("announcementSecond")
end

function WinAnnouncementSecond:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("announcementSecond")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinAnnouncementSecond:playOpenAnim()
  local cfg = World.cfg.announcementSetting
  if not cfg then
    return
  end
  self.btnClose:SetVisible(false)
  StartScaleTweenAnim(self.lytContent, {
    peakInfo = cfg.jointUI.openScaleAnim.peakInfo
  }, function()
    self.btnClose:SetVisible(true)
  end)
end

function WinAnnouncementSecond:onOpen()
  self:initView()
  self:playOpenAnim()
  self:subscribeEvent()
  self.startShowTime = os.time()
end

function WinAnnouncementSecond:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.startShowTime then
    local defaultData = {
      news_ui_time = os.time() - self.startShowTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "news_ui_open", defaultData, Me)
  end
end

return WinAnnouncementSecond
