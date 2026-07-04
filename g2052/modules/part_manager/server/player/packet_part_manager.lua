local LuaTimer = T(Lib, "LuaTimer")
local PropsAttrConfig = T(Config, "PropsAttrConfig")
local handles = T(Player, "PackageHandlers")

local function getTargetHouseOwner(target)
  local houseModel = target:findFirstAncestor("house")
  if houseModel then
    local instanceId = houseModel:getInstanceID()
    local locationList = HouseManager:getLocationList()
    for _, v in pairs(locationList) do
      if v.houseId == instanceId then
        return v.ownerId
      end
    end
  end
end

function handles:onFinishSlideLadderInteract(packet)
  if packet.playerId == self.objID then
    self:onFinishSlideLadderInteract(packet.pos)
  end
end

function handles:doStartSlideLadder(packet)
  if self.objID == packet.objID then
    self:doStartSlideLadder()
  end
end

function handles:doStartSlideLadder(packet)
  if self.objID == packet.objID then
    self:doStartSlideLadder()
  end
end

function handles:RequestChangePartContent(packet)
  SceneUIPartManager:doChangePartContent(packet, self)
end
