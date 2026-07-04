local uuid = require("common.uuid")
local MessageConfig = T(Config, "MessageConfig")
local MessageNoticeManager = T(Lib, "MessageNoticeManager")

function MessageNoticeManager:init()
  self.messageNoticeList = {}
  self.messageNoticePopStampList = {}
  self.popTimer = {}
end

function MessageNoticeManager:broadcastNotice(id, replaceStr)
  self:pushMessageNotice(id, Game.GetAllPlayers(), replaceStr)
end

function MessageNoticeManager:pushMessageNotice(id, receiverList, replaceStr)
  if not (id and receiverList) or not next(receiverList) then
    return
  end
  local cfg = MessageConfig:getCfgById(id)
  if not cfg then
    return
  end
  local _uuid = uuid()
  for _, player in pairs(receiverList) do
    local playerId = player.platformUserId
    if player and player:isValid() then
      if not self.messageNoticeList[playerId] then
        self.messageNoticeList[playerId] = {}
      end
      local checkCD = self:checkPushMessageCD(id, player)
      local insertIndex = self:getInsertIndex(playerId, id)
      if checkCD and insertIndex then
        local noticeObj = {}
        noticeObj.id = id
        noticeObj.uuid = _uuid
        noticeObj.level = cfg.level
        noticeObj.white = cfg.white
        noticeObj.replaceStr = replaceStr
        noticeObj.pushTimeStamp = os.time()
        table.insert(self.messageNoticeList[playerId], insertIndex, noticeObj)
        if #self.messageNoticeList[playerId] > 50 then
          print("!!!!!!!!!!!!!!!!!!!!! #self.messageNoticeList[playerId]: num ", #self.messageNoticeList[playerId])
        end
        if self.popTimer[playerId] == nil then
          self:popMessageNotice(playerId)
        end
      end
    end
  end
  return _uuid
end

function MessageNoticeManager:deleteMessageNotice(uuid)
  if not uuid then
    return
  end
  for _, list in pairs(self.messageNoticeList) do
    for i = 1, #list do
      local obj = list[i]
      if obj.uuid == uuid then
        table.remove(list, i)
        break
      end
    end
  end
end

function MessageNoticeManager:popMessageNotice(playerId)
  if not playerId then
    return
  end
  local list = self.messageNoticeList[playerId]
  if not list or next(list) == nil then
    return
  end
  local messageNotice = table.remove(list, 1)
  if not self.messageNoticePopStampList[playerId] then
    self.messageNoticePopStampList[playerId] = {}
  end
  self.messageNoticePopStampList[playerId][messageNotice.id] = messageNotice.pushTimeStamp
  local player = Game.GetPlayerByUserId(playerId)
  if player and player:isValid() then
    self:clearTimer(playerId)
    local cfg = MessageConfig:getCfgById(messageNotice.id)
    if cfg then
      self.popTimer[playerId] = World.Timer(cfg.showTime * 20, function()
        self:clearTimer(playerId)
        self:popMessageNotice(playerId)
      end)
      player:sendPacket({
        pid = "SendMessageNoticeS2C",
        messageNotice = messageNotice
      })
    end
  else
    self:clearMessageNotice(playerId)
  end
end

function MessageNoticeManager:clearMessageNotice(playerId)
  if not playerId then
    return
  end
  self.messageNoticeList[playerId] = nil
  self.messageNoticePopStampList[playerId] = nil
  self.clearTimer(playerId)
  print("---------------------------  clearMessageNotice ", playerId)
end

function MessageNoticeManager:clearTimer(playerId)
  if not playerId then
    return
  end
  if self.popTimer[playerId] then
    self.popTimer[playerId]()
    self.popTimer[playerId] = nil
  end
end

function MessageNoticeManager:getInsertIndex(playerId, id)
  local list = self.messageNoticeList[playerId]
  local cfg = MessageConfig:getCfgById(id)
  if list and cfg then
    if next(list) == nil then
      return 1
    end
    for i = 1, #list do
      local obj = list[i]
      if obj.level < cfg.level then
        return i
      end
    end
    return #list + 1
  else
    print("!!!!!!!!!!!!!!!!!!!!!!!  MessageNoticeManager:getInsertIndex error ", playerId, id, list, cfg)
    return nil
  end
end

function MessageNoticeManager:checkPushMessageCD(id, player)
  if not (id and player) or not player:isValid() then
    return false
  end
  local cfg = MessageConfig:getCfgById(id)
  if not cfg then
    return false
  end
  local popStampList = self.messageNoticePopStampList[player.platformUserId]
  if popStampList and popStampList[id] and os.time() - popStampList[id] <= cfg.push_cd then
    return false
  end
  local list = self.messageNoticeList[player.platformUserId]
  if not list or next(list) == nil then
    return true
  end
  for index = #list, 1, -1 do
    local msg = list[index]
    if msg.id == id then
      if os.time() - msg.pushTimeStamp <= cfg.push_cd then
        return false
      end
      break
    end
  end
  return true
end

MessageNoticeManager:init()
