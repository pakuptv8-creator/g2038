local RedDotModel = Lib.class("RedDotModel")

function RedDotModel:ctor()
  self.key = ""
  self.show = 0
  self.subDots = {}
  self.parent = nil
end

function RedDotModel:hasSubDot()
  return #self.subDots > 0
end

return RedDotModel
