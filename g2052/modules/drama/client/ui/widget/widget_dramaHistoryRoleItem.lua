local widget_base = require("ui.widget.widget_base")
local WidgetHistoryDramaRoleItem = Lib.derive(widget_base)

function WidgetHistoryDramaRoleItem:init()
  widget_base.init(self, "DramaHistoryRoleItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHistoryDramaRoleItem:initUI()
  self.txtName = self:child("DramaHistoryRoleItem-Name")
  self.lytContentPanel = self:child("DramaHistoryRoleItem-ContentPanel")
end

function WidgetHistoryDramaRoleItem:initEvent()
end

function WidgetHistoryDramaRoleItem:updateRoleInfo(data)
  self.txtName:SetText(data.roleName)
end

function WidgetHistoryDramaRoleItem:setRoleVisible(value)
  self.lytContentPanel:SetVisible(value)
end

function WidgetHistoryDramaRoleItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHistoryDramaRoleItem
