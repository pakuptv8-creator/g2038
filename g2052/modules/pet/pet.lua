local PetConfig = require("common.config.pet_config")
PetConfig:init()
require("common.config.pet_status_config")
require("common.event_pet")
require("common.define_pet")
require("common.entity_pet")
local PetMgr = require("common.pet_mgr")
if World.isClient then
  require("client.player.player_pet")
  require("client.player.packet_pet")
  require("client.entity.entity_pet")
  require("client.entity.entity_value_func_pet")
  require("client.interaction.status_checker")
  require("client.gate_pet")
  require("client.gm_pet")
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    if info.objID ~= Me.objID then
      return
    end
    local isActivityCanShow = Me:isPeakDayActivityCanShow()
    if isActivityCanShow and not Me:hasPeakDayPetReceived() then
      if not Me:hasPeakDayShowWndToday() then
        UI:getWnd("peakDay"):onShow()
        Me:sendPacket({
          pid = "setPeakDayShowWndDayC2S"
        })
      end
      Lib.emitEvent(Event.EVENT_UPDATE_PEAK_DAY_BTN, true)
    end
  end)
else
  require("server.player.player_pet")
  require("server.player.packet_pet")
  require("server.entity.entity_pet")
  require("server.interaction.player_interact_with_pet")
  require("server.interaction.player_pet_interact")
  require("server.gate_pet")
  require("server.gm_pet")
end
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    print("pet init data")
    PetMgr:initPetListData(entity)
  else
  end
end

function handlers.ENTITY_LEAVE(context)
  local player = context.obj1
  if not player.isPlayer then
    return
  end
  local petObjId = player:getCurCarryPetObjId()
  if petObjId and petObjId ~= 0 then
    local entity = World.CurWorld:getEntity(petObjId)
    if entity and entity:isValid() then
      entity:destroy()
      player:setCurCarryPetObjId(0)
    end
  end
  local petId = player:getCurCarryPetId()
  if petId ~= 0 then
    player:reportChildData(petId)
  end
end

function handlers.SKILL_CAST(context)
  local player = context.obj1
  if not (player and player:isValid()) or not player.isPlayer then
    return
  end
  if context.fullName == "myplugin/lift_down_pet" then
    local petObjId = player:getCurCarryPetObjId()
    local entity = World.CurWorld:getEntity(petObjId)
    if entity then
      local passengers = player:data("passengers")
      for _, objId in pairs(passengers) do
        if objId == petObjId then
          entity:rideOn()
          if context.pos then
            entity:setPosition(context.pos + Lib.v3(0, 1, 0))
          end
          break
        end
      end
    end
    player:removeSkill("myplugin/lift_down_pet")
  end
end

function handlers.entity_click_client(objID)
  if not World.isClient then
    return
  end
  local objId_pet = Me:getCurCarryPetObjId()
  if objId_pet == objID then
    local StatusChecker = T(Lib, "StatusChecker")
    StatusChecker:statusRemoveConditionCheck(objID, Define.PET_STATUS_REMOVE_CONDITION.Clicked)
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
