local setting = require("common.setting")
local PartCfg = setting:mod("part")
local SelectState = {}

function SelectState:enteredState()
  self:setSelection(true)
end

function SelectState:exitedState()
end

return SelectState
