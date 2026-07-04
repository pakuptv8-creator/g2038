local FirstPersonState = {}

function FirstPersonState:enteredState()
  Lib.logDebug("FirstPersonState:enteredState")
end

function FirstPersonState:exitedState()
  Lib.logDebug("FirstPersonState:exitedState")
end

return FirstPersonState
