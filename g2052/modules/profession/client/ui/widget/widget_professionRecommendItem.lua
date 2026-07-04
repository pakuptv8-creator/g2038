local widget_base = require("ui.widget.widget_base")
local WidgetProfessionRecommendItem = Lib.derive(widget_base)
local SUB_ITEM_LIST = {
  [Define.ProfessionRecommendType.Cloth] = "dressItem",
  [Define.ProfessionRecommendType.Prop] = "bagItem",
  [Define.ProfessionRecommendType.Vehicle] = "carItem",
  [Define.ProfessionRecommendType.Pet] = "partnerCell"
}

function WidgetProfessionRecommendItem:init()
  widget_base.init(self, "ProfessionRecommendItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetProfessionRecommendItem:initUI()
  self.imgSelectBG = self:child("ProfessionRecommendItem-SelectBG")
  self.lytPanel = self:child("ProfessionRecommendItem-Panel")
  self.rectSize = self._root:GetWidth()[2]
end

function WidgetProfessionRecommendItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
  end)
end

function WidgetProfessionRecommendItem:onDataChanged(data)
  self.data = data
  self.fun = data.clickCb
  self.inf = data.data
  self:resetSubItem()
end

function WidgetProfessionRecommendItem:resetSubItem()
  if self.subItem and (self.recommendType ~= self.inf.recommendType or self.recommendId ~= self.inf.recommendId) then
    self.lytPanel:RemoveChildWindow1(self.subItem)
    self.subItem = nil
  end
  local subItemName = SUB_ITEM_LIST[self.inf.recommendType]
  if not subItemName then
    return
  end
  if not self.subItem then
    self.subItem = UIMgr:new_widget(subItemName)
    self.recommendType = self.inf.recommendType
    self.recommendId = self.inf.recommendId
    if self.inf.recommendType == Define.ProfessionRecommendType.Cloth then
      self.subItem:invoke("setIsProfessionRecommend", true)
    end
  end
  if not self.subItem then
    return
  end
  self.subItem:SetWidth({
    0,
    self.rectSize
  })
  self.subItem:SetHeight({
    0,
    self.rectSize
  })
  self.lytPanel:AddChildWindow(self.subItem)
  self.subItem:invoke("onDataChanged", self.data)
  self.subItem:invoke("hideNormalImage")
end

function WidgetProfessionRecommendItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetProfessionRecommendItem
