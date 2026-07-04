local CareerBase = require("common.career.career_base")
local CareerRobber = Lib.class("CareerRobber", CareerBase)

function CareerRobber:init()
  self.type = Define.CareerType.Robber
end

function CareerRobber:initSpecialEvent()
end

return CareerRobber
