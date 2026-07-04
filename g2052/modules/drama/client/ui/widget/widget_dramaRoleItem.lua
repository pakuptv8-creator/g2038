local widget_base = require("ui.widget.widget_base")
local WidgetDramaRoleItem = Lib.derive(widget_base)

function WidgetDramaRoleItem:init()
  widget_base.init(self, "DramaRoleItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaRoleItem:initUI()
  self.imgNormalBg = self:child("DramaRoleItem-NormalBg")
  self.imgSelectBg = self:child("DramaRoleItem-SelectBg")
  self.txtName = self:child("DramaRoleItem-Name")
  self.lytContentPanel = self:child("DramaRoleItem-ContentPanel")
end

function WidgetDramaRoleItem:initEvent()
end

function WidgetDramaRoleItem:updateRoleInfo(data)
  self.txtName:SetText(data.roleName)
  self.imgSelectBg:SetVisible(data.playState > 0)
  self.imgNormalBg:SetVisible(data.playState < 1)
end

function WidgetDramaRoleItem:setRoleVisible(value)
  self.lytContentPanel:SetVisible(value)
end

function WidgetDramaRoleItem:setDotVisible(value)
  self.imgSelectBg:SetVisible(value)
end

function WidgetDramaRoleItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaRoleItem
