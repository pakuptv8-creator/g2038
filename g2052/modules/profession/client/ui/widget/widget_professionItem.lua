local widget_base = require("ui.widget.widget_base")
local WidgetProfessionItem = Lib.derive(widget_base)

function WidgetProfessionItem:init()
  widget_base.init(self, "ProfessionItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetProfessionItem:initUI()
  self.imgBg1 = self:child("ProfessionItem-bg1")
  self.imgBg2 = self:child("ProfessionItem-bg2")
  self.imgProfessionIcon = self:child("ProfessionItem-ProfessionIcon")
  self.txtProfessionName = self:child("ProfessionItem-ProfessionName")
end

function WidgetProfessionItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    local professionId = UI:getWnd("professionWnd"):getCurProfessionId()
    if self.data.id == professionId then
      Me:clientSetProfession(Define.CareerType.Base)
      return
    end
    Me:clientSetProfession(self.data.id)
  end)
end

function WidgetProfessionItem:onDataChanged(data)
  self.data = data
  self.imgProfessionIcon:SetImage(data.sceneIcon)
  self.txtProfessionName:SetText(Lang:toText(data.careerName))
  local professionId = UI:getWnd("professionWnd"):getCurProfessionId()
  if data.id == professionId then
    self.imgBg2:SetVisible(true)
    self.imgBg1:SetVisible(false)
  else
    self.imgBg2:SetVisible(false)
    self.imgBg1:SetVisible(true)
  end
end

function WidgetProfessionItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetProfessionItem
