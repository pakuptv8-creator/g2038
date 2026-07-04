local widget_base = require("ui.widget.widget_base")
local WidgetModRankTabItem = Lib.derive(widget_base)

function WidgetModRankTabItem:init()
  widget_base.init(self, "ModRankTabItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModRankTabItem:initUI()
  self.imgSelectIcon = self:child("ModRankTabItem-SelectIcon")
  self.txtLabel = self:child("ModRankTabItem-Label")
end

function WidgetModRankTabItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_MOD_RANK_TAB_SELECT, self.tabIndex)
  end)
end

function WidgetModRankTabItem:initTabIndex(index)
  self.tabIndex = index
  self.txtLabel:SetText(Lang:toText("g2052.gui.mod_rank.tab.name" .. index))
end

function WidgetModRankTabItem:updateSelectState(isSelect)
  self.imgSelectIcon:SetVisible(isSelect)
  if isSelect then
    self.txtLabel:SetTextColor(Lib.getTextColor("000000"))
  else
    self.txtLabel:SetTextColor(Lib.getTextColor("FFFFFF"))
  end
end

function WidgetModRankTabItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModRankTabItem
