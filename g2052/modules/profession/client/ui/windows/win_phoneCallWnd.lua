local WinPhoneCallWnd = M

function WinPhoneCallWnd:init()
  WinBase.init(self, "PhoneCallWnd.json")
  self._allEvent = {}
  self:initUI()
  self.itemCache = {}
  self.itemList = {}
  self.refreshTimes = 0
  self.lastRefresh = -999999
  self:initEvent()
end

function WinPhoneCallWnd:initUI()
  self.lytContent = self:child("PhoneCallWnd-content")
end

function WinPhoneCallWnd:initEvent()
  Lib.subscribeEvent(Event.EVENT_UPDATE_PHONE_CALL_ICON, function(objId, isShow)
    if isShow then
      if not self.itemList[objId] then
        self.itemList[objId] = {
          itemNode = self:getItem(),
          objId = objId
        }
      end
    else
      self:removeOneEffectItem(objId)
    end
  end)
end

function WinPhoneCallWnd:subscribeEvent()
end

function WinPhoneCallWnd:initView()
  if self.callIconTimer then
    self.callIconTimer()
    self.callIconTimer = nil
  end
  self.refreshTimes = 0
  self.lastRefresh = -999999
  local time = 1
  self.callIconTimer = World.Timer(time, function()
    self:updateItemShow(time)
    return true
  end)
end

function WinPhoneCallWnd:updateItemShow(time)
  local myPos = Me:getPosition()
  local outsideList
  self.refreshTimes = self.refreshTimes + time
  for objId, val in pairs(self.itemList) do
    local entity = World.CurWorld:getEntity(objId)
    if entity and entity:isValid() then
      local entityPos = entity:getPosition()
      self:updateEffectInfo(val, myPos, entityPos, entity.map.name)
      self.itemList[objId].lastRefresh = -9999999
    elseif World.cfg.phoneProfession.isKeepShowTopEffect then
      outsideList = outsideList or {}
      table.insert(outsideList, objId)
    else
      self:rangeShowUIOnVPos(val.itemNode)
    end
  end
  if outsideList and self.refreshTimes - self.lastRefresh >= World.cfg.phoneProfession.keepShowRefreshTime then
    self.lastRefresh = self.refreshTimes
    Me:sendPacket({
      pid = "GetPlayerServerMapAndPos",
      outsideList = outsideList
    }, function(ret)
      if ret then
        for objId, val in pairs(self.itemList) do
          local entity = World.CurWorld:getEntity(objId)
          if entity and entity:isValid() then
          elseif ret[objId] then
            self:updateEffectInfo(val, myPos, ret[objId].pos, ret[objId].mapName)
          else
            self:rangeShowUIOnVPos(val.itemNode)
          end
        end
      end
    end)
  end
end

function WinPhoneCallWnd:updateEffectInfo(val, myPos, otherPos, otherMapName)
  local dis = Lib.getPosDistance(myPos, otherPos)
  val.itemNode:invoke("updateDistanceShow", dis)
  local pos = Lib.copyTable1(otherPos)
  pos.y = pos.y + World.cfg.phoneProfession.topEffectHeight
  self:rangeShowUIOnVPos(val.itemNode, pos, otherMapName)
end

function WinPhoneCallWnd:removeOneEffectItem(objId)
  if self.itemList[objId] then
    self.itemList[objId].itemNode:SetVisible(false)
    table.insert(self.itemCache, self.itemList[objId].itemNode)
    self.itemList[objId] = nil
  end
end

function WinPhoneCallWnd:getItem()
  if #self.itemCache > 0 then
    return table.remove(self.itemCache, 1)
  end
  local item = UIMgr:new_widget("phoneCallItem")
  self:root():AddChildWindow(item)
  return item
end

function WinPhoneCallWnd:rangeShowUIOnVPos(ui, pos, mapName)
  if not ui then
    return
  end
  if not pos then
    ui:SetVisible(false)
    return
  end
  if not mapName then
    ui:SetVisible(false)
    return
  end
  local minDis = 0
  local maxDis = 999999999 or math.huge - 1
  
  local function resultTimer()
    if Me.map.name ~= mapName then
      ui:SetVisible(false)
      return
    end
    local p1 = pos
    local p2 = Me:getPosition()
    local dis = Lib.getPosDistanceSqr(p1, p2)
    if dis < minDis or dis >= maxDis then
      ui:SetVisible(false)
      return true
    end
    ui:SetLevel(math.floor(dis))
    ui:SetVisible(true)
  end
  
  resultTimer()
  
  local function stopFollowFunc()
    UILib.showUIOnVector3Pos(ui, {
      x = pos.x,
      y = pos.y,
      z = pos.z
    }, {
      uiSize = {
        width = ui:GetWidth(),
        height = ui:GetHeight()
      },
      autoScale = false,
      anchorX = 0,
      anchorY = 0
    })
  end
  
  stopFollowFunc()
end

function WinPhoneCallWnd:onHide()
  UI:closeWnd("phoneCallWnd")
end

function WinPhoneCallWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("phoneCallWnd")
    end
  else
    self:onHide()
  end
end

function WinPhoneCallWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinPhoneCallWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.callIconTimer then
    self.callIconTimer()
    self.callIconTimer = nil
  end
end

return WinPhoneCallWnd
