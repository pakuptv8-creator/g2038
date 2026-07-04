local widget_base = require("ui.widget.widget_base")
local WidgetBiddingRankInfo = Lib.derive(widget_base)
local BiddingRankManager = T(Lib, "BiddingRankManager")
local UP_IMG = "set:g2052_buttons.json image:btn_9_general05"
local UN_UP_IMG = "set:g2052_buttons.json image:btn_9_general06"

function WidgetBiddingRankInfo:init()
  widget_base.init(self, "BiddingRankInfo.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBiddingRankInfo:initUI()
  self.imgBg = self:child("BiddingRankInfo-Bg")
  self.txtRankNum = self:child("BiddingRankInfo-RankNum")
  self.imgBuildImg = self:child("BiddingRankInfo-BuildImg")
  self.txtCreaterName = self:child("BiddingRankInfo-CreaterName")
  self.btnUpBtn = self:child("BiddingRankInfo-UpBtn")
  self.imgUpImg = self:child("BiddingRankInfo-UpImg")
  self.txtUpNum = self:child("BiddingRankInfo-UpNum")
end

function WidgetBiddingRankInfo:initEvent()
  self:subscribe(self.btnUpBtn, UIEvent.EventButtonClick, function()
    local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", self.blockId)
    if blockStatus == Define.BIDDING_STATUS.ELECTION or blockStatus == Define.BIDDING_STATUS.FINALS then
      BiddingRankManager:upPlayerBuild(self.blockId, self.data.mapId, self.pageNum, "rank")
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.bidding_rank.select_status_click_like_tips"))
    end
  end)
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    local playerName = BiddingRankManager:getPlayerName(self.data.userId) or self.data.userId
    Me:biddingRankToPreview(playerName, self.blockId, self.data.mapId)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_LOADED_PLAYER_NAME, function(userId, name)
    if self.data and self.data.userId == userId then
      self.txtCreaterName:SetText(name)
    end
  end)
end

function WidgetBiddingRankInfo:updateData(blockId, pageNum, data)
  if not data then
    return
  end
  self.blockId = blockId
  self.pageNum = pageNum
  self.data = data
  local playerId = data.userId
  local playerName = data.nickName or BiddingRankManager:getPlayerName(playerId)
  local img = data.picUrl
  local upNum = data.likeNumber
  local isUp = data.userLikeType == 1
  Lib.logDebug("img === ", img)
  self.txtRankNum:SetText(data.rank)
  self.txtCreaterName:SetText(playerName)
  self.imgBuildImg:SetImageUrl(img)
  self.txtUpNum:SetText(upNum)
  self:updateUpBtn(isUp)
end

function WidgetBiddingRankInfo:updateUpBtn(isUp)
  self.btnUpBtn:SetNormalImage(isUp and UP_IMG or UN_UP_IMG)
  self.btnUpBtn:SetPushedImage(isUp and UP_IMG or UN_UP_IMG)
end

function WidgetBiddingRankInfo:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetBiddingRankInfo
