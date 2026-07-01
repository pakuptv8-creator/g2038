local RegularGiftConfig = T(Config, "RegularGiftConfig")
local settings = {}

function RegularGiftConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/regular_gift.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.tabId = tonumber(vConfig.n_tabId) or 0
    data.giftType = tonumber(vConfig.n_giftType) or 0
    data.sort_id = vConfig.s_sort_id or ""
    data.giftName = vConfig.s_giftName or ""
    data.giftContent = Lib.split(vConfig.s_giftContent, "#")
    data.currencyType = tonumber(vConfig.n_currencyType) or 0
    data.originalPrice = tonumber(vConfig.n_originalPrice) or 0
    data.discount = tonumber(vConfig.n_discount) or 0
    data.buyCount = tonumber(vConfig.n_buyCount) or 0
    data.giftTypeIcon = vConfig.s_giftTypeIcon or ""
    data.autoWeight = tonumber(vConfig.n_auto_weight) or 0
    if 0 >= data.discount then
      data.finalPrice = data.originalPrice
    else
      data.finalPrice = math.ceil(data.originalPrice * data.discount)
    end
    if World.cfg.useFDiamonds and data.currencyType == 0 then
      data.currencyType = 4
    end
    if data.currencyType == 0 then
      data.isPay = true
    else
      data.isPay = false
    end
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return tonumber(a.sort_id) < tonumber(b.sort_id)
  end)
end

function RegularGiftConfig:getConfigById(Id)
  for key, val in pairs(settings) do
    if tonumber(Id) == val.id then
      return val
    end
  end
  return nil
end

function RegularGiftConfig:getAllConfig(Id)
  return settings
end

return RegularGiftConfig
