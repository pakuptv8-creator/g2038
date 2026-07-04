local WinHandBag = M
local PropsConfig = T(Config, "PropsConfig")
local cellW = 74
local cellDisX = 4

function WinHandBag:init()
  WinBase.init(self, "HandBag.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinHandBag:initUI()
  self.lytView = self:child("HandBag-bg")
  self.lytList = self:child("HandBag-list")
  self.lytActionSwitch = self:child("HandBag-Action-Switch")
  self.txtActionSwitchIndex = self:child("HandBag-Action-Switch-Index")
  self.imgActionSwitchIcon = self:child("HandBag-Action-Switch-Icon")
  self.lytActionSwitch:SetVisible(false)
  self.btnDel = self:child("HandBag-DelBtn")
  self.btnDel:SetVisible(false)
  self:initHandBagList()
end

function WinHandBag:initHandBagList()
  self.handBagGridView = GridViewHelper.new({
    name = "handBagGridView",
    xCellNum = 5,
    xDis = cellDisX,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    widgetWidth = cellW,
    widgetHeight = cellW,
    widgetJson = "HandBagCell.json",
    widgetName = "handBagCell",
    gvParent = self.lytList,
    itemAlignment = 1,
    cellSelectedCb = function(data, type, index)
      if self.isUpdating then
        return
      end
      if not type then
        return
      end
      if type == "Normal" then
        if self.curIndex == index then
          return
        end
        Me:sendPacket({
          pid = "SwitchHandItem",
          slot = index
        })
      elseif type == "Selected" then
        if self.curIndex ~= index then
          return
        end
        Me:sendPacket({
          pid = "CancelHandItem",
          slot = index
        })
        local itemId = data.itemId
        local itemInfo = PropsConfig:getCfgById(itemId)
        if itemInfo.throwCfgType == "entity" then
          local inUseItem = Me:getInUseProp()
          if (itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem or itemInfo.throwTrigger == Define.ThrowObjTrigger.specifiedActionIndex and inUseItem and inUseItem.index == itemInfo.throwActionIndex) and itemInfo.rideOnPlayerIndex == 0 then
            self:cancelVehicle()
          end
        end
      elseif type == "Empty" then
        UI:openWnd("g2052Bag")
      end
    end
  })
end

function WinHandBag:cancelVehicle()
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

local function BuildHandbagsData(playerData)
  local len = #playerData
  local orderCount = len == Define.Prop.MaxHandBagCount and Define.Prop.MaxHandBagCount or len + 1
  local data = {}
  for i = 1, orderCount do
    if i <= len then
      data[i] = playerData[i]
    else
      data[i] = {}
    end
  end
  return data
end

function WinHandBag:updateHandBag()
  self.isUpdating = true
  local initIndex = -1
  local playerData = Me:getHandbagsInfo()
  local data = BuildHandbagsData(playerData)
  self.handBagGridView:updateGridViewConfig(cellDisX, 0, #data)
  self.lytView:SetWidth({
    0,
    #data * cellW + (#data - 1) * cellDisX + cellDisX
  })
  for i, v in pairs(playerData) do
    if v.inUse then
      initIndex = i
    end
  end
  self.curIndex = initIndex
  self.handBagGridView:setData(data, self.curIndex, nil, true)
  self.isUpdating = nil
  Me:syncItemUserInfo()
end

function WinHandBag:initEvent()
  self:subscribe(self.lytActionSwitch, UIEvent.EventWindowClick, function()
    Me:sendPacket({
      pid = "SwitchHandItemStyle"
    })
  end)
  self:subscribe(self.btnDel, UIEvent.EventButtonClick, function()
    if not self.curIndex then
      return
    end
    Lib.emitEvent(Event.EVENT_REMOVE_HAND_BAG_INFO, self.curIndex)
  end)
end

function WinHandBag:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_HAND_BAG_INFO, function()
    self:updateHandBag()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_IN_USE_PROP, function(inUseProp, objID)
    if objID ~= Me.objID then
      return
    end
    self.lytActionSwitch:SetVisible(false)
    self.btnDel:SetVisible(false)
    Lib.emitEvent(Event.EVENT_UPDATE_MAIN_ITEM_BTN, false)
    if inUseProp then
      local propInfo = PropsConfig:getCfgById(inUseProp.itemId)
      if not propInfo then
        return
      end
      self.btnDel:SetVisible(true)
      if inUseProp.itemId == World.cfg.phoneProfession.phoneItemId then
        Lib.emitEvent(Event.EVENT_UPDATE_MAIN_ITEM_BTN, true, World.cfg.phoneProfession.phoneItemId)
      elseif inUseProp.itemId == World.cfg.graffitiSetting.graffitiItemId then
        Lib.emitEvent(Event.EVENT_UPDATE_MAIN_ITEM_BTN, true, World.cfg.graffitiSetting.graffitiItemId)
      end
      if propInfo.isThrowObj == Define.ThrowObjType.Billboard then
        Lib.emitEvent(Event.EVENT_UPDATE_MAIN_ITEM_BTN, true, Define.ThrowObjType.Billboard)
      end
      if not propInfo.actionGroupCount then
        return
      end
      if propInfo.actionGroupCount == 1 then
        return
      end
      self.lytActionSwitch:SetVisible(true)
      self.txtActionSwitchIndex:SetText(inUseProp.index or 1)
      self.imgActionSwitchIcon:SetImage(propInfo.icon)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_CLIENT_BAG_INFO, function()
    self:updateClientBagData(self.curSelect)
  end)
end

function WinHandBag:updateClientBagData()
  self.isUpdating = true
  local initIndex = -1
  local playerData = Me.clientBagsInfo or {}
  local data = BuildHandbagsData(playerData)
  self.handBagGridView:updateGridViewConfig(cellDisX, 0, #data)
  self.lytView:SetWidth({
    0,
    #data * cellW + (#data - 1) * cellDisX + cellDisX
  })
  for i, v in pairs(playerData) do
    if v.inUse then
      initIndex = i
    end
  end
  self.curIndex = initIndex
  self.handBagGridView:setData(data, self.curIndex, nil, true)
  self.isUpdating = nil
end

function WinHandBag:initView()
  self:updateHandBag()
end

function WinHandBag:onHide()
  UI:closeWnd("g2052HandBag")
end

function WinHandBag:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052HandBag")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinHandBag:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinHandBag:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinHandBag
