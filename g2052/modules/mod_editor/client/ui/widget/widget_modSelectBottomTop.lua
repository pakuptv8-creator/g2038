local widget_base = require("ui.widget.widget_base")
local WidgetModSelectBottomTop = Lib.derive(widget_base)

function WidgetModSelectBottomTop:init()
  widget_base.init(self, "ModSelectBottomTop.json")
  self._allEvent = {}
  self:initUI()
end

function WidgetModSelectBottomTop:initUI()
  self.lytMapPanel = self:child("ModSelectBottomTop-MapPanel")
  self.txtBottomTitle = self:child("ModSelectBottomTop-BottomTitle")
  self.lytMapList = self:child("ModSelectBottomTop-MapList")
  self.txtBottomTitle:SetText(Lang:toText("g2052.gui.mod_main.recommend.title"))
  self:initMapItem()
  self:initEvent()
end

function WidgetModSelectBottomTop:initMapItem()
  self.mapGameList = {}
  local itemWidth = 195
  local widgetHeight = 271
  local xDis = 48
  local yDis = 40
  for i = 0, 7 do
    local widget = UIMgr:new_widget("modMapItem")
    local row = math.floor(i / 4)
    local col = i - row * 4
    widget:SetXPosition({
      0,
      col * (itemWidth + xDis)
    })
    widget:SetYPosition({
      0,
      row * (widgetHeight + yDis)
    })
    self.lytMapList:AddChildWindow(widget)
    self.mapGameList[i + 1] = widget
    self.mapGameList[i + 1]:SetVisible(false)
  end
  self.recommendGameData = {}
end

function WidgetModSelectBottomTop:initEvent()
end

function WidgetModSelectBottomTop:resetRecommendData()
  self.recommendGameData = {}
end

function WidgetModSelectBottomTop:updateItemByData(data)
  if self.recommendGameData and not Lib.table_is_empty(self.recommendGameData) then
    return
  end
  data = data.data
  for _, val in pairs(data or {}) do
    table.insert(self.recommendGameData, val)
  end
  for i = 1, 8 do
    if self.recommendGameData[i] then
      self.mapGameList[i]:SetVisible(true)
      self.mapGameList[i]:invoke("updateMapGameInfo", self.recommendGameData[i])
    else
      self.mapGameList[i]:SetVisible(false)
    end
  end
end

function WidgetModSelectBottomTop:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModSelectBottomTop
