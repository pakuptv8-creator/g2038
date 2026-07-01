local movie = require("script_client.movie.movie")
local MovieManager = L("MovieManager", {})
local queue = require("common.stl.queue")
local LuaTimer = T(Lib, "LuaTimer")
local curMovie
local tick = 0
local movieSequence = queue.new()
local movieSequenceCallback
local movieSequenceFinish = false
local movieCallback

function MovieManager:init()
  Lib.subscribeEvent(Event.EVENT_PLAY_CUTSCENE, function(name, callback, param)
    self.onPlayCutscene(name, false, callback, param)
  end)
  Lib.subscribeEvent(Event.EVENT_SKIP_CUTSCENE, function()
    self.onSkipCutscene()
  end)
  LuaTimer:cancel(self.updateTimer)
  self.updateTimer = LuaTimer:schedule(function()
    self:update(tick)
    tick = tick + 1
  end, 0, Lib.tickToTime(1))
end

function MovieManager.playSequence(tb, callback)
  movieSequence = queue.new(tb)
  movieSequenceCallback = callback
  MovieManager.onPlayCutscene(movieSequence:front_pop(), true)
end

function MovieManager.onPlayCutscene(name, isSequence, callback, param)
  Lib.logDebug("MovieManager.onPlayCutscene " .. name)
  if curMovie then
    Lib.logError("MovieManager.onPlayCutscene curMovie exist!", curMovie.name)
    MovieManager.onSkipCutscene()
  end
  curMovie = movie.new(name, callback, param)
  curMovie.isSequence = isSequence
  curMovie:play(tick)
  return curMovie
end

function MovieManager.onSkipCutscene()
  if not curMovie then
    return
  end
  Lib.logDebug("MovieManager.onSkipCutscene", curMovie.name)
  movieSequenceFinish = curMovie.isSequence and movieSequence:empty()
  movieCallback = curMovie.callback
  curMovie:stop()
  curMovie = nil
end

function MovieManager:update(t)
  if movieCallback then
    movieCallback()
    movieCallback = nil
  end
  if not curMovie and not movieSequence:empty() then
    MovieManager.onPlayCutscene(movieSequence:front_pop(), true)
  end
  if movieSequenceFinish and movieSequenceCallback then
    movieSequenceCallback()
    movieSequenceCallback = nil
    movieSequenceFinish = false
  end
  if curMovie and not curMovie:update(t) then
    self.onSkipCutscene()
  end
end

return MovieManager
