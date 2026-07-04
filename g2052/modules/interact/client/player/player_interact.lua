Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
  if info.objID ~= Me.objID then
    return
  end
  Blockman.instance:setPersonView(Define.PersonView.THIRD)
end)

function Player:updateInstanceInteractionUI(data)
  local objID, show, reset = data.objID, data.show, data.reset
  local recheck = data.recheck
  local object = self.world:getObject(objID)
  if show and not object then
    print("can not find object! ", objID)
    return
  end
  local canShow = self:canShowObjectInteractionUI(objID)
  if recheck then
    local ranges = self:data("inInteractionRanges")
    Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_SWITCH, objID, canShow and ranges[objID])
    return
  end
  if reset then
    local defaultCfg = canShow and object:cfg().interactionUI
    assert(not canShow or defaultCfg, " has no interaction cfg!")
    Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_SET, objID, show and canShow, defaultCfg)
  end
  if not reset then
    local cfg
    if data.cfgKey then
      cfg = object:cfg()[data.cfgKey]
    end
    if cfg then
      Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_SET, objID, false, cfg)
    end
    Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_SWITCH, objID, show and canShow)
  end
end

function Player:showPartInteractionTip(partID)
end
