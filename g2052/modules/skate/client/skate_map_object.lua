local SkateMapObject = T(Lib, "SkateMapObject")
local PartType = Define.PartType

function SkateMapObject:init()
  self.mapObjTypeDict = {}
end

function SkateMapObject:recordPart(partName, partType)
  local pType
  if partType == "Box" then
    pType = PartType.Box
  elseif partType == "Jump" then
    pType = PartType.Jump
  else
    pType = PartType.Other
  end
  self.mapObjTypeDict[partName] = pType
  return pType
end

function SkateMapObject:getObjectType(partName)
  return self.mapObjTypeDict[partName]
end

SkateMapObject:init()
return SkateMapObject
