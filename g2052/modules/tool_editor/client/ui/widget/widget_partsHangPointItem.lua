local widget_base = require("ui.widget.widget_base")
local WidgetPartsHangPointItem = Lib.derive(widget_base)

function WidgetPartsHangPointItem:init(callBack, showPanelCb)
  widget_base.init(self, "partsHangPointItem.json")
  self._allEvent = {}
  self.showPanel = false
  self.callBack = callBack
  self.showPanelCb = showPanelCb
  self.index = 0
  self.params = {}
  self:initUI()
  self:initEvent()
end

function WidgetPartsHangPointItem:initUI()
  self.lytPartsHangPointItemSp = self:child("partsHangPointItem-sp")
  self.txtPartsHangPointItemSpDec = self:child("partsHangPointItem-spDec")
  self.editPartsHangPointItemSpInput = self:child("partsHangPointItem-spInput")
  self.btnPartsHangPointItemSpHangPointBtn = self:child("partsHangPointItem-spHangPointBtn")
  self.lytPartsHangPointItemSpHangPointPanel = self:child("partsHangPointItem-spHangPointPanel")
  self.hangPointItemListGridView = UIMgr:new_widget("grid_view")
  self.hangPointItemListGridView:InitConfig(0, 3, 1)
  self.hangPointItemListGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPartsHangPointItemSpHangPointPanel:AddChildWindow(self.hangPointItemListGridView)
  self.lytPartsHangPointItemSpHangPointPanel:SetVisible(false)
end

function WidgetPartsHangPointItem:initEvent()
  self:subscribe(self.btnPartsHangPointItemSpHangPointBtn, UIEvent.EventButtonClick, function()
    local param = self.editPartsHangPointItemSpInput:GetPropertyString("Text", "")
    if not param or param == "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "\232\175\183\229\133\136\232\190\147\229\133\165sp\229\128\188\229\134\141\232\191\155\232\161\140\229\190\174\232\176\131")
      return
    end
    if self.showPanel then
      self:showHangPointPanel(false)
    else
      self:showHangPointPanel(true)
      if self.showPanelCb then
        self.showPanelCb(self.index)
      end
    end
  end)
  self:subscribe(self.editPartsHangPointItemSpInput, UIEvent.EventEditTextInput, function()
    local param = self.editPartsHangPointItemSpInput:GetPropertyString("Text", "")
    self:setParam(param)
  end)
end

function WidgetPartsHangPointItem:showHangPointPanel(show)
  self.showPanel = show
  self.lytPartsHangPointItemSpHangPointPanel:SetVisible(show)
  if not show then
    return
  end
  local param = self.editPartsHangPointItemSpInput:GetPropertyString("Text", "")
  if not param or param == "" then
    return
  end
  local tbParam = Lib.splitString(param, "#")
  self.hangPointItemListGridView:RemoveAllItems()
  for i = 1, #tbParam do
    self.params[i] = tbParam[i]
    local item = UIMgr:new_widget("hangUpPointSpItem", function(index, param)
      self.params[index] = param
      local value = ""
      for i, v in pairs(self.params) do
        if value == "" then
          value = v
        else
          value = value .. "#" .. v
        end
      end
      self:setParam(value)
    end)
    if item then
      item:SetArea({0, 0}, {0, 0}, {0, 214}, {0, 32})
      self.hangPointItemListGridView:AddItem(item)
      item:invoke("setData", i, tbParam[i])
    else
      Lib.logDebug("Error\239\188\154item is nil when  UIMgr:new_widget(hangUpPointSpItem)")
    end
  end
end

function WidgetPartsHangPointItem:setParam(param)
  self.editPartsHangPointItemSpInput:SetProperty("Text", tostring(param))
  if self.callBack then
    self.callBack(self.index, param)
  end
end

function WidgetPartsHangPointItem:setData(index, params)
  self:clearData()
  self.index = index
  self.txtPartsHangPointItemSpDec:SetText("sp" .. index)
  self.editPartsHangPointItemSpInput:SetProperty("Text", params)
end

function WidgetPartsHangPointItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetPartsHangPointItem:clearData()
  self.index = 0
  self.params = {}
  self.editPartsHangPointItemSpInput:SetProperty("Text", "")
end

return WidgetPartsHangPointItem
