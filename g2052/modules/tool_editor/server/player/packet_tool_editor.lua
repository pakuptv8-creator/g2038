local InteractEventConfig = T(Config, "InteractEventConfig")
local RegionEffectsConfig = T(Config, "RegionEffectsConfig")
local handles = T(Player, "PackageHandlers")

function handles:rewriteInteractEventCfg(packet)
  InteractEventConfig:init()
end

function handles:rewriteRegionEffectsCfg(packet)
  RegionEffectsConfig:init()
end

function handles:tryInteract(packet)
  local from = World.CurWorld:getObject(packet.fromID)
  local part = Instance.getByInstanceId(packet.partId)
  if not from or not from:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  print("-----tryInteract", Lib.v2s(packet))
  if from[packet.func] then
    if packet.trigger[1] and from[packet.func] then
      from[packet.func](from, Define.PART_INTERACT_TYPE.CLICKED, part, packet.param)
    end
    if packet.trigger[2] and from[packet.func] then
      from[packet.func](from, Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, packet.param)
    end
    if packet.trigger[3] and from[packet.func] then
      from[packet.func](from, Define.PART_INTERACT_TYPE.TOUCH_END, part, packet.param)
    end
  end
end
