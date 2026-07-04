local ThirdPersonState = {}

function ThirdPersonState:enteredState()
  Lib.logDebug("ThirdPersonState:enteredState")
  Blockman.Instance().gameSettings:setLockSlideScreen(true)
end

function ThirdPersonState:exitedState()
  Lib.logDebug("ThirdPersonState:exitedState")
  Blockman.Instance().gameSettings:setLockSlideScreen(false)
end

return ThirdPersonState
