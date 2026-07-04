local cm = CameraManager:Instance()
local HouseConfig = T(Config, "HouseConfig")
local MonitorHelper = T(Lib, "MonitorHelper")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2052/\230\137\147\229\188\128\230\136\191\229\173\144ui"] = function()
  UI:openWnd("house")
end
GMItem["g2052/\231\155\145\232\167\134\228\189\141\231\189\174"] = function()
  local monitorCamera = cm:findCamera("monitorCamera")
  if monitorCamera then
    local curPos = monitorCamera:getPosition()
    Lib.pv(curPos, nil, "monitor_pos")
  end
end
GMItem["g2052/x+"] = function()
  local monitorCamera = cm:findCamera("monitorCamera")
  if monitorCamera then
    local curPos = monitorCamera:getPosition()
    monitorCamera:setPosition({
      x = curPos.x + 2,
      y = curPos.y,
      z = curPos.z
    })
  end
end
GMItem["g2052/x-"] = function()
  local monitorCamera = cm:findCamera("monitorCamera")
  if monitorCamera then
    local curPos = monitorCamera:getPosition()
    monitorCamera:setPosition({
      x = curPos.x - 2,
      y = curPos.y,
      z = curPos.z
    })
  end
end
GMItem["g2052/z+"] = function()
  local monitorCamera = cm:findCamera("monitorCamera")
  if monitorCamera then
    local curPos = monitorCamera:getPosition()
    monitorCamera:setPosition({
      x = curPos.x,
      y = curPos.y,
      z = curPos.z + 2
    })
  end
end
GMItem["g2052/z-"] = function()
  local monitorCamera = cm:findCamera("monitorCamera")
  if monitorCamera then
    local curPos = monitorCamera:getPosition()
    monitorCamera:setPosition({
      x = curPos.x,
      y = curPos.y,
      z = curPos.z - 2
    })
  end
end
GMItem["g2052/\229\136\135\230\141\162\229\174\137\233\152\178\231\148\187\233\157\162"] = function()
  local isHasHouse, houseInfo = Me:doIOwnAHouse()
  if not isHasHouse then
    return
  end
  local cPos = houseInfo.pos
  local houseConfig = HouseConfig:getHouseInfoByCfgName("land", houseInfo.houseName)
  local securityCameraOffset = houseConfig.cameraOffset
  if securityCameraOffset[1] then
    local cameraPos = Lib.v3add(cPos, securityCameraOffset[1].cameraPosOffset)
    local targetPos = Lib.v3add(cPos, securityCameraOffset[1].targetPosOffset)
    MonitorHelper:activate(cameraPos, targetPos)
  end
end
GMItem["g2052/\229\133\179\233\151\173\229\174\137\233\152\178\231\148\187\233\157\162"] = function()
  MonitorHelper:deactivate()
end
GMItem["g2052\229\183\165\229\133\183/\229\156\176\229\157\151\228\191\161\230\129\175\229\129\143\231\167\187\231\188\150\232\190\145"] = function()
  UI:openWnd("landInfoEdit")
end
