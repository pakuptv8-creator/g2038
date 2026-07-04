local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeActivityMenu = Lib.derive(widget_base)
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local activityEntry = {
  [Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY] = false,
  [Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT] = false,
  [Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT] = false
}
local activityEntryInfo = Define.LIMITED_TIME_ACTIVITY_ENTRY or {
  [Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY] = {
    icon = "set:general_limited_time.json image:btn_0_gift_bag2",
    name = "gui.limit.time.activity.title",
    type = Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY,
    effect = ""
  },
  [Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT] = {
    icon = "set:general_limited_time.json image:btn_0_gift_bag3",
    name = "gui.limit.time.combined.title",
    type = Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT,
    effect = "limited_giftpack_entrance_1.effect"
  },
  [Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT] = {
    icon = "set:general_limited_time.json image:btn_0_gift_bag3",
    name = "gui.limit.time.combined.title",
    type = Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT,
    effect = "limited_giftpack_entrance_1.effect"
  }
}

function WidgetLimitedTimeActivityMenu:init(params)
  widget_base.init(self, "LimitedTimeActivityMenu.json")
  self._allEvent = {}
  self.cells = {}
  self:initUI(params)
  self:initEvent()
end

function WidgetLimitedTimeActivityMenu:initUI(params)
  if not self._root then
    return
  end
  if params then
    self._root:SetVerticalAlignment(params.va or 0)
    self._root:SetHorizontalAlignment(params.ha or 0)
    local x, y, w, h
    if params.area then
      x = params.area and params.area[1]
      y = params.area and params.area[2]
      w = params.area and params.area[3]
      h = params.area and params.area[4]
    end
    self._root:SetArea(x or {0, 0}, y or {0, 0}, w or {0, 100}, h or {0, 60})
    self.params = params
  end
  self.gvBtnList = UIMgr:new_widget("grid_view")
  self._root:AddChildWindow(self.gvBtnList)
  self.gvBtnList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBtnList:SetMoveAble(false)
  self.gvBtnList:SetClipChild(false)
  self:initList()
end

function WidgetLimitedTimeActivityMenu:initList()
  local count = 0
  for i, v in pairs(activityEntry) do
    count = count + 1
    local cell = UIMgr:new_widget("limitedTimeActivityMenuCell")
    local font
    if self.params then
      cell:SetWidth({
        0,
        self.params.cellW or 74
      })
      cell:SetHeight({
        0,
        self.params.cellW or 74
      })
      font = self.params.font
    end
    self.gvBtnList:AddItem(cell)
    cell:invoke("updateView", activityEntryInfo[i], font)
    self.cells[i] = cell
  end
end

function WidgetLimitedTimeActivityMenu:initEvent()
end

function WidgetLimitedTimeActivityMenu:updateMenuBtn(type, value)
  if type == Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY then
    activityEntry[type] = LimitedTimeActivityGameMgr:checkGroupActivityIsCanShow(Define.LIMITED_TIME_ACTIVITY_WND.COMMON_WND)
  elseif value ~= nil then
    activityEntry[type] = value
  end
  local count = 0
  local curInfo = {}
  for i, v in pairs(activityEntry) do
    if self.cells[i] then
      self.cells[i]:SetVisible(v)
      if v then
        count = count + 1
        table.insert(curInfo, activityEntryInfo[i])
      end
      self.cells[i]:invoke("empty")
    end
  end
  for i, v in ipairs(curInfo) do
    if self.cells[i] then
      self.cells[i]:invoke("updateView", v)
    end
  end
  self.gvBtnList:InitConfig(0, 0, count)
  local w = self.params and (self.params.cellW or 74) or 74
  if 0 < count then
    self._root:SetWidth({
      0,
      count * w + (count - 1) * 10
    })
  else
    self._root:SetWidth({0, 0})
  end
end

function WidgetLimitedTimeActivityMenu:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeActivityMenu
