local BrightnessScaleHelper = T(Lib, "brightnessScaleHelper")
BrightnessScaleHelper.playerList = {}
if World.isClient then
  function BrightnessScaleHelper:updatePlayerBrightnessScale(info, all)
    if all then
      self.playerList = info
      
      self:changeAllPlayerBrightnessScale()
    else
      for objID, brightnessScale in pairs(info or {}) do
        self.playerList[objID] = brightnessScale
        self:changePlayerBrightnessScale(objID)
      end
    end
  end
  
  function BrightnessScaleHelper:changeAllPlayerBrightnessScale()
    for objID, brightnessScale in pairs(self.playerList) do
      local target = World.CurWorld:getEntity(objID)
      if target and target:isValid() then
        target:changeBrightnessScale(brightnessScale)
      end
    end
  end
  
  function BrightnessScaleHelper:changePlayerBrightnessScale(objID)
    local brightnessScale = self.playerList[objID]
    if not brightnessScale then
      return
    end
    local target = World.CurWorld:getEntity(objID)
    if target and target:isValid() then
      target:changeBrightnessScale(brightnessScale)
    end
  end
else
  function BrightnessScaleHelper:updateBrightnessScale(objID, brightnessScale)
    if self.playerList[objID] ~= brightnessScale then
      self.playerList[objID] = brightnessScale
      
      self:sendPlayerList(nil, objID)
    end
  end
  
  function BrightnessScaleHelper:sendPlayerList(player, targetID)
    if player then
      player:sendPacket({
        pid = "UpdatePlayerBrightnessScaleList",
        all = true,
        info = self.playerList
      })
    else
      local info = self.playerList
      if targetID then
        info = {}
        info[targetID] = self.playerList[targetID]
      end
      if not next(info) then
        return
      end
      WorldServer.BroadcastPacket({
        pid = "UpdatePlayerBrightnessScaleList",
        info = info
      })
    end
  end
end

function BrightnessScaleHelper:getPlayerList()
  return self.playerList or {}
end

return BrightnessScaleHelper
