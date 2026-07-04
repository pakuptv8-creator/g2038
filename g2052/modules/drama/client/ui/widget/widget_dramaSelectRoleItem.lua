local widget_base = require("ui.widget.widget_base")
local WidgetSelectRoleItem = Lib.derive(widget_base)

function WidgetSelectRoleItem:init()
  widget_base.init(self, "DramaSelectRoleItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetSelectRoleItem:initUI()
  self.lytNormalPanel = self:child("DramaSelectRoleItem-NormalPanel")
  self.txtRoleName = self:child("DramaSelectRoleItem-RoleName")
  self.txtRoleNum = self:child("DramaSelectRoleItem-RoleNum")
  self.txtRoleDesc = self:child("DramaSelectRoleItem-RoleDesc")
  self.imgSelect = self:child("DramaSelectRoleItem-SelectImage")
  self.btnRoleHead = self:child("DramaSelectRoleItem-RoleHeadButton")
  self.btnRoleHead:SetTouchable(false)
end

function WidgetSelectRoleItem:initEvent()
  self:subscribe(self.lytNormalPanel, UIEvent.EventWindowClick, function()
    if not self.isFull and self.fun then
      self.fun()
    end
  end)
end

function WidgetSelectRoleItem:onDataChanged(data)
  self.data = data
  self.fun = data.clickCb
  self.inf = data.data
  self.txtRoleName:SetText(self.inf.roleName)
  self.txtRoleDesc:SetText(self.inf.roleDesc)
  self.txtRoleNum:SetText((self.inf.roleSelects or 0) .. "/" .. (self.inf.roleNum or 0))
  self.imgSelect:SetVisible(data.select)
  self.isFull = self.inf.roleSelects >= self.inf.roleNum
  self.btnRoleHead:SetEnabled(not self.isFull)
  local textColor = self.isFull and "000000" or "FFFFFF"
  self.txtRoleNum:SetTextColor(Lib.getTextColor(textColor))
  self.txtRoleName:SetTextColor(Lib.getTextColor(textColor))
end

function WidgetSelectRoleItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetSelectRoleItem
