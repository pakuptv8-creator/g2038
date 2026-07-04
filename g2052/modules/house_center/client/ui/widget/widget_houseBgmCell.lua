local widget_base = require("ui.widget.widget_base")
local WidgetHouseBgmCell = Lib.derive(widget_base)

function WidgetHouseBgmCell:init()
  widget_base.init(self, "HouseBgmCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHouseBgmCell:initUI()
  self.imgIcon = self:child("HouseBgmCell-icon")
  self.txtLine = self:child("HouseBgmCell-line")
  self.txtName = self:child("HouseBgmCell-name")
  self.lytEffect = self:child("HouseBgmCell-effect")
end

function WidgetHouseBgmCell:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_OWN_HOUSE_BGM, function(bgm)
    local inPlay = false
    if bgm and self.info and bgm == self.info.soundKey then
      inPlay = true
    end
    self.lytEffect:SetVisible(inPlay)
    self.imgIcon:SetVisible(not inPlay)
  end)
end

function WidgetHouseBgmCell:onDataChanged(data)
  self.data = data or {}
  self.info = data.data
  self.fun = data.clickCb
  if self.info then
    self:updateView()
  else
    self:empty()
  end
end

function WidgetHouseBgmCell:updateView()
  if self.data.select then
    self:root():SetAlpha(1)
  else
    self:root():SetAlpha(0.5)
  end
  self.txtName:SetText(Lang:toText(self.info.name))
end

function WidgetHouseBgmCell:empty()
end

function WidgetHouseBgmCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHouseBgmCell
