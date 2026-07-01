local CheatConfig = T(Config, "CheatConfig")
local settings = {}

function CheatConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/cheat.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.userId = tonumber(vConfig.userId) or 0
    data.time = tonumber(vConfig.time) or 0
    data.pay = tonumber(vConfig.pay) or 0
    settings[data.id] = data
  end
end

function CheatConfig:getUser(userId)
  Lib.logDebug("CheatConfig getUser userId = ", userId)
  local datas = {}
  for _, cheat_data in pairs(settings) do
    Lib.logDebug("getUser cheat_data = ", Lib.v2s(cheat_data))
    if cheat_data.userId == userId then
      table.insert(datas, cheat_data)
    end
  end
  return datas
end

return CheatConfig
