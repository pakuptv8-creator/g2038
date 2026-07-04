local WinLimitTimeOptionalWnd = M
local LimitedTimeOptionalGiftConfig = T(Config, "LimitedTimeOptionalGiftConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WinLimitTimeOptionalWnd:init()
  WinBase.init(self, "LimitTimeOptionalWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeOptionalWnd:initUI()
  self.btnHelp = self:child("LimitTimeOptionalWnd-help")
  self.txtTitle = self:child("LimitTimeOptionalWnd-title")
  self.txtBigTips = self:child("LimitTimeOptionalWnd-BigTips")
  self.btnBigAward = self:child("LimitTimeOptionalWnd-BigAward")
  self.txtBigText = self:child("LimitTimeOptionalWnd-BigText")
  self.btnCustomBtn = self:child("LimitTimeOptionalWnd-CustomBtn")
  self.txtCustomText = self:child("LimitTimeOptionalWnd-CustomText")
  self.txtProText = self:child("LimitTimeOptionalWnd-ProText")
  self.lytAwardPanel = self:child("LimitTimeOptionalWnd-AwardPanel")
  self.imgAddIcon = self:child("LimitTimeOptionalWnd-AddIcon")
  self.imgGoodsBg = self:child("LimitTimeOptionalWnd-GoodsBg")
  self.imgGoodsIcon = self:child("LimitTimeOptionalWnd-GoodsIcon")
  self.txtGoodsNum = self:child("LimitTimeOptionalWnd-GoodsNum")
  self.imgChangeIcon = self:child("LimitTimeOptionalWnd-changeIcon")
  self.lytContentPanel = self:child("LimitTimeOptionalWnd-ContentPanel")
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.optional.title"))
  self.txtCustomText:SetText(Lang:toText("gui.limit.time.activity.optional.custom"))
  self.txtBigText:SetText(Lang:toText("gui.limit.time.activity.optional.receive"))
  self:initNormalGirdView()
end

function WinLimitTimeOptionalWnd:initNormalGirdView()
  self.goodsGridView = UIMgr:new_widget("grid_view", self.lytContentPanel)
  self.goodsGridView:SetMoveAble(true)
  self.goodsGridView:SetvScorllMoveAble(true)
  self.goodsGridView:SethScorllMoveAble(false)
  self.goodsGridView:InitConfig(0, 4, 1)
  self.goodsGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.goodsGridView:SetAutoColumnCount(false)
  self.goodsAdapter = UIMgr:new_adapter("common", 616, 186, "limitTimeOptionalItem", "LimitTimeOptionalItem.json")
  self.goodsGridView:invoke("setAdapter", self.goodsAdapter)
end

function WinLimitTimeOptionalWnd:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.optional.help"
    })
  end)
  self:subscribe(self.btnBigAward, UIEvent.EventButtonClick, function()
    if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
      return
    end
    Me:clientBuyLimitOptionalGift(self.optionalCfg.bigAward)
  end)
  self:subscribe(self.btnCustomBtn, UIEvent.EventButtonClick, function()
    if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
      return
    end
    UI:openWnd("limitTimeOptionalCustomWnd", true, self.optionalCfg.bigAward.id, 1)
  end)
  self:subscribe(self.imgAddIcon, UIEvent.EventWindowClick, function()
    if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
      return
    end
    UI:openWnd("limitTimeOptionalCustomWnd", true, self.optionalCfg.bigAward.id, 1)
  end)
  self:subscribe(self.imgChangeIcon, UIEvent.EventWindowClick, function()
    if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
      return
    end
    UI:openWnd("limitTimeOptionalCustomWnd", true, self.optionalCfg.bigAward.id, 1)
  end)
  self:subscribe(self.imgGoodsIcon, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
      return
    end
    UI:openWnd("limitTimeOptionalCustomWnd", true, self.optionalCfg.bigAward.id, 1)
  end)
end

function WinLimitTimeOptionalWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_OPTIONAL_INFO, function()
    self:updateBigAwardView()
    self:updateNormalAwardView()
  end)
end

