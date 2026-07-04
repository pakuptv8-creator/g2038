local widget_base = require("ui.widget.widget_base")
local WidgetModMapItem = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

function WidgetModMapItem:init()
  widget_base.init(self, "ModMapItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModMapItem:initUI()
  self.imgBg1 = self:child("ModMapItem-bg1")
  self.imgIcon = self:child("ModMapItem-icon")
  self.imgPlayerBg = self:child("ModMapItem-PlayerBg")
  self.txtPlayerName = self:child("ModMapItem-PlayerName")
  self.imgMapBg = self:child("ModMapItem-MapBg")
  self.txtMapName = self:child("ModMapItem-MapName")
  self.imgPraisePanel = self:child("ModMapItem-PraisePanel")
  self.txtPraiseNum = self:child("ModMapItem-PraiseNum")
  self.imgPraiseIcon = self:child("ModMapItem-PraiseIcon")
end

function WidgetModMapItem:initEvent()
  self:subscribe(self.imgBg1, UIEvent.EventWindowClick, function()
    local from = "any"
    if self.data and self.data.attachInfo then
      from = self.data.attachInfo.from
    end
    ModAsyncProxy:requestOpenModDetailsUI(self.data.gameId, self.data.parentGameId, from)
  end)
end

function WidgetModMapItem:onDataChanged(data)
  if data.data ~= nil then
    data = data.data
  end
  self:updateMapGameInfo(data)
end

function WidgetModMapItem:updateMapGameInfo(data)
  self.data = data
  self.txtMapName:SetText(Lib.standardizeModTitle(data.gameTitle))
  local likeNum = data.likeNumber or 0
  self.txtPraiseNum:SetText(Lib.simplifyNumber2Str(likeNum))
  self.txtPlayerName:SetText(Lib.standardizeModTitle(data.gameId))
  if data.authorInfo and data.authorInfo.nickName then
    self.txtPlayerName:SetText(Lib.standardizeModTitle(data.authorInfo.nickName))
  end
  Lib.setModMapItemDefaultImage(self.imgIcon)
  if data.gameCoverPic and 0 < #data.gameCoverPic then
    self.imgIcon:SetImageUrl(data.gameCoverPic)
  end
end

function WidgetModMapItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModMapItem
