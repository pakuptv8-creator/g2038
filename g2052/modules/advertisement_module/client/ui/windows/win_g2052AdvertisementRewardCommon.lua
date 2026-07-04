local win_g2052AdvertisementRewardCommon = M
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function win_g2052AdvertisementRewardCommon:init()
  WinBase.init(self, "LimitedTimeActivityAwardPopup.json")
  self._allEvent = {}
  self._timer = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function win_g2052AdvertisementRewardCommon:initData()
  self.cells = {}
end

function win_g2052AdvertisementRewardCommon:initUI()
  self.imgBg = self:child("LimitedTimeActivityAwardPopup-bg")
  self.imgItemBg = self:child("LimitedTimeActivityAwardPopup-itemBg")
  self.txtTitle = self:child("LimitedTimeActivityAwardPopup-title")
  self.lytItemList = self:child("LimitedTimeActivityAwardPopup-item_list")
  self.txtTip = self:child("LimitedTimeActivityAwardPopup-tip")
  self.txtTip:SetText(Lang:toText("gui.limit.time.activity.click.on.the.screen.to.continue"))
  self:initItemList()
end

function win_g2052AdvertisementRewardCommon:initItemList()
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.lytItemList:AddChildWindow(self.gvItemList)
  self.gvItemList:SetMoveAble(false)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:SetClipChild(false)
  self.itemAdapter = UIMgr:new_adapter("common", 109, 130, "g2052AdvertisementRewardItemCommon", "LimitedTimeActivityItem.json")
  self.gvItemList:invoke("setAdapter", self.itemAdapter)
end

function win_g2052AdvertisementRewardCommon:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function win_g2052AdvertisementRewardCommon:subscribeEvent()
end

function win_g2052AdvertisementRewardCommon:initView(itemList)
  if not itemList or #itemList <= 0 then
    return
  end
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.congratulations"))
  self.imgItemBg:SetVisible(false)
  local len = #itemList
  local row = 5 < len and 5 or len
  self.gvItemList:InitConfig(20, 20, row)
  self.lytItemList:SetHeight({
    0,
    150 * math.ceil(len / 5)
  })
  self.lytItemList:SetWidth({
    0,
    row * 109 + 20 * (row - 1)
  })
  self.itemAdapter:setData(itemList)
end

function win_g2052AdvertisementRewardCommon:onHide()
  UI:closeWnd("g2052AdvertisementRewardCommon")
end

function win_g2052AdvertisementRewardCommon:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052AdvertisementRewardCommon")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function win_g2052AdvertisementRewardCommon:onOpen(itemList)
  self:initView(itemList)
  self:subscribeEvent()
  Me:playUiSoundByKey("getAwardSound")
  self:showPerform()
end

function win_g2052AdvertisementRewardCommon:showPerform()
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

function win_g2052AdvertisementRewardCommon:onClose()
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
end

return win_g2052AdvertisementRewardCommon
