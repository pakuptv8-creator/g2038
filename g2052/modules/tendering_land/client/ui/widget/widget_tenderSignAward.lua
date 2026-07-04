local widget_base = require("ui.widget.widget_base")
local WidgetTenderSignAward = Lib.derive(widget_base)

function WidgetTenderSignAward:init()
  widget_base.init(self, "TenderSignAward.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetTenderSignAward:initUI()
  self.imgAwardBg = self:child("TenderSignAward-AwardBg")
  self.imgAwardIcon = self:child("TenderSignAward-AwardIcon")
  self.lytImageBg = self:child("TenderSignAward-ImageBg")
  self.txtAwardName = self:child("TenderSignAward-AwardName")
end

function WidgetTenderSignAward:initEvent()
  self:subscribe(self.lytImageBg, UIEvent.EventWindowClick, function()
    if self.data.gainType == 2 then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.tendering.award.success")
    elseif self.data.itemInfo[1] == "pet" and self.data.itemInfo[2] then
      local petId = tonumber(self.data.itemInfo[2])
      local takeInLandPet = Me:getTakeInLandPet()
      if takeInLandPet[petId] then
        Me:openGuideUI("partner", petId)
        UI:getWnd("tenderSignWnd"):onShow(false)
      else
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.tendering.award.take")
      end
    elseif self.data.itemInfo[1] == "cloth" and self.data.itemInfo[2] then
      local clothId = tonumber(self.data.itemInfo[2])
      local takeInLandCloth = Me:getTakeInLandCloth()
      if takeInLandCloth[clothId] then
        Me:openGuideUI("role", 1, 1, clothId)
        UI:getWnd("tenderSignWnd"):onShow(false)
      else
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.tendering.award.take")
      end
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.tendering.award.take")
    end
  end)
end

function WidgetTenderSignAward:onDataChanged(data)
  self.data = data
  self.imgAwardIcon:SetImage(data.icon or "")
  if data.text and data.text ~= "" then
    self.txtAwardName:SetText(Lang:toText(data.text))
  else
    self.txtAwardName:SetText("")
  end
end

function WidgetTenderSignAward:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetTenderSignAward
