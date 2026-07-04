local widget_base = require("ui.widget.widget_base")
local WidgetRolePage1 = Lib.derive(widget_base)

function WidgetRolePage1:init(data)
  widget_base.init(self, "RolePage1.json")
  self._allEvent = {}
  self.data = data
  self._tabCount = Lib.getTableSize(self.data.list or {})
  self:initUI()
  self:initEvent()
  self:initView()
end

function WidgetRolePage1:initUI()
  self.lytTabContainer = self:child("RolePage1-TabContainer")
  self._tabGridView = GridViewHelper.new({
    name = "tabGridView",
    xCellNum = 1,
    yDis = 10,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    widgetWidth = 45,
    widgetHeight = 45,
    widgetJson = "TabItem.json",
    widgetName = "tabItem",
    gvParent = self.lytTabContainer,
    cellSelectedCb = function(data, dx, dy, index)
      self:updateTabContent(data)
      if self.lastIndex then
        Me:scanDressItemsByIndex(self.lastIndex)
      end
      self.lastIndex = data.id
    end
  })
  self.lytContentContainer = self:child("RolePage1-ContentContainer")
  self._contentGridView = GridViewHelper.new({
    name = "contentGridView",
    xCellNum = 3,
    xDis = 4,
    yDis = 6,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    moveAble = true,
    widgetWidth = 88,
    widgetHeight = 88,
    widgetJson = "DressItem.json",
    widgetName = "dressItem",
    gvParent = self.lytContentContainer,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
end

function WidgetRolePage1:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_APPEARANCE_INFO_UPDATE, function(shapeInfo)
    local data = self.contentData
    if data then
      local initTabIndex = -1
      for i, v in ipairs(data.member) do
        local parts = v.parts
        for master, val in pairs(parts) do
          if shapeInfo[master] == val then
            initTabIndex = i
          end
        end
        if initTabIndex ~= -1 then
          break
        end
      end
      self._contentGridView:setData(data.member, initTabIndex, nil, true, true)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_WATCH_AD_UPDATE, function()
    self._contentGridView:getAdapter():notifyDataChange()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRESS_FREE_AD_TIME, function()
    self:updateSelf()
  end)
end

function WidgetRolePage1:initView()
  local data = {}
  local list = self.data.list
  for i, v in pairs(list) do
    data[#data + 1] = v
  end
  table.sort(data, function(a, b)
    return a.id < b.id
  end)
  self._tabGridView:setData(data, 1, nil, false)
end

function WidgetRolePage1:openTabIndex(index, dressId)
  self._tabGridView:setClickByOrder(index)
  if dressId then
    local data = self.contentData
    if data then
      local initTabIndex = -1
      local curData
      for i, v in ipairs(data.member) do
        if v.id == dressId then
          initTabIndex = i
          curData = v
        end
      end
      if 0 < initTabIndex then
        self._contentGridView:setData(data.member, initTabIndex, nil, true, true)
        Me:sendPacket({
          pid = "roleChangeSkin",
          skinData = curData.parts,
          isReset = false,
          conflictParts = curData.conflictParts,
          conflictOriginal = curData.conflictOriginal,
          id = curData.id,
          lockState = curData.lockState,
          needBuy = curData.needBuy
        })
      end
    end
  end
end

function WidgetRolePage1:updateTabContent(data)
  if data == nil then
    return
  end
  local isUpdateSelf = self.contentData == data
  self.contentData = data
  local shapeInfo = Me:getShapeInfo()
  local initTabIndex = -1
  table.sort(data.member, function(a, b)
    if a.priority == b.priority then
      return a.id < b.id
    else
      return a.priority < b.priority
    end
  end)
  for i, v in ipairs(data.member) do
    local parts = v.parts
    for master, val in pairs(parts) do
      if shapeInfo[master] == val then
        initTabIndex = i
      end
    end
    if initTabIndex ~= -1 then
      break
    end
  end
  if not isUpdateSelf then
    self._contentGridView:getAdapter():setScrollOffset(0)
  end
  self._contentGridView:setData(data.member, initTabIndex, nil, true, true)
end

function WidgetRolePage1:getLastIndex()
  return self.lastIndex
end

function WidgetRolePage1:updateSelf()
  self:updateTabContent(self.contentData)
end

function WidgetRolePage1:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetRolePage1
