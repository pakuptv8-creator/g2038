local class = require("common.3rd.middleclass.middleclass")
local Command = class("Command")

function Command:initialize(targets)
  self.targets = targets
end

function Command:execute()
end

function Command:update(params)
end

function Command:undo()
end

function Command:redo()
end

return Command
