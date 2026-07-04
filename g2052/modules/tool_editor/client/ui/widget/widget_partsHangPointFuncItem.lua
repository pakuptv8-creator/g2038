local widget_base = require("ui.widget.widget_base")
local WidgetPartsHangPointFuncItem = Lib.derive(widget_base)

function WidgetPartsHangPointFuncItem:init(callBack)
  widget_base.init(self, "partsHangPointFuncItem.json")
  self.callBack = callBack
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPartsHangPointFuncItem:initUI()
  self.txtPartsHangPointFuncItemFuncName = self:child("partsHangPointFuncItem-funcName")
  self.imgPartsHangPointSelectImg = self:child("partsHangPointFuncItem-selectImg")
end

function WidgetPartsHangPointFuncItem:initEvent()
  self:lightSubscribe("error: WidgetNavigationDataListItem event : EventWindowClick", self:root(), UIEvent.EventWindowClick, function()
    self:setSelectState(true)
    if self.callBack then
      self.callBack(self.func)
    end
  end)
end

function WidgetPartsHangPointFuncItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetPartsHangPointFuncItem:setSelectState(isSelect)
  self.imgPartsHangPointSelectImg:SetVisible(isSelect)
end

function WidgetPartsHangPointFuncItem:setData(func, dec, isSelect)
  self.func = func
  self.txtPartsHangPointFuncItemFuncName:SetText(func .. ":" .. dec)
  self:setSelectState(isSelect)
end

return WidgetPartsHangPointFuncItem
