local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local Player = _ENV.Player

function Player:onSceneAdvertisemenetClick(type, part, params)
  local partId = part.___scene_part_id
  if not partId then
    Lib.logError("onSceneAdvertisemenetClick invalid partId, part:", tostring(part.name))
    return
  end
  AdvertisementModuleHelper:doOnSceneAdvertisemenetClick(partId)
end
