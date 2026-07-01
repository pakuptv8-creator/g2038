function Lib.setPlayableScriptParam(key, value)
  local PlayableScript = require("script_client.time_line.playable_script")
  
  PlayableScript.param[key] = value
  Lib.logDebug("setPlayableScriptParam", key, Lib.v2s(value))
end
