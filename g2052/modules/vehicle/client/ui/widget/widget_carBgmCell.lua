local widget_base = require("ui.widget.widget_base")
local WidgetCarBgmCell = Lib.derive(widget_base)

function WidgetCarBgmCell:init()
  widget_base.init(self, "CarBgmCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetCarBgmCell:initUI()
  self.imgIcon = self:child("CarBgmCell-icon")
  self.txtLine = self:child("CarBgmCell-line")
  self.txtName = self:child("CarBgmCell-name")
  self.lytEffect = self:child("CarBgmCell-effect")
end

function WidgetCarBgmCell:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CAR_BGM_UPDATE, function(bgm)
    local inPlay = false
    if bgm and self.info and bgm == self.info.soundKey then
      inPlay = true
    end
    self.lytEffect:SetVisible(inPlay)
    self.imgIcon:SetVisible(not inPlay)
  end)
end

function WidgetCarBgmCell:onDataChanged(data)
  self.data = data or {}
  self.info = data.data
  self.fun = data.clickCb
  if self.info then
    self:updateView()
  else
    self:empty()
  end
end

function WidgetCarBgmCell:updateView()
  if self.data.select then
    self:root():SetAlpha(1)
  else
    self:root():SetAlpha(0.5)
  end
  self.txtName:SetText(Lang:toText(self.info.name))
end

function WidgetCarBgmCell:empty()
end

function WidgetCarBgmCell:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetCarBgmCell
