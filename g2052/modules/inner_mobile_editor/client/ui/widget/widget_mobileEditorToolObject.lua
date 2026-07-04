local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorToolObject = Lib.derive(widget_base)
local GameManager = T(MobileEditor, "GameManager")
local ConfigManager = T(MobileEditor, "ConfigManager")
local SideBarContent = {
  color = {
    text = "ui.select.object_color",
    icon = "set:g2052_mobile_editor_common.json image:btn_0_color"
  },
  material = {
    text = "ui.select.object_material",
    icon = "set:g2052_mobile_editor_common.json image:btn_0_map"
  }
}

function WidgetMobileEditorToolObject:canMultiple()
  local groupObjects = GameManager:instance():all(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.GROUP)
  end)
  if Lib.getTableSize(groupObjects) > 0 then
    return true
  end
  return false
end

function WidgetMobileEditorToolObject:canDuplicate()
  local duplicateObjects = GameManager:instance():all(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.DUPLICATE)
  end)
  if Lib.getTableSize(duplicateObjects) > 0 then
    return true
  end
  return false
end

function WidgetMobileEditorToolObject:canDelete()
  local deleteObjects = GameManager:instance():all(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.DELETE)
  end)
  if Lib.getTableSize(deleteObjects) > 0 then
    return true
  end
end

function WidgetMobileEditorToolObject:canRotate()
  local rotateObjects = GameManager:instance():all(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.ROTATE)
  end)
  if Lib.getTableSize(rotateObjects) > 0 then
    return true
  end
end

function WidgetMobileEditorToolObject:canScale()
  local scaleObjects = GameManager:instance():all(self.targets, function(node)
    return node:checkAbility(Define.ABILITY_EDITOR.SCALE)
  end)
  if Lib.getTableSize(scaleObjects) > 0 then
    return true
  end
end

function WidgetMobileEditorToolObject:init()
  widget_base.init(self, "MobileEditorToolObject.json")
  self._allEvent = {}
  self.textureIndex = 1
  self.colorIndex = 1
  self.selectPanel = "none"
  self:initUI()
  self:initEvent()
end

function WidgetMobileEditorToolObject:setTargets(targets)
  self.targets = targets
  self:updateMaterial()
  if self:canMultiple() then
    self.btnConnectBtn:SetEnabled(true)
    self.btnConnectBtn:SetProperty("Alpha", 1.0)
  else
    self.btnConnectBtn:SetEnabled(false)
    self.btnConnectBtn:SetProperty("Alpha", 0.5)
  end
  if self:canDuplicate() then
    self.btnCopyBtn:SetEnabled(true)
    self.btnCopyBtn:SetProperty("Alpha", 1.0)
  else
    self.btnCopyBtn:SetEnabled(false)
    self.btnCopyBtn:SetProperty("Alpha", 0.5)
  end
  if self.enableMaterial then
    self.btnColorBtn:setEnabled(true)
    self.btnColorBtn:SetProperty("Alpha", 1.0)
    self.btnMaterialBtn:setEnabled(true)
    self.btnMaterialBtn:SetProperty("Alpha", 1.0)
  else
    self.btnColorBtn:setEnabled(false)
    self.btnColorBtn:SetProperty("Alpha", 0.5)
    self.btnMaterialBtn:setEnabled(false)
    self.btnMaterialBtn:SetProperty("Alpha", 0.5)
    self:hidePanel()
  end
  if self:canDelete() then
    self.btnDeleteBtn:SetEnabled(true)
    self.btnDeleteBtn:SetProperty("Alpha", 1.0)
  else
    self.btnDeleteBtn:SetEnabled(false)
    self.btnDeleteBtn:SetProperty("Alpha", 0.5)
  end
  if self:canRotate() then
    self.btnRotateBtn:SetEnabled(true)
    self.btnRotateBtn:SetProperty("Alpha", 1.0)
  else
    self.btnRotateBtn:SetEnabled(false)
    self.btnRotateBtn:SetProperty("Alpha", 0.5)
  end
  if self:canScale() then
    self.btnZoomBtn:SetEnabled(true)
    self.btnZoomBtn:SetProperty("Alpha", 1.0)
  else
    self.btnZoomBtn:SetEnabled(false)
    self.btnZoomBtn:SetProperty("Alpha", 0.5)
  end
end

function WidgetMobileEditorToolObject:initUI()
  self.lytNode = self:child("MobileEditorToolObject-node")
  self.imgNodeBg = self:child("MobileEditorToolObject-nodeBg")
  self.btnColorBtn = self:child("MobileEditorToolObject-colorBtn")
  self.imgColorBg = self:child("MobileEditorToolObject-colorBg")
  self.imgColorSelectBg = self:child("MobileEditorToolObject-colorSelectBg")
  self.btnMaterialBtn = self:child("MobileEditorToolObject-materialBtn")
  self.imgMaterialBg = self:child("MobileEditorToolObject-materialBg")
  self.imgMaterialSelectBg = self:child("MobileEditorToolObject-materialSelectBg")
  self.btnCopyBtn = self:child("MobileEditorToolObject-copyBtn")
  self.imgCopyBg = self:child("MobileEditorToolObject-copyBg")
  self.btnConnectBtn = self:child("MobileEditorToolObject-connectBtn")
  self.imgConnectBg = self:child("MobileEditorToolObject-connectBg")
  self.imgDisconnectBg = self:child("MobileEditorToolObject-disconnectBg")
  self.btnFocusBtn = self:child("MobileEditorToolObject-focusBtn")
  self.imgFocusBg = self:child("MobileEditorToolObject-focusBg")
  self.lytMove = self:child("MobileEditorToolObject-move")
  self.imgMoveBg = self:child("MobileEditorToolObject-moveBg")
  self.btnMoveBtn = self:child("MobileEditorToolObject-moveBtn")
  self.lytZoom = self:child("MobileEditorToolObject-zoom")
  self.imgZoomBg = self:child("MobileEditorToolObject-zoomBg")
  self.btnZoomBtn = self:child("MobileEditorToolObject-zoomBtn")
  self.lytRotate = self:child("MobileEditorToolObject-rotate")
  self.imgRotateBg = self:child("MobileEditorToolObject-rotateBg")
  self.btnRotateBtn = self:child("MobileEditorToolObject-rotateBtn")
  self.btnDeleteBtn = self:child("MobileEditorToolObject-deleteBtn")
  self.imgDeleteBg = self:child("MobileEditorToolObject-deleteBg")
  self.imgSideBg = self:child("MobileEditorToolObject-sideBg")
  self.imgIcon = self:child("MobileEditorToolObject-icon")
  self.txtTitle = self:child("MobileEditorToolObject-title")
  self.gvGrid = self:child("MobileEditorToolObject-grid")
  self.gvGrid:InitConfig(2, 2, 2)
  self.lytMultiple = self:child("MobileEditorToolObject-multiple")
  self.btnMultipleCancel = self:child("MobileEditorToolObject-cancel")
  self.btnMultipleSave = self:child("MobileEditorToolObject-save")
  self:refreshTransformBtnSelect()
  self:refreshMaterialBtnSelect()
end

function WidgetMobileEditorToolObject:refreshMaterialBtnSelect()
  self.imgColorSelectBg:SetVisible(self.selectPanel == "color")
  self.imgMaterialSelectBg:SetVisible(self.selectPanel == "material")
end

function WidgetMobileEditorToolObject:showSelection(index)
  if index and 0 < index then
    local item = self.gvGrid:GetItem(index - 1)
    if item then
      item:invoke("highLightSelect", true)
    end
  end
end

function WidgetMobileEditorToolObject:resetSelection()
  local childCount = self.gvGrid:GetItemCount()
  for i = 1, childCount do
    local child = self.gvGrid:GetItem(i - 1)
    if child then
      child:invoke("highLightSelect", false)
    end
  end
end

function WidgetMobileEditorToolObject:updateMaterial()
  self:resetSelection()
  self.enableMaterial = false
  local allGeometry = true
  local colorIndex = 0
  local textureIndex = 0
  for i = 1, #self.targets do
    local inode = GameManager:instance():getNode(self.targets[i])
    if inode then
      if inode:contains("MeshPart") then
        allGeometry = false
      else
        colorIndex = -1
        local textures = inode:getMaterialTextureIndex()
        if type(textures) == "table" then
          textureIndex = -1
        else
          textureIndex = textures
        end
      end
    end
  end
  if not allGeometry then
    return
  end
  self.enableMaterial = true
  if 1 < Lib.getTableSize(self.targets) then
    colorIndex = 0
    textureIndex = 0
  end
  if colorIndex then
    self.colorIndex = colorIndex
  end
  if textureIndex then
    self.textureIndex = textureIndex
  end
  if self.selectPanel == "color" then
    self:showSelection(self.colorIndex)
  end
  if self.selectPanel == "material" then
    self:showSelection(self.textureIndex)
  end
