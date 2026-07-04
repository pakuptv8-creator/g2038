local widget_base = require("ui.widget.widget_base")
local WidgetPlayerInteractItem = Lib.derive(widget_base)

function WidgetPlayerInteractItem:init()
  widget_base.init(self, "PlayerInteractItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPlayerInteractItem:initUI()
  self.imgActionIcon = self:child("PlayerInteractItem-ActionIcon")
  self.txtActionName = self:child("PlayerInteractItem-ActionName")
end

function WidgetPlayerInteractItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    Me:sendPacket({
      pid = "RequestPlayerInteractive",
      targetID = self.targetID,
      interactiveID = self.data.id
    })
    UI:getWnd("playerInteractPop"):onShow(false)
    local defaultData = {
      double_interact_id = self.data.id
    }
    Plugins.CallTargetPluginFunc("report", "report", "doubleAction_send", defaultData, Me)
  end)
end

function WidgetPlayerInteractItem:onDataChanged(data)
  self.data = data
  self.imgActionIcon:SetImage(data.normalIcon)
  self.txtActionName:SetText(Lang:toText(data.actionName))
end

function WidgetPlayerInteractItem:updateTargetInfo(targetID)
  self.targetID = targetID
end

function WidgetPlayerInteractItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPlayerInteractItem
