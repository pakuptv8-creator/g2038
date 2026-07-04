local widget_base = require("ui.widget.widget_base")
local widget_g2052AdvertisementRewardItem = Lib.derive(widget_base)
local AdvertisementPoolConfig = T(Config, "AdvertisementPoolConfig")

function widget_g2052AdvertisementRewardItem:init()
  widget_base.init(self, "LimitedTimeActivityItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function widget_g2052AdvertisementRewardItem:initUI()
  self.imgFrame = self:child("LimitedTimeActivityItem-frame")
  self.imgIcon = self:child("LimitedTimeActivityItem-icon")
  self.txtName = self:child("LimitedTimeActivityItem-name")
  self.txtNum = self:child("LimitedTimeActivityItem-num")
  self.lytEffect = self:child("LimitedTimeActivityItem-effect")
end

function widget_g2052AdvertisementRewardItem:initEvent()
end

function widget_g2052AdvertisementRewardItem:updateInfo(info)
  local rewardId = info.rewardId
  local count = info.count
  local rewardCfg = AdvertisementPoolConfig:getCfgById(rewardId)
  local itemType = rewardCfg.itemType
  local itemId = rewardCfg.itemId
  local itemCfg = Me:getBusinessItemCfg(itemType, itemId)
  local itemIcon = itemCfg and itemCfg.icon or nil
  local itemCount = rewardCfg.itemCount
  if count == 2 then
    itemCount = itemCount * 2
  elseif count == 3 then
    itemCount = itemCount * 5
  end
  self.txtName:SetVisible(false)
  self.lytEffect:SetVisible(true)
  local quality = 5
  self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
  if itemIcon then
    self.imgIcon:SetImage(itemIcon)
  end
  self.txtNum:SetText("x" .. itemCount)
end

function widget_g2052AdvertisementRewardItem:setSpecialModel()
  self.imgFrame:SetImage()
  self.imgIcon:SetImage()
  self.txtNum:SetText()
end

function widget_g2052AdvertisementRewardItem:onDataChanged(data)
  self.data = data
  self.isClick = data.isClick
  self:updateInfo(data)
end

function widget_g2052AdvertisementRewardItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return widget_g2052AdvertisementRewardItem
