local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
local setting = require("common.setting")
local settings = {}
local cfgs = setting:modCfgs("item")

local function getFullName(itemId)
  local fullName
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemId) == tonumber(itemId) then
      fullName = _fullName
      break
    end
  end
  return fullName
end

function TriggerGiftConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/trigger_gift.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.type = tonumber(vConfig.n_type) or 0
    data.title = vConfig.s_title or ""
    data.quality = tonumber(vConfig.n_quality) or 0
    data.original = tonumber(vConfig.n_original) or 0
    data.discount = tonumber(vConfig.n_discount) or 0
    data.items = vConfig.s_items or ""
    data.itemsType = vConfig.s_itemsType or ""
    data.itemsCount = vConfig.s_itemsCount or ""
    data.highlight = vConfig.s_highlight or ""
    data.duration = tonumber(vConfig.n_duration) or 0
    data.premiseGiftId = tonumber(vConfig.n_premiseGiftId)
    data.trigger = vConfig.s_trigger or ""
    local trigger_type = Lib.split(vConfig.s_trigger, "#")
    data.triggerType = tonumber(trigger_type[1])
    data.s_sp_icon = vConfig.s_sp_icon or ""
    data.autoWeight = tonumber(vConfig.n_auto_weight) or 0
    data.battleShow = true
    if not tonumber(vConfig.n_battleShow) or tonumber(vConfig.n_battleShow) == 0 then
      data.battleShow = false
    end
    if vConfig.s_items ~= "" then
      data.giftItems = {}
      local gift_items = Lib.split(vConfig.s_items, "#")
      for _, item in pairs(gift_items) do
        local selItems = Lib.split(item, ",")
        if selItems and 1 < #selItems then
          local numSelItem = {}
          for _, sel in pairs(selItems) do
            table.insert(numSelItem, tonumber(sel))
          end
          table.insert(data.giftItems, numSelItem)
        else
          table.insert(data.giftItems, tonumber(item))
        end
      end
      if vConfig.s_itemsType ~= "" then
        data.giftType = {}
        local gift_type = Lib.split(vConfig.s_itemsType, "#")
        for _, _type in pairs(gift_type) do
          table.insert(data.giftType, tonumber(_type))
        end
      end
      if vConfig.s_itemsCount ~= "" then
        data.giftItemCount = {}
        local gift_count = Lib.split(vConfig.s_itemsCount, "#")
        for _, count in pairs(gift_count) do
          table.insert(data.giftItemCount, tonumber(count))
        end
      end
      if vConfig.s_highlight ~= "" then
        data.highlight = {}
        local highlight = Lib.split(vConfig.s_highlight, "#")
        for i = 1, #data.giftItems do
          data.highlight[i] = false
          for _, index in pairs(highlight) do
            if tonumber(index) == i then
              data.highlight[i] = true
            end
          end
        end
      end
      if vConfig.s_petStarLevel ~= "" then
        data.petStarLevel = {}
        local star_level = Lib.split(vConfig.s_petStarLevel, "#")
        for _, level in pairs(star_level) do
          table.insert(data.petStarLevel, tonumber(level))
        end
      end
    end
    data.sameTypeGift = {}
    if vConfig.s_sameTypeGift ~= "" then
      local giftIds = Lib.split(vConfig.s_sameTypeGift, "#")
      for _, giftId in pairs(giftIds) do
        table.insert(data.sameTypeGift, tonumber(giftId))
      end
    end
    table.insert(settings, data)
  end
end

function TriggerGiftConfig:getSettings()
  return settings
end

function TriggerGiftConfig:getGiftById(id)
  for _, _setting in pairs(settings) do
    if _setting.id == id then
      return _setting
    end
  end
  return
end

function TriggerGiftConfig:getTriggerGiftNumByTrigger(trigger)
  local num = 0
  for _, _setting in pairs(settings) do
    if _setting.trigger == trigger then
      num = num + 1
    end
  end
  return num
end

function TriggerGiftConfig:getGiftItemsInfoById(id)
  local giftItems = {}
  for _, _setting in pairs(settings) do
    if _setting.id == id then
      for i, itemId in pairs(_setting.giftItems) do
        local info = itemId
        if _setting.giftType[i] == Define.TRIGGER_GIFT_ITEM_TYPE.PET then
        elseif _setting.giftType[i] == Define.TRIGGER_GIFT_ITEM_TYPE.GOLD then
          info = Coin:coinNameByCoinId(info)
        elseif _setting.giftType[i] == Define.TRIGGER_GIFT_ITEM_TYPE.ITEM then
          info = getFullName(info)
        end
        local petStarLevel = _setting.petStarLevel and _setting.petStarLevel[i] or nil
        giftItems[i] = {
          id = id,
          giftType = _setting.giftType[i],
          item = info,
          sp_icon = _setting.s_sp_icon,
          count = _setting.giftItemCount[i],
          highlight = _setting.highlight[i],
          petStarLevel = petStarLevel
        }
      end
      break
    end
  end
  return giftItems
end

return TriggerGiftConfig
