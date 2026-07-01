local TimeLine = Lib.class("TimeLine")
local SLAXML = require("common.xml.slaxml")

function TimeLine:ctor(name, param)
  self.attribute = {}
  self.param = param
  self.tracks = {}
  self:loadTracks(name)
  self.startTick = 0
  self.endTick = 0
end

function TimeLine:getTrackClass(type)
  local trackMap = {
    animation = require("script_client.time_line.track.animation_track"),
    playable = require("script_client.time_line.track.playable_track"),
    ui = require("script_client.time_line.track.ui_track"),
    audio = require("script_client.time_line.track.audio_track"),
    control = require("script_client.time_line.track.control_track"),
    camera = require("script_client.time_line.track.camera_track"),
    activation = require("script_client.time_line.track.activation_track")
  }
  return trackMap[type]
end

function TimeLine:loadTrack(type, name, foldername, time)
  local class = self:getTrackClass(type)
  if class then
    table.insert(self.tracks, class.new(self, name, foldername, tonumber(time)))
  end
end

function TimeLine:getTrackByName(name)
  for _, track in pairs(self.tracks) do
    if track.name == name then
      return track
    end
  end
  return nil
end

function TimeLine:loadTracks(foldername, filename)
  filename = filename or foldername
  local path = string.format("%sresource/movie/%s/%s.xml", Root.Instance():getGamePath(), foldername, filename)
  local file = io.open(path)
  if not file then
    Lib.logError("TimeLine:load not file " .. filename)
    return
  end
  local element = {
    name = "",
    attribute = {}
  }
  local parser = SLAXML:parser({
    startElement = function(name, nsURI, nsPrefix)
      element.name = name
    end,
    attribute = function(name, value, nsURI, nsPrefix)
      element.attribute[name] = value
    end,
    closeElement = function(name, nsURI)
      if element.name == "TimeLine" then
        self.attribute = element.attribute
      elseif element.name == "Track" and element.attribute.enable ~= "false" then
        self:loadTrack(element.attribute.type, element.attribute.name, foldername, self.attribute.time)
      end
      element = {
        name = "",
        attribute = {}
      }
    end
  })
  parser:parse(file:read("*all"), {stripWhitespace = true})
end

function TimeLine:start(tick)
  self.startTick = tick
  self.endTick = self.startTick + Lib.timeToTick(tonumber(self.attribute.time))
  for i = 1, #self.tracks do
    self.tracks[i]:start(self.startTick)
  end
end

function TimeLine:update(tick)
  if tick > self.endTick then
    return false
  end
  for i = 1, #self.tracks do
    self.tracks[i]:update(tick)
  end
  return true
end

function TimeLine:stop()
  for i = 1, #self.tracks do
    self.tracks[i]:stop()
  end
  local worldCfg = World.cfg
  local viewMode = worldCfg.cameraCfg and worldCfg.cameraCfg.defaultView
  viewMode = viewMode or worldCfg.viewMode or self:cfg().defaultView or 0
  if not Lib.toBool(self.attribute.keepViewMode) then
    Blockman.instance:setPersonView(viewMode)
  end
end

return TimeLine
