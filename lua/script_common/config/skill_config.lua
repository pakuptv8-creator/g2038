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
    data.accuracy = tonumber(vConfig.n_accuracy) or 0
    data.max_number = tonumber(vConfig.n_max_number) or 0
    data.skill_effect = Lib.split(vConfig.s_skill_effect, ",")
    data.describe = vConfig.s_describe or ""
    data.icon = vConfig.s_icon or ""
    data.score = tonumber(vConfig.n_score) or 0
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

function SkillConfig:getConfigByName(name)
  for _, data in pairs(settings) do
    if data.name == name then
      return data
    end
  end
  return nil
end

function SkillConfig:getSkillSpeedById(Id)
  return settings[tostring(Id)] and settings[tostring(Id)].skill_speed or 1
end

function SkillConfig:getSkillNameById(Id)
  return settings[tostring(Id)] and settings[tostring(Id)].name or ""
end

function SkillConfig:getSkillScoreById(Id)
  return settings[tostring(Id)] and settings[tostring(Id)].score or 0
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

return SkillConfig
