local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\229\164\150\232\167\130/\228\189\147\229\158\139\229\162\158\229\138\1600.05"] = function(self)
  local actorScale = self:getShapeScale()
  if actorScale >= Define.SHAPE_SCALE_MAX then
    Lib.logDebug("had been max shape scale")
    return
  end
  self:setShapeScale(actorScale + 0.05)
end
GMItem["\229\164\150\232\167\130/\228\189\147\229\158\139\229\135\143\229\176\1450.05"] = function(self)
  local actorScale = self:getShapeScale()
  if actorScale <= Define.SHAPE_SCALE_MIN then
    Lib.logDebug("had been min shape scale")
    return
  end
  self:setShapeScale(actorScale - 0.05)
end
GMItem["\229\164\150\232\167\130/\230\155\180\230\150\176\228\184\138\232\186\171"] = function(self)
  local skinPartData = {clothes_tops = 10}
  self:changeSkinPart(skinPartData)
end
GMItem["\229\164\150\232\167\130/\233\154\143\230\156\186\232\161\163\230\156\141"] = function(self)
  self:onDressUp(nil, nil, {
    [1] = "12001"
  })
end
GMItem["\229\164\150\232\167\130/\230\159\147\229\164\180\229\143\145"] = function(self)
  self:triggerColorSelect(nil, nil, {
    "custom_hair"
  })
end
