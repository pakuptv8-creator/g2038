local widget_base = require("ui.widget.widget_base")
local WidgetBiddingFourItem = Lib.derive(widget_base)
local BiddingRankManager = T(Lib, "BiddingRankManager")
local UP_IMG = "set:g2052_buttons.json image:btn_9_general05"
local UN_UP_IMG = "set:g2052_buttons.json image:btn_9_general06"

function WidgetBiddingFourItem:init()
  widget_base.init(self, "BiddingFourItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBiddingFourItem:initUI()
  self.imgBg = self:child("BiddingFourItem-Bg")
  self.imgBuildImg = self:child("BiddingFourItem-BuildImg")
  self.txtCreateName = self:child("BiddingFourItem-CreateName")
  self.btnUpBtn = self:child("BiddingFourItem-UpBtn")
  self.imgUpImg = self:child("BiddingFourItem-UpImg")
  self.txtUpNum = self:child("BiddingFourItem-UpNum")
end

function WidgetBiddingFourItem:initEvent()
  self:subscribe(self.btnUpBtn, UIEvent.EventButtonClick, function()
    local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", self.blockId)
    if blockStatus == Define.BIDDING_STATUS.ELECTION or blockStatus == Define.BIDDING_STATUS.FINALS then
      BiddingRankManager:upPlayerBuild(self.blockId, self.data.mapId, nil, "recommend")
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.bidding_rank.select_status_click_like_tips"))
    end
  end)
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    local playerName = self.data.nickName or Me.name
    Me:biddingRankToPreview(playerName, self.blockId, self.data.mapId)
  end)
end

function WidgetBiddingFourItem:onDataChanged(data)
  self.data = data
  self.blockId = data.blockId
  local playerId = data.userId
  local img = data.picUrl
  local upNum = data.likeNumber
  local isUp = data.userLikeType == 1
  self.imgBuildImg:SetImageUrl(img)
  self.txtUpNum:SetText(upNum)
  local playerName = data.nickName or BiddingRankManager:getPlayerName(playerId)
  if data.curTabType == Define.BiddingRankTab.Mine then
    self.btnUpBtn:SetTouchable(false)
    playerName = data.nickName or Me.name
  else
    self.btnUpBtn:SetTouchable(true)
  end
  self.txtCreateName:SetText(playerName)
  self:updateUpBtn(isUp)
end

function WidgetBiddingFourItem:updateUpBtn(isUp)
  self.btnUpBtn:SetNormalImage(isUp and UP_IMG or UN_UP_IMG)
  self.btnUpBtn:SetPushedImage(isUp and UP_IMG or UN_UP_IMG)
end

function WidgetBiddingFourItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetBiddingFourItem
