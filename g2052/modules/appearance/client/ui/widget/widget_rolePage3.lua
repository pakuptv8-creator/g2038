local widget_base = require("ui.widget.widget_base")
local WidgetRolePage3 = Lib.derive(widget_base)

function WidgetRolePage3:init(data)
  widget_base.init(self, "RolePage3.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:updateTabContent(data)
end

function WidgetRolePage3:initUI()
  self.lytContentContainer = self:child("RolePage3-ContentContainer")
  self._contentGridView = GridViewHelper.new({
    name = "contentGridView",
    xCellNum = 3,
    yDis = 7,
    xDis = 4,
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
    widgetWidth = 102,
    widgetHeight = 102,
    widgetJson = "DressItem.json",
    widgetName = "dressItem",
    gvParent = self.lytContentContainer,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
end

function WidgetRolePage3:initEvent()
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
end

function WidgetRolePage3:updateTabContent(data)
  if data.list and next(data.list) ~= nil then
    for _, v in pairs(data.list) do
      table.sort(v.member, function(a, b)
        if a.priority == b.priority then
          return a.id < b.id
        else
          return a.priority < b.priority
        end
      end)
      self.contentData = v
      self._contentGridView:setData(v.member, -1, nil, true, true)
      break
    end
  end
end

function WidgetRolePage3:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetRolePage3
