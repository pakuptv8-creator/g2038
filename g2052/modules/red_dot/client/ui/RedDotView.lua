local rdMgr = require("client.controller.RedDotMgr")
local RedDotMgr = rdMgr:getInstance()
local widget_base = require("ui.widget.widget_base")
local WidgetRedDot = Lib.class("WidgetRedDot", widget_base)

function WidgetRedDot:ctor(key, parentKey)
  self.key = key
  self.parentKey = parentKey
  self.defaultRadius = 11
  self.customImage = nil
  self.isShowNumber = false
  self.redDotImgSize = nil
  self.fontSize = "HT16"
  self.offset = {x = 0, y = 0}
  self:init()
end

function WidgetRedDot:init()
  widget_base.init(self)
  self:root():SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self:root():SetTouchable(false)
end

function WidgetRedDot:initView()
  local imgRedDot = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "redDot")
  imgRedDot:SetTouchable(false)
  imgRedDot:SetProperty("Material", "CullBackLinear")
  imgRedDot:SetHorizontalAlignment(2)
  self:root():AddChildWindow(imgRedDot)
  if self.isShowNumber then
    self.txtNum = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "numText")
    self.txtNum:SetHorizontalAlignment(1)
    self.txtNum:SetVerticalAlignment(1)
    self.txtNum:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
    self.txtNum:SetTextVertAlign(1)
    self.txtNum:SetTextHorzAlign(1)
    self.txtNum:SetFontSize(self.fontSize)
    imgRedDot:AddChildWindow(self.txtNum)
  end
  local size
  if self.customImage then
    local isEffect = string.find(self.customImage, ".effect")
    if isEffect then
      imgRedDot:SetEffectName(self.customImage)
    else
      UILib:setImageAdjustSize(imgRedDot, self.customImage, 60, 60)
      size = imgRedDot:GetPixelSize()
    end
  else
    local imgUrl = "set:red_dot.json image:reddot"
    UILib:setImageAdjustSize(imgRedDot, imgUrl, 60, 60)
    size = {
      x = self.defaultRadius * 2,
      y = self.defaultRadius * 2
    }
  end
  if self.redDotImgSize then
    size = self.redDotImgSize
  end
  imgRedDot:SetArea({
    0,
    0 + self.offset.x
  }, {
    0,
    0 + self.offset.y
  }, {
    0,
    size.x
  }, {
    0,
    size.y
  })
end

function WidgetRedDot:setDefaultRadius(radius)
  self.defaultRadius = radius
  return self
end

function WidgetRedDot:setRedDotImgSize(redDotImgSize)
  self.redDotImgSize = redDotImgSize
  return self
end

function WidgetRedDot:setIsShowNumber(isShowNum)
  self.isShowNumber = isShowNum
  return self
end

function WidgetRedDot:setCustomImage(imageUrl)
  self.customImage = imageUrl
  return self
end

function WidgetRedDot:setOffset(offset)
  self.offset = offset
  return self
end

function WidgetRedDot:setFontSize(sizeStr)
  self.fontSize = sizeStr
  return self
end

function WidgetRedDot:show(parent, isVisible)
  assert(parent, "must have parent node")
  self:initView()
  parent:AddChildWindow(self:root())
  if isVisible ~= nil then
    self:root():SetVisible(isVisible)
  end
  if self.key then
    self:root():SetVisible(false)
    if not RedDotMgr:isAlreadyRegistered(self.key) then
      if self.parentKey then
        local parentKey = self.parentKey
        local profile = {
          [parentKey] = {
            self.key
          }
        }
        RedDotMgr:registerProfile(profile)
      else
        RedDotMgr:registerProfile(self.key)
      end
    else
      print("Warn: key (" .. self.key .. ") is already registered ,can not register again")
    end
    RedDotMgr:linkRedDotAction(self.key, function(show)
      self:refresh(show)
    end)
  end
  return self
end

function WidgetRedDot:refresh(show)
  self:root():SetVisible(0 < show)
  if self.isShowNumber then
    self.txtNum:SetText(tostring(show))
  end
end

function WidgetRedDot:onDestroy()
  if self.key then
    RedDotMgr:unlinkRedDotAction(self.key)
  end
end

local RedDotView = T(UILib, "RedDotView")

function RedDotView.builder(key, parentKey)
  local widget = WidgetRedDot.new(key, parentKey)
  return widget
end

return RedDotView
