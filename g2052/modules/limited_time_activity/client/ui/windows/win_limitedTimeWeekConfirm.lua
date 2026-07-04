local WinLimitedTimeWeekConfirm = M
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitedTimeWeekConfirm:init()
  WinBase.init(self, "LimitedTimeWeekConfirm.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeWeekConfirm:initUI()
  self.lytWnd = self:child("LimitedTimeWeekConfirm-wnd")
  self.imgWndBg = self:child("LimitedTimeWeekConfirm-wnd_bg")
  self.imgTopImg = self:child("LimitedTimeWeekConfirm-topImg")
  self.txtTitle = self:child("LimitedTimeWeekConfirm-title")
  self.txtGiftTitle = self:child("LimitedTimeWeekConfirm-GiftTitle")
  self.lytGoodsPanel = self:child("LimitedTimeWeekConfirm-GoodsPanel")
  self.lytDetails = self:child("LimitedTimeWeekConfirm-details")
  self.txtRewardDesc = self:child("LimitedTimeWeekConfirm-reward_desc")
  self.imgLAdorn = self:child("LimitedTimeWeekConfirm-l_adorn")
  self.imgRAdorn0 = self:child("LimitedTimeWeekConfirm-r_adorn_0")
  self.imgDetailsBg = self:child("LimitedTimeWeekConfirm-details_bg")
  self.txtDecText = self:child("LimitedTimeWeekConfirm-dec_text")
  self.imgPriceBg = self:child("LimitedTimeWeekConfirm-priceBg")
  self.imgDiaIcon = self:child("LimitedTimeWeekConfirm-DiaIcon")
  self.txtInitPrice = self:child("LimitedTimeWeekConfirm-InitPrice")
  self.imgLine = self:child("LimitedTimeWeekConfirm-Line")
  self.txtFinalPrice = self:child("LimitedTimeWeekConfirm-finalPrice")
  self.imgPerIcon = self:child("LimitedTimeWeekConfirm-PerIcon")
  self.txtPerText1 = self:child("LimitedTimeWeekConfirm-PerText1")
  self.txtPerText2 = self:child("LimitedTimeWeekConfirm-PerText2")
  self.btnClose = self:child("LimitedTimeWeekConfirm-close")
  self.imgCloseImg = self:child("LimitedTimeWeekConfirm-closeImg")
  self.btnCancelBtn = self:child("LimitedTimeWeekConfirm-CancelBtn")
  self.imgCancelIcon = self:child("LimitedTimeWeekConfirm-CancelIcon")
  self.txtCancelText = self:child("LimitedTimeWeekConfirm-CancelText")
  self.btnConfirmBtn = self:child("LimitedTimeWeekConfirm-ConfirmBtn")
  self.imgConfirmIcon = self:child("LimitedTimeWeekConfirm-ConfirmIcon")
  self.txtConfirmText = self:child("LimitedTimeWeekConfirm-ConfirmText")
  self.lytGoodsItem = {}
  self.imgGoodsIcon = {}
  self.txtGoodsNum = {}
  self.imgGoodsBg = {}
  for i = 1, 3 do
    self.lytGoodsItem[i] = self:child("LimitedTimeWeekConfirm-GoodsItem" .. i)
    self.imgGoodsIcon[i] = self:child("LimitedTimeWeekConfirm-GoodsIcon" .. i)
    self.txtGoodsNum[i] = self:child("LimitedTimeWeekConfirm-GoodsNum" .. i)
    self.imgGoodsBg[i] = self:child("LimitedTimeWeekConfirm-GoodsBg" .. i)
  end
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.buy.title"))
  self.txtRewardDesc:SetText(Lang:toText("gui.limit.time.activity.gift.desc"))
  self.txtPerText2:SetText(Lang:toText("gui.limit.time.combined.off"))
  self.txtCancelText:SetText(Lang:toText("gui.limit.time.activity.cancel.tips"))
  self.txtConfirmText:SetText(Lang:toText("gui.limit.time.activity.confirm.tips"))
end

function WinLimitedTimeWeekConfirm:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnCancelBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnConfirmBtn, UIEvent.EventButtonClick, function()
    if self.data.dataType == "week" then
      Me:clientBuyLimitTimeWeekGift(self.data)
    else
      Me:clientBuyLimitTimeMonthGift(self.data)
    end
    self:onHide()
  end)
  self:subscribe(self._root, UIEvent.EventWindowClick, function(window, dx, dy)
    self:onHide()
  end)
  for i = 1, 3 do
    self:subscribe(self.imgGoodsIcon[i], UIEvent.EventWindowClick, function(window, dx, dy)
      if not self.goodData then
        return
      end
      if not self.goodData[i] then
        return
      end
      LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.goodData[i], dx, dy)
    end)
  end
