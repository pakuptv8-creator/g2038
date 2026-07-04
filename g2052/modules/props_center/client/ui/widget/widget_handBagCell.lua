local widget_base = require("ui.widget.widget_base")
local WidgetHandBagCell = Lib.derive(widget_base)
local PropsConfig = T(Config, "PropsConfig")

function WidgetHandBagCell:init()
  widget_base.init(self, "HandBagCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHandBagCell:initUI()
  self.lytNormal = self:child("HandBagCell-NormalView")
  self.lytSelect = self:child("HandBagCell-SelectView")
  self.lytEmpty = self:child("HandBagCell-EmptyView")
  self.imgNormalIcon = self:child("HandBagCell-Normal-Icon")
  self.imgSelectIcon = self:child("HandBagCell-Select-Icon")
  self.imgSelect = self:child("HandBagCell-select")
  self.imgDelete = self:child("HandBagCell-delete")
  self.viewTabs = {}
  table.insert(self.viewTabs, self.lytNormal)
  table.insert(self.viewTabs, self.lytSelect)
  table.insert(self.viewTabs, self.lytEmpty)
end

function WidgetHandBagCell:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REMOVE_HAND_BAG_INFO, function(index)
    if index == self.index then
      self:callRemoveItemReq()
    end
  end)
  self:subscribe(self.lytNormal, UIEvent.EventWindowClick, function()
    if self.itemId and self.fun then
      local canUse = self:checkCanUse()
      if canUse then
        self.fun(nil, "Normal", self.index)
      end
    end
  end)
  self:subscribe(self.lytSelect, UIEvent.EventWindowClick, function()
    if self.itemId and self.fun then
      self.fun(nil, "Selected", self.index)
    end
  end)
  self:subscribe(self.lytEmpty, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun(nil, "Empty", self.index, {doNotChangeSelect = true})
    end
  end)
  self:subscribe(self.imgDelete, UIEvent.EventWindowClick, function()
    self:callRemoveItemReq()
  end)
end

function WidgetHandBagCell:callRemoveItemReq()
  if self.index == nil or self.info == nil then
    return
  end
  Me:sendPacket({
    pid = "RemoveHandItem",
    slot = self.index
  })
  if self.info and self.info.itemId then
    local itemId = self.info.itemId
    local itemInfo = PropsConfig:getCfgById(itemId)
    if itemInfo.throwCfgType == "entity" then
      local inUseItem = Me:getInUseProp()
      if (itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem or itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex and inUseItem and inUseItem.index == itemInfo.throwActionIndex) and itemInfo.rideOnPlayerIndex == 0 then
        local packet = {
          pid = "InteractionWithMovementEvent",
          objID = Me.objID,
          params = {
            interactionType = UIEvent.EventWindowTouchUp,
            interactionName = "debark",
            targetObjId = Me.objID
          }
        }
        Me:sendPacket(packet)
      end
    end
  end
end

function WidgetHandBagCell:onDataChanged(data)
  self.data = data
  self.fun = data.clickCb
  self.index = data.index
  for _, view in pairs(self.viewTabs) do
    view:SetVisible(false)
  end
  if data.data and not Lib.table_is_empty(data.data) then
    self.info = data.data
    if self.info.inUse ~= nil and self.info.inUse == false and self.data.select == true then
      self.data.select = false
    end
    self:updateView()
  else
    self.lytEmpty:SetVisible(true)
  end
end

function WidgetHandBagCell:updateView()
  self.itemId = self.info.itemId
  local itemInfo = PropsConfig:getCfgById(self.itemId)
  local view, icon
  if self.data.select then
    view = self.lytSelect
    icon = self.imgSelectIcon
  else
    view = self.lytNormal
    icon = self.imgNormalIcon
  end
  view:SetVisible(true)
  if itemInfo then
    icon:SetImage(itemInfo.icon)
  end
end

function WidgetHandBagCell:empty()
  self.imgIcon:SetImage()
end

function WidgetHandBagCell:checkCanUse()
  local function isInHelicopter()
    if Me.rideOnId and Me.rideOnId > 0 then
      local target = World.CurWorld:getEntity(Me.rideOnId)
      
      if target and target:cfg().isAircraft == true then
        return true
      end
    end
    return false
  end
  
  local itemInfo = PropsConfig:getCfgById(self.itemId)
  if (Me:isSwimming() or isInHelicopter()) and itemInfo.throwCfgType == "entity" and (itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex or itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem) then
    return false
  end
  if isInHelicopter() and itemInfo.isThrowObj == Define.Prop.ThrowObj.Football then
    return false
  end
  if itemInfo.throwCfgType == "entity" and itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem then
    if Me:getInteractCarEnterID() ~= "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
      return false
    end
    if itemInfo.rideOnPlayerIndex > 0 then
      local footPos = Me:getPosition()
      local pos = Me:getEyePos()
      local midPos = Lib.v3(pos.x, (pos.y - footPos.y) / 2 + footPos.y, pos.z)
      local frontPos = Me:getFrontPos(1, false, false)
      local dir = Lib.v3cut(frontPos, pos)
      dir = Lib.v3normalize(dir)
      local dis = 1.5
      if self.itemId == 1655 then
        dis = 2.5
      end
      local chestResult = Me.map:getPhysicsWorld():raycast(pos, dir, dis, -1) or {}
      local chestResult_mid = Me.map:getPhysicsWorld():raycast(midPos, dir, dis, -1) or {}
      if chestResult.targetType ~= 0 or chestResult_mid.targetType ~= 0 then
        local isObstacle_eye = chestResult.targetType ~= 0
        local isObstacle_mid = chestResult_mid.targetType ~= 0
        
        local function checkAgain(chestResult)
          local chestTarget = chestResult.target
          if chestTarget and chestTarget.isPlayer then
            return false
          end
          if chestTarget and chestTarget.cfg and chestTarget:cfg() and chestTarget:cfg().isTrolley then
            return false
          end
          local isVisible = chestTarget:getProperty("isVisible")
          local materialAlpha = chestTarget:getProperty("materialAlpha")
          local useCollide = chestTarget:getProperty("useCollide")
          if (isVisible == "false" or materialAlpha == "0") and useCollide == "false" then
            return false
          end
          return true
        end
        
        isObstacle_eye = isObstacle_eye and checkAgain(chestResult)
        isObstacle_mid = isObstacle_mid and checkAgain(chestResult_mid)
        if isObstacle_eye or isObstacle_mid then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
          return false
        end
      end
    end
  end
  return true
end

function WidgetHandBagCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHandBagCell
