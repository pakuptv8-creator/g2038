local engine_new_wnd = UIMgr.new_wnd

function UIMgr:new_wnd(name, ...)
  local wnd = engine_new_wnd(self, name, ...)
  return wnd
end

local old_ui_event = ui_event

function ui_event(event, sender, ...)
  old_ui_event(event, sender, ...)
  if event == UIEvent.EventWindowTouchDown or event == UIEvent.EventWindowClick or event == UIEvent.EventButtonClick or event == UIEvent.EventScrollCardClick then
    Lib.emitEvent(Event.EVENT_TOUCH_SCREEN, sender)
  end
end
