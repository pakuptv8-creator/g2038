local DailyLotteryConfig = T(Config, "DailyLotteryConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local settings = {}

function DailyLotteryConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/daily_lottery.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.cycleId = tonumber(vConfig.n_cycle_id) or 1
    data.items = {}
    for i = 1, 7 do
      local item = {}
      local itemData = Lib.split(vConfig["s_item_" .. i], "#")
      item.type = tonumber(itemData[1])
      if item.type == 1 then
        item.fullName = tostring(itemData[2])
        item.itemNum = tonumber(itemData[3])
        item.weight = tonumber(itemData[4])
        item.itemIcon = tostring(itemData[5])
        item.itemName = tostring(itemData[6])
      elseif item.type == 2 then
        item.petId = tostring(itemData[2])
        local petCfg = PokemonConfig:getConfigById(item.petId)
        item.itemNum = tonumber(itemData[3])
        item.weight = tonumber(itemData[4])
        if petCfg then
          item.itemIcon = itemData[5] and tostring(itemData[5]) or petCfg.icon
          item.itemName = itemData[6] and tostring(itemData[6]) or petCfg.name
        else
          print("CANT FIND LOTTERY REWARD PET CFG,ID IS:", item.petId)
        end
      end
      data.items[i] = item
    end
    settings[data.cycleId] = data
  end
end

function DailyLotteryConfig:getConfigById(Id)
  return settings[tonumber(Id)]
end

function DailyLotteryConfig:getMaxCircle()
  return #settings
end

function DailyLotteryConfig:getItemData(circleId, index)
  if settings[tonumber(circleId)] then
    return settings[tonumber(circleId)].items[index] or nil
  end
  return nil
end

return DailyLotteryConfig
