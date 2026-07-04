local WinBiddingPreview = M
local UP_IMG = "set:g2052_buttons.json image:btn_9_general05"
local UN_UP_IMG = "set:g2052_buttons.json image:btn_9_general06"
local BiddingRankManager = T(Lib, "BiddingRankManager")

function WinBiddingPreview:init()
  WinBase.init(self, "BiddingPreview.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinBiddingPreview:initUI()
  self.btnReturn = self:child("BiddingPreview-Return")
  self.btnLike = self:child("BiddingPreview-Like")
  self.imgLikeImg = self:child("BiddingPreview-LikeImg")
  self.txtLikeNum = self:child("BiddingPreview-LikeNum")
end

function WinBiddingPreview:initEvent()
  self:subscribe(self.btnReturn, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "leavePreviewModel"
    })
  end)
  self:subscribe(self.btnLike, UIEvent.EventButtonClick, function()
    local modelData = Me.modelData
    local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", modelData.blockId)
    if blockStatus == Define.BIDDING_STATUS.ELECTION or blockStatus == Define.BIDDING_STATUS.FINALS then
      BiddingRankManager:upPlayerBuild(modelData.blockId, modelData.mapId, nil, "preview")
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.bidding_rank.select_status_click_like_tips"))
    end
  end)
end

function WinBiddingPreview:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_RANK_INFO_LOADED, function(blockId, mapId, info)
    self:updateView(info)
  end)
end

function WinBiddingPreview:initView()
  local modelData = Me.modelData
  BiddingRankManager:getRankInfo(modelData.blockId, modelData.mapId)
end

function WinBiddingPreview:updateView(info)
  self:updateUpBtn(info.userLikeType == 1)
  self.txtLikeNum:SetText(info.likeNumber)
end

function WinBiddingPreview:updateUpBtn(isUp)
  self.btnLike:SetNormalImage(isUp and UP_IMG or UN_UP_IMG)
  self.btnLike:SetPushedImage(isUp and UP_IMG or UN_UP_IMG)
end

function WinBiddingPreview:onHide()
  UI:closeWnd("biddingPreview")
end

function WinBiddingPreview:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("biddingPreview")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinBiddingPreview:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinBiddingPreview:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinBiddingPreview
