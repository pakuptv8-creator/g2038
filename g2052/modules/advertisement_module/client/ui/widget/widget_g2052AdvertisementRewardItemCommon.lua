local widget_base = require("ui.widget.widget_base")
local widget_g2052AdvertisementRewardItemCommon = Lib.derive(widget_base)

function widget_g2052AdvertisementRewardItemCommon:init()
  widget_base.init(self, "LimitedTimeActivityItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function widget_g2052AdvertisementRewardItemCommon:initUI()
  self.imgFrame = self:child("LimitedTimeActivityItem-frame")
  self.imgIcon = self:child("LimitedTimeActivityItem-icon")
  self.txtName = self:child("LimitedTimeActivityItem-name")
  self.txtNum = self:child("LimitedTimeActivityItem-num")
  self.lytEffect = self:child("LimitedTimeActivityItem-effect")
end

function widget_g2052AdvertisementRewardItemCommon:initEvent()
end

function widget_g2052AdvertisementRewardItemCommon:updateInfo(info)
  local itemType = info.itemType
  local itemId = info.itemId
  local itemCfg = Me:getBusinessItemCfg(itemType, itemId)
  local itemIcon = itemCfg and itemCfg.icon or nil
  local itemCount = info.itemCount
  self.txtName:SetVisible(false)
  self.lytEffect:SetVisible(true)
  local quality = 5
  self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
  if itemIcon then
    self.imgIcon:SetImage(itemIcon)
  end
  self.txtNum:SetText("x" .. itemCount)
end

function widget_g2052AdvertisementRewardItemCommon:setSpecialModel()
  self.imgFrame:SetImage()
  self.imgIcon:SetImage()
  self.txtNum:SetText()
end

function widget_g2052AdvertisementRewardItemCommon:onDataChanged(data)
  self.data = data
  self.isClick = data.isClick
  self:updateInfo(data)
end

function widget_g2052AdvertisementRewardItemCommon:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return widget_g2052AdvertisementRewardItemCommon
