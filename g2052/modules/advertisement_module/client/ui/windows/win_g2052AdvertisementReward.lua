local win_g2052AdvertisementReward = M
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function win_g2052AdvertisementReward:init()
  WinBase.init(self, "LimitedTimeActivityAwardPopup.json")
  self._allEvent = {}
  self._timer = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function win_g2052AdvertisementReward:initData()
  self.cells = {}
end

function win_g2052AdvertisementReward:initUI()
  self.imgBg = self:child("LimitedTimeActivityAwardPopup-bg")
  self.imgItemBg = self:child("LimitedTimeActivityAwardPopup-itemBg")
  self.txtTitle = self:child("LimitedTimeActivityAwardPopup-title")
  self.lytItemList = self:child("LimitedTimeActivityAwardPopup-item_list")
  self.txtTip = self:child("LimitedTimeActivityAwardPopup-tip")
  self.txtTip:SetText(Lang:toText("gui.limit.time.activity.click.on.the.screen.to.continue"))
  self:initItemList()
end

function win_g2052AdvertisementReward:initItemList()
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.lytItemList:AddChildWindow(self.gvItemList)
  self.gvItemList:SetMoveAble(false)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:SetClipChild(false)
  self.itemAdapter = UIMgr:new_adapter("common", 109, 130, "g2052AdvertisementRewardItem", "LimitedTimeActivityItem.json")
  self.gvItemList:invoke("setAdapter", self.itemAdapter)
end

function win_g2052AdvertisementReward:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function win_g2052AdvertisementReward:subscribeEvent()
end

function win_g2052AdvertisementReward:initView(rewardIds)
  if not rewardIds or #rewardIds <= 0 then
    return
  end
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.congratulations"))
  self.imgItemBg:SetVisible(false)
  local len = #rewardIds
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
  local data_list = {}
  local data_count = {}
  for i = 1, len do
    local id = rewardIds[i]
    data_count[id] = (data_count[id] or 0) + 1
  end
  for i = 1, len do
    local id = rewardIds[i]
    data_list[#data_list + 1] = {
      rewardId = id,
      count = data_count[id] or 1
    }
  end
  self.itemAdapter:setData(data_list)
end

function win_g2052AdvertisementReward:onHide()
  UI:closeWnd("g2052AdvertisementReward")
end

function win_g2052AdvertisementReward:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052AdvertisementReward")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function win_g2052AdvertisementReward:onOpen(rewardIds)
  self:initView(rewardIds)
  self:subscribeEvent()
  Me:playUiSoundByKey("getAwardSound")
  self:showPerform()
end

function win_g2052AdvertisementReward:showPerform()
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

function win_g2052AdvertisementReward:onClose()
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

return win_g2052AdvertisementReward
