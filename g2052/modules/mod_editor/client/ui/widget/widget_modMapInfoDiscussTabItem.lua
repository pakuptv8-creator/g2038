local widget_base = require("ui.widget.widget_base")
local WidgetModMapInfoDiscussTabItem = Lib.derive(widget_base)
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModMapInfoDiscussTabItem:init()
  widget_base.init(self, "ModMapInfoDiscussTabItem.json")
  self:initUI()
  self:initEvent()
end

function WidgetModMapInfoDiscussTabItem:initUI()
  self.btnBtn = self:child("ModMapInfoDiscussTabItem-Btn")
  self.txtLabel = self:child("ModMapInfoDiscussTabItem-Label")
end

function WidgetModMapInfoDiscussTabItem:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if self.reportKey then
      ModReportProxy:btnClickReport(self.reportKey)
    end
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetModMapInfoDiscussTabItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  self.select = data.select
  self.reportKey = data.data.reportKey
  if self.info then
    self:updateView()
  end
end

local SelectedImg = "set:g2052_mod.json image:btn_9_pagination03"
local UnSelectedImg = ""

function WidgetModMapInfoDiscussTabItem:updateView()
  local number = self.info.number or 2
  self:updateNumber(number)
  local img = self.select and SelectedImg or UnSelectedImg
  self.btnBtn:SetNormalImage(img)
  self.btnBtn:SetPushedImage(img)
end

function WidgetModMapInfoDiscussTabItem:updateNumber(num)
  local lang = self.info.lang
  self.txtLabel:SetText(Lang:toText({
    lang,
    Lib.simplifyNumber2Str(num)
  }))
end

return WidgetModMapInfoDiscussTabItem