end

function WinLimitedTimeWeekConfirm:subscribeEvent()
end

function WinLimitedTimeWeekConfirm:initView(data)
  self.data = data
  self.txtPerText1:SetText(data.percent)
  self.txtGiftTitle:SetText(Lang:toText(data.giftName))
  self.txtFinalPrice:SetText(data.finalPrice)
  self.txtInitPrice:SetText(data.initPrice)
  local strW = self.txtInitPrice:GetFont():GetStringWidth(data.initPrice)
  self.imgLine:SetWidth({
    0,
    strW + 10
  })
  if #data.giftContent == 1 then
    self.lytGoodsItem[1]:SetXPosition({0, 104})
  elseif #data.giftContent == 2 then
    self.lytGoodsItem[1]:SetXPosition({0, 52.0})
    self.lytGoodsItem[2]:SetXPosition({0, 52.0})
  else
    self.lytGoodsItem[1]:SetXPosition({0, 0})
    self.lytGoodsItem[2]:SetXPosition({0, 0})
  end
  local giftDesc = ""
  self.goodData = {}
  for i = 1, 3 do
    if data.giftContent[i] then
      local itemInfo = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[i])
      if itemInfo then
        self.goodData[i] = itemInfo
        self.lytGoodsItem[i]:SetVisible(true)
        local itemData = LimitedTimeActivityGameMgr:getItemInfo(self.goodData[i])
        if self.goodData[i].itemIcon and self.goodData[i].itemIcon ~= "" then
          self.imgGoodsIcon[i]:SetImage(self.goodData[i].itemIcon)
        else
          self.imgGoodsIcon[i]:SetImage(itemData.itemIcon or "")
        end
        local goodsName = ""
        if self.goodData[i].showName and self.goodData[i].showName ~= "" then
          goodsName = Lang:toText(self.goodData[i].showName or "")
        else
          goodsName = Lang:toText(itemData.itemName or "")
        end
        local count = itemData.itemCount
        if count <= 1 then
          self.txtGoodsNum[i]:SetText("")
          if giftDesc ~= "" then
            giftDesc = giftDesc .. "\n"
          end
          giftDesc = giftDesc .. goodsName
        else
          self.txtGoodsNum[i]:SetText("x" .. count)
          if giftDesc ~= "" then
            giftDesc = giftDesc .. "\n"
          end
          giftDesc = giftDesc .. goodsName .. "x" .. count
        end
        local quality = itemData.quality or 1
        self.imgGoodsBg[i]:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
      else
        self.lytGoodsItem[i]:SetVisible(false)
      end
    else
      self.lytGoodsItem[i]:SetVisible(false)
    end
  end
  self.txtDecText:SetText(giftDesc)
end

function WinLimitedTimeWeekConfirm:onHide()
  UI:closeWnd("limitedTimeWeekConfirm")
end

function WinLimitedTimeWeekConfirm:onShow(isShow, data)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeWeekConfirm", data)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeWeekConfirm:onOpen(data)
  self:initView(data)
  self:subscribeEvent()
end

function WinLimitedTimeWeekConfirm:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitedTimeWeekConfirm
