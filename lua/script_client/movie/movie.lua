local class = require("common.class")
local Movie = class("Movie")
local TimeLine = require("script_client.time_line.time_line")

function Movie:ctor(name, callback, param)
  self.name = name
  self.callback = callback
  self.param = param
  self.timeline = TimeLine.new(self.name, self.param)
end

function Movie:getTimeLine()
  return self.timeline
end

function Movie:play(tick)
  Blockman.instance.gameSettings:setSpecifiedRenderRange(World.cfg.movieChunksRange)
  self.timeline:start(tick)
end

function Movie:update(tick)
  if self.timeline then
    return self.timeline:update(tick)
  end
  return false
end

function Movie:stop()
  if self.timeline then
    self.timeline:stop()
    self.timeline = nil
  end
  Blockman.instance.gameSettings:setSpecifiedRenderRange(0)
end

function Movie:hideAllEntity(hide)
  local allEntity = World.CurWorld:getAllEntity()
  for _, _entity in pairs(allEntity) do
    if not (not _entity.isPlayer or _entity.isMainPlayer) or _entity:cfg().isRobot or _entity:cfg().petType then
      _entity:setEntityHide(hide)
    end
  end
end

return Movie
