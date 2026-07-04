local handles = T(Player, "PackageHandlers")
local BiddingConfig = T(Config, "BiddingConfig")

function handles:requestBlockTimeConfig(packet)
  local timeLineInfo = Lib.copyTable1(BiddingConfig:getAllTimeLine())
  for landName, val in pairs(timeLineInfo) do
    for status, info in pairs(val) do
      timeLineInfo[landName][status].timeRemaining = math.ceil((info.endTime - os.time()) / 86400)
    end
  end
  return timeLineInfo
end
