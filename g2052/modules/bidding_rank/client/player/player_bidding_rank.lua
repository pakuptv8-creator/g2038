local Player = _ENV.Player

function Player:biddingRankToPreview(playerName, blockId, mapId)
  UI:getWnd("commonDialog"):onShow(true, {
    title = Lang:toText("g2052.gui.bidding_rank.preview_tip"),
    desc = Lang:formatMessageByIndex("g2052.gui.bidding_rank.preview", playerName),
    confirmCallback = function()
      UI:closeWnd("car")
      Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, true, 40)
      Me:sendPacket({
        pid = "previewBiddingMap",
        blockId = blockId,
        mapId = mapId
      })
      UI:closeWnd("biddingRankList", true)
    end,
    cancelCallback = function()
    end
  })
end
