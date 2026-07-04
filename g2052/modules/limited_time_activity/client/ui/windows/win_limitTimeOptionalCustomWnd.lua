local WinLimitTimeOptionalCustomWnd = M
local LimitedTimeOptionalGiftConfig = T(Config, "LimitedTimeOptionalGiftConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitTimeOptionalCustomWnd:init()
  WinBase.init(self, "LimitTimeOptionalCustomWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitTimeOptionalCustomWnd:initUI()
  self.lytWnd = self:child("LimitTimeOptionalCustomWnd-wnd")
  self.imgWndBg = self:child("LimitTimeOptionalCustomWnd-wnd_bg")
  self.imgTopImg = self:child("LimitTimeOptionalCustomWnd-topImg")
  self.txtTitle = self:child("LimitTimeOptionalCustomWnd-title")
  self.lytGoodsPanel = self:child("LimitTimeOptionalCustomWnd-GoodsPanel")
  self.lytDetails = self:child("LimitTimeOptionalCustomWnd-details")
  self.txtRewardDesc = self:child("LimitTimeOptionalCustomWnd-reward_desc")
  self.imgLAdorn = self:child("LimitTimeOptionalCustomWnd-l_adorn")
  self.imgRAdorn0 = self:child("LimitTimeOptionalCustomWnd-r_adorn_0")
  self.imgDetailsBg = self:child("LimitTimeOptionalCustomWnd-details_bg")
  self.lytDescPanel = self:child("LimitTimeOptionalCustomWnd-descPanel")
  self.txtDecText = self:child("LimitTimeOptionalCustomWnd-dec_text")
  self.btnClose = self:child("LimitTimeOptionalCustomWnd-close")
  self.imgCloseImg = self:child("LimitTimeOptionalCustomWnd-closeImg")
  self.btnConfirmBtn = self:child("LimitTimeOptionalCustomWnd-ConfirmBtn")
  self.txtConfirmText = self:child("LimitTimeOptionalCustomWnd-ConfirmText")
  self.btnContinueBtn = self:child("LimitTimeOptionalCustomWnd-ContinueBtn")
  self.txtContinueText = self:child("LimitTimeOptionalCustomWnd-ContinueText")
  self.gvDescTxt = UIMgr:new_widget("grid_view")
  self.lytDescPanel:AddChildWindow(self.gvDescTxt)
  self.gvDescTxt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDescTxt:SetAutoColumnCount(false)
  self.gvDescTxt:InitConfig(0, 5, 1)
  self.gvDescTxt:AddItem(self.txtDecText)
  self.txtConfirmText:SetText(Lang:toText("gui.limit.time.activity.confirm.tips"))
  self.txtContinueText:SetText(Lang:toText("gui.limit.time.activity.optional.continue"))
  self:initNormalGirdView()
end

function WinLimitTimeOptionalCustomWnd:initNormalGirdView()
  self.goodsGridView = UIMgr:new_widget("grid_view", self.lytGoodsPanel)
  self.goodsGridView:SetMoveAble(true)
  self.goodsGridView:SetvScorllMoveAble(true)
  self.goodsGridView:SethScorllMoveAble(false)
  self.goodsGridView:InitConfig(20, 20, 5)
  self.goodsGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.goodsGridView:SetAutoColumnCount(false)
  self.goodsAdapter = UIMgr:new_adapter("common", 95, 95, "limitTimeOptionalCustomCell", "LimitTimeOptionalCustomCell.json")
  self.goodsGridView:invoke("setAdapter", self.goodsAdapter)
end

function WinLimitTimeOptionalCustomWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnConfirmBtn, UIEvent.EventButtonClick, function()
    if Me.isLimitOptionalGiftCustom then
      return
    end
    if Me.isLimitOptionalGiftPlaying then
      return
    end
    local optionalBuy = Me:getLimitedTimeOptionalBuy()
    if self.data.limitCounts > 0 and optionalBuy[self.data.giftKey] and optionalBuy[self.data.giftKey] >= self.data.limitCounts then
      self:onHide()
      return
    end
    if 0 < self.data.limitDayNum and optionalBuy[self.data.giftKey] and optionalBuy[self.data.giftKey] >= self.data.limitDayNum then
      self:onHide()
      return
    end
    Me.isLimitOptionalGiftCustom = true
    local optionalData = Me:getLimitedTimeOptionalData()
    optionalData[self.data.giftKey] = self.customList
    Me:setLimitedTimeOptionalData(optionalData)
    self:onHide()
  end)
  self:subscribe(self.btnContinueBtn, UIEvent.EventButtonClick, function()
    self:updateGoodsShow(self.curIndex + 1)
  end)
end

function WinLimitTimeOptionalCustomWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LIMITED_TIME_OPTIONAL_SELECT, function(awardId)
    for key, val in pairs(self.goodsAdapter.data) do
      if awardId == self.goodsAdapter.data[key].awardId then
        self.goodsAdapter.data[key].isSelect = true
      else
        self.goodsAdapter.data[key].isSelect = false
      end
    end
    self.goodsAdapter:notifyDataChange()
    self:updateSelectInfo(awardId)
  end)
end

function WinLimitTimeOptionalCustomWnd:initView(isChange, giftId, index)
  self.isChange = isChange
  self.startIndex = index
  self.data = LimitedTimeOptionalGiftConfig:getCfgById(giftId)
  self.customList = Me:getLimitedTimeOptionalKeyData(self.data.giftKey)
  self:updateGoodsShow(index)
end

function WinLimitTimeOptionalCustomWnd:updateGoodsShow(index)
  self.curIndex = index
  local showData = {}
  local initAwardId = self.customList[self.curIndex]
  for _, awardId in pairs(self.data.optionalContent[index] or {}) do
    initAwardId = initAwardId or awardId
    table.insert(showData, {
      awardId = awardId,
      isSelect = initAwardId == awardId
    })
  end
  self.goodsAdapter:setData(showData)
  self:updateSelectInfo(initAwardId)
  if self.data.isBigAward == 1 then
    self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.optional.custom.big"))
    self.btnConfirmBtn:SetVisible(true)
    self.btnContinueBtn:SetVisible(false)
  else
    self.txtTitle:SetText(Lang:toText({
      "gui.limit.time.activity.optional.custom.normal",
      self.curIndex
    }))
    if self.isChange then
      self.btnConfirmBtn:SetVisible(true)
      self.btnContinueBtn:SetVisible(false)
    elseif self.curIndex >= self.data.optionalNum then
      self.btnConfirmBtn:SetVisible(true)
      self.btnContinueBtn:SetVisible(false)
    else
      self.btnConfirmBtn:SetVisible(false)
      self.btnContinueBtn:SetVisible(true)
    end
  end
end

function WinLimitTimeOptionalCustomWnd:updateSelectInfo(awardId)
  if not awardId then
    self.txtDecText:SetText("")
    self.txtRewardDesc:SetText("")
    return
  end
  self.customList[self.curIndex] = awardId
  local itemInfo = LimitedTimeGiftItemConfig:getCfgById(awardId)
  local itemData = LimitedTimeActivityGameMgr:getItemInfo(itemInfo)
  local nameText = ""
  if itemInfo.showName and itemInfo.showName ~= "" then
    nameText = Lang:toText(itemInfo.showName or "")
  else
    nameText = Lang:toText(itemData.itemName or "")
  end
  self.txtRewardDesc:SetText(nameText)
  if itemInfo.showDesc and itemInfo.showDesc ~= "" then
    self.txtDecText:SetText(Lang:toText(itemInfo.showDesc))
  else
    local count = itemData.itemCount or 0
    if count <= 1 then
      self.txtDecText:SetText(nameText)
    else
      self.txtDecText:SetText(nameText .. "x" .. count)
    end
  end
end

function WinLimitTimeOptionalCustomWnd:onHide()
  UI:closeWnd("limitTimeOptionalCustomWnd")
end

function WinLimitTimeOptionalCustomWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitTimeOptionalCustomWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitTimeOptionalCustomWnd:onOpen(isChange, giftId, index)
  self:initView(isChange, giftId, index)
  self:subscribeEvent()
end

function WinLimitTimeOptionalCustomWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitTimeOptionalCustomWnd
