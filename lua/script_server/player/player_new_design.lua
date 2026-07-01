local Player = _ENV.Player
local handles = T(Player, "PackageHandlers")

function Player:pokemonNewDesign(pokemon, eventKey, changeKey, startVal, endVal)
  local parts = {
    uid = pokemon:getUid(),
    cfgId = pokemon:getCfgId(),
    name = pokemon:getCfg().name,
    star = pokemon:getStar(),
    wake = pokemon:getWake(),
    level = pokemon:getLevel(),
    quality = pokemon:getQuality(),
    change_key = changeKey,
    design_type = "pokemon_event"
  }
  parts.start_value = startVal
  parts.end_value = endVal
  GameAnalytics.NewDesign(self.platformUserId, eventKey, parts)
end

function Player:useBlessingNewDesign(pokemon, attr_type, bless_level)
  local blessKey = ""
  if attr_type == Define.POKEMON_ATTR_TYPE.Hp then
    blessKey = "bless_Hp"
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.Speed then
    blessKey = "bless_Speed"
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PAtk then
    blessKey = "bless_PAtk"
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PDef then
    blessKey = "bless_PDef"
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SAtk then
    blessKey = "bless_SAtk"
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SDef then
    blessKey = "bless_SDef"
  end
  local parts = {
    uid = pokemon:getUid(),
    cfgId = pokemon:getCfgId(),
    name = pokemon:getCfg().name,
    bless_key = blessKey,
    bless_level = bless_level,
    count_change = 1,
    design_type = "bless_use_event"
  }
  GameAnalytics.NewDesign(self.platformUserId, Define.newDesignEventKey.CANDY_USE, parts)
end

function Player:diamondCostNewDesign(eventKey, parts)
  parts.design_type = "diamond_cost_event"
  GameAnalytics.NewDesign(self.platformUserId, eventKey, parts)
end

function Player:coinCostNewDesign(eventKey, parts)
  parts.design_type = "coin_cost_event"
  GameAnalytics.NewDesign(self.platformUserId, eventKey, parts)
end

function Player:commonNewDesign(eventKey, parts)
  parts.design_type = "normal_event"
  GameAnalytics.NewDesign(self.platformUserId, eventKey, parts)
end
