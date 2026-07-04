local widget_base = require("ui.widget.widget_base")
local WidgetModMyMapItem = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

function WidgetModMyMapItem:init()
  widget_base.init(self, "ModAuthorMapItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModMyMapItem:initUI()
  self.lytOverView = self:child("ModAuthorMapItem-OverView")
  self.imgOverViewImage = self:child("ModAuthorMapItem-OverView-Image")
  self.lytLike = self:child("ModAuthorMapItem-Like")
  self.imgLikeBg = self:child("ModAuthorMapItem-Like-Bg")
  self.imgLikeIcon = self:child("ModAuthorMapItem-Like-Icon")
  self.txtLikeNum = self:child("ModAuthorMapItem-Like-Num")
  self.lytName = self:child("ModAuthorMapItem-Name")
  self.imgNameBg = self:child("ModAuthorMapItem-Name-Bg")
  self.txtNameText = self:child("ModAuthorMapItem-Name-Text")
end

function WidgetModMyMapItem:initEvent()
  self.imgOverViewImage:subscribe(UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    else
      local from = "any"
      if self.data and self.data.attachInfo then
        from = self.data.attachInfo.from
      end
      ModAsyncProxy:requestOpenModDetailsUI(self.data.gameId, self.data.parentGameId, from)
    end
  end)
end

function WidgetModMyMapItem:onDataChanged(data)
  local likeNum = data.likeNumber or 0
  local mapName = data.gameTitle or ""
  self.fun = data.cb
  self.data = data
  self.txtLikeNum:SetText(Lib.simplifyNumber2Str(likeNum))
  self.txtNameText:SetText(Lib.standardizeModTitle(mapName))
  Lib.setModMapItemDefaultImage(self.imgOverViewImage)
  if data.gameCoverPic and 0 < #data.gameCoverPic then
    self.imgOverViewImage:SetImageUrl(data.gameCoverPic)
  end
end

function WidgetModMyMapItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModMyMapItem
