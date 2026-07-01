local PokemonConfig = T(Config, "PokemonConfig")
local RaceConfig = T(Config, "RaceConfig")
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonEvolution.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonEvolutionEffectBg = self:child("PokemonEvolution-Effect-Bg")
  self.lytPokemonEvolutionEffectAction = self:child("PokemonEvolution-Effect-action")
  self.actorPokemonEvolutionActor = self:child("PokemonEvolution-Actor")
end

function M:initEvent()
end

function M:subscribeEvent()
end

function M:initView()
end

function M:setActor(pokemon_config)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(pokemon_config.fullName)
  self.actorPokemonEvolutionActor:SetActor1(entity_cfg.actorName, "idle")
  self.actorPokemonEvolutionActor:SetActorScale(pokemon_config.uiScale)
  if getmetatable(self.actorPokemonEvolutionActor).SetActorOffset then
    self.actorPokemonEvolutionActor:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  self.actorPokemonEvolutionActor:SetYPosition({
    pokemon_config.uiOffsetY,
    0
  })
  self.actorPokemonEvolutionActor:SetRotateY(-30)
  self.actorPokemonEvolutionActor:SetRotateX(15)
  local color = RaceConfig:getColorBg(pokemon_config.race)
  self._root:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
end

function M:onHide()
  UI:closeWnd("pokemonEvolution")
end

function M:onShow(pokemonId, callBack)
  self.old_pokemon_config = PokemonConfig:getConfigById(pokemonId)
  self.new_pokemon_config = PokemonConfig:getConfigById(self.old_pokemon_config.nextEvolutionId)
  Me:playSoundByKey("evolution")
  if self.old_pokemon_config and self.new_pokemon_config then
    UI:openWnd("pokemonEvolution")
    self:setActor(self.old_pokemon_config)
    self.lytPokemonEvolutionEffectAction:SetEffectName("g2038_evolution_light.effect")
    self.lytPokemonEvolutionEffectAction:SetVisible(true)
    LuaTimer:schedule(function()
      self:setActor(self.new_pokemon_config)
    end, 1900)
    LuaTimer:schedule(function()
      UI:getWnd("battle_dialog"):showDialogText({
        text = string.format(PokemonConfig:getColorByQuality(self.new_pokemon_config.quality) .. Lang:getMessage("battle_result_evolution"), Lang:toText(self.old_pokemon_config.name), Lang:toText(self.new_pokemon_config.name)),
        isHideMask = true,
        yesCb = function()
        end,
        closeFunc = function()
          if callBack then
            callBack()
          end
          self:onHide()
        end
      })
    end, 3500)
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  self:root():SetAlwaysOnTop(true)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self.lytPokemonEvolutionEffectAction:SetVisible(false)
  self.lytPokemonEvolutionEffectAction:SetEffectName("")
end

return M
