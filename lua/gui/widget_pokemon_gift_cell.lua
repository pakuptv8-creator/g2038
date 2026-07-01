local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
local timeTypeIcon = "set:pokemon_gift_bag.json image:img_0_time_gift_"
local growTypeIcon = "set:pokemon_gift_bag.json image:img_0_grow_gift_"
local growBoardIcon = {
  [1] = "set:pokemon_gift_bag.json image:chb_9_grow_board_left_",
  [2] = "set:pokemon_gift_bag.json image:chb_9_grow_board_center_",
  [3] = "set:pokemon_gift_bag.json image:chb_9_grow_board_right_",
  [4] = "set:pokemon_gift_bag.json image:chb_9_grow_board_specail_"
}
local timeBoardIcon = {
  [1] = "set:pokemon_gift_bag.json image:chb_9_time_board_left_",
  [2] = "set:pokemon_gift_bag.json image:chb_9_time_board_center_",
  [3] = "set:pokemon_gift_bag.json image:chb_9_time_board_right_",
  [4] = "set:pokemon_gift_bag.json image:chb_9_time_board_specail_"
}

function M:init()
  widget_base.init(self, "pokemon_gift_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonGiftCellBg = self:child("pokemon_gift_cell-bg")
  self.imgPokemonGiftCellIcon = self:child("pokemon_gift_cell-icon")
end

function M:initEvent()
end

function M:updateInfo(data, style, giftType)
  self.giftId = data.id
  local gift = TriggerGiftConfig:getGiftById(self.giftId)
  if not gift then
    return
  end
  local icon = ""
  self.boardIcon = ""
  if giftType == Define.TRIGGER_GIFT_TYPE.GROW then
    icon = growTypeIcon .. gift.quality
    self.boardIcon = growBoardIcon[style]
  elseif giftType == Define.TRIGGER_GIFT_TYPE.TIME then
    icon = timeTypeIcon .. gift.quality
    self.boardIcon = timeBoardIcon[style]
  end
  self.imgPokemonGiftCellIcon:SetImage(icon)
  self.imgPokemonGiftCellBg:SetImage(self.boardIcon .. "2")
end

function M:getGiftId()
  return self.giftId
end

function M:onChecked(isChecked)
  if isChecked then
    self.imgPokemonGiftCellBg:SetImage(self.boardIcon .. "1")
  else
    self.imgPokemonGiftCellBg:SetImage(self.boardIcon .. "2")
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