function WinLimitTimeOptionalWnd:initView()
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT)
  self.optionalCfg = Lib.copy(LimitedTimeOptionalGiftConfig:getCfgByActivityId(self.activityInfo.id))
  self.txtBigTips:SetText(Lang:toText({
    "gui.limit.time.activity.optional.tips",
    self.optionalCfg.bigAward.bigLimit
  }))
  self:updateBigAwardView()
  self.goodsAdapter:setData(self.optionalCfg.normalList)
end

function WinLimitTimeOptionalWnd:updateBigAwardView()
  self.bigCustomList = Me:getLimitedTimeOptionalKeyData(self.optionalCfg.bigAward.giftKey)
  self.bigBoughtCounts = Me:getLimitedTimeOptionalBuy()[self.optionalCfg.bigAward.giftKey] or 0
  self:updateBigAwardShow(self.bigCustomList)
  self:updateBigBtnShow()
end

function WinLimitTimeOptionalWnd:updateBigBtnShow()
  self.boughtNum = 0
  local optionalBuy = Me:getLimitedTimeOptionalBuy()
  for key, val in pairs(self.optionalCfg.normalList) do
    if 0 < val.limitCounts and optionalBuy[val.giftKey] then
      self.boughtNum = self.boughtNum + optionalBuy[val.giftKey]
    end
  end
  self.txtProText:SetText(self.boughtNum .. "/" .. self.optionalCfg.bigAward.bigLimit)
  if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
    self.txtBigText:SetText(Lang:toText("gui.limit.time.activity.optional.received"))
    self.btnCustomBtn:SetVisible(false)
    self.btnBigAward:SetVisible(true)
    self.btnBigAward:SetEnabled(false)
    self.btnBigAward:SetTouchable(false)
  elseif 0 >= #self.bigCustomList then
    self.btnCustomBtn:SetVisible(true)
    self.btnBigAward:SetVisible(false)
  elseif self.boughtNum >= self.optionalCfg.bigAward.bigLimit then
    self.btnCustomBtn:SetVisible(false)
    self.btnBigAward:SetVisible(true)
    self.btnBigAward:SetEnabled(true)
    self.btnBigAward:SetTouchable(true)
    self.txtBigText:SetText(Lang:toText("gui.limit.time.activity.optional.receive"))
  else
    self.btnCustomBtn:SetVisible(true)
    self.btnBigAward:SetVisible(false)
  end
end

function WinLimitTimeOptionalWnd:updateBigAwardShow(customList)
  local customNum = #customList
  if 0 < customNum then
    if self.bigBoughtCounts >= self.optionalCfg.bigAward.limitCounts then
      self.imgAddIcon:SetVisible(false)
      self.imgChangeIcon:SetVisible(false)
      self.imgGoodsBg:SetVisible(true)
    else
      self.imgAddIcon:SetVisible(false)
      self.imgChangeIcon:SetVisible(true)
      self.imgGoodsBg:SetVisible(true)
    end
    self.goodData = LimitedTimeGiftItemConfig:getCfgById(customList[1])
    local itemData = LimitedTimeActivityGameMgr:getItemInfo(self.goodData)
    if self.goodData.itemIcon and self.goodData.itemIcon ~= "" then
      self.imgGoodsIcon:SetImage(self.goodData.itemIcon)
    else
      self.imgGoodsIcon:SetImage(itemData.itemIcon or "")
    end
    local count = itemData.itemCount
    if count <= 1 then
      self.txtGoodsNum:SetText("")
    else
      self.txtGoodsNum:SetText("x" .. count)
    end
    local quality = itemData.quality or 1
    self.imgGoodsBg:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
  else
    self.goodData = nil
    self.imgAddIcon:SetVisible(true)
    self.imgChangeIcon:SetVisible(false)
    self.imgGoodsBg:SetVisible(false)
  end
end

function WinLimitTimeOptionalWnd:updateNormalAwardView()
  self.goodsAdapter:notifyDataChange()
end

function WinLimitTimeOptionalWnd:onHide()
  UI:closeWnd("limitTimeOptionalWnd")
end

function WinLimitTimeOptionalWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeOptionalWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeOptionalWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLimitTimeOptionalWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitTimeOptionalWnd
