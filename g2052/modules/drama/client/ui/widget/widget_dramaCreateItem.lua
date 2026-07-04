local widget_base = require("ui.widget.widget_base")
local WidgetDramaCreateItem = Lib.derive(widget_base)

function WidgetDramaCreateItem:init()
  widget_base.init(self, "DramaCreateItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaCreateItem:initUI()
  self.imgBg = self:child("DramaCreateItem-Bg")
  self.lytNormalPanel = self:child("DramaCreateItem-NormalPanel")
  self.lytNonePanel = self:child("DramaCreateItem-NonePanel")
  self.imgPen = self:child("DramaCreateItem-pen")
  self.txtRoleName = self:child("DramaCreateItem-RoleName")
  self.txtRoleNum = self:child("DramaCreateItem-RoleNum")
  self.txtRoleDesc = self:child("DramaCreateItem-RoleDesc")
  self.btnRoleIcon = self:child("DramaCreateItem-RoleIcon")
  self.btnAdd = self:child("DramaCreateItem-Add")
  self.btnSub = self:child("DramaCreateItem-Sub")
end

function WidgetDramaCreateItem:initEvent()
  self:subscribe(self.btnAdd, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_CREATE_ITEM, "add", self.data.index)
  end)
  self:subscribe(self.btnSub, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_CREATE_ITEM, "sub", self.data.index)
  end)
  self:subscribe(self.lytNormalPanel, UIEvent.EventWindowClick, function()
    local function backFunc(titleText, descText)
      Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_ROLE_ITEM_NAME, self.data.index, titleText, descText)
    end
    
    UI:getWnd("dramaEditorWnd"):onShow(true, "role", self.data.roleName, self.data.roleDesc, backFunc)
  end)
  self:subscribe(self.lytNonePanel, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_CREATE_ITEM, "new")
  end)
end

function WidgetDramaCreateItem:onDataChanged(data)
  self.data = data
  if data.isAddIcon then
    self.lytNormalPanel:SetVisible(false)
    self.lytNonePanel:SetVisible(true)
  else
    self.lytNormalPanel:SetVisible(true)
    self.lytNonePanel:SetVisible(false)
    self.txtRoleName:SetText(data.roleName)
    if data.roleDesc == "" then
      self.txtRoleDesc:SetText(Lang:toText("g2052.gui.drama.role.desc"))
    else
      self.txtRoleDesc:SetText(data.roleDesc)
    end
    self.txtRoleNum:SetText(data.roleNum or 0)
  end
end

function WidgetDramaCreateItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaCreateItem
