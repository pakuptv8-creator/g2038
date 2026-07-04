local Player = _ENV.Player

function Player:openAnnouncementWnd()
  local typ = World.cfg.announcementSetting.type
  if typ == "urlImage" then
    UI:openWnd("announcement")
  elseif typ == "joint" then
    UI:openWnd("announcementJoint")
  elseif typ == "second" then
    UI:openWnd("announcementSecond")
  elseif typ == "slide" then
    UI:openWnd("announcementSlide")
  end
end

function Player:openAnnouncementUI(type, part, params)
  if part and part:isValid() then
    self:openAnnouncementWnd()
  end
end
