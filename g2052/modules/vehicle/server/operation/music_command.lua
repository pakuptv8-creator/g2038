local VehicleManager = T(Lib, "VehicleManager")
local CommandBase = require("server.operation.command_base")
local MusicCommand = class("MusicCommand", CommandBase)

function MusicCommand:ctor(car)
  MusicCommand.super.ctor(self, car)
  self._bgmKey = nil
end

function MusicCommand:execute(params, player)
  if not params.key then
    return
  end
  self._bgmKey = params.key
  local riders = VehicleManager:getVehicleDriverAndPassenger(self.car)
  for _, rider in ipairs(riders) do
    if rider and rider:isValid() and rider.isPlayer then
      rider:sendPacket({
        pid = "stopCarMusic"
      })
      rider:sendPacket({
        pid = "playCarMusic",
        params = {
          key = params.key
        }
      })
      rider:setPlaySpecialBgm(true)
    end
  end
  self.isActive = true
end

function MusicCommand:undo(player)
  local riders = VehicleManager:getVehicleDriverAndPassenger(self.car)
  for _, rider in ipairs(riders) do
    if rider and rider:isValid() then
      if rider.isPlayer then
        rider:sendPacket({
          pid = "stopCarMusic"
        })
        rider:setPlaySpecialBgm(false)
      end
      local res = HouseManager:playCurHouseBgm(player.platformUserId)
      if not res then
        player:sendPacket({
          pid = "updateAreaBgm",
          key = "weather"
        })
      end
    end
  end
  self._bgmKey = nil
  self.isActive = false
end

function MusicCommand:playMusicForPlayer(player)
  if player and player:isValid() then
    player:sendPacket({
      pid = "playCarMusic",
      params = {
        key = self._bgmKey
      }
    })
    player:setPlaySpecialBgm(true)
  end
end

function MusicCommand:stopMusicForPlayer(player)
  if player and player:isValid() then
    player:sendPacket({
      pid = "stopCarMusic"
    })
    player:setPlaySpecialBgm(false)
    local res = HouseManager:playCurHouseBgm(player.platformUserId)
    if not res then
      player:sendPacket({
        pid = "updateAreaBgm",
        key = "weather"
      })
    end
  end
end

function MusicCommand:getBgmKey()
  return self._bgmKey
end

function MusicCommand:getCommandStatus()
  return {
    isActive = self.isActive,
    bgm = self._bgmKey
  }
end

return MusicCommand
