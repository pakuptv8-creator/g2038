require("common.config.profession_config")
require("common.event_profession")
require("common.define_profession")
require("common.professionHelper")
require("common.entity_profession")
require("common.config.profession_recommend_config")
if World.isClient then
  require("client.player.player_profession")
  require("client.player.packet_profession")
  require("client.entity.entity_profession")
  require("client.entity.entity_value_func_profession")
  require("client.gate_profession")
  require("client.gm_profession")
else
  require("server.player.player_profession")
  require("server.player.packet_profession")
  require("server.entity.entity_profession")
  require("server.gate_profession")
  require("server.gm_profession")
end
local handlers = {}
if World.isClient then
  function handlers.openCallProfessionWnd()
    UI:getWnd("phoneCareerWnd"):onShow(true)
  end
else
  local ProfessionalHelper = T(Lib, "ProfessionalHelper")
  
  function handlers.OnPlayerLogin(player)
    player:sendPacket({
      pid = "SyncPlayerName",
      name = player.name
    })
    if player:getNameContent() == "" then
      player:setNameContent(player.name)
    end
  end
  
  function handlers.ENTITY_LEAVE(context)
    local entity = context and context.obj1
    if entity and entity.isPlayer then
      local oldJobId = entity:getProfessionId()
      local oldJobTime = entity:getValue("professionTime")
      if oldJobId ~= 0 then
        local defaultData = {
          job_id = oldJobId,
          job_time = os.time() - oldJobTime
        }
        Plugins.CallTargetPluginFunc("report", "report", "job_call", defaultData, entity)
      end
      ProfessionalHelper:removeSendCallData(entity.objID)
    end
  end
  
  function handlers.updatePlayerProfession(player, professionId, isFromScene)
    player:setProfessionId(tonumber(professionId), isFromScene)
  end
  
  function handlers.resetAsBaseProfession(player, isFromScene)
    player:setProfessionId(Define.CareerType.Base, isFromScene)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
