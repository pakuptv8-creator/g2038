local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
local settings = {}

function RegularGiftItemConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/regular_gift_item.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.rarity = tonumber(vConfig.n_rarity) or 0
    data.itemName = vConfig.s_itemName or ""
    data.itemCount = tonumber(vConfig.n_itemCount) or 0
    data.itemType = tonumber(vConfig.n_itemType) or 0
    data.icon = vConfig.s_icon or ""
    settings[data.id] = data
  end
end

function RegularGiftItemConfig:getConfigById(Id)
  return settings[tonumber(Id)]
end

function RegularGiftItemConfig:getAllConfig()
  return settings
end

return RegularGiftItemConfig
