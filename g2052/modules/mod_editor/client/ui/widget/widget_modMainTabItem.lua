local widget_base = require("ui.widget.widget_base")
local WidgetModMainTabItem = Lib.derive(widget_base)

function WidgetModMainTabItem:init()
  widget_base.init(self, "ModMainTabItem.json")
  self:initUI()
  self:initEvent()
end

function WidgetModMainTabItem:initUI()
  self.btnBtn = self:child("ModMainTabItem-Btn")
  self.txtLabel = self:child("ModMainTabItem-Label")
end

function WidgetModMainTabItem:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetModMainTabItem:onDataChanged(data)
  print("----data---", Lib.v2s(data))
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
local UnSelectedImg = "set:g2052_mod.json image:btn_9_pagination02"

function WidgetModMainTabItem:updateView()
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

return WidgetModMainTabItem
