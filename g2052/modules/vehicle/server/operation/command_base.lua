local CommandBase = class("CommandBase")

function CommandBase:ctor(car)
  self.car = car
  self.act = ""
  self.isActive = false
end

function CommandBase:execute(params)
  self.isActive = true
end

function CommandBase:undo()
  self.isActive = false
end

function CommandBase:getDuration()
  return -1
end

function CommandBase:getActiveStatus()
  return self.isActive
end

function CommandBase:getCommandStatus()
  return {
    isActive = self.isActive
  }
end

return CommandBase
