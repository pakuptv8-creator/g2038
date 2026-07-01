local SkillPerformConfig = T(Config, "SkillPerformConfig")
local settings = {}

function SkillPerformConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/skill_perform.csv")
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.startEffect = vConfig.s_startEffect or ""
    data.startSound = vConfig.s_startSound or ""
    data.startEffectOwner = vConfig.s_startEffectOwner or ""
    data.skillEffect = vConfig.s_skillEffect or ""
    data.skillSound = vConfig.s_skillSound or ""
    data.skillEffectOwner = vConfig.s_skillEffectOwner or ""
    data.hitEffect = vConfig.s_hitEffect or ""
    data.hitSound = vConfig.s_hitSound or ""
    data.hitEffectOwner = vConfig.s_hitEffectOwner or ""
    table.insert(settings, data)
  end
end

function SkillPerformConfig:getSkillPerformConfig(id)
  for _, setting in pairs(settings) do
    if setting.id == id then
      return setting
    end
  end
  return nil
end

return SkillPerformConfig
