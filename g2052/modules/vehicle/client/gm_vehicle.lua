local CarConfig = T(Config, "CarConfig")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local debugDraw = DebugDraw.instance
GMItem["\232\189\189\229\133\183/\233\149\156\229\164\180\230\179\168\232\167\134\228\189\141\231\189\174"] = function()
  if Me.rideOnInstanceId then
    local ins = Instance.getByInstanceId(Me.rideOnInstanceId)
    if not ins or not ins:isValid() then
      return
    end
    local name = ins:getProperty("name")
    local pos = ins:getPosition()
    local cfg = CarConfig:getCfgByName("myplugin/" .. name) or {}
    debugDraw:setEnabled(true)
    debugDraw.addEntry("drawMesh", function()
      local lookPos = pos + Lib.v3(cfg.cameraFollowOffset[1] or 0, cfg.cameraFollowOffset[2] or 0, cfg.cameraFollowOffset[3] or 0)
      debugDraw:drawSphere(lookPos, 0.02, 4278190335)
      local foot = pos
      debugDraw:drawSphere(foot, 0.02, 16711935)
      debugDraw:drawLine(foot, lookPos, 65535)
    end)
    debugDraw:setDrawMeshEnabled(true)
    ins:connect("on_destroy", function(instance)
      if instance == ins then
        debugDraw:setEnabled(false)
      end
    end)
  end
end
