local VoicePackConfig = T(Config, "VoicePackConfig")
local settings = {}

function VoicePackConfig:init()
  local csvData = {}
  local path = Root.Instance():getGamePath() .. "config/voice_pack.csv"
  local file = io.open(path)
  if file then
    file:close()
    csvData = Lib.read_csv_file(path, 2)
  else
    path = Root.Instance():getGamePath() .. "modules/voice_pack/voice_pack.csv"
    file = io.open(path)
    if file then
      file:close()
      csvData = Lib.read_csv_file(path, 2)
    end
  end
  for _, config in pairs(csvData) do
    local data = {
      id = tonumber(config.n_id),
      path = config.s_path,
      volume = tonumber(config.n_volume),
      distance = tonumber(config.n_distance),
      time = tonumber(config.n_time),
      name = config.s_name,
      image = config.s_image
    }
    settings[data.id] = data
  end
end

function VoicePackConfig:getAllCfgs()
  return settings
end

function VoicePackConfig:getCfgById(id)
  return settings[id]
end

VoicePackConfig:init()
