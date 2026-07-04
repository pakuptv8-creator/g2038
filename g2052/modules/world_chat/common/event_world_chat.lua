if World.isClient then
  Event.EVENT_WORLD_CHAT_SEND_EMOJI = Event.register("EVENT_WORLD_CHAT_SEND_EMOJI")
  Event.EVENT_WORLD_CHAT_LANG_SELECT = Event.register("EVENT_WORLD_CHAT_LANG_SELECT")
else
end
