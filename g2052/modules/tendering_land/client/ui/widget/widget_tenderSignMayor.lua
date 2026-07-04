local widget_base = require("ui.widget.widget_base")
local WidgetTenderSignMayor = Lib.derive(widget_base)

function WidgetTenderSignMayor:init()
  widget_base.init(self, "TenderSignMayor.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetTenderSignMayor:initUI()
  self.imgHeadPanel = self:child("TenderSignMayor-HeadPanel")
  self.imgHeadIcon = self:child("TenderSignMayor-HeadIcon")
  self.imgHeadFrame = self:child("TenderSignMayor-HeadFrame")
  self.imgTopIcon = self:child("TenderSignMayor-TopIcon")
  self.txtPostName = self:child("TenderSignMayor-PostName")
  self.txtPlayerName = self:child("TenderSignMayor-PlayerName")
  self.txtPostName:SetText(Lang:toText(World.cfg.tenderAwardSetting.mayorTxt))
  self.txtPostName:SetTextColor(Lib.getTextColor(World.cfg.tenderAwardSetting.mayorColor))
  self.txtPlayerName:SetText(Lang:toText("g2052.gui.tendering.sign.none_post"))
end

function WidgetTenderSignMayor:initEvent()
end

function WidgetTenderSignMayor:updatePostInfo(data)
  if data.normalMayor then
    for userId, val in pairs(data.normalMayor) do
      self.txtPlayerName:SetText(val.nickName or "")
    end
    self.txtPostName:SetTextColor(Lib.getTextColor(World.cfg.tenderAwardSetting.mayorColor))
    self.txtPostName:SetText(Lang:toText(World.cfg.tenderAwardSetting.mayorTxt))
    if data.bigMayorList[data.normalMayor.userId] then
      self.txtPostName:SetTextColor(Lib.getTextColor(World.cfg.tenderAwardSetting.bigMayorColor))
      self.txtPostName:SetText(Lang:toText(World.cfg.tenderAwardSetting.bigMayorTxt))
    end
  else
    self.txtPostName:SetText(Lang:toText(World.cfg.tenderAwardSetting.mayorTxt))
    self.txtPostName:SetTextColor(Lib.getTextColor(World.cfg.tenderAwardSetting.mayorColor))
    self.txtPlayerName:SetText(Lang:toText("g2052.gui.tendering.sign.none_post"))
  end
end

function WidgetTenderSignMayor:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetTenderSignMayor
