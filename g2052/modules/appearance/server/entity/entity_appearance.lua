local AppearanceConfig = T(Config, "AppearanceConfig")
local DyeingStatusMgr = T(Lib, "DyeingStatusMgr")
local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function EntityServer:parseNewSkinData(skinDataChange)
  local shapeInfo = self:getShapeInfo()
  local newSkinData = Lib.copyTable1(shapeInfo)
  local originalSkin = self:getOriginalSkin()
  local exclusiveParts = self:getExclusiveParts() or {}
  local curSkin = self:data("skin")
  local conflictNames = {}
  local hideSkinData = {}
  for i, v in pairs(newSkinData) do
    local conflictParts = AppearanceConfig:getConflictPartsByPart(i, v)
    if conflictParts and next(conflictParts) then
      for _, vv in pairs(conflictParts) do
        conflictNames[vv] = {parent = i}
        hideSkinData[vv] = "0"
      end
    end
    local conflictOriginal = AppearanceConfig:getConflictOriginal(i, v)
    if conflictOriginal and next(conflictOriginal) then
      for _, vv in pairs(conflictOriginal) do
        if newSkinData[vv] == "0" or newSkinData[vv] == 0 or curSkin[vv] == "0" or curSkin[vv] == 0 then
          newSkinData[vv] = originalSkin[vv]
        end
      end
    end
  end
  for i, v in pairs(hideSkinData) do
    newSkinData[i] = v
  end
  if originalSkin.custom_suits and type(originalSkin.custom_suits) == "table" and next(originalSkin.custom_suits) ~= nil then
    if newSkinData.custom_suits and type(newSkinData.custom_suits) == "string" and newSkinData.custom_suits ~= "" and next(exclusiveParts) ~= nil then
      for _, exclusiveName in pairs(exclusiveParts) do
        if exclusiveName ~= "null" and (not newSkinData[exclusiveName] or newSkinData[exclusiveName] == 0) then
          newSkinData[exclusiveName] = 1
        end
      end
    end
    local needTakeOffSuit = false
    if not newSkinData.custom_suits or type(newSkinData.custom_suits) ~= "string" or newSkinData.custom_suits == "" then
      for _, exclusiveName in pairs(exclusiveParts) do
        if newSkinData[exclusiveName] and newSkinData[exclusiveName] ~= 1 and newSkinData[exclusiveName] ~= 0 then
          needTakeOffSuit = true
          break
        end
      end
      if needTakeOffSuit then
        newSkinData.custom_suits = {}
        for _, exclusiveName in pairs(exclusiveParts) do
          if exclusiveName ~= "null" and not newSkinData[exclusiveName] then
            newSkinData[exclusiveName] = 1
          end
        end
      end
    end
  end
  local shapeInfoRemove = {}
  if skinDataChange then
    for i, v in pairs(skinDataChange) do
      if conflictNames[i] then
        local parent = conflictNames[i].parent
        if parent == "custom_suits" then
          newSkinData[parent] = {}
        else
          newSkinData[parent] = ""
        end
        shapeInfoRemove[parent] = true
        for name, vv in pairs(conflictNames) do
          if vv.parent == parent then
            newSkinData[name] = originalSkin[name]
          end
        end
      end
      if newSkinData[i] then
        local preConflict = AppearanceConfig:getConflictPartsByPart(i, newSkinData[i])
        if preConflict and next(preConflict) then
          for _, vv in pairs(preConflict) do
            newSkinData[vv] = originalSkin[vv]
          end
        end
      end
      newSkinData[i] = v
      local conflictParts = AppearanceConfig:getConflictPartsByPart(i, v)
      if conflictParts and next(conflictParts) then
        for _, vv in pairs(conflictParts) do
          newSkinData[vv] = "0"
        end
      end
      if i == "custom_suits" then
        if type(v) == "table" and next(v) ~= nil then
          for name, v in pairs(conflictNames) do
            if v.parent == "custom_suits" then
              newSkinData[name] = originalSkin[name]
            end
          end
          for _, exclusiveName in pairs(exclusiveParts) do
            if exclusiveName ~= "null" then
              newSkinData[exclusiveName] = 0
            end
          end
        elseif type(v) == "string" then
          if originalSkin.custom_suits and type(originalSkin.custom_suits) == "table" and next(originalSkin.custom_suits) ~= nil then
            Lib.logDebug("exclusiveParts: ", Lib.v2s(exclusiveParts))
            Lib.logDebug("newSkinData: ", Lib.v2s(newSkinData))
            for _, exclusiveName in pairs(exclusiveParts) do
              if exclusiveName ~= "null" and (not newSkinData[exclusiveName] or newSkinData[exclusiveName] == 0) then
                newSkinData[exclusiveName] = 1
              end
            end
          end
        elseif type(v) == "table" and next(v) == nil and curSkin.custom_suits and type(curSkin.custom_suits) == "string" then
          for name, v in pairs(conflictNames) do
            if v.parent == "custom_suits" then
              newSkinData[name] = originalSkin[name]
            end
          end
        end
      else
        local IsExclusiveName = false
        for _, name in pairs(exclusiveParts) do
          if i == name then
            IsExclusiveName = true
            break
          end
        end
        if IsExclusiveName then
          if not newSkinData.custom_suits or type(newSkinData.custom_suits) ~= "string" then
            if v == 0 then
              if originalSkin.custom_suits and type(originalSkin.custom_suits) == "table" and next(originalSkin.custom_suits) ~= nil then
                local canRevertToSuit = true
                for _, exclusiveName in pairs(exclusiveParts) do
                  if exclusiveName ~= "null" and exclusiveName ~= i and (newSkinData[exclusiveName] and newSkinData[exclusiveName] ~= 0 and newSkinData[exclusiveName] ~= 1 or curSkin[exclusiveName] and curSkin[exclusiveName] ~= 0 and curSkin[exclusiveName] ~= 1) then
                    canRevertToSuit = false
                    break
                  end
                end
                if canRevertToSuit then
                  for _, exclusiveName in pairs(exclusiveParts) do
                    if exclusiveName ~= "null" and exclusiveName ~= i then
                      newSkinData[exclusiveName] = 0
                    end
                  end
                  newSkinData.custom_suits = originalSkin.custom_suits
                end
              end
            else
              newSkinData.custom_suits = {}
              for _, exclusiveName in pairs(exclusiveParts) do
                if exclusiveName ~= "null" and not newSkinData[exclusiveName] then
                  newSkinData[exclusiveName] = 1
                end
              end
            end
          elseif v == 0 then
            newSkinData[i] = 1
          end
        end
      end
    end
  end
  for i, v in pairs(newSkinData) do
    local conflictParts = AppearanceConfig:getConflictPartsByPart(i, v)
    if conflictParts and next(conflictParts) then
      for _, vv in pairs(conflictParts) do
        newSkinData[vv] = "0"
      end
    end
    local conflictOriginal = AppearanceConfig:getConflictOriginal(i, v)
    if conflictOriginal and next(conflictOriginal) then
      for _, vv in pairs(conflictOriginal) do
        if not newSkinData[vv] or newSkinData[vv] == originalSkin[vv] then
          newSkinData[vv] = "0"
        end
      end
    end
  end
  return newSkinData, shapeInfoRemove
