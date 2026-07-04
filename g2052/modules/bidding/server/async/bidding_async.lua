local self = AsyncProcess
local strfmt = string.format
local BiddingConfig = T(Config, "BiddingConfig")
local bidding_data_catch

function AsyncProcess.loadBiddingConfig()
  local url = strfmt("%s/config/files/%s", self.ServerHttpHost, "g2052-land-bidding-process-config")
  self.HttpRequest("GET", url, {}, function(response)
    local data = response.data
    if data ~= nil and (not bidding_data_catch or not Lib.equals(bidding_data_catch, data)) then
      BiddingConfig:setTimeLineConfig(data)
      bidding_data_catch = data
      Lib.logDebug(Lib.v2s(bidding_data_catch, 5))
    end
  end)
end
