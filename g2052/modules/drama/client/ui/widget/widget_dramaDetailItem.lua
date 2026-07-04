local widget_base = require("ui.widget.widget_base")
local WidgetDramaDetailItem = Lib.derive(widget_base)

function WidgetDramaDetailItem:init()
  widget_base.init(self, "DramaDetailItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaDetailItem:initUI()
  self.txtRoleName = self:child("DramaDetailItem-RoleName")
  self.txtRoleNum = self:child("DramaDetailItem-RoleNum")
  self.txtRoleDesc = self:child("DramaDetailItem-RoleDesc")
  self.btnRoleIcon = self:child("DramaDetailItem-RoleIcon")
  self.lytMaskPanel = self:child("DramaDetailItem-MaskPanel")
  self.btnRoleIcon:SetTouchable(false)
end

function WidgetDramaDetailItem:initEvent()
end

function WidgetDramaDetailItem:onDataChanged(roleInfo)
  self.roleInfo = roleInfo
  self.txtRoleName:SetText(roleInfo.roleName)
  self.txtRoleDesc:SetText(roleInfo.roleDesc)
  self.txtRoleNum:SetText((roleInfo.roleSelects or 0) .. "/" .. roleInfo.roleNum)
  if roleInfo.roleSelects >= roleInfo.roleNum then
    self.btnRoleIcon:SetEnabled(false)
    self.lytMaskPanel:SetVisible(true)
  else
    self.btnRoleIcon:SetEnabled(true)
    self.lytMaskPanel:SetVisible(false)
  end
end

function WidgetDramaDetailItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaDetailItem
