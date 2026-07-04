local MessageConfig = T(Config, "MessageConfig")
local MessageNoticeManager = T(Lib, "MessageNoticeManager")
local Player = _ENV.Player

function Player:checkSendMessageNoticeCD(messageId)
  if not messageId then
    return false
  end
  if not MessageConfig:needCheckSendCD(messageId) then
    return true
  end
  if not self.sendMessageNoticeStamp then
    return true
  end
  local cd = World.cfg.messageNotice.PlayerSendMessageCD or 5
  return cd <= os.time() - self.sendMessageNoticeStamp
end

function Player:sendMessageNoticeCDRecord(messageId)
  if not messageId then
    return
  end
  if not MessageConfig:needCheckSendCD(messageId) then
    return
  end
  self.sendMessageNoticeStamp = os.time()
end

function Player:onSendMessageNotice(type, part, params, isBreak)
  if not params then
    return
  end
  local receiveList = Game.GetAllPlayers()
  local receiveType = tonumber(params[4])
  local replaceType = tonumber(params[6])
  local replaceStr
  if receiveType and receiveType == 1 then
    local professionId = tonumber(params[5])
    if professionId then
      local newList = {}
      for _, player in pairs(receiveList) do
        if player:getProfessionId() == professionId then
          table.insert(newList, player)
        end
      end
      receiveList = newList
    end
  end
  if replaceType and replaceType == 1 then
    replaceStr = self.name
  end
  if not isBreak then
    if tonumber(params[1]) then
      MessageNoticeManager:pushMessageNotice(tonumber(params[1]), receiveList, replaceStr)
    end
  elseif tonumber(params[2]) == 1 and tonumber(params[3]) then
    MessageNoticeManager:pushMessageNotice(tonumber(params[3]), receiveList, replaceStr)
  end
end
