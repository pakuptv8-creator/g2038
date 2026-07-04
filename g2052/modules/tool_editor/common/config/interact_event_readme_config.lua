local InteractEventReadMeConfig = T(Config, "InteractEventReadMeConfig")
local cjson = require("cjson")
local settings = {}

function InteractEventReadMeConfig:init()
  local csvData = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/interact_events_readme.csv", 2)
  for _, vConfig in pairs(csvData) do
    local data = {
      dec = vConfig.s_dec or "",
      func = vConfig.s_func or "",
      sync = vConfig.s_sync or "",
      triggers = vConfig.s_triggers or "",
      s_p1 = vConfig.s_p1 or "",
      s_p2 = vConfig.s_p2 or "",
      s_p3 = vConfig.s_p3 or "",
      s_p4 = vConfig.s_p4 or "",
      s_p5 = vConfig.s_p5 or "",
      s_p6 = vConfig.s_p6 or ""
    }
    settings[data.func] = data
  end
end

function InteractEventReadMeConfig:getAllCfgs()
  return settings
end

InteractEventReadMeConfig:init()
