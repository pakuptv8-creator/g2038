local WinFacePhotoWnd = M
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local MustWinLotteryAwardConfig = T(Config, "MustWinLotteryAwardConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

local function getTimeByArray(array)
  local data = {
    year = array[1] or 0,
    month = array[2] or 0,
    day = array[3] or 0,
    hour = array[4] or 0,
    min = array[5] or 0,
    sec = array[6] or 0
  }
  return os.time(data)
end

function WinFacePhotoWnd:init()
  WinBase.init(self, "FacePhotoWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinFacePhotoWnd:initUI()
  self.lytMask = self:child("FacePhotoWnd-mask")
  self.lytWnd = self:child("FacePhotoWnd-wnd")
  self.imgPanelBg = self:child("FacePhotoWnd-panelBg")
  self.btnClose = self:child("FacePhotoWnd-close")
  self.imgCloseImg = self:child("FacePhotoWnd-closeImg")
  self.imgFrame1 = self:child("FacePhotoWnd-frame1")
  self.imgIcon1 = self:child("FacePhotoWnd-icon1")
  self.btnGoBtn1 = self:child("FacePhotoWnd-goBtn1")
  self.txtGoText1 = self:child("FacePhotoWnd-goText1")
  self.imgFrame2 = self:child("FacePhotoWnd-frame2")
  self.imgIcon2 = self:child("FacePhotoWnd-icon2")
  self.btnGoBtn2 = self:child("FacePhotoWnd-goBtn2")
  self.txtGoText2 = self:child("FacePhotoWnd-goText2")
  self.imgFrame3 = self:child("FacePhotoWnd-frame3")
  self.imgIcon3 = self:child("FacePhotoWnd-icon3")
  self.btnGoBtn3 = self:child("FacePhotoWnd-goBtn3")
  self.txtGoText3 = self:child("FacePhotoWnd-goText3")
  self.imgTimeBg = self:child("FacePhotoWnd-timeBg")
  self.imgTimeIcon = self:child("FacePhotoWnd-timeIcon")
  self.txtTimeText = self:child("FacePhotoWnd-timeText")
  self.txtDescText = self:child("FacePhotoWnd-descText")
  self.txtTitleText = self:child("FacePhotoWnd-titleText")
  self.titleImage = self:child("FacePhotoWnd-titleImage")
  self.txtGoText1:SetText(Lang:toText("g2052.gui.tendering.sign.go_land"))
  self.txtGoText2:SetText(Lang:toText("g2052.gui.tendering.sign.go_land"))
  self.txtGoText3:SetText(Lang:toText("g2052.gui.tendering.sign.go_land"))
end

function WinFacePhotoWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:updateShowIndex()
  end)
  self:subscribe(self.btnGoBtn1, UIEvent.EventButtonClick, function()
    self:DoGoToFunc(1)
  end)
  self:subscribe(self.btnGoBtn2, UIEvent.EventButtonClick, function()
    self:DoGoToFunc(2)
  end)
  self:subscribe(self.btnGoBtn3, UIEvent.EventButtonClick, function()
    self:DoGoToFunc(3)
  end)
  self:subscribe(self.imgFrame1, UIEvent.EventWindowClick, function()
    self:previewFaceItem(1)
  end)
  self:subscribe(self.imgFrame2, UIEvent.EventWindowClick, function()
    self:previewFaceItem(2)
  end)
  self:subscribe(self.imgFrame3, UIEvent.EventWindowClick, function()
    self:previewFaceItem(3)
  end)
end

function WinFacePhotoWnd:subscribeEvent()
end

local function getCountDown(self)
  if not self.curEndTime then
    return 0
  end
  local curTime = LimitedTimeActivityGameMgr:getServerTime()
  local surplus = self.curEndTime - curTime
  if surplus < 0 then
    return 0
  end
  local d = math.floor(surplus / 86400)
  local h, m, s = Lib.timeFormatting(surplus % 86400)
  if 0 < d then
    return d .. "d " .. h .. "h "
  end
  if 0 < h then
    return h .. "h " .. m .. "m "
  end
  return m .. "m " .. s .. "s "
end

function WinFacePhotoWnd:initView(showList)
  self.showList = showList
  self.curIndex = 1
  self.curShowCfg = nil
  self:updateViewShow()
end

function WinFacePhotoWnd:updateShowIndex()
  self.curIndex = self.curIndex + 1
  if self.curIndex > #self.showList then
    self:onHide()
  else
    self:updateViewShow()
  end
end

local qualityImage = {
  [3] = "set:g2052_shop_new.json image:img_0_bubble3",
  [4] = "set:g2052_shop_new.json image:img_0_bubble2",
  [5] = "set:g2052_shop_new.json image:img_0_bubble1"
}

function WinFacePhotoWnd:updateViewShow()
  if self.activityTimer then
    self.activityTimer()
    self.activityTimer = nil
  end
  self.curShowCfg = self.showList[self.curIndex]
  self.imgPanelBg:SetImage(self.curShowCfg.faceImage)
  self.txtDescText:SetText(Lang:toText(self.curShowCfg.desc))
  self.imgFrame1:SetVisible(false)
  self.imgFrame2:SetVisible(false)
  self.imgFrame3:SetVisible(false)
  self.btnGoBtn1:SetVisible(false)
  self.btnGoBtn2:SetVisible(false)
  self.btnGoBtn3:SetVisible(false)
  self.titleImage:SetVisible(false)
  self.txtTitleText:SetVisible(false)
  self.imgTimeBg:SetVisible(false)
  if self.curShowCfg.typeId == 1 then
    self.btnGoBtn1:SetVisible(true)
    self.titleImage:SetVisible(true)
    self.titleImage:SetImage("set:g2052_shop_new.json image:text_" .. World.LangPrefix)
    for i = 1, 3 do
      local goodsId = self.curShowCfg.goodsList[i]
      if goodsId then
        self["imgFrame" .. i]:SetVisible(true)
        local mustCfg = MustWinLotteryAwardConfig:getCfgById(goodsId)
        local awardData = LimitedTimeGiftItemConfig:getCfgById(mustCfg.giftContent[1])
        local itemCfg = Me:getBusinessItemCfg(awardData.awardType, awardData.itemId)
        self["imgIcon" .. i]:SetImage(itemCfg.icon)
        if mustCfg.quality then
          self["imgFrame" .. i]:SetImage(qualityImage[mustCfg.quality])
          if mustCfg.quality == 5 then
            self["imgFrame" .. i]:SetEffectName("fisherman_gift_gold.effect")
          else
            self["imgFrame" .. i]:SetEffectName("")
          end
        end
      end
    end
    self.imgTimeBg:SetVisible(true)
    local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
    self.curEndTime = params.contentEndTime and params.contentEndTime or params.endNumTime or getTimeByArray(params.endTime)
    self.txtTimeText:SetText(getCountDown(self))
    self.activityTimer = Me:timer(20, function()
      self:updateDownTimeShow()
      return true
    end)
  else
    self.txtTitleText:SetVisible(true)
    self.txtTitleText:SetText(Lang:toText(self.curShowCfg.title))
    self.btnGoBtn1:SetVisible(true)
    self.btnGoBtn2:SetVisible(true)
    self.btnGoBtn3:SetVisible(true)
    for i = 1, 3 do
      local goodsId = self.curShowCfg.goodsList[i]
      if goodsId then
        self["imgFrame" .. i]:SetVisible(true)
        local goodsCfg = BusinessGoodsConfig:getCfgById(goodsId)
        local itemCfg = Me:getBusinessItemCfg(goodsCfg.goodsType, goodsCfg.itemId)
        self["imgIcon" .. i]:SetImage(itemCfg.icon)
        self["imgFrame" .. i]:SetImage(qualityImage[3])
      end
    end
  end
  local reportData = {
    face_photo_id = self.curShowCfg.id or 0
  }
  Plugins.CallTargetPluginFunc("report", "report", "event_image_appear", reportData, Me)
end

function WinFacePhotoWnd:updateDownTimeShow()
  self.txtTimeText:SetText(getCountDown(self))
end

function WinFacePhotoWnd:DoGoToFunc(clickIndex)
  if self.curShowCfg.typeId == 1 then
    Plugins.CallTargetPluginFunc("limited_time_activity", "openLimitTimeActivityWnd")
  else
    local goodsId = self.curShowCfg.goodsList[clickIndex]
    UI:openWnd("g2052Shop", goodsId)
  end
  local reportData = {
    face_photo_id = self.curShowCfg.id or 0
  }
  Plugins.CallTargetPluginFunc("report", "report", "fish_image_enter", reportData, Me)
  self:updateShowIndex()
end

function WinFacePhotoWnd:previewFaceItem(clickIndex)
  if self.curShowCfg.typeId == 1 then
    local goodsId = self.curShowCfg.goodsList[clickIndex]
    if goodsId then
      local mustCfg = MustWinLotteryAwardConfig:getCfgById(goodsId)
      UI:openWnd("shopAwardPreview", mustCfg)
      local reportData = {
        face_award_id = goodsId or 0
      }
      Plugins.CallTargetPluginFunc("report", "report", "fish_image_preview", reportData, Me)
    end
  end
end

function WinFacePhotoWnd:onHide()
  UI:closeWnd("facePhotoWnd")
end

function WinFacePhotoWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("facePhotoWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinFacePhotoWnd:onOpen(showList)
  self:initView(showList)
  self:subscribeEvent()
end

function WinFacePhotoWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.activityTimer then
    self.activityTimer()
    self.activityTimer = nil
  end
end

return WinFacePhotoWnd
