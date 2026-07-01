local RaceConfig = T(Config, "RaceConfig")
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  WinBase.init(self, "PokemonEvolutionShow.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgMask = self:child("PokemonEvolutionShow-Mask")
  self.imgLyt = self:child("PokemonEvolutionShow-Lyt")
  self.imgTopBar = self:child("PokemonEvolutionShow-TopBar")
  self.btnCloseBtn = self:child("PokemonEvolutionShow-CloseBtn")
  self.txtTitle = self:child("PokemonEvolutionShow-Title")
  self.actorEntityBefore = self:child("PokemonEvolutionShow-EntityBefore")
  self.actorEntityAfter = self:child("PokemonEvolutionShow-EntityAfter")
  self.txtTip = self:child("PokemonEvolutionShow-Tip")
  self.imgArrow = self:child("PokemonEvolutionShow-Arrow")
  self.lytBeforeStar = self:child("PokemonEvolutionShow-BeforeStarLyt")
  self.lytAfterStar = self:child("PokemonEvolutionShow-AfterStarLyt")
  self.txtTitle:SetText(Lang:toText("gui.evolution.title"))
end

function M:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView()
  self.lytBeforeStar:CleanupChildren()
  self.lytAfterStar:CleanupChildren()
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local pokemon_config_1 = PokemonConfig:getConfigById(self.pokemon:getCfgId())
  local entity_cfg_1 = Entity.GetCfg(pokemon_config_1.fullName)
  self.actorEntityBefore:SetActor1(entity_cfg_1.actorName, "idle")
  self.actorEntityBefore:SetActorScale(pokemon_config_1.uiScale)
  if getmetatable(self.actorEntityBefore).SetActorOffset then
    self.actorEntityBefore:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config_1.uiOffsetZ
    })
  end
  self.actorEntityBefore:SetYPosition({
    pokemon_config_1.uiOffsetY,
    0
  })
  local beforeStarItem = UIMgr:new_widget("pokemon_star_item_cell")
  self.lytBeforeStar:AddChildWindow(beforeStarItem)
  beforeStarItem:invoke("updateUI", self.pokemon:getStarLevel(), self.pokemon:getWake())
  local pokemon_config_2 = PokemonConfig:getConfigById(self.pokemon:getCfg().nextEvolutionId)
  local entity_cfg_2 = Entity.GetCfg(pokemon_config_2.fullName)
  self.actorEntityAfter:SetActor1(entity_cfg_2.actorName, "idle")
  self.actorEntityAfter:SetActorScale(pokemon_config_2.uiScale)
  if getmetatable(self.actorEntityAfter).SetActorOffset then
    self.actorEntityAfter:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config_2.uiOffsetZ
    })
  end
  self.actorEntityAfter:SetYPosition({
    pokemon_config_2.uiOffsetY,
    0
  })
  local afterStarItem = UIMgr:new_widget("pokemon_star_item_cell")
  self.lytAfterStar:AddChildWindow(afterStarItem)
  local times = pokemon_config_1.evolutionWake - self.pokemon:getWake()
  times = 0 < times and times or 1
  afterStarItem:invoke("updateUI", self.pokemon:getStarLevel(), self.pokemon:getWake() + times)
  self.txtTip:SetText(Lang:toText("gui.evolution.need") .. times)
end

function M:onHide()
  UI:closeWnd("pokemonEvolutionShow")
end

function M:onShow(pokemon)
  if pokemon then
    self.pokemon = pokemon
    if not UI:isOpen(self) then
      UI:openWnd("pokemonEvolutionShow")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
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
