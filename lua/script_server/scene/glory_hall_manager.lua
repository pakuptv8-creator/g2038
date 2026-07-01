local GloryHallMgr = _ENV.GloryHallMgr
local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")

function GloryHallMgr:init()
  self.doorEntityList = {}
  self.doorNameTxtList = {}
end

function GloryHallMgr:setDoorEntity(gymId, entityObjID)
  self.doorEntityList[gymId] = entityObjID
  if #self.doorEntityList >= 4 and 4 <= #self.doorNameTxtList then
    self:updateDoorsEntityShow()
    self:updateAllDoorsTimeShow()
  end
end

function GloryHallMgr:setDoorNameTxt(gymId, entityObjID)
  self.doorNameTxtList[gymId] = entityObjID
  if #self.doorEntityList >= 4 and #self.doorNameTxtList >= 4 then
    self:updateDoorsEntityShow()
    self:updateAllDoorsTimeShow()
  end
end

function GloryHallMgr:updateDoorsEntityShow()
  local curServerTime = os.time()
  local curWeekDay = os.date("%w", curServerTime)
  local data = PokemonGloryHallConfig:getCfgByOpenDay(curWeekDay)
  local openedDoor = {}
  for _, cfg in pairs(data) do
    openedDoor[cfg.id] = true
  end
  for gymId, objID in pairs(self.doorEntityList) do
    local doorEntity = World.CurWorld:getEntity(objID)
    if openedDoor[gymId] then
      doorEntity:addBuff("myplugin/entity_hide_buff")
    else
      doorEntity:addBuff("myplugin/entity_show_buff")
    end
  end
  for gymId, objID in pairs(self.doorNameTxtList) do
    local doorNameEntity = World.CurWorld:getEntity(objID)
    if openedDoor[gymId] then
      doorNameEntity:addBuff("myplugin/entity_hide_buff")
    else
      doorNameEntity:addBuff("myplugin/entity_show_buff")
    end
  end
end

function GloryHallMgr:refreshKickedOutGloryHall(player)
  local map = player.map
  if map.name == World.cfg.gloryHallMap then
    player:doLeaveGloryHall()
    local packet = {
      pid = "pushGloryHallRefresh"
    }
    player:sendPacket(packet)
  elseif player:isInBattle() then
    player.needKickedOutGloryHall = true
  end
end

function GloryHallMgr:updateAllDoorsTimeShow()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and not player.removed then
      local map = player.map
      if map.name == World.cfg.gloryHallMap then
        player:pushClientUpdateGloryDoor()
      end
    end
  end
end

return GloryHallMgr
