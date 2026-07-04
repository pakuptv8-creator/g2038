local CLASS_COMMAND = {
  headlight = "server.operation.headlight_command",
  honk = "server.operation.honk_command",
  lock = "server.operation.lock_command",
  music = "server.operation.music_command",
  doubleFlash = "server.operation.double_flash_command",
  alarm = "server.operation.alarm_command",
  firstAid = "server.operation.first_aid_command",
  squirtWater = "server.operation.squirt_water_command",
  armTurn = "server.operation.arm_turn_command",
  stopSign = "server.operation.stop_sign_command"
}
local CommandFactory = T(Lib, "CommandFactory")

function CommandFactory.createCommand(act, vehicle)
  if CLASS_COMMAND[act] then
    local class = require(CLASS_COMMAND[act])
    local command = class.new(vehicle)
    return command
  else
    Lib.logDebug("no command named: ", act)
  end
end

return CommandFactory
