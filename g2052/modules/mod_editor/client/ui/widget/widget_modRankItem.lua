local widget_base = require("ui.widget.widget_base")
local WidgetModRankItem = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

function WidgetModRankItem:init()
  widget_base.init(self, "ModRankItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModRankItem:initUI()
  self.txtRankNum = self:child("ModRankItem-RankNum")
  self.imgHeadIcon = self:child("ModRankItem-MapIcon")
  self.txtNickName = self:child("ModRankItem-MapName")
  self.imgPraisePanel = self:child("ModRankItem-PraisePanel")
  self.imgPraiseIcon = self:child("ModRankItem-PraiseIcon")
  self.txtPraiseNum = self:child("ModRankItem-PraiseNum")
  self.txtLine = self:child("ModRankItem-line")
end

function WidgetModRankItem:initEvent()
  self:subscribe(self.imgHeadIcon, UIEvent.EventWindowClick, function()
    ModAsyncProxy:requestOpenAuthorInfoUI(self.data.userId, self.data.teamId)
  end)
end

function WidgetModRankItem:onDataChanged(data)
  self.data = data
  self.txtNickName:SetText(data.nickName or "")
  local likeNum = data.likeNumber or 0
  self.txtPraiseNum:SetText(Lib.simplifyNumber2Str(likeNum))
  self.txtRankNum:SetText(data.rank or "")
  if data.headPic and 0 < #data.headPic then
    self.imgHeadIcon:SetImageUrl(data.headPic)
  else
    self.imgHeadIcon:SetImageUrl("")
  end
end

function WidgetModRankItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModRankItem
