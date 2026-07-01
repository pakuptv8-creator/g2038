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
  local cameraXOffset, cameraZOffset, cameraYawOffset = 0, 0, 0
  if casterBp == 2 or casterBp == 8 then
    cameraXOffset = 0
    cameraZOffset = 0
    cameraYawOffset = 0
  elseif casterBp == 3 or casterBp == 9 then
    cameraXOffset = 0
    cameraZOffset = 0
    cameraYawOffset = 0
  end
  Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, "catch_stage_1", function()
    Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, "catch_stage_2", function()
      if q:size() == 1 and q:front() == true then
        Lib.setPlayableScriptParam("CatchSuccess", true)
        MovieManager.playSequence({
          "catch_success"
        }, function()
          Me:notifyStateReady(Define.READY_TYPE.CATCH)
          Me.needShowCapture = true
        end)
      else
        Lib.setPlayableScriptParam("CatchSuccess", false)
        MovieManager.playSequence(genMovieSequence(q), function()
          Me:notifyStateReady(Define.READY_TYPE.CATCH)
          Me.needShowCapture = true
        end)
      end
    end)
  end)
end

return BallMovieManager
