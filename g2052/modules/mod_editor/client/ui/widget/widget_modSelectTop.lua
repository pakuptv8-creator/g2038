local widget_base = require("ui.widget.widget_base")
local WidgetModSelectTop = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModSelectTop:init()
  widget_base.init(self, "ModSelectTop.json")
  self._allEvent = {}
  self:initUI()
  self.reqTopicInfoKey = "ModSelectTop_TopicInfo"
  ModAsyncProxy:regDelegateRequest(self.reqTopicInfoKey, AsyncProcess.GetTopicTitleInfo, Event.EVENT_MOD_RESPONSE_TOPIC_TITLE_INFO)
  self:initEvent()
end

function WidgetModSelectTop:initUI()
  self.lytTopPanel = self:child("ModSelectTop-TopPanel")
  self.lytTopLeftPanel = self:child("ModSelectTop-TopLeftPanel")
  self.btnTopEvent1 = self:child("ModSelectTop-TopEvent1")
  self.btnTopEvent2 = self:child("ModSelectTop-TopEvent2")
  self.txtEventTitle1 = self:child("ModSelectTop-EventTitle1")
  self.txtEventTitle2 = self:child("ModSelectTop-EventTitle2")
  self.imgTopEventIcon1 = self:child("ModSelectTop-TopEventIcon1")
  self.imgTopEventIcon2 = self:child("ModSelectTop-TopEventIcon2")
  self.lytPagePanel = self:child("ModSelectTop-PagePanel")
  self.eventGridView = UIMgr:new_widget("grid_view")
  self.lytTopLeftPanel:AddChildWindow(self.eventGridView)
  self.eventGridView:SethScorllMoveAble(true)
  self.eventGridView:SetvScorllMoveAble(false)
  self.eventGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.eventGridView:InitConfig(0, 0, 1)
  self.eventCells = {}
  self.topEventData1 = {}
  self.topEventData2 = {}
  self.topEventList = {}
  self.topEventPoint = {}
end

function WidgetModSelectTop:initEvent()
  self:subscribe(self.btnTopEvent1, UIEvent.EventButtonClick, function()
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.MainBannerR1)
    self:handleBannerEvent(self.topEventData1)
  end)
  self:subscribe(self.btnTopEvent2, UIEvent.EventButtonClick, function()
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.MainBannerR2)
    self:handleBannerEvent(self.topEventData2)
  end)
  self:subscribe(self.eventGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.eventGridView:GetScrollOffset()
    self:updatePointPageShow(offset)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_HANDLE_MAIN_BANNER, function(data)
    self:handleBannerEvent(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_TOPIC_TITLE_INFO, function(data)
    Lib.emitEvent(Event.EVENT_MOD_JUMP_TO_TOPIC, data)
  end)
end

function WidgetModSelectTop:handleBannerEvent(data)
  if not data then
    return
  end
  if data.eventType then
    if data.eventType == Define.Mod.BannerEventType.ADS then
      UI:openWnd("modMapAds")
    elseif data.eventType == Define.Mod.BannerEventType.Topic then
      local topicId = tonumber(data.eventData)
      ModAsyncProxy:request(self.reqTopicInfoKey, topicId)
    end
  end
end

function WidgetModSelectTop:updatePointPageShow(offset)
  if not self.totalPage then
    return
  end
  if 0 < offset then
    self:updatePointSelectState(self.totalPage)
  else
    local offsetS = -offset + 225
    local pageNum = math.floor(offsetS / 455)
    local result = self.totalPage - pageNum
    if result < 1 then
      result = 1
    end
    self:updatePointSelectState(result)
  end
end

function WidgetModSelectTop:updateItemByData(data)
  self.topEventData1 = {}
  self.topEventData2 = {}
  self.topEventList = {}
  for _, val in pairs(data) do
    if val.posKey == 2 then
      self.topEventData1 = val
      self:updateEventBtnInfo(self.imgTopEventIcon1, self.txtEventTitle1, val)
    elseif val.posKey == 3 then
      self.topEventData2 = val
      self:updateEventBtnInfo(self.imgTopEventIcon2, self.txtEventTitle2, val)
    else
      table.insert(self.topEventList, val)
    end
  end
  if next(self.topEventData1) then
    self.btnTopEvent1:SetVisible(true)
  else
    self.btnTopEvent1:SetVisible(false)
  end
  if next(self.topEventData2) then
    self.btnTopEvent2:SetVisible(true)
  else
    self.btnTopEvent2:SetVisible(false)
  end
  self.totalPage = #self.topEventList
  self:updateEventListShow()
  self:updateEventPointShow()
end

function WidgetModSelectTop:updateEventBtnInfo(imageNode, txtNode, btnData)
  imageNode:SetImageUrl(btnData.imagePic)
  txtNode:SetText(btnData.eventDesc or "")
end

function WidgetModSelectTop:updateEventListShow()
  self.eventGridView:InitConfig(0, 0, #self.topEventList)
  for i, cell in pairs(self.eventCells or {}) do
    if i > #self.topEventList then
      self.eventGridView:RemoveItem(cell)
      self.eventCells[i] = nil
    end
  end
  for index, value in ipairs(self.topEventList or {}) do
    if not self.eventCells[index] then
      local cell = UIMgr:new_widget("modSelectTopItem")
      cell:invoke("updateModEventShow", value)
      self.eventGridView:AddItem(cell)
      self.eventCells[index] = cell
    else
      self.eventCells[index]:invoke("updateModEventShow", value)
    end
  end
end

function WidgetModSelectTop:updateEventPointShow()
  for _, val in pairs(self.topEventPoint) do
    val:SetVisible(false)
  end
  local pointWidth = 10
  local disX = 15
  for index, value in ipairs(self.topEventList or {}) do
    if not self.topEventPoint[index] then
      local widget = UIMgr:new_widget("modSelectTopPoint")
      widget:SetArea({
        0,
        -(index - 1) * (disX + pointWidth)
      }, {0, 0}, {0, pointWidth}, {0, pointWidth})
      self.lytPagePanel:AddChildWindow(widget)
      self.topEventPoint[index] = widget
    end
    self.topEventPoint[index]:invoke("updatePointStateShow", false)
    self.topEventPoint[index]:SetVisible(true)
  end
  self:updatePointSelectState(self.totalPage)
end

function WidgetModSelectTop:updatePointSelectState(curIndex)
  for index, val in pairs(self.topEventPoint) do
    self.topEventPoint[index]:invoke("updatePointStateShow", index == curIndex)
  end
end

function WidgetModSelectTop:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModSelectTop
