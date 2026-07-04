local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorToolModel = Lib.derive(widget_base)
local btnCfg = {
  {
    name = "game",
    icon = "set:g2052_mobile_editor_common.json image:btn_0_game",
    title = "ui.select.model.game"
  },
  {
    name = "geometry",
    icon = "set:g2052_mobile_editor_common.json  image:btn_0_geometry",
    title = "ui.select.model.geometry"
  },
  {
    name = "outdoor",
    icon = "set:g2052_mobile_editor_common.json  image:btn_0_outdoor",
    title = "ui.select.model.outdoor"
  },
  {
    name = "plant",
    icon = "set:g2052_mobile_editor_common.json  image:btn_0_plant",
    title = "ui.select.model.plant"
  },
  {
    name = "indoor",
    icon = "set:g2052_mobile_editor_common.json  image:btn_0_indoor",
    title = "ui.select.model.indoor"
  },
  {
    name = "props",
    icon = "set:g2052_mobile_editor_common.json  image:btn_0_props",
    title = "ui.select.model.props"
  }
}

function WidgetMobileEditorToolModel:init()
  widget_base.init(self, "MobileEditorToolModel.json")
  self.showModel = ""
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetMobileEditorToolModel:setTargets(targets)
  self.targets = targets
end

function WidgetMobileEditorToolModel:initUI()
  self.imgBg = self:child("MobileEditorToolModel-bg")
  self.lstButtonList = self:child("MobileEditorToolModel-buttonList")
  self.lytSecondaryNode = self:child("MobileEditorToolModel-secondaryNode")
  for _, tab in pairs(btnCfg) do
    local btn = UIMgr:new_widget("mobileEditorWidgetModelButton")
    btn:invoke("setContent", tab)
    self.lstButtonList:AddItem(btn)
  end
  local model_common = UIMgr:new_widget("mobileEditorWidgetModelCommonSecondary")
  self.model_common = model_common
  self.lytSecondaryNode:AddChildWindow(model_common)
  self.lytSecondaryNode:SetVisible(false)
end

function WidgetMobileEditorToolModel:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_MODEL_EDITOR, function(modelType)
    if modelType ~= "" then
      self.lytSecondaryNode:SetVisible(true)
      if self.model_common then
        for i, v in pairs(btnCfg) do
          if v.name == modelType then
            self.model_common:invoke("refreshTitle", v.title, v.icon)
            break
          end
        end
      end
    else
      self.lytSecondaryNode:SetVisible(false)
    end
    self.showModel = modelType
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LEAVE_EDIT_MODE, function()
    self.lytSecondaryNode:SetVisible(false)
  end)
end

function WidgetMobileEditorToolModel:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorToolModel
