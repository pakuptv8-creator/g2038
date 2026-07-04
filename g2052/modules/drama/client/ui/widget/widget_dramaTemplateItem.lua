local widget_base = require("ui.widget.widget_base")
local WidgetDramaTemplateItem = Lib.derive(widget_base)
local DramaTemplateConfig = T(Config, "DramaTemplateConfig")

function WidgetDramaTemplateItem:init()
  widget_base.init(self, "DramaTemplateItem.json")
  self:root():SetName("DramaTemplateItem")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaTemplateItem:initUI()
  self.lytContentPanel = self:child("DramaTemplateItem-ContentPanel")
  self.imgItemBg = self:child("DramaTemplateItem-ItemBg")
  self.imgTemplateBg = self:child("DramaTemplateItem-TemplateBg")
  self.txtTemplateName = self:child("DramaTemplateItem-TemplateName")
  self.btnClickBtn = self:child("DramaTemplateItem-ClickBtn")
end

function WidgetDramaTemplateItem:initEvent()
  self:subscribe(self.btnClickBtn, UIEvent.EventButtonClick, function()
    if self.data.isCustom == 1 then
      local allMod = DramaTemplateConfig:getAllCfgs(true)
      UI:openWnd("dramaTemplateEdit", nil, {
        allMod[1].id,
        allMod[2].id
      })
    else
      UI:openWnd("dramaTemplateEdit", nil, {
        self.data.id
      })
    end
    UI:closeWnd("dramaTemplate")
  end)
end

function WidgetDramaTemplateItem:onDataChanged(data)
  self.data = data
  self.txtTemplateName:SetText(Lang:toText(data.templateName or ""))
  self.imgTemplateBg:SetImage(data.smallImg or "")
end

function WidgetDramaTemplateItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaTemplateItem
