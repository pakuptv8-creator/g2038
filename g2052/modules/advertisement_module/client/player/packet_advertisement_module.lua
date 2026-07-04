local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local handles = T(Player, "PackageHandlers")

function handles:S2COnAdvertisementDraw(packet)
  if packet.objID ~= Me.objID then
    return
  end
  local reward_ids = packet.reward_ids
  local state_code = packet.state_code
  AdvertisementModuleHelper:onDrawReward(state_code, reward_ids)
end

function handles:S2COnAdvertisementLockSlot(packet)
  if packet.objID ~= Me.objID then
    return
  end
  local state_code = packet.state_code
  local lock_slot = packet.lock_slot
  local lock_id = packet.lock_id
  AdvertisementModuleHelper:onLockSlot(state_code, lock_slot, lock_id)
end

function handles:S2COnAdvertisementSceneClick(packet)
  if packet.objID ~= Me.objID then
    return
  end
  local part_id = packet.part_id
  local state_code = packet.state_code
  AdvertisementModuleHelper:onSceneAdvertisemenetClick(state_code, part_id)
end
