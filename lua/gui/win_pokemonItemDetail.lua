local setting = require("common.setting")

function M:init()
  WinBase.init(self, "PokemonItemDetail.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.isProtected = true
  self._desktop = GUISystem.instance:GetRootWindow()
  self.mid_x = self._desktop:GetPixelSize().x / 2
  self.mid_y = self._desktop:GetPixelSize().y / 2
  self.lytPokemonItemDetailClickPosition = self:child("PokemonItemDetail-Click-Position")
  self.lytPokemonItemDetailContent = self:child("PokemonItemDetail-Content")
  self.imgPokemonItemDetailIcon = self:child("PokemonItemDetail-Icon")
  self.imgPokemonItemDetailFrameIcon = self:child("PokemonItemDetail-FrameIcon")
  self.lytPokemonItemDetailDescBg = self:child("PokemonItemDetail-Desc-Bg")
  self.txtPokemonItemDetailDesc = self:child("PokemonItemDetail-Desc")
  self.txtPokemonItemDetailName = self:child("PokemonItemDetail-Name")
  self.txtPokemonItemDetailQualityLabel = self:child("PokemonItemDetail-Quality-Label")
  self.txtPokemonItemDetailQualityText = self:child("PokemonItemDetail-Quality-Text")
end

function M:initEvent()
  self:subscribe(self._desktop, UIEvent.EventWindowClick, function()
    if UI:isOpen(self) and not self.isProtected then
      self:onHide()
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_TOUCH_SCREEN, function(sender)
    if UI:isOpen(self) and not self.isProtected then
      self:onHide()
    end
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd("pokemonItemDetail")
end

function M:onShow(fullName, dx, dy)
  self.isProtected = true
  UI:closeWnd("pokemonItemDetail")
  local cfg = setting:fetch("item", fullName)
  if cfg then
    self.imgPokemonItemDetailFrameIcon:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
    self.imgPokemonItemDetailIcon:SetImage(cfg.icon)
    self.txtPokemonItemDetailQualityLabel:SetText(Lang:toText("title_quality"))
    self.txtPokemonItemDetailQualityText:SetText(Lang:toText(string.format("ui_item_rarity_%d", cfg.rarity)))
    self.txtPokemonItemDetailName:SetText(Lang:toText(cfg.itemName))
    self.txtPokemonItemDetailDesc:SetText(Lang:toText(cfg.desc))
  end
  self.lytPokemonItemDetailClickPosition:SetXPosition({0, dx})
  self.lytPokemonItemDetailClickPosition:SetYPosition({0, dy})
  if dx < self.mid_x then
    self.lytPokemonItemDetailContent:SetHorizontalAlignment(0)
  else
    self.lytPokemonItemDetailContent:SetHorizontalAlignment(2)
  end
  if dy < self.mid_y then
    self.lytPokemonItemDetailContent:SetVerticalAlignment(0)
  else
    self.lytPokemonItemDetailContent:SetVerticalAlignment(2)
  end
  UI:openWnd("pokemonItemDetail")
  World.Timer(5, function()
    self.isProtected = false
  end)
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(1)
  self:initView()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
