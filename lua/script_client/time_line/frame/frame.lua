local Frame = Lib.class("Frame")

function Frame:ctor(track, attribute, time)
  self.cfg = attribute
  self.track = track
  self.startTime = self.cfg.startTime
  self.endTime = self.cfg.endTime or time
  self.isLeave = false
end

function Frame:start(tick)
  self.startTick = tick + Lib.timeToTick(self.startTime)
  self.endTick = self.startTick + Lib.timeToTick(self.endTime - self.startTime)
end

function Frame:update(tick)
  if tick == self.startTick then
    self:enter(tick)
  elseif tick == self.endTick then
    self:leave(tick)
  elseif tick > self.startTick and tick < self.endTick then
    self:apply(tick)
  end
end

function Frame:stop()
  if not self.isLeave then
    self:leave()
  end
end

function Frame:leave(tick)
  self:onLeave(tick)
  self.isLeave = true
end

function Frame:enter(tick)
end

function Frame:apply(tick)
end

function Frame:onLeave(tick)
end

return Frame
