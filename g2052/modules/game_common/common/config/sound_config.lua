local SoundConfig = T(Config, "SoundConfig")
local sounds = {}

function SoundConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/sound_action.csv", 2)
  for _, v in pairs(config) do
    local data = {}
    data.id = tonumber(v.id)
    data.key = v.key
    data.sound = v.sound
    data.loop = 1 == tonumber(v.loop)
    data.volume = tonumber(v.volume)
    sounds[data.key] = data
  end
end

function SoundConfig:getSound(key)
  return key and sounds[key]
end

SoundConfig:init()
return SoundConfig
