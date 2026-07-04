local SkateConfig = T(Config, "SkateConfig")
local settings = {}

function SkateConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/skate.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      skateCfg = vConfig.s_skateCfg or "",
      component = vConfig.s_component or "",
      stepOnSpeed = tonumber(vConfig.n_stepOnSpeed) or 0,
      maxSpeed = tonumber(vConfig.n_maxSpeed) or 0,
      moveAcc = tonumber(vConfig.n_moveAcc) or 0,
      stopAcc = tonumber(vConfig.n_stopAcc) or 0,
      jumpSpeed = tonumber(vConfig.n_jumpSpeed) or 0,
      jumpAnim = {},
      flyingAnim = {}
    }
    for i = 1, 5 do
      local key = "jumpAnim" .. i
      local animCfg = vConfig[key]
      if animCfg then
        local tab = {}
        local jumpAnim = Lib.split(animCfg, ",")
        tab.skate = jumpAnim[1]
        tab.player = jumpAnim[2]
        data[key] = tab
      end
    end
    local flyingAnim = Lib.split(vConfig.flyingAnim, ",")
    data.flyingAnim.skate = flyingAnim[1]
    data.flyingAnim.player = flyingAnim[2]
    settings[data.id] = data
  end
end

function SkateConfig:getCfgById(id)
  if not settings[id] then
    return
  end
  return settings[id]
end

function SkateConfig:getAllCfgs()
  return settings
end

SkateConfig:init()
return SkateConfig
