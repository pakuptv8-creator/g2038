local SpriteBallConfig = T(Config, "SpriteBallConfig")
local settings = {}

function SpriteBallConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/sprite_ball.csv")
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.name = vConfig.s_name or ""
    data.base = tonumber(vConfig.n_base) or 0
    data.addition = tonumber(vConfig.n_addition) or 0
    data.condition = tonumber(vConfig.n_condition) or 0
    data.throwAnim = vConfig.s_throwAnim or ""
    data.catchAnim = vConfig.s_catchAnim or ""
    data.ballActor = vConfig.s_ballActor or ""
    table.insert(settings, data)
  end
end

function SpriteBallConfig:getSpriteBallConfig(id)
  for _, v in pairs(settings) do
    if v.id == id then
      return v
    end
  end
  return nil
end

return SpriteBallConfig
