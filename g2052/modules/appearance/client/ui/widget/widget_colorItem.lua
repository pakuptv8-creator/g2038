local widget_base = require("ui.widget.widget_base")
local WidgetColorItem = Lib.derive(widget_base)

local function parseToColor(colorStr)
  local rgba = Lib.splitString(colorStr, ",", true)
  if rgba[4] == nil then
    return {
      0,
      0,
      0,
      0
    }
  else
    return {
      rgba[1],
      rgba[2],
      rgba[3],
      rgba[4]
    }
  end
end

function WidgetColorItem:init()
  widget_base.init(self, "ColorItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetColorItem:initUI()
  self.btnChoose = self:child("ColorItem-Choose")
  self.imgColor = self:child("ColorItem-Color")
end

function WidgetColorItem:initEvent()
  self:subscribe(self.btnChoose, UIEvent.EventButtonClick, function()
    if self.clickCb then
      self.clickCb()
    end
    local isReset = false
    local skinData = {}
    if self.select then
      skinData = {
        skin_color = self.color
      }
    else
      local originalSkin = Me:getOriginalSkin()
      for key, _ in pairs(self.data.parts) do
        skinData[key] = originalSkin[key]
        if Lib.isSameTable(skinData[key] or {}, {
          0,
          0,
          0,
          0
        }) then
          skinData[key] = {
            1,
            1,
            1,
            0
          }
        end
      end
      isReset = true
    end
    local packet = {
      pid = "roleChangeSkin",
      skinData = skinData,
      isReset = isReset,
      opOrder = Me:getChangeSkinOpOrder()
    }
    Me:sendPacket(packet)
    Me:changeSkinClient(packet)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_APPEARANCE_INFO_UPDATE, function(shapeInfo)
    if next(shapeInfo) == nil and self.select and self.clickCb then
      self.clickCb()
    end
  end)
end

function WidgetColorItem:onDataChanged(params)
  self.data = Lib.copyTable1(params.data)
  self.color = parseToColor(self.data.parts.skin_color)
  self.imgColor:SetDrawColor(self.color)
  self.clickCb = params.clickCb
  self.select = params.select
  self:updateSelectStatus(params.select)
end

function WidgetColorItem:updateSelectStatus(select)
  self.btnChoose:SetNormalImage(select and "set:g2052_function.json image:img_0_colour03" or "")
  self.btnChoose:SetPushedImage(select and "set:g2052_function.json image:img_0_colour03" or "")
end

function WidgetColorItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetColorItem
