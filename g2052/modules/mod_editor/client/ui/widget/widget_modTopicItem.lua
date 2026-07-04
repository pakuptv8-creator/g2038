local widget_base = require("ui.widget.widget_base")
local WidgetModTopicItem = Lib.derive(widget_base)

function WidgetModTopicItem:init()
  widget_base.init(self, "ModTopicItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModTopicItem:initUI()
  self.lytMapPanel = self:child("ModTopicItem-MapPanel")
  self.txtTopicTitle = self:child("ModTopicItem-TopicTitle")
  self.lytMapList = self:child("ModTopicItem-MapList")
  self.lytMorePanel = self:child("ModTopicItem-MorePanel")
  self.txtMoreText = self:child("ModTopicItem-MoreText")
  self.txtMoreText:SetText(Lang:toText("g2052.gui.mod_main.topic.more"))
  self:initMapItem()
end

function WidgetModTopicItem:initMapItem()
  self.mapGameList = {}
  local itemWidth = 195
  local xDis = 48
  for i = 1, 4 do
    local widget = UIMgr:new_widget("modMapItem")
    widget:SetXPosition({
      0,
      (i - 1) * (itemWidth + xDis)
    })
    widget:SetYPosition({0, 0})
    self.lytMapList:AddChildWindow(widget)
    self.mapGameList[i] = widget
  end
end

function WidgetModTopicItem:initEvent()
  self:subscribe(self.lytMorePanel, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_MOD_TOPIC_WND_UPDATE, true, self.data)
  end)
end

function WidgetModTopicItem:onDataChanged(data)
  self.data = data
  self.txtTopicTitle:SetText(data.title)
  for i = 1, 4 do
    if data.gameList[i] then
      Lib.attachModItemInfo(data.gameList[i], World.cfg.modUIInfo.modItemFromPathMappings.MainTopic)
      self.mapGameList[i]:SetVisible(true)
      self.mapGameList[i]:invoke("updateMapGameInfo", data.gameList[i])
    else
      self.mapGameList[i]:SetVisible(false)
    end
  end
end

function WidgetModTopicItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModTopicItem
