local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "CameraNode.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.btnCameraNodeNode = self:child("CameraNode-Node")
  self.btnDelNode = self:child("CameraNode-Del")
  self.imgCameraNodeArray = self:child("CameraNode-Array")
end

function M:initEvent()
  self:subscribe(self.btnCameraNodeNode, UIEvent.EventButtonClick, function()
    if self.isAddBtn then
      Lib.emitEvent("EVENT_NODE_ADD")
    else
      Lib.emitEvent("EVENT_NODE_SEL", self.idx)
    end
  end)
  self:subscribe(self.btnDelNode, UIEvent.EventButtonClick, function()
    Lib.emitEvent("EVENT_NODE_DEL", self.idx)
  end)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

function M:selectNode(isSelect)
  self.btnCameraNodeNode:SetBackgroundColor(isSelect and {
    0,
    0.5,
    0.7,
    1
  } or {
    0,
    0.5,
    0,
    1
  })
end

function M:initAddBtn()
  self.imgCameraNodeArray:SetVisible(false)
  self.btnCameraNodeNode:SetBackgroundColor({
    1,
    0,
    0,
    1
  })
  self.btnCameraNodeNode:SetText("+")
  self.isAddBtn = true
end

function M:initNormalNode(idx)
  self.idx = idx
  self.btnCameraNodeNode:SetText("" .. self.idx)
  self.imgCameraNodeArray:SetVisible(false)
  self:selectNode(true)
  Lib.emitEvent("EVENT_NODE_SEL", self.idx)
end

function M:setTailShow(isShow)
  self.imgCameraNodeArray:SetVisible(isShow)
end

return M
