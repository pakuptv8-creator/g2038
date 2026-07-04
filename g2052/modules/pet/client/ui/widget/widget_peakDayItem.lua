local PetConfig = T(Config, "PetConfig")
local widget_base = require("ui.widget.widget_base")
local WidgetPeakDayItem = Lib.derive(widget_base)

function WidgetPeakDayItem:init()
  widget_base.init(self, "PeakDayItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPeakDayItem:initUI()
  self.imgNormalIcon = self:child("PeakDayItem-NormalIcon")
  self.imgIcon = self:child("PeakDayItem-icon")
  self.imgSelectIcon = self:child("PeakDayItem-SelectIcon")
  self.txtName = self:child("PeakDayItem-Name")
  self.lytHavePanel = self:child("PeakDayItem-HavePanel")
  self:child("PeakDayItem-HaveText"):SetText(Lang:toText("gui.goods.already.have"))
end

function WidgetPeakDayItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.lytHavePanel:IsVisible() then
      return
    end
    if self.clickCb then
      self.clickCb()
    end
  end)
end

function WidgetPeakDayItem:onDataChanged(params)
  self.data = params.data
  self.imgSelectIcon:SetVisible(params.select)
  self.clickCb = params.clickCb
  self:updateRewardItemInfo()
  self.lytHavePanel:SetVisible(self:ifIHaveThisPet())
end

function WidgetPeakDayItem:updateRewardItemInfo()
  if not self.data then
    return
  end
  if self.data.rewardType == "pet" then
    local rewardId = tonumber(self.data.rewardId)
    local cfg = PetConfig:getCfgById(rewardId)
    if not cfg then
      return
    end
    self.imgIcon:SetImage(cfg.icon)
    self.txtName:SetText("")
  end
end

function WidgetPeakDayItem:ifIHaveThisPet()
  if not self.data then
    return false
  end
  return Me:isPetReceived(self.data.rewardId)
end

function WidgetPeakDayItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPeakDayItem
