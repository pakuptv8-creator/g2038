local PartManagerShow = T(Lib, "PartManagerShow")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local InteractEventConfig = T(Config, "InteractEventConfig")

function PartManagerShow:init()
  self:createRootPart()
  self.hidePoolList = {}
end

function PartManagerShow:createRootPart()
  self.rootPart = Instance.Create("Model")
end

function PartManagerShow:updateParentChildList(parent, nodeList)
  local parentInsId = parent:getInstanceID()
  for partID, partInfo in pairs(self.hidePoolList) do
    if partInfo.parentInsId == parentInsId then
      table.insert(nodeList, Instance.getByInstanceId(partInfo.partID))
    end
  end
end

function PartManagerShow:updatePartShowByParent(partName, parent)
  local parentInsId = parent:getInstanceID()
  for partID, partInfo in pairs(self.hidePoolList) do
    if partInfo.parentInsId == parentInsId and partInfo.partName == partName then
      self:onShowPopPool(partID)
      return
    end
  end
  local count = parent:getChildrenCount()
  for i = 0, count - 1 do
    local childPart = parent:getChildAt(i)
    if childPart and childPart:isValid() and childPart.properties and childPart.properties.name and partName == childPart.properties.name then
      self:onHidePushPool(childPart)
      return
    end
  end
end

function PartManagerShow:updatePartShowState(part)
  local partID = part:getInstanceID()
  if self.hidePoolList[partID] then
    self:onShowPopPool(partID)
  else
    self:onHidePushPool(part)
  end
end

function PartManagerShow:onHidePushPool(part)
  local partID = part:getInstanceID()
  if self.hidePoolList[partID] then
    return
  end
  local parent = part:getParent()
  local parentInsId = parent and parent:isValid() and parent:getInstanceID() or nil
  local partName = ""
  if part.properties and part.properties.name then
    partName = part.properties.name
  end
  local partInfo = {
    parentInsId = parentInsId,
    partName = partName,
    initPos = part:getPosition(),
    partID = partID
  }
  self.hidePoolList[partID] = partInfo
  self:removeChildPartInteract(part)
  part:setParent(self.rootPart)
end

function PartManagerShow:removeChildPartInteract(part)
  if not part or not part:isValid() then
    return
  end
  local count = part:getChildrenCount()
  for i = 0, count - 1 do
    local childPart = part:getChildAt(i)
    self:removeChildPartInteract(childPart)
  end
  PartManagerHelper:removePartInteractState(part)
end

function PartManagerShow:onShowPopPool(partID)
  if self.hidePoolList[partID] then
    local partInfo = self.hidePoolList[partID]
    local part = Instance.getByInstanceId(partInfo.partID)
    local parent = Instance.getByInstanceId(partInfo.parentInsId)
    part:setParent(parent)
    part:setPosition(partInfo.initPos)
    self.hidePoolList[partID] = nil
  end
end

function PartManagerShow:initSecretBlackboardPart(part)
  local cfg = InteractEventConfig:getCfgById(part.name)
  if not (cfg and cfg.precondition) or not cfg.precondition.paramArr then
    return
  end
  part.isFinishCollection = false
  local tbPartList = Lib.split(cfg.params[1], "#")
  local isFinishInit = true
  for i = 1, #tbPartList do
    local itemId = tonumber(cfg.precondition.paramArr[i])
    local decPart = Instance.getByInstanceId(tonumber(tbPartList[i]))
    if decPart and decPart:isValid() and decPart:getParent() then
      self:onHidePushPool(decPart)
      if not part.curShowPart then
        part.curShowPart = {}
      end
      part.curShowPart[itemId] = 0
    else
      print("error:decPart is not valid", tbPartList[i])
      isFinishInit = false
    end
  end
  if cfg.params[2] and cfg.params[2] ~= "" then
    local transformPartId = Lib.split(cfg.params[2], ":")
    if transformPartId[2] then
      local transformPart = Instance.getByInstanceId(tonumber(transformPartId[2]))
      if transformPart and transformPart:isValid() and transformPart:getParent() then
        self:onHidePushPool(transformPart)
      else
        isFinishInit = false
        print("error:transformPart is not valid", cfg.params[2])
      end
    end
  end
  if not isFinishInit then
    World.Timer(5, function()
      if part and part:isValid() then
        local isFinis = true
        for i = 1, #tbPartList do
          local itemId = tonumber(cfg.precondition.paramArr[i])
          local decPart = Instance.getByInstanceId(tonumber(tbPartList[i]))
          if decPart and decPart:isValid() and decPart:getParent() then
            self:onHidePushPool(decPart)
            if not part.curShowPart then
              part.curShowPart = {}
            end
            part.curShowPart[itemId] = 0
          else
            print("error:decPart is not valid", tbPartList[i])
            isFinis = false
          end
        end
        if cfg.params[2] and cfg.params[2] ~= "" then
          local transformPartId = Lib.split(cfg.params[2], ":")
          if transformPartId[2] then
            local transformPart = Instance.getByInstanceId(tonumber(transformPartId[2]))
            if transformPart and transformPart:isValid() and transformPart:getParent() then
              self:onHidePushPool(transformPart)
            else
              isFinis = false
              print("error:transformPart is not valid", cfg.params[2])
            end
          end
        end
        if isFinis then
          return false
        end
      else
        return false
      end
      return true
    end)
  end
end

PartManagerShow:init()
