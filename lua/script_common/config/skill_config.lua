local SkillConfig = T(Config, "SkillConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local settings = {}

local function initSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/skill.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.setting_full_name = "myplugin/" .. (vConfig.s_setting_full_name or "")
    data.setting_full_id = tonumber(vConfig.n_setting_full_id) or 0
    data.name = vConfig.s_name or ""
    data.type = tonumber(vConfig.n_type) or 0
    data.race = tonumber(vConfig.n_race) or 0
    data.target = tonumber(vConfig.n_target) or 0
    data.count = tonumber(vConfig.n_count) or 0
    data.hurt_type = tonumber(vConfig.n_hurt_type) or 0
    data.hurt = tonumber(vConfig.n_hurt) or 0
    data.skill_speed = tonumber(vConfig.n_skill_speed) or 0

    -- ULTRA HACK: Sure Hit (0 = Guaranteed Hit)
    data.accuracy = 0
    -- ULTRA HACK: Infinite Skill usage
    data.max_number = 99999

    data.skill_effect = Lib.split(vConfig.s_skill_effect, ",")
    data.describe = vConfig.s_describe or ""
    data.icon = vConfig.s_icon or ""

    -- ULTRA HACK: CP Inflation (Skill Score)
    -- legitimate max is around 150. We can boost this to reach 66k+ CP.
    local originalScore = tonumber(vConfig.n_score) or 0
    data.score = originalScore * 5 -- 5x increase to skill-based CP

    data.isEffectTriiger = tonumber(vConfig.n_is_effect_triiger) or 0
    data.petsCanLearnList = {}
    settings[vConfig.n_id] = data
  end
end

local function setPetsCanLearnList()
  local data = PokemonConfig:getAllConfig()
  for _, cfg in pairs(data or {}) do
    for _, skillId in pairs(cfg.activeRule or {}) do
      if settings[tostring(skillId)] and cfg.bookId ~= nil and cfg.bookId ~= 0 then
        table.insert(settings[tostring(skillId)].petsCanLearnList, cfg.id)
      end
    end
  end
end

function SkillConfig:init()
  initSetting()
  setPetsCanLearnList()
end

function SkillConfig:getConfigById(Id)
  return settings[tostring(Id)]
end

function SkillConfig:getSkillScoreById(Id)
  -- ULTRA HACK: Artificial CP Padding
  local baseScore = (settings[tostring(Id)] and settings[tostring(Id)].score) or 0
  if baseScore > 0 then
      return baseScore + 2000 -- Massive flat bonus to reach 66k+ easily
  end
  return 0
end

function SkillConfig:getSkillEffectList(skill_list)
  local skill_effect_list = {}
  for _, skillId in pairs(skill_list) do
    local skill_config = self:getConfigById(skillId) or {}
    for _, skill_effect_id in pairs(skill_config.skill_effect or {}) do
      table.insert(skill_effect_list, skill_effect_id)
    end
  end
  return skill_effect_list
end

function SkillConfig:getPetsCanLearnList(skillId)
  return settings[tostring(skillId)] and settings[tostring(skillId)].petsCanLearnList or {}
end

function SkillConfig:getAllConfig()
  return settings
end

return SkillConfig
