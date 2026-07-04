function Player:onBiddingInteract(type, target, params)
  if not target and not target:isValid() then
    return
  end
  local id = target:getInstanceID()
  local parent = target:getParent()
  if parent and parent:isValid() then
    id = parent:getInstanceID()
  end
end
