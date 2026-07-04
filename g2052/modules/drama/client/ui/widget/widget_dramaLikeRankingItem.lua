local widget_base = require("ui.widget.widget_base")
local WidgetDramaLikeRankingItem = Lib.derive(widget_base)
WidgetDramaLikeRankingItem.MedalImageSet = {
  "set:g2052_teaming.json image:img_0_ranking01",
  "set:g2052_teaming.json image:img_0_ranking02",
  "set:g2052_teaming.json image:img_0_ranking03"
}

function WidgetDramaLikeRankingItem:init()
  widget_base.init(self, "DramaLikeRankingItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaLikeRankingItem:initUI()
  self.imgMedal = self:child("DramaLikeRankingItem-Medal")
  self.txtLevel = self:child("DramaLikeRankingItem-Level")
  self.imgHeadImg = self:child("DramaLikeRankingItem-HeadImg")
  self.txtPlayerName = self:child("DramaLikeRankingItem-PlayerName")
  self.txtLikeNum = self:child("DramaLikeRankingItem-LikeNum")
  self.btnAddFriendBtn = self:child("DramaLikeRankingItem-AddFriendBtn")
  self.imgBGImage = self:child("DramaLikeRankingItem-BGImage")
end

function WidgetDramaLikeRankingItem:initEvent()
  self:subscribe(self.btnAddFriendBtn, UIEvent.EventButtonClick, function()
    AsyncProcess.FriendOperation(FriendManager.operationType.ADD_FRIEND, self.data.userId)
    self.btnAddFriendBtn:SetVisible(false)
  end)
end

function WidgetDramaLikeRankingItem:onDataChanged(data)
  self.data = data
  self.txtPlayerName:SetText(data.nickName)
  self.txtLikeNum:SetText(Lib.toNewThousandthString(data.score))
  self.txtLevel:SetText(data.rank)
  if data.picUrl and #data.picUrl > 0 then
    self.imgHeadImg:SetImageUrl(data.picUrl)
  else
    self.imgHeadImg:SetImage(World.cfg.defaultAvatar)
  end
  if data.rank >= 1 and data.rank <= 3 then
    self.imgMedal:SetVisible(true)
    self.imgMedal:SetImage(WidgetDramaLikeRankingItem.MedalImageSet[data.rank])
  else
    self.imgMedal:SetVisible(false)
  end
  local hideButton = Me:checkUserIDIsFriend(data.userId) or data.userId == Me.platformUserId
  self.btnAddFriendBtn:SetVisible(not hideButton)
end

function WidgetDramaLikeRankingItem:setSelfMode()
  self.imgBGImage:SetVisible(false)
  self.btnAddFriendBtn:SetVisible(false)
end

function WidgetDramaLikeRankingItem:selfDataChanged(data)
  if data then
    self.txtLikeNum:SetText(Lib.toNewThousandthString(data.score))
    self.txtLevel:SetText(data.rank)
    self.txtPlayerName:SetText(data.nickName)
    if data.picUrl and #data.picUrl > 0 then
      self.imgHeadImg:SetImageUrl(data.picUrl)
    else
      self.imgHeadImg:SetImage(World.cfg.defaultAvatar)
    end
  end
end

function WidgetDramaLikeRankingItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaLikeRankingItem
