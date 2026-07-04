local widget_base = require("ui.widget.widget_base")
local WidgetChatVipItem = Lib.derive(widget_base)

function WidgetChatVipItem:init()
  widget_base.init(self, "ChatVipItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetChatVipItem:initUI()
  self.imgBg = self:child("ChatVipItem-Bg")
  self.imgSelectIcon = self:child("ChatVipItem-SelectIcon")
  self.imgNormalIcon = self:child("ChatVipItem-NormalIcon")
end

function WidgetChatVipItem:initEvent()
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

function WidgetChatVipItem:updateInfo(data)
  self.colorData = data
  self.imgBg:SetDrawColor(getColorOfRGB(data))
end

function WidgetChatVipItem:updateColorSelectState(value)
  self.imgSelectIcon:SetVisible(value)
end

function WidgetChatVipItem:setClickBackFunc(func)
  self.callBackFunc = func
end

function WidgetChatVipItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetChatVipItem
