local setting = require("common.setting")
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  WinBase.init(self, "GetItemTip.json", false)
  self:initWnd()
end

function M:initWnd()
  self.close = self:child("GetItemTip-close")
  self.conformBtn = self:child("GetItemTip-conformBtn")
  self.titleText = self:child("GetItemTip-title")
  self.itemNumText = self:child("GetItemTip-itemNum")
  self.itemNameText = self:child("GetItemTip-itemName")
  self.itemImage = self:child("GetItemTip-itemIcon")
  self.itemQuality = self:child("GetItemTip-itemQuality")
  self:initEvent()
end

function M:initEvent()
  self:subscribe(self.close, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.conformBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
end

function M:showUIData(itemDate)
  local cfg = itemDate.type == 1 and setting:fetch("item", itemDate.fullName) or PokemonConfig:getConfigById(itemDate.petId)
  if cfg then
    self.itemQuality:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", itemDate.type == 1 and cfg.rarity or cfg.quality + 2))
    self.itemImage:SetImage(cfg.icon)
  end
  self.titleText:SetText(Lang:toText("gui_get_item_tip_title"))
  self.itemNumText:SetText("x " .. itemDate.count)
  self.itemNameText:SetText(Lang:toText(itemDate.itemName))
end

function M:onShow(isShow, itemDate)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("get_item_tip")
    end
    self:showUIData(itemDate)
  else
    self:onHide()
  end
end

function M:onOpen()
end

function M:onClose()
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
  if self.showTimer then
    LuaTimer:cancel(self.showTimer)
    self.showTimer = nil
  end
end

return M
