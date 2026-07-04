local handles = T(Player, "PackageHandlers")

function handles:popAnnouncementUI(packet)
  if packet.objID ~= Me.objID then
    return
  end
  self:openAnnouncementWnd()
end
