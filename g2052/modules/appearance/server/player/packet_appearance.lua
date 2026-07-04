local DyeingStatusMgr = T(Lib, "DyeingStatusMgr")
local handles = T(Player, "PackageHandlers")
local AppearanceConfig = T(Config, "AppearanceConfig")

function handles:roleChangeSkin(packet)
  self:doRoleChangeSkin(packet)
end

function handles:roleResetSkin(packet)
  self:doResetRoleSkin(packet.opOrder)
end

function handles:changeShapeScale(packet)
  local action = packet.action
  if DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    local giantSetting = World.cfg.dramaSetting.giantSetting
    local actorScale = self:getGiantScale()
    local step = tonumber(giantSetting.stepShapeScale)
    local newScale = actorScale
    if action == "add" then
      newScale = actorScale + step
    elseif action == "sub" then
      newScale = actorScale - step
    end
    self:setGiantScale(newScale)
  else
    local actorScale = self:getShapeScale()
    local step = tonumber(World.cfg.shapeScaleSetting.step)
    local newScale = actorScale
    if action == "add" then
      newScale = actorScale + step
    elseif action == "sub" then
      newScale = actorScale - step
    end
    self:setShapeScale(newScale)
  end
end

function handles:reqDyeingStatus(packet)
  local userId = packet.userId
  if not userId then
    return
  end
  local player = Game.GetPlayerByUserId(userId)
  if not player or not player:isValid() then
    return
  end
  local dyeingStatus = DyeingStatusMgr:getStatus(userId)
  if not dyeingStatus or next(dyeingStatus) == nil then
    return
  end
  local curSkin = player:data("skin")
  local data = {}
  for partName, color in pairs(dyeingStatus) do
    data[#data + 1] = {
      objID = player.objID,
      color = color,
      masterSlaveName = partName .. "." .. curSkin[partName]
    }
  end
  if 0 < #data then
    self:sendPacket({
      pid = "syncStatusToClient",
      data = data
    })
  end
end