end

function WidgetMobileEditorToolObject:selectColorIndex(item, index)
  self:resetSelection()
  self.colorIndex = index
  item:invoke("highLightSelect", true)
  Lib.emitEvent(Event.EVENT_CHANGE_MATERIAL_COLOR, index)
end

function WidgetMobileEditorToolObject:selectTextureIndex(item, index)
  self:resetSelection()
  self.textureIndex = index
  item:invoke("highLightSelect", true)
  Lib.emitEvent(Event.EVENT_CHANGE_MATERIAL_TEXTURE, index)
end

function WidgetMobileEditorToolObject:initColorGridView()
  self.gvGrid:RemoveAllItems()
  self.gvGrid:SetScrollOffset(0)
  local configs = ConfigManager:instance().materialColorConfig:getConfigs()
  for index, data in ipairs(configs) do
    local item = UIMgr:new_widget("mobileEditorWidgetColorButton", data)
    self:subscribe(item, UIEvent.EventWindowClick, function()
      Lib.logDebug("click color index = ", index)
      self:selectColorIndex(item, index)
      Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    end)
    if index == self.colorIndex then
      item:invoke("highLightSelect", true)
    end
    self.gvGrid:AddItem(item)
  end
end

function WidgetMobileEditorToolObject:initMaterialGridView()
  self.gvGrid:RemoveAllItems()
  self.gvGrid:SetScrollOffset(0)
  local configs = ConfigManager:instance().materialTextureConfig:getConfigs()
  for index, data in ipairs(configs) do
    local item = UIMgr:new_widget("mobileEditorWidgetMaterialButton", data)
    self:subscribe(item, UIEvent.EventWindowClick, function()
      Lib.logDebug("click texture index = ", index)
      self:selectTextureIndex(item, index)
      Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    end)
    if index == self.textureIndex then
      item:invoke("highLightSelect", true)
    end
    self.gvGrid:AddItem(item)
  end
end

function WidgetMobileEditorToolObject:setColorContent()
  self.txtTitle:SetText(Lang:toText(SideBarContent.color.text or ""))
  self.imgIcon:SetImage(SideBarContent.color.icon or "")
  self:initColorGridView()
end

function WidgetMobileEditorToolObject:setMaterialContent()
  self.txtTitle:SetText(Lang:toText(SideBarContent.material.text or ""))
  self.imgIcon:SetImage(SideBarContent.material.icon or "")
  self:initMaterialGridView()
end

function WidgetMobileEditorToolObject:setSideBarContent(name)
  if name == "color" then
    self.selectPanel = "color"
    self:setColorContent()
  end
  if name == "material" then
    self.selectPanel = "material"
    self:setMaterialContent()
  end
end

function WidgetMobileEditorToolObject:hidePanel()
  self.selectPanel = "none"
  self.imgColorSelectBg:SetVisible(false)
  self.imgMaterialSelectBg:SetVisible(false)
  self.imgSideBg:SetVisible(false)
end

function WidgetMobileEditorToolObject:showColorPanel()
  self.imgSideBg:SetVisible(true)
  self:setSideBarContent("color")
end

function WidgetMobileEditorToolObject:showMaterialPanel()
  self.imgSideBg:SetVisible(true)
  self:setSideBarContent("material")
end

function WidgetMobileEditorToolObject:initEvent()
  self:subscribe(self.btnColorBtn, UIEvent.EventButtonClick, function()
    if not self.enableMaterial then
      return
    end
    if self.selectPanel == "color" then
      self:hidePanel()
    else
      self.selectPanel = "color"
      self:showColorPanel()
      self:updateMaterial()
    end
    self:refreshMaterialBtnSelect()
  end)
  self:subscribe(self.btnMaterialBtn, UIEvent.EventButtonClick, function()
    if not self.enableMaterial then
      return
    end
    if self.selectPanel == "material" then
      self:hidePanel()
    else
      self.selectPanel = "material"
      self:showMaterialPanel()
      self:updateMaterial()
    end
    self:refreshMaterialBtnSelect()
  end)
  self:subscribe(self.btnCopyBtn, UIEvent.EventButtonClick, function()
    if not self:canDuplicate() then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.duplicate"))
    Lib.emitEvent(Event.EVENT_DUPLICATE_TARGET)
  end)
  self:subscribe(self.btnConnectBtn, UIEvent.EventButtonClick, function()
    if not self:canMultiple() then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_SWITCH_GIZMO, Define.TRANSFORM_TYPE.NONE)
    self.imgSideBg:SetVisible(false)
    self.lytNode:SetVisible(false)
    self.lytMultiple:SetVisible(true)
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.multiple"))
    Lib.emitEvent(Event.EVENT_CLOSE_TOP)
    Lib.emitEvent(Event.EVENT_ENABLE_MULTIPLE, true)
  end)
  self:subscribe(self.btnFocusBtn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_FOCUS_TARGET)
  end)
  self:subscribe(self.btnMoveBtn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    if self.type == Define.TRANSFORM_TYPE.TRANSLATE then
      self.type = Define.TRANSFORM_TYPE.NONE
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.unselect.translate"))
    else
      self.type = Define.TRANSFORM_TYPE.TRANSLATE
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.translate"))
    end
    self:refreshTransformBtnSelect(self.type)
    Lib.emitEvent(Event.EVENT_SWITCH_GIZMO, self.type)
  end)
  self:subscribe(self.btnZoomBtn, UIEvent.EventButtonClick, function()
    if not self:canScale() then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    if self.type == Define.TRANSFORM_TYPE.SCALE then
      self.type = Define.TRANSFORM_TYPE.NONE
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.unselect.scale"))
    else
      self.type = Define.TRANSFORM_TYPE.SCALE
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.scale"))
    end
    self:refreshTransformBtnSelect(self.type)
    Lib.emitEvent(Event.EVENT_SWITCH_GIZMO, self.type)
  end)
  self:subscribe(self.btnRotateBtn, UIEvent.EventButtonClick, function()
    if not self:canRotate() then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    if self.type == Define.TRANSFORM_TYPE.ROTATE then
      self.type = Define.TRANSFORM_TYPE.NONE
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.unselect.rotate"))
    else
      self.type = Define.TRANSFORM_TYPE.ROTATE
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.rotate"))
    end
    self:refreshTransformBtnSelect(self.type)
    Lib.emitEvent(Event.EVENT_SWITCH_GIZMO, self.type)
  end)
  self:subscribe(self.btnDeleteBtn, UIEvent.EventButtonClick, function()
    if not self:canDelete() then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.delete"))
    Lib.emitEvent(Event.EVENT_DELETE_TARGET)
  end)
  self:subscribe(self.btnMultipleSave, UIEvent.EventButtonClick, function()
    self.lytNode:SetVisible(true)
    self.lytMultiple:SetVisible(false)
    Lib.emitEvent(Event.EVENT_OPEN_TOP)
    Lib.emitEvent(Event.EVENT_CONFIRM_MULTIPLE)
    self:hidePanel()
  end)
  self:subscribe(self.btnMultipleCancel, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.unselect.multiple"))
    self.lytNode:SetVisible(true)
    self.lytMultiple:SetVisible(false)
    Lib.emitEvent(Event.EVENT_OPEN_TOP)
    Lib.emitEvent(Event.EVENT_CANCEL_MULTIPLE)
    self:hidePanel()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LEAVE_EDIT_MODE, function()
    self.type = Define.TRANSFORM_TYPE.NONE
    self:refreshTransformBtnSelect(self.type)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MATERIAL_COLOR, function(colorIndex)
    self:resetSelection()
    self.colorIndex = colorIndex
    self:showSelection(colorIndex)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MATERIAL_TEXTURE, function(textureIndex)
    self:resetSelection()
    self.textureIndex = textureIndex
    self:showSelection(textureIndex)
  end)
end

function WidgetMobileEditorToolObject:refreshTransformBtnSelect(transformType)
  self.imgMoveBg:SetVisible(transformType == Define.TRANSFORM_TYPE.TRANSLATE)
  self.imgRotateBg:SetVisible(transformType == Define.TRANSFORM_TYPE.ROTATE)
  self.imgZoomBg:SetVisible(transformType == Define.TRANSFORM_TYPE.SCALE)
end

function WidgetMobileEditorToolObject:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorToolObject
