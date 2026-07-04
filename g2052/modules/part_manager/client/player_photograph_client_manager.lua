local PlayerPhotographManager = T(Lib, "PlayerPhotographManager")

function PlayerPhotographManager:init()
  self.photographList = {}
  self.playerPictureUI = {}
  self:startCheckDistanceTick()
end

function PlayerPhotographManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("PlayerPhotographManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("PlayerPhotographManager/checkDistanceTick")
    return true
  end)
end

function PlayerPhotographManager:checkDistanceTick()
  local playerPos = Me:getPosition()
  for partID, info in pairs(self.photographList) do
    if info and info.viewDistance > 0 then
      local isInRange = Lib.getPosDistance(playerPos, info.position) <= info.viewDistance
      local needShow = isInRange and World.CurMap.name == info.mapName
      if self.playerPictureUI[partID] and not needShow then
        self:closePictureUI(partID)
      elseif not self.playerPictureUI[partID] and needShow then
        self:showPictureUI(partID)
      end
    end
  end
end

function PlayerPhotographManager:updatePlayerPhotographShow(packet)
  if packet.allPhotographInfo then
    self.photographList = packet.allPhotographInfo
    for partId, ui in pairs(self.playerPictureUI) do
      if self.photographList[partId] then
        self.playerPictureUI[partId]:initView(self.photographList[partId])
      else
        self:closePictureUI(partId)
      end
    end
  elseif packet.partID then
    self.photographList[packet.partID] = packet.curPhotographInfo
    if self.playerPictureUI[packet.partID] then
      if self.photographList[packet.partID] then
        self.playerPictureUI[packet.partID]:initView(self.photographList[packet.partID])
      else
        self:closePictureUI(packet.partID)
      end
    end
  end
end

function PlayerPhotographManager:showPictureUI(partID)
  if not self.photographList[partID] then
    return
  end
  local uiInfo = self.photographList[partID]
  if not self.playerPictureUI[partID] then
    local uiName = "playerPicture"
    local pictureUIKey = uiName .. partID
    self.playerPictureUI[partID] = UI:openSceneWnd(pictureUIKey, uiName, uiInfo.width / 64, uiInfo.height / 64, uiInfo.rotate, uiInfo.position, self.photographList[partID])
  else
    self.playerPictureUI[partID]:initView(uiInfo)
  end
end

function PlayerPhotographManager:closePictureUI(partID)
  if self.playerPictureUI[partID] then
    local pictureUIKey = "playerPicture" .. partID
    UI:closeSceneWnd(pictureUIKey)
    self.playerPictureUI[partID] = nil
  end
end

PlayerPhotographManager:init()
