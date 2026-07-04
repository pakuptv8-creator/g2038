local class = require("common.3rd.middleclass.middleclass")
local PartOperationHelper = class("PartOperationHelper")

function PartOperationHelper:initialize()
  Lib.logDebug("PartOperationHelper:initialize")
end

function PartOperationHelper.static.partCopy(list)
end

function PartOperationHelper.static.partPaste(list)
end

function PartOperationHelper.static.partRepetition(list)
end

return PartOperationHelper
