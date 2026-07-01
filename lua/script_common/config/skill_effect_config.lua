local SkillEffectConfig = T(Config, "SkillEffectConfig")
local settings = {}

function SkillEffectConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/skill_effect.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.effect_type = tonumber(vConfig.n_effect_type) or 0
    data.target = tonumber(vConfig.n_target) or 0
    data.race = tonumber(vConfig.n_race) or 0
    data.round = Lib.split(vConfig.n_round, "#")
    data.timing = tonumber(vConfig.n_timing) or 0
    data.timingDelay = tonumber(vConfig.n_timingDelay) or 0
    data.pr = tonumber(vConfig.n_pr) or 0
    data.dcm = tonumber(vConfig.n_dcm) or 0
    data.intger = tonumber(vConfig.n_intger) or 0
    data.effect_desc = vConfig.s_effect_desc or ""
    data.effect_trigger_desc = vConfig.s_effect_trigger_desc or ""
    data.effectTipDec = vConfig.s_effect_tip_dec or ""
    data.icon = vConfig.s_icon or ""
    data.abnormalType = tonumber(vConfig.n_abnormal_type) or 0
    data.addEffect = vConfig.s_add_effect or ""
    data.addSound = vConfig.s_add_sound or ""
    data.effectFullname = vConfig.s_effect_fullname or ""
    data.triggerEffect = vConfig.s_trigger_effect or ""
    data.triggerSound = vConfig.s_trigger_sound or ""
    data.immune = Lib.split(vConfig.s_immune, ",")
    data.trigger = tonumber(vConfig.n_trigger) or 0
    data.effectSkill = tonumber(vConfig.n_effectSkill) or 0
    data.effectSkillType = tonumber(vConfig.n_effectSkillType) or 0
    data.isLongRoundEffect = tonumber(vConfig.n_isLongRoundEffect) or 0
    data.isVulnerability = tonumber(vConfig.n_isVulnerability) or 0
    data.iconEffectName = vConfig.iconEffectName or ""
    settings[data.id] = data
  end
end

function SkillEffectConfig:getConfigById(Id)
  return settings[tonumber(Id)]
end

function SkillEffectConfig:getEffectIconById(Id)
  return settings[tonumber(Id)] and settings[tonumber(Id)].icon or ""
end

function SkillEffectConfig:getEffectIconByDisplay(effectId)
  for key, val in pairs(settings) do
    if val.id == effectId then
      return val.icon
    end
  end
  return ""
end

return SkillEffectConfig
