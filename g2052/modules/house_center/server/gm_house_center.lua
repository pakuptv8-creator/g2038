local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local HouseConfig = T(Config, "HouseConfig")
GMItem["g2052\229\183\165\229\133\183/\230\136\191\229\177\139\229\129\143\231\167\187\228\191\174\230\148\185"] = GM:inputStr(function(self, value)
  local info, id = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info then
    local cfg = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName)
    if not cfg then
      return
    end
    local arr = Lib.splitString(value, ",")
    local posOffset, rotateOffset, panelOffset = {}, {}, {}
    if arr[1] then
      posOffset = Lib.splitString(arr[1], "#")
    end
    if arr[2] then
      rotateOffset = Lib.splitString(arr[2], "#")
    end
    if arr[3] then
      panelOffset = Lib.splitString(arr[3], "#")
    end
    if #posOffset ~= 3 or #rotateOffset ~= 3 or #panelOffset ~= 3 then
      Lib.logError("Input error:" .. value)
      return
    end
    local tbData = {
      n_id = tostring(cfg.id),
      s_posOffset = arr[1],
      s_rotateOffset = arr[2],
      s_panelOffset = arr[3]
    }
    HouseConfig:rewriteCfg(tbData)
    self:sendPacket({
      pid = "updateHouseConfig",
      tbData = tbData
    })
    HouseManager:updateHouseCd(self.platformUserId, nil)
    World.Timer(1, function()
      HouseManager:switchHouseModel(id, cfg.cfgName, true)
    end)
  end
end, function(self)
  local info = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info then
    local houseName = info.houseName
    local landName = info.landName
    local cfg = HouseConfig:getHouseInfoByCfgName(landName, houseName)
    local posOffset = cfg.posOffset
    local rotateOffset = cfg.rotateOffset
    local panelOffset = cfg.panelOffset
    return Lib.createStringByV3(posOffset) .. "," .. Lib.createStringByV3(rotateOffset) .. "," .. Lib.createStringByV3(panelOffset)
  end
end)
GMItem["ME/\230\136\191\229\177\139\231\129\175\229\188\128\229\133\179"] = function(self)
  HouseManager:controlLight(self)
end
