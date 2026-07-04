local handles = T(Player, "PackageHandlers")

function handles:SendMessageNoticeS2C(packet)
  Lib.emitEvent(Event.EVENT_SHOW_MESSAGE_NOTICE, packet.messageNotice)
end
