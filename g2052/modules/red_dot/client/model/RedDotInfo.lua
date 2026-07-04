local RedDotInfo = Lib.class("RedDotInfo")

function RedDotInfo:ctor()
  self.key = ""
  self.refreshBlock = nil
end

function RedDotInfo:execute(show)
  if self.refreshBlock then
    self.refreshBlock(show)
  end
end

return RedDotInfo
