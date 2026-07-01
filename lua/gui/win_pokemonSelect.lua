local PokemonConfig = T(Config, "PokemonConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local RaceConfig = T(Config, "RaceConfig")
local setting = require("common.setting")

function M:init()
  WinBase.init(self, "PokemonSelect.json", false)
  self._root:SetLevel(2)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.id = 0
  self.pokemonitems = {}
end

function M:initWnd()
  self.stTitle = self:child("PokemonSelect-Title")
  self.stTitle:SetText(Lang:toText("gui_select_pokemon_title"))
  self.leftLayout = self:child("PokemonSelect-Left-Layout")
  self.lstPokemon = self:child("PokemonSelect-Pokemon-List")
  self.pokemon_grid_view = UIMgr:new_widget("grid_view")
  self.pokemon_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.pokemon_grid_view:InitConfig(0, 15, 1)
  self.pokemon_grid_view:SetMoveAble(false)
  self.lstPokemon:AddChildWindow(self.pokemon_grid_view)
  self:initPokemonList()
  self.awActor = self:child("PokemonSelect-ActorWindow")
  self.lyEvolution1 = self:child("PokemonSelect-Evolution-Level-1")
  self.siEvolutionAvatar1 = self:child("PokemonSelect-Evolution-Avatar-1")
  self.siEvolutionSelect1 = self:child("PokemonSelect-Evolution-Select-1")
  self.lyEvolution2 = self:child("PokemonSelect-Evolution-Level-2")
  self.siEvolutionAvatar2 = self:child("PokemonSelect-Evolution-Avatar-2")
  self.siEvolutionSelect2 = self:child("PokemonSelect-Evolution-Select-2")
  self.lyEvolution3 = self:child("PokemonSelect-Evolution-Level-3")
  self.siEvolutionAvatar3 = self:child("PokemonSelect-Evolution-Avatar-3")
  self.siEvolutionSelect3 = self:child("PokemonSelect-Evolution-Select-3")
  self.siRace = self:child("PokemonSelect-ImgRace")
  self.stRace = self:child("PokemonSelect-TextRace")
  self.stName = self:child("PokemonSelect-TextName")
  self.stInfoTitle = self:child("PokemonSelect-Info-Title")
  self.stInfoText = self:child("PokemonSelect-Info-Text")
  self.btnSelect = self:child("PokemonSelect-BtnSelect")
  self.stSelect = self:child("PokemonSelect-TextSelect")
end

function M:initEvent()
  self:subscribe(self.btnSelect, UIEvent.EventButtonClick, function()
    Me:selectInitPokemon(self.id)
    UI:closeWnd(self)
  end)
end

function M:onShow(type)
  self:select(type)
  UI:openWnd("pokemonSelect")
  Lib.reportPokemonOpen(Me)
end

function M:initPokemonList()
  local pokemon_ids = {
    10200101,
    10300101,
    10400101
  }
  local itemWidth = 112
  local itemHeight = 112
  for i = 1, #pokemon_ids do
    local pokemon_id = pokemon_ids[i]
    local node = UIMgr:new_widget("pokemon_icon_cell")
    node:invoke("initById", pokemon_id)
    node:SetArea({0, 0}, {0, 0}, {0, itemWidth}, {0, itemWidth})
    self.pokemon_grid_view:InitConfig(0, 30, 1)
    self.pokemon_grid_view:AddItem(node, true)
    self.pokemonitems[i] = node
    self:subscribe(node, UIEvent.EventWindowClick, function()
      self:select(pokemon_id)
    end)
  end
end

function M:select(id)
  Lib.logDebug("select id = ", id)
  self.id = id
  self:load(self.id)
  for _, pokemonItem in pairs(self.pokemonitems) do
    pokemonItem:invoke("onChecked", self.id)
  end
end

function M:load(id)
  local config = PokemonConfig:getConfigById(id)
  local color = RaceConfig:getColorBg(config.race)
  self._root:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
  self.stInfoTitle:SetText(Lang:toText("gui_intro"))
  self.stInfoText:SetText(Lang:toText(config.intro))
  self.stName:SetText(Lang:toText(config.name))
  self.siRace:SetImage(RaceConfig:getClassifyIcon(config.race))
  self.stRace:SetText(Lang:toText(RaceConfig:getName(config.race)))
  self.stRace:SetTextColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
  self.stSelect:SetText(Lang:toText("gui_select_pokemon"))
  self:loadActor(config, 1)
  self.siEvolutionAvatar1:SetImage(config.icon)
  self:subscribe(self.lyEvolution1, UIEvent.EventWindowClick, function()
    self:loadActor(config, 1)
  end)
  local firstEvoId = config.nextEvolutionId
  Lib.logDebug("firstEvoId  = ", firstEvoId)
  if firstEvoId ~= 0 then
    local firstConfig = PokemonConfig:getConfigById(firstEvoId)
    self.siEvolutionAvatar2:SetImage(firstConfig.icon)
    self:subscribe(self.lyEvolution2, UIEvent.EventWindowClick, function()
      self:loadActor(firstConfig, 2)
    end)
    local secondEvoId = firstConfig.nextEvolutionId
    if secondEvoId ~= 0 then
      do
        local secondConfig = PokemonConfig:getConfigById(secondEvoId)
        self.siEvolutionAvatar3:SetImage(secondConfig.icon)
        self:subscribe(self.lyEvolution3, UIEvent.EventWindowClick, function()
          self:loadActor(secondConfig, 3)
        end)
      end
    end
  end
end

function M:loadActor(config, index)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(config.fullName)
  self.awActor:SetActor1(entity_cfg.actorName, "idle")
  self.awActor:SetActorScale(config.uiScale)
  if getmetatable(self.awActor).SetActorOffset then
    self.awActor:SetActorOffset({
      x = 0,
      y = 0,
      z = config.uiOffsetZ
    })
  end
  self.awActor:SetYPosition({
    config.uiOffsetY,
    0
  })
  self.awActor:SetRotateY(-40)
  self.awActor:SetRotateX(10)
  if index == 1 then
    self.siEvolutionSelect1:SetVisible(true)
    self.siEvolutionSelect2:SetVisible(false)
    self.siEvolutionSelect3:SetVisible(false)
  elseif index == 2 then
    self.siEvolutionSelect1:SetVisible(false)
    self.siEvolutionSelect2:SetVisible(true)
    self.siEvolutionSelect3:SetVisible(false)
  elseif index == 3 then
    self.siEvolutionSelect1:SetVisible(false)
    self.siEvolutionSelect2:SetVisible(false)
    self.siEvolutionSelect3:SetVisible(true)
  end
end

function M:onHide()
  UI:closeWnd("pokemonSelect")
end

function M:onOpen()
end

function M:onClose()
  self.id = 0
  self.pokemonitems = {}
end

return M
