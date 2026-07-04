local widget_base = require("ui.widget.widget_base")
local WidgetBiddingTabItem = Lib.derive(widget_base)

function WidgetBiddingTabItem:init()
  widget_base.init(self, "BiddingTabItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBiddingTabItem:initUI()
  self.btnBtn = self:child("BiddingTabItem-Btn")
  self.txtLabel = self:child("BiddingTabItem-Label")
end

function WidgetBiddingTabItem:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetBiddingTabItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  self.select = data.select
  if self.info then
    self:updateView()
  end
end

local SelectedImg = "set:g2052_mod.json image:btn_9_pagination01"
local UnSelectedImg = "set:g2052_mod.json image:btn_9_pagination05"

function WidgetBiddingTabItem:updateView()
  local lang = self.info.lang
  self.txtLabel:SetText(Lang:toText(lang))
  local img = self.select and SelectedImg or UnSelectedImg
  self.btnBtn:SetNormalImage(img)
  self.btnBtn:SetPushedImage(img)
  if self.select then
    self.txtLabel:SetTextColor(Lib.getTextColor("000000"))
  else
    self.txtLabel:SetTextColor(Lib.getTextColor("FFFFFF"))
  end
end

function WidgetBiddingTabItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetBiddingTabItem
