function Player:onClickBiddingNoticeBoard(type, target, params)
  if self.lastClickNoticeBoardTime and os.time() - self.lastClickNoticeBoardTime < 2 then
    return
  end
  local parent = target:getParent()
  local biddingBlock = parent.biddingBlock
  if biddingBlock then
    local info = Plugins.CallTargetPluginFunc("tendering_land", "getBlockInfo", biddingBlock.id)
    local screenShot = info.cfg.screenShot
    self:sendPacket({
      pid = "syncBiddingOpenEditor",
      blockId = biddingBlock.id,
      screenShot = screenShot
    })
  end
  self.lastClickNoticeBoardTime = os.time()
end

function Player:onClickBiddingNoticeRank(type, target, params)
  if self.lastClickNoticeBoardTime and os.time() - self.lastClickNoticeBoardTime < 2 then
    return
  end
  local parent = target:getParent()
  local biddingBlock = parent.biddingBlock
  if biddingBlock then
    biddingBlock.status:click(self)
  end
  self.lastClickNoticeBoardTime = os.time()
end
