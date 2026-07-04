local LuaTimer = T(Lib, "LuaTimer")
local main = {}
local roomGameConfig = Server.CurServer:getConfig()

function main:init()
  self:setGlobalProperty()
  self:initLog()
  self:loadConfig()
  self:startTimer()
  local next = tostring(os.time()):reverse():sub(1, 6)
  math.randomseed(tonumber(next))
end

function main:setGlobalProperty()
  GlobalProperty.Instance():setBoolProperty("DisableCheckBlockTouch", true)
end

function main:initLog()
  Lib.setDebugLog(roomGameConfig:isDebug())
  Lib.setLogLevel(3)
end

function main:loadConfig()
end

local lastTime = os.time()

function main:startTimer()
  LuaTimer:scheduleTimer(function()
    local nowTime = os.time()
    if not Lib.isSameDay(lastTime, nowTime) then
      lastTime = nowTime
      for _, player in pairs(Game.GetAllPlayers()) do
        if player and player:isValid() then
          player:autoDataExpire()
        end
      end
    end
  end, 1000, -1)
end

main:init()
