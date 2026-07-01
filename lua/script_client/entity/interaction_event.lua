local LuaTimer = T(Lib, "LuaTimer")
local RangeObjRecord = {}
local interactionEventEngineHandler = interaction_event
local handles = {}

function interaction_event(name, ...)
  interactionEventEngineHandler(name, ...)
  local func = handles[name]
  if not func then
    return
  end
  func(Me, ...)
end

function handles:ButtonDisplay(objID, context)
end

function handles:ButtonSetClickAction(objID, context)
end

function handles:showInteractionUI(objID, context)
end

function handles:ShowSingleUI(objID, context)
end

function handles:onEnterEntityRange(objID, context)
end

function handles:onQuitEntityRange(objID, context)
end
