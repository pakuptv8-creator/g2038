local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local BiddingManager = T(Lib, "BiddingManager")
local BiddingStatusTimeLine = T(Lib, "BiddingStatusTimeLine")
GMItem["bidding/\228\184\139\228\184\128\228\184\170\230\181\129\231\168\139"] = GM:inputStr(function(self, var)
  local blockId = var
  local block = BiddingManager:getBlock(blockId)
  block:updateStatus(BiddingStatusTimeLine:getNextStatus(block.status.status))
  block:syncData()
end)
GMItem["bidding/\232\174\190\231\189\174\232\181\183\229\167\139\233\152\182\230\174\181"] = GM:inputStr(function(self, var)
  local blockId = var
  local block = BiddingManager:getBlock(blockId)
  block:updateStatus(Define.BIDDING_STATUS.WAIT)
  block:syncData()
end)