end

function EntityServer:doResetRoleSkin(opOrder)
  local originalSkin = self:getOriginalSkin()
  local oldSkin = Lib.copyTable1(originalSkin)
  if Lib.isSameTable(oldSkin.skin_color or {}, {
    0,
    0,
    0,
    0
  }) then
    oldSkin.skin_color = {
      1,
      1,
      1,
      0
    }
  end
  local skin = self:data("skin")
  for master, v in pairs(skin) do
    if not oldSkin[master] then
      oldSkin[master] = ""
    end
  end
  local skinQueue = self.skinQueue
  for _, queue in ipairs(skinQueue or {}) do
    for k, v in pairs(queue.value or {}) do
      oldSkin[k] = v
    end
  end
  self:changeSkin(oldSkin, nil, opOrder)
  self:clearShapeInfo()
  DyeingStatusMgr:resetStatus(self)
end

function EntityServer:dyeing(partName, color)
  local curSkin = self:data("skin")
  if type(curSkin[partName]) == "table" then
    return
  end
  local packet = {
    pid = "dyeing",
    objID = self.objID,
    masterSlaveName = partName .. "." .. curSkin[partName],
    color = color
  }
  self:sendPacketToTracking(packet, true)
  DyeingStatusMgr:setStatus(self.platformUserId, partName, color)
end

function EntityServer:changeSkin(skinData, sync, opOrder)
  local mySkin = self:data("skin")
  for k, v in pairs(skinData) do
    mySkin[k] = v
  end
  local packet = {
    pid = "SkinChange",
    objID = self.objID,
    skinData = mySkin,
    opOrder = opOrder
  }
  self:sendPacketToTracking(packet, true)
end
