local widget_base = require("ui.widget.widget_base")
local WidgetPartInteractionPop = Lib.derive(widget_base)
local InteractEventConfig = T(Config, "InteractEventConfig")

function WidgetPartInteractionPop:init()
  widget_base.init(self, "PartInteractionPop.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPartInteractionPop:initUI()
  self.btnBtn = self:child("PartInteractionPop-btn")
  self.imgIcon = self:child("PartInteractionPop-Icon")
  self.lytTvBtnList = self:child("PartInteractionPop-tv_btn_list")
  self.btnTvBtnR = self:child("PartInteractionPop-tv_btn_r")
  self.btnTvBtnL = self:child("PartInteractionPop-tv_btn_l")
end

function WidgetPartInteractionPop:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if Me:isCameraMode() then
      return
    end
    if self.targetID then
      Me:sendPacket({
        pid = "ClickPartInteractionPop",
        targetID = self.targetID
      })
      Me:removePartInteractPop(self.targetID)
    end
  end)
  self:subscribe(self.btnTvBtnR, UIEvent.EventButtonClick, function()
    if Me:isCameraMode() then
      return
    end
    if self.targetID then
      Me:sendPacket({
        pid = "SwitchTelevisionChannels",
        targetID = self.targetID,
        add = true
      })
    end
  end)
  self:subscribe(self.btnTvBtnL, UIEvent.EventButtonClick, function()
    if Me:isCameraMode() then
      return
    end
    if self.targetID then
      Me:sendPacket({
        pid = "SwitchTelevisionChannels",
        targetID = self.targetID
      })
    end
  end)
end

function WidgetPartInteractionPop:updatePopData(targetID, isTv)
  self.targetID = targetID
  local part = Instance.getByInstanceId(targetID)
  if not part then
    return
  end
  local pos
  if part.className == "Decal" then
    local parent = part:getParent()
    if not parent or not parent.getPosition then
      return
    end
    pos = parent:getPosition()
  else
    pos = part:getPosition()
    self:updateIconImage(part)
  end
  self.targetPos = pos
  self.lytTvBtnList:SetVisible(isTv)
  self.btnBtn:SetVisible(not isTv)
end

function WidgetPartInteractionPop:updateIconImage(part)
  local partName = part.name
  local prop = InteractEventConfig:getCfgById(partName)
  self.imgIcon:SetImage(prop.interactPopIcon)
end

function WidgetPartInteractionPop:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPartInteractionPop
