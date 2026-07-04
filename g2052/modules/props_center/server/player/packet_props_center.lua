local handles = T(Player, "PackageHandlers")
local PropsConfig = T(Config, "PropsConfig")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local setting = require("common.setting")
local PartCfg = setting:mod("part")

function handles:SwitchHandItem(packet)
  self:useHandItem(packet)
end

function handles:SwitchHandItemStyle(packet)
  self:handItemStyleSwitch(packet)
end

function handles:RemoveAllHandItem(packet)
  self:removeAllHandItem()
end

function handles:RemoveHandItem(packet)
  self:removeHandItem(packet)
end

function handles:CancelHandItem(packet)
  self:cancelHandItem(packet)
end

function handles:OnOperationBag(packet)
  self:onOperationBag(packet.params)
end

function handles:tryPlayBasketball(packet)
  local player = World.CurWorld:getEntity(packet.objID)
  if not player or not player:isValid() then
    return
  end
  local inUseItem = player:getInUseProp()
  if not inUseItem then
    return
  end
  local propCfg = PropsConfig:getCfgById(inUseItem.itemId)
  if not propCfg or propCfg.isThrowObj ~= Define.ThrowObjType.Basketball then
    return
  end
  WorldServer.BroadcastPacket({
    pid = "playBasketball",
    objID = packet.objID,
    pos = packet.pos,
    itemId = inUseItem.itemId
  })
end

function handles:requestGiveProp(packet)
  local itemId = packet.itemId
  local targetUserId = packet.targetUserId
  local player = Game.GetPlayerByUserId(targetUserId)
  if player and player:isValid() then
    local inUseProp = player:getInUseProp()
    if inUseProp then
      player:sendPacket({
        pid = "requestGiveProp",
        itemId = itemId,
        fromId = self.objID,
        fromUserId = self.platformUserId
      })
    else
      player:doReceivePropAction(itemId, self.platformUserId, true)
    end
  end
end

function handles:agreeGiveProp(packet)
  local itemId = packet.itemId
  local fromUserId = packet.fromUserId
  self:doReceivePropAction(itemId, fromUserId)
end

function handles:ThrowWishGoldCoin(packet)
  local player = World.CurWorld:getEntity(packet.objID)
  if not player or not player:isValid() then
    return
  end
  local inUseItem = player:getInUseProp()
  if not inUseItem or inUseItem.itemId ~= player:cfg().goldCoinItemId then
    return
  end
  local itemId = player:cfg().goldCoinItemId
  local isCanPlace, placePartName = PropsConfig:canPlaceToWorld(itemId)
  if not isCanPlace or placePartName == "" then
    return
  end
  
  local function createGoldCoin()
    local part = self:addItemPartToWorld(placePartName)
    if part then
      local partPos = self:getFrontPos(0.3, true, false) + {
        x = 0,
        y = 1.2,
        z = 0
      }
      part:setPosition(partPos)
      PartManagerHelper:addOnePlacePart(self.platformUserId, itemId, part)
      self:throwWishGoldCoin(part, packet.dis, packet.maxDis, packet.angle)
    end
  end
  
  if self:cfg().throwGoldCoinAction and self:cfg().throwGoldCoinAction ~= "" then
    local packet = {
      pid = "EntityPlayAction",
      objID = self.objID,
      action = self:cfg().throwGoldCoinAction,
      time = self:cfg().throwGoldCoinActionTime
    }
    self:sendPacketToTracking(packet, true)
    local delayTime = self:cfg().throwGoldCoinActionTime - 5
    if delayTime < 0 then
      delayTime = 0
    end
    World.Timer(delayTime, function()
      createGoldCoin()
    end)
  else
    createGoldCoin()
  end
end
