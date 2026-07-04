local ReportAttr = T(Config, "ReportAttr")
local cjson = require("cjson")

function ReportAttr.platform_friends_num(player)
  return Plugins.CallTargetPluginFunc("platform_chat", "getPlayerFriendsNum", player, 0)
end

function ReportAttr.game_friends_num(player)
  return Plugins.CallTargetPluginFunc("platform_chat", "getPlayerFriendsNum", player, 1)
end

function ReportAttr.player_area(player)
  local info = player:getPlayerCurArea()
  if World.isClient then
    return info.name or ""
  else
    return info.name or ""
  end
end

function ReportAttr.item_id(player)
  local inUseProp = player:getInUseProp()
  if inUseProp then
    return inUseProp.itemId
  end
  return 0
end

function ReportAttr.item_time(player)
  local inUseProp = player:getInUseProp()
  if inUseProp and inUseProp.useStamp then
    return os.time() - inUseProp.useStamp
  end
  return 0
end

function ReportAttr.area_name(player)
  local info = player:getPlayerCurArea()
  return info.name or ""
end

function ReportAttr.area_sojourn_time(player)
  local info = player:getPlayerCurArea()
  return info.time and os.time() - info.time or 0
end

function ReportAttr.player_active(player)
  local info = player:getPlayerActive()
  return info.activeType or 1
end

function ReportAttr.chat_count(player)
  return player:getChatCount() or 0
end

function ReportAttr.action_count(player)
  return player.playerDoDanceCount or 0
end

function ReportAttr.job_count(player)
  return player.changeProfessionCount or 0
end

function ReportAttr.house_count(player)
  return player:getHouseCount() or 0
end

function ReportAttr.item_count(player)
  return player:getItemCount() or 0
end

function ReportAttr.car_count(player)
  return player:getUseCarCount() or 0
end

function ReportAttr.child_count(player)
  return player:getUsePetCount() or 0
end

function ReportAttr.appearance_count(player)
  return player:getDressCount() or 0
end

function ReportAttr.suit_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_suits or ""
end

function ReportAttr.coat_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.clothes_tops or ""
end

function ReportAttr.pants_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.clothes_pants or ""
end

function ReportAttr.shoes_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_shoes or ""
end

function ReportAttr.wing_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_wing or ""
end

function ReportAttr.belt_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_back or ""
end

function ReportAttr.hat_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_hat or ""
end

function ReportAttr.hairstyle_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_hair or ""
end

function ReportAttr.face_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_glasses or ""
end

function ReportAttr.phiz_id(player)
  local shapeInfo = player:getShapeInfo()
  return shapeInfo.custom_face or ""
end

function ReportAttr.player_sex(player)
  return player:checkSex() or 1
end

function ReportAttr.client_memory(player)
  if not World.isClient then
    return 0
  end
  local info = cjson.decode(CGame.instance:getShellInterface():getClientInfo())
  local us_memory = Lib.splitString(info.ram_memory or "", " ", true)
  return us_memory[1] or 0
end

function ReportAttr.script_uid(player)
  if World.isClient then
    return
  end
  return Server.CurServer:getGameId()
end

function ReportAttr.a_fps(player)
  return player.afps or 0
end

function ReportAttr.far_clip_level(player)
  return player:getFarClipLevel()
end
