local BallMovieManager = L("BallMovieManager", {})
local MovieManager = require("script_client.movie.movie_manager")

local function genMovieSequence(q)
  local tb = {}
  local success = true
  for i = 1, #q._data do
    if not q._data[i] then
      success = false
      break
    else
      table.insert(tb, "catch_c" .. i)
    end
  end
  if success then
    table.insert(tb, "catch_success")
  else
    table.insert(tb, "catch_d" .. #q._data)
  end
  Lib.logDebug("genMovieSequence", Lib.v2s(tb))
  return tb
end

function BallMovieManager.play(q, casterBp)
  local success = true
  for i = 1, #q._data do
    if not q._data[i] then
      success = false
      break
    end
  end
  Lib.setPlayableScriptParam("CatchSuccess", success)
  Me:notifyStateReady(Define.READY_TYPE.CATCH)
  Me.needShowCapture = true
end

return BallMovieManager
