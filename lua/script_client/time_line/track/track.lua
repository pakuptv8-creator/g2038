local SLAXML = require("common.xml.slaxml")
local Track = Lib.class("Track")

function Track:ctor(timeLine, name, rootName, time)
  self.timeLine = timeLine
  self.name = name
  self.cfg = nil
  self.frames = {}
  self.time = time
  self:load(name, rootName)
end

function Track:getFrameClass(type)
  return nil
end

function Track:load(name, rootName)
  local path = string.format("%sresource/movie/%s/%s.xml", Root.Instance():getGamePath(), rootName, name)
  local file = io.open(path)
  if not file then
    Lib.logError(string.format("********** Track:load not file %s **********", path))
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
      if element.name == "Track" then
        self.cfg = element.attribute
      end
      local class = self:getFrameClass(element.name)
      if class then
        table.insert(self.frames, class.new(self, element.attribute, self.time))
      end
      element = {
        name = "",
        attribute = {}
      }
    end
  })
  parser:parse(file:read("*all"), {stripWhitespace = true})
end

function Track:start(tick)
  self:onStart(tick)
  for i = 1, #self.frames do
    self.frames[i]:start(tick)
  end
end

function Track:update(tick)
  self:onUpdate(tick)
  for i = 1, #self.frames do
    self.frames[i]:update(tick)
  end
end

function Track:stop()
  self:onStop()
  for i = 1, #self.frames do
    self.frames[i]:stop()
  end
end

function Track:onStart(tick)
end

function Track:onUpdate(tick)
end

function Track:onStop()
end

return Track
