local CommandFactory = T(Lib, "CommandFactory")
local OperationManager = T(Lib, "OperationManager")

function OperationManager:init()
  self.operationCommands = {}
end

function OperationManager:addOperation(instanceId, act, params, player)
  local vehicle = Instance.getByInstanceId(instanceId)
  if not vehicle then
    return
  end
  if not self.operationCommands[instanceId] then
    self.operationCommands[instanceId] = {}
  end
  if not self.operationCommands[instanceId][act] then
    local command = CommandFactory.createCommand(act, vehicle)
    if command then
      self.operationCommands[instanceId][act] = command
    end
  end
  if self.operationCommands[instanceId][act] then
    local opCommand = self.operationCommands[instanceId][act]
    if not opCommand:getActiveStatus() then
      opCommand:execute(params, player)
    else
      opCommand:undo(player)
    end
    return opCommand:getActiveStatus()
  else
    Lib.logDebug("error no target command, act name is " .. act)
  end
end

function OperationManager:getCommandStatus(instanceId, act)
  if self.operationCommands[instanceId] and self.operationCommands[instanceId][act] then
    local command = self.operationCommands[instanceId][act]
    return command:getActiveStatus(), command
  end
end

function OperationManager:getCommand(instanceId, act)
  if self.operationCommands[instanceId] and self.operationCommands[instanceId][act] then
    local command = self.operationCommands[instanceId][act]
    return command
  end
end

function OperationManager:removeCommands(instanceId)
  if self.operationCommands[instanceId] then
    self.operationCommands[instanceId] = nil
  end
end

function OperationManager:getAllCommandStatus(instanceId)
  if self.operationCommands[instanceId] then
    local data = {}
    for act, command in pairs(self.operationCommands[instanceId]) do
      data[act] = command:getCommandStatus()
    end
    return data
  end
end

OperationManager:init()
return OperationManager
