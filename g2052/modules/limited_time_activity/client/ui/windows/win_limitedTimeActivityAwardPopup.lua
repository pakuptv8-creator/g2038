local WinLimitedTimeActivityAwardPopup = M
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitedTimeActivityAwardPopup:init()
  WinBase.init(self, "LimitedTimeActivityAwardPopup.json")
  self._allEvent = {}
  self._timer = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeActivityAwardPopup:initData()
  self.awardData = LimitedTimeGiftItemConfig:getAllCfgs()
  self.cells = {}
end

function WinLimitedTimeActivityAwardPopup:initUI()
  self.imgBg = self:child("LimitedTimeActivityAwardPopup-bg")
  self.imgItemBg = self:child("LimitedTimeActivityAwardPopup-itemBg")
  self.txtTitle = self:child("LimitedTimeActivityAwardPopup-title")
  self.lytItemList = self:child("LimitedTimeActivityAwardPopup-item_list")
  self.txtTip = self:child("LimitedTimeActivityAwardPopup-tip")
  self.txtTip:SetText(Lang:toText("gui.limit.time.activity.click.on.the.screen.to.continue"))
  self:initItemList()
end

function WinLimitedTimeActivityAwardPopup:initItemList()
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.lytItemList:AddChildWindow(self.gvItemList)
  self.gvItemList:SetMoveAble(false)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:SetClipChild(false)
  self.itemAdapter = UIMgr:new_adapter("common", 109, 130, "limitedTimeActivityItem", "LimitedTimeActivityItem.json")
  self.gvItemList:invoke("setAdapter", self.itemAdapter)
end

function WinLimitedTimeActivityAwardPopup:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinLimitedTimeActivityAwardPopup:subscribeEvent()
end

function WinLimitedTimeActivityAwardPopup:initView(addition, title)
  if not addition then
    return
  end
  local item = addition.item
  if title then
    self.txtTitle:SetText(Lang:toText(title))
  else
    self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.congratulations"))
  end
  if item then
    local showItemBg = addition.showItemBg or item.luckyDrawType and item.luckyDrawType == Define.LUCKY_DRAW_TYPE.TEN
    self.imgItemBg:SetVisible(showItemBg)
    local giftContent = addition.item.giftContent or {}
    local count = #giftContent
    local row = 5 < count and 5 or count
    self.gvItemList:InitConfig(20, 20, row)
    self.lytItemList:SetHeight({
      0,
      150 * math.ceil(count / 5)
    })
    self.lytItemList:SetWidth({
      0,
      row * 109 + 20 * (row - 1)
    })
    local data = {}
    for _, id in pairs(giftContent) do
      if self.awardData and self.awardData[id] then
        if self.awardData[id].itemName == "" then
          self.awardData[id].itemName = addition.item.name
        end
        if not self.awardData[id].quality then
          self.awardData[id].quality = addition.item.quality
        end
        self.awardData[id].isShowEffect = true
        if addition.isCombined then
          self.awardData[id].combinedNum = addition.item.giftNum
        end
        table.insert(data, self.awardData[id])
      end
    end
    self.itemAdapter:setData(data)
  end
end

function WinLimitedTimeActivityAwardPopup:onHide()
  UI:closeWnd("limitedTimeActivityAwardPopup")
end

function WinLimitedTimeActivityAwardPopup:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeActivityAwardPopup")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeActivityAwardPopup:onOpen(addition, title)
  self:initView(addition, title)
  self:subscribeEvent()
  Me:playUiSoundByKey("getAwardSound")
  self:showPerform()
  Me.inShowLimitedTimeActivityAwardPopup = true
end

function WinLimitedTimeActivityAwardPopup:showPerform()
  local initAlpha = 0.3
  self._root:SetAlpha(initAlpha)
  self._timer[#self._timer + 1] = Me:timer(1, function()
    initAlpha = initAlpha + 0.08
    if 1 <= initAlpha then
      initAlpha = 1
    end
    self._root:SetAlpha(initAlpha)
    return initAlpha ~= 1
  end)
end

function WinLimitedTimeActivityAwardPopup:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self._timer then
    for k, fun in pairs(self._timer) do
      fun()
    end
    self._timer = {}
  end
  Me:stopUiSoundByKey("getAwardSound")
  Me.inShowLimitedTimeActivityAwardPopup = false
  Me:showCombinedLimitTimeCardRewards()
end

return WinLimitedTimeActivityAwardPopup
