local widget_base = require("ui.widget.widget_base")
local WidgetEditorMapUIParams = Lib.derive(widget_base)

function WidgetEditorMapUIParams:init()
  widget_base.init(self, "EditorMapUIParams.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetEditorMapUIParams:initUI()
  self.txtName = self:child("EditorMapUIParams-name")
  self.lytParamsLyt = self:child("EditorMapUIParams-ParamsLyt")
  self.btnAddBtn = self:child("EditorMapUIParams-AddBtn")
  self.txtName:SetText("\229\143\130\230\149\176")
end

function WidgetEditorMapUIParams:initEvent()
  self:subscribe(self.btnAddBtn, UIEvent.EventButtonClick, function()
    self:addParam("key", "value")
  end)
end

function WidgetEditorMapUIParams:addParam(key, value)
  local node = UIMgr:new_widget("editorMapUIParamsCell")
  self.lytParamsLyt:AddChildWindow(node)
  table.insert(self.infoList, node)
  node:SetYPosition({
    0,
    50 * #self.infoList - 50
  })
  local index = #self.infoList
  local cell = node:get()
  cell:dataUpdate(function(k, v)
    self:updateParam(key, k, v)
  end, function()
    self:updateParam(key)
    self:removeParam(node)
  end)
  cell:setData(key, value)
  self.btnAddBtn:SetYPosition({
    0,
    50 * #self.infoList + 50
  })
  self:root():SetArea({0, 0}, {0, 0}, {1, 0}, {
    0,
    50 * #self.infoList + 150
  })
end

function WidgetEditorMapUIParams:removeParam(node)
  for i, n in ipairs(self.infoList) do
    if n == node then
      table.remove(self.infoList, i)
      break
    end
  end
  self.lytParamsLyt:RemoveChildWindow1(node)
  for i, n in ipairs(self.infoList) do
    node:SetYPosition({
      0,
      50 * i
    })
  end
  self.btnAddBtn:SetYPosition({
    0,
    50 * #self.infoList + 50
  })
  self:root():SetArea({0, 0}, {0, 0}, {1, 0}, {
    0,
    50 * #self.infoList + 150
  })
end

function WidgetEditorMapUIParams:updateParam(key, k, v)
  self.params[key] = nil
  if k and v then
    self.params[k] = v
  end
  if next(self.params) then
    self.uiCfg.params = self.params
  else
    self.uiCfg.params = nil
  end
  self.valueUpdateCallback()
end

function WidgetEditorMapUIParams:updateView()
  self.infoList = {}
  self.lytParamsLyt:CleanupChildren()
  local uiParams = self.curr_ui:root():data("sceneUIParams")
  local key = uiParams.key
  self.uiCfg = Plugins.CallTargetPluginFunc("scene_ui", "getSceneUICfg", key)
  local params = self.uiCfg.params or {}
  self.params = params
  for k, v in pairs(params) do
    self:addParam(k, v)
  end
end

function WidgetEditorMapUIParams:setData(select_ui)
  self.curr_ui = select_ui
  self:updateView()
end

function WidgetEditorMapUIParams:valueUpdate(callback)
  self.valueUpdateCallback = callback
end

function WidgetEditorMapUIParams:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetEditorMapUIParams
