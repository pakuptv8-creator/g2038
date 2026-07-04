local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local settings = {}
local tabGoods = {}

function BusinessGoodsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/business_goods.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      goodsId = tonumber(vConfig.n_goodsId) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      goodsType = tonumber(vConfig.n_goodsType) or 0,
      itemId = tonumber(vConfig.n_itemId) or 0,
      price = tonumber(vConfig.n_price) or 0,
      itemIcon = vConfig.s_itemIcon or "",
      actorName = vConfig.s_actor_name or "",
      actorScale = tonumber(vConfig.n_actor_scale) or 1,
      actorRotateY = tonumber(vConfig.n_actor_rotateY) or 0,
      actorRotateX = tonumber(vConfig.n_actor_rotateX) or 0
    }
    local uiOffset = Lib.splitString(vConfig.s_actor_uiOffset or "", "#", true)
    data.actorUIOffset = Lib.v2(uiOffset[1] or 0, uiOffset[2] or 0)
    settings[data.goodsId] = data
    if not tabGoods[data.goodsType] then
      tabGoods[data.goodsType] = {}
    end
    table.insert(tabGoods[data.goodsType], data)
  end
  for type, val in pairs(tabGoods) do
    table.sort(tabGoods[type], function(a, b)
      return a.sortId < b.sortId
    end)
  end
end

function BusinessGoodsConfig:getCfgById(goodsId)
  if not settings[goodsId] then
    Lib.logError("can not find cfgBusinessGoodsConfig, id:", goodsId)
    return
  end
  return settings[goodsId]
end

function BusinessGoodsConfig:getAllCfgs()
  return settings
end

function BusinessGoodsConfig:getAllByTabType(tabType)
  return tabGoods[tabType] or {}
end

function BusinessGoodsConfig:getCfgByTabTypeAndItemId(tabType, itemId)
  if not tabGoods[tabType] then
    Lib.logError("can not find getCfgByTabTypeAndItemId, id:", tabType)
    return
  end
  for _, val in pairs(tabGoods[tabType]) do
    if itemId == val.itemId then
      return val
    end
  end
  return
end

BusinessGoodsConfig:init()
return BusinessGoodsConfig
