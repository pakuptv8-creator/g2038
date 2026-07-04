local widget_base = require("ui.widget.widget_base")
local WidgetHeadColorItem = Lib.derive(widget_base)

function WidgetHeadColorItem:init()
  widget_base.init(self, "HeadColorItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHeadColorItem:initUI()
  self.imgBg = self:child("HeadColorItem-Bg")
  self.imgSelectIcon = self:child("HeadColorItem-SelectIcon")
  self.imgNormalIcon = self:child("HeadColorItem-NormalIcon")
end

function WidgetHeadColorItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.callBackFunc then
      self.callBackFunc(self.colorData)
    end
  end)
end

local function getColorOfRGB(str)
  local curColorStr = str or "000000"
  local newstr = string.gsub(curColorStr, "#", "")
  local colorlist = {}
  local index = 1
  while index < string.len(newstr) do
    local tempstr = string.sub(newstr, index, index + 1)
    table.insert(colorlist, tonumber(tempstr, 16))
    index = index + 2
  end
  return {
    (colorlist[1] or 0) / 255,
    (colorlist[2] or 0) / 255,
    (colorlist[3] or 0) / 255,
    1
  }
end

function WidgetHeadColorItem:updateInfo(data)
  self.colorData = data
  self.imgBg:SetDrawColor(getColorOfRGB(data))
end

function WidgetHeadColorItem:updateColorSelectState(value)
  self.imgSelectIcon:SetVisible(value)
end

function WidgetHeadColorItem:setClickBackFunc(func)
  self.callBackFunc = func
end

function WidgetHeadColorItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHeadColorItem
