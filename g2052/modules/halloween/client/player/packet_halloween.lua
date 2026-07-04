local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local handles = T(Player, "PackageHandlers")
local HalloweenUIHelper = T(Lib, "HalloweenUIHelper")
local HalloweenUIManager = T(Lib, "HalloweenUIManager")

function handles:setHalloweenDayS2C(packet)
  if packet then
    HalloweenHelperCommon:setHalloweenDay(packet.isOpen)
  end
end

function handles:SCShowShareCandySuccess(packet)
  UI:getWnd("candyShareSuccess"):onShow(true, packet.targetUserID)
  local text = Lang:toText({
    "g2052.gui.halloween.share.remain",
    packet.remainCounts or 0
  })
  Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
end

function handles:SCShowAcceptCandySuccess(packet)
  UI:getWnd("candyAcceptSuccess"):onShow(true, packet.fromUserID)
  if packet.remainCounts then
    local text = Lang:toText({
      "g2052.gui.halloween.accept.remain",
      packet.remainCounts or 0
    })
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
  end
end

function handles:SCShowAskForCandyWnd(packet)
  UI:getWnd("candyAskForWnd"):onShow(true, packet.fromUserID, packet.fromName)
end

function handles:SCHalloweenPartUIInfo(packet)
  HalloweenUIManager:updateHalloweenSceneUIInfo(packet.mapName, packet.partUIData, packet.serverTime, packet.resetTime)
end

function handles:SCRemoveAllHalloweenUI(packet)
  HalloweenUIManager:removeAllHalloweenUI()
end

function handles:SCShowCandyExchangeTips(packet)
  UI:getWnd("commonDialog"):onShow(true, {
    title = "g2052.gui.tendering.tips",
    desc = "g2052.gui.halloween.exchange.desc",
    confirmCallback = function()
      local packet = {
        pid = "CSConfirmCandyExchange",
        keyId = packet.keyId
      }
      Me:sendPacket(packet)
    end,
    cancelCallback = function()
    end
  })
end
