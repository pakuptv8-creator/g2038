local CareerBase = require("common.career.career_base")
local CareerPolice = Lib.class("CareerPolice", CareerBase)

function CareerPolice:init()
  self.type = Define.CareerType.Police
end

function CareerPolice:initSpecialEvent()
end

return CareerPolice
