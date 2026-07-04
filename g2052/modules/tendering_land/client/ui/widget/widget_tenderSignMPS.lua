local widget_base = require("ui.widget.widget_base")
local WidgetTenderSignMPS = Lib.derive(widget_base)

function WidgetTenderSignMPS:init()
  widget_base.init(self, "TenderSignMPS.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetTenderSignMPS:initUI()
  self.imgHeadPanel1 = self:child("TenderSignMPS-HeadPanel1")
  self.imgHeadIcon1 = self:child("TenderSignMPS-HeadIcon1")
  self.imgHeadFrame1 = self:child("TenderSignMPS-HeadFrame1")
  self.imgTopIcon1 = self:child("TenderSignMPS-TopIcon1")
  self.txtPostName1 = self:child("TenderSignMPS-PostName1")
  self.txtPlayerName1 = self:child("TenderSignMPS-PlayerName1")
  self.imgHeadPanel2 = self:child("TenderSignMPS-HeadPanel2")
  self.imgHeadIcon2 = self:child("TenderSignMPS-HeadIcon2")
  self.imgHeadFrame2 = self:child("TenderSignMPS-HeadFrame2")
  self.imgTopIcon2 = self:child("TenderSignMPS-TopIcon2")
  self.txtPostName2 = self:child("TenderSignMPS-PostName2")
  self.txtPlayerName2 = self:child("TenderSignMPS-PlayerName2")
  self.txtPostName1:SetText(Lang:toText(World.cfg.tenderAwardSetting.MPSTxt))
  self.txtPostName1:SetTextColor(Lib.getTextColor(World.cfg.tenderAwardSetting.MPSColor))
  self.txtPostName2:SetText(Lang:toText(World.cfg.tenderAwardSetting.MPSTxt))
  self.txtPostName2:SetTextColor(Lib.getTextColor(World.cfg.tenderAwardSetting.MPSColor))
  self.txtPlayerName1:SetText(Lang:toText("g2052.gui.tendering.sign.none_post"))
  self.txtPlayerName2:SetText(Lang:toText("g2052.gui.tendering.sign.none_post"))
  self.imgHeadPanel1:SetVisible(true)
  self.imgHeadPanel2:SetVisible(true)
end

function WidgetTenderSignMPS:initEvent()
end

function WidgetTenderSignMPS:updateSecondShow(vis)
  self.imgHeadPanel2:SetVisible(vis)
end

function WidgetTenderSignMPS:updatePostInfo(data1, data2)
  if data1 then
    self.txtPlayerName1:SetText(data1.nickName or "")
  else
    self.txtPlayerName1:SetText(Lang:toText("g2052.gui.tendering.sign.none_post"))
  end
  if data2 then
    self.txtPlayerName2:SetText(data2.nickName or "")
  else
    self.txtPlayerName2:SetText(Lang:toText("g2052.gui.tendering.sign.none_post"))
  end
end

function WidgetTenderSignMPS:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetTenderSignMPS
