local PlaceState = {}

function PlaceState:enteredState()
  self:setSelection(false)
end

function PlaceState:exitedState()
end

return PlaceState
