local WinInteractionClickWnd = M
local bmSetting = Blockman.instance.gameSettings
local DEFAULT_ANCHOR = {x = 0.5, y = 0.5}
local DEFAULT_OFFSET = {
  x = 0,
  y = 0,
  z = 0
}
local PropsConfig = T(Config, "PropsConfig")
local PlayerInteractiveConfig = T(Config, "PlayerInteractiveConfig")

function WinInteractionClickWnd:init()
  WinBase.init(self, "InteractionClickWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinInteractionClickWnd:initUI()
  self.interactWndList = {}
  self.noOperationList = {}
  self.scanningCd = World.cfg.interaction_uiSetting.ScanningCDTime or 10
end

function WinInteractionClickWnd:initEvent()
  Lib.lightSubscribeEvent("error!!!!! : WinInteractionClickWnd: EVENT_CLIENT_HANDLE_TICK", Event.EVENT_CLIENT_HANDLE_TICK, function()
    self:startScanningSurroundingEntities()
  end)
  Lib.lightSubscribeEvent("error!!!!! : WinInteractionClickWnd lib event : EVENT_SCENE_TOUCH_BEGIN", Event.EVENT_SCENE_TOUCH_BEGIN, function()
    if self.answerSceneClick then
      return
    end
    self.answerSceneClick = World.Timer(3, function()
      self.answerSceneClick = nil
      if bmSetting:isMouseMoving() then
        return
      end
      self:hideAllInteractAction(self.clickTargetId)
      self.clickTargetId = nil
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, function(value)
    if not value then
      self:hideAllInteractAction()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CLOSE_INTERACT_ACTION_WND, function(value)
    self:hideAllInteractAction()
  end)
end

function WinInteractionClickWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_INTERACT_CLICK_SHOW, function(targetID, isShow, showState)
    local entity = World.CurWorld:getObject(targetID)
    if not entity or not entity:isValid() then
      self:removeInteractWnd(targetID)
      return
    end
    if isShow then
      local MePos = Me:getPosition()
      local targetPos = entity:getPosition()
      local distance = Lib.getPosDistance(MePos, targetPos)
      if distance > World.cfg.interaction_uiSetting.ShowInteractRange then
        return
      end
      self.noOperationList[targetID] = nil
      self.clickTargetId = targetID
      self:showInteractWnd(targetID, showState)
    else
      self:hideInteractWnd(targetID)
    end
  end)
end

function WinInteractionClickWnd:initView()
end

function WinInteractionClickWnd:startScanningSurroundingEntities(immediately)
  self.scanningCd = self.scanningCd - 1
  if self.scanningCd > 0 and not immediately then
    return
  end
  self.scanningCd = World.cfg.interaction_uiSetting.ScanningCDTime or 10
  local range = math.max(World.cfg.interaction_uiSetting.ShowInteractRange, World.cfg.interaction_uiSetting.HideInteractRange)
  local MePos = Me:getPosition()
  local offset = Lib.v3(range, range, range)
  local minPos = MePos - offset
  local maxPos = MePos + offset
  local entities = Me.map:getTouchEntities(minPos, maxPos)
  for objID, _ in pairs(self.noOperationList) do
    local isNone
    for _, entity in ipairs(entities) do
      if entity.objID == objID then
        isNone = true
      end
    end
    self.noOperationList[objID] = isNone
  end
  local newShowList = {}
  local allShowList = {}
  local newCounts = 0
  for _, entity in ipairs(entities) do
    if self:checkIsCanShowInteractWnd(entity) then
      if self:checkIsOverTimeWnd(entity.objID) then
        self:removeInteractWnd(entity.objID)
        self.noOperationList[entity.objID] = true
      else
        local targetPos = entity:getPosition()
        local distance = Lib.getPosDistance(MePos, targetPos)
        if distance <= World.cfg.interaction_uiSetting.ShowInteractRange then
          local temp = {
            distance = distance,
            objID = entity.objID
          }
          newCounts = newCounts + 1
          newShowList[newCounts] = temp
        end
        allShowList[entity.objID] = true
      end
    end
  end
  table.sort(newShowList, function(a, b)
    return a.distance < b.distance
  end)
  local resultShow = {}
  local clickNum = 0
  for objID, val in pairs(self.interactWndList) do
    if not allShowList[objID] then
      self:removeInteractWnd(objID)
    else
      local entity = World.CurWorld:getObject(objID)
      if not entity or not entity:isValid() then
        self:removeInteractWnd(objID)
      elseif val.showState == Define.InteractClickType.ActionShow then
        clickNum = clickNum + 1
        resultShow[objID] = true
      end
    end
  end
  for i = clickNum + 1, World.cfg.interaction_uiSetting.MaxInteractNum do
    if newShowList[i - clickNum] then
      local objID = newShowList[i - clickNum].objID
      if not self.interactWndList[objID] then
        self:showInteractWnd(objID, Define.InteractClickType.ClickTips)
      elseif self.interactWndList[objID].showState == Define.InteractClickType.HidingState then
        self:showInteractWnd(objID, Define.InteractClickType.ClickTips)
      end
      resultShow[objID] = true
    end
  end
  for objID, val in pairs(self.interactWndList) do
    if not resultShow[objID] then
      self:hideInteractWnd(objID)
    end
  end
end

function WinInteractionClickWnd:checkIsOverTimeWnd(objID)
  if self.interactWndList[objID] and self.interactWndList[objID].showState == Define.InteractClickType.ClickTips then
    local passTime = os.time() - self.interactWndList[objID].createTime
    return passTime > World.cfg.interaction_uiSetting.NoOperationTime
  end
  return false
end

function WinInteractionClickWnd:checkIsCanShowInteractWnd(entity)
  if self.noOperationList[entity.objID] then
    return false
  end
  if entity.objID == Me.objID then
    return false
  end
  if not entity.isPlayer then
    return false
  end
  
  local function isRideEntity(entity)
    if entity.objID == Me:getInteractPlayerHorseID() then
      return true
    end
    if entity.objID == Me:getInteractPlayerUpID() then
      return true
    end
    if entity:getInteractPlayerHorseID() > 0 then
      return true
    end
    if 0 < entity.rideOnId then
      return true
    end
    if entity:getInteractCarEnterID() ~= "" then
      return true
    end
    if entity.rideOnInstanceId then
      return true
    end
    if entity.rideFixedPointVehicleId and entity.rideFixedPointVehicleId ~= "" then
      return true
    end
    return false
  end
  
  if isRideEntity(entity) then
    if self.interactWndList[entity.objID] then
      if self.interactWndList[entity.objID].showState == Define.InteractClickType.ActionShow then
        return true
      else
        return false
      end
    else
      return false
    end
  end
  return true
end

function WinInteractionClickWnd:setContainerFollow(containerWnd, objID, params)
  local followParams = {
    anchor = DEFAULT_ANCHOR,
    offset = params.offset or DEFAULT_OFFSET
  }
  local result = UILib.uiFollowObject(containerWnd, objID, followParams)
  return result
end

function WinInteractionClickWnd:removeInteractWnd(objID)
  if not self.interactWndList[objID] then
    return
  end
  if not self.interactWndList[objID].interactType then
    return
  end
  for showState, val in pairs(self.interactWndList[objID].interactType) do
    if val.containerFollow then
      val.containerFollow()
    end
    GUIWindowManager.instance:DestroyGUIWindow(val.containerWnd)
  end
  self.interactWndList[objID] = nil
end

local function newButton(params, pos)
  local item = UIMgr:new_widget("button", params.widgetFileName)
  if pos then
    item:invoke("pos", pos)
  elseif params.pos then
    item:invoke("pos", params.pos)
  end
  if params.image then
    item:invoke("image", params.image)
  end
  if params.background then
    item:invoke("background", params.background)
  else
    item:invoke("background", "")
  end
  if params.text then
    item:invoke("text", params.text)
  end
  if params.imageSize then
    item:SetWidth({
      0,
      params.imageSize.width
    })
    item:SetHeight({
      0,
      params.imageSize.height
    })
  end
  return item
end

function WinInteractionClickWnd:displayTipsButtons(containerWnd, objID)
  local item = newButton(World.cfg.interaction_uiSetting.signalParams)
  self:subscribe(item, UIEvent.EventButtonClick, function()
    Me:showPlayerFriendPop(objID)
    self:showInteractWnd(objID, Define.InteractClickType.ActionShow)
  end)
  containerWnd:AddChildWindow(item)
  return item
end

function WinInteractionClickWnd:displayPropsButtons(containerWnd, objID, circleParams)
  local posCfgs = UILib.autoLayoutCircle({
    count = 1,
    radius = circleParams.radius or 100,
    startAngle = 0,
    endAngle = 360
  })
  local params = {
    imageSize = World.cfg.interaction_uiSetting.multipleParams.propsSize,
    widgetFileName = World.cfg.interaction_uiSetting.multipleParams.propsFileName,
    background = World.cfg.interaction_uiSetting.multipleParams.propsBackground
  }
  local item = newButton(params, posCfgs[1])
  self:subscribe(item, UIEvent.EventButtonClick, function()
    local entity = World.CurWorld:getObject(objID)
    if not entity or not entity:isValid() then
      return
    end
    if self.interactWndList[objID].interactType[Define.InteractClickType.ActionShow].giveItemId == 0 then
      UI:openWnd("giftWnd", objID)
    else
      Me:requestGiveProp(entity.platformUserId, self.interactWndList[objID].interactType[Define.InteractClickType.ActionShow].giveItemId)
    end
    UI:getWnd("playerInteractPop"):onShow(false)
    self:hideInteractWnd(objID)
  end)
  containerWnd:AddChildWindow(item)
  return item
end

function WinInteractionClickWnd:displayCandyButtons(containerWnd, objID, posCfgs, posIndex, isShare)
  local multipleParams = World.cfg.interaction_uiSetting.multipleParams
  local params = {
    imageSize = multipleParams.imageSize,
    widgetFileName = multipleParams.candyFileName
  }
  if isShare then
    params.image = multipleParams.candyShareImage
    params.text = multipleParams.candyShareTitle
  else
    params.image = multipleParams.candyAcceptImage
    params.text = multipleParams.candyAcceptTitle
  end
  local item = newButton(params, posCfgs[posIndex])
  self:subscribe(item, UIEvent.EventButtonClick, function()
    if isShare then
      Plugins.CallTargetPluginFunc("halloween", "doShareCandyToOthers", objID)
    else
      Plugins.CallTargetPluginFunc("halloween", "doAcceptCandyToOthers", objID)
    end
    UI:getWnd("playerInteractPop"):onShow(false)
    self:hideInteractWnd(objID)
  end)
  containerWnd:AddChildWindow(item)
end

function WinInteractionClickWnd:getMultipleButtonsPosCfg(multipleParams, count)
  local posCfgs = UILib.autoLayoutCircle({
    count = count,
    radius = multipleParams.radius or 100,
    startAngle = multipleParams.startAngle,
    endAngle = multipleParams.endAngle,
    deltaAngle = multipleParams.deltaAngle
  })
  return posCfgs
end

function WinInteractionClickWnd:displayMultipleButtons(containerWnd, objID)
  local interactiveCfg = PlayerInteractiveConfig:getAllCfgs()
  local multipleParams = World.cfg.interaction_uiSetting.multipleParams
  local isShowCandy = Plugins.CallTargetPluginFunc("halloween", "isDuringHalloweenPeriod")
  local posCfgs
  local posIndex = 0
  local circleParams
  if isShowCandy then
    circleParams = multipleParams.halloweenParams
    posCfgs = self:getMultipleButtonsPosCfg(circleParams, #interactiveCfg + 2)
    posIndex = posIndex + 1
    self:displayCandyButtons(containerWnd, objID, posCfgs, posIndex, false)
  else
    circleParams = multipleParams.normalParams
    posCfgs = self:getMultipleButtonsPosCfg(circleParams, #interactiveCfg)
  end
  for index, val in ipairs(interactiveCfg) do
    posIndex = posIndex + 1
    local params = {
      imageSize = multipleParams.imageSize,
      image = val.normalIcon,
      text = val.actionName,
      widgetFileName = multipleParams.widgetFileName
    }
    local item = newButton(params, posCfgs[posIndex])
    self:subscribe(item, UIEvent.EventButtonClick, function()
      Me:sendPacket({
        pid = "RequestPlayerInteractive",
        targetID = objID,
        interactiveID = val.id
      })
      local defaultData = {
        double_interact_id = val.id
      }
      Plugins.CallTargetPluginFunc("report", "report", "doubleAction_send", defaultData, Me)
      UI:getWnd("playerInteractPop"):onShow(false)
      self:hideInteractWnd(objID)
    end)
    containerWnd:AddChildWindow(item)
  end
  if isShowCandy then
    posIndex = posIndex + 1
    self:displayCandyButtons(containerWnd, objID, posCfgs, posIndex, true)
  end
  return self:displayPropsButtons(containerWnd, objID, circleParams)
end

function WinInteractionClickWnd:createInteractWnd(objID, showState, giveItemId)
  local containerWnd = GUIWindowManager.instance:LoadWindowFromJSON("InteractionLayout.json")
  self._root:AddChildWindow(containerWnd)
  containerWnd:SetVisible(true)
  self.interactWndList[objID].interactType[showState] = {containerWnd = containerWnd}
  local containerFollow
  if showState == Define.InteractClickType.ClickTips then
    self:displayTipsButtons(containerWnd, objID)
    containerFollow = self:setContainerFollow(containerWnd, objID, World.cfg.interaction_uiSetting.signalParams)
  elseif showState == Define.InteractClickType.ActionShow then
    self.interactWndList[objID].interactType[showState].giveItemId = giveItemId
    self.interactWndList[objID].interactType[showState].propItem = self:displayMultipleButtons(containerWnd, objID)
    containerFollow = self:setContainerFollow(containerWnd, objID, World.cfg.interaction_uiSetting.multipleParams)
  end
  self.interactWndList[objID].interactType[showState].containerFollow = containerFollow
end

function WinInteractionClickWnd:hideAllInteractAction(extraId)
  for objID, val in pairs(self.interactWndList) do
    if val.showState == Define.InteractClickType.ActionShow and objID ~= extraId then
      self:hideInteractWnd(objID)
    end
  end
end

function WinInteractionClickWnd:hideInteractWnd(objID)
  if not self.interactWndList[objID] then
    return
  end
  self.interactWndList[objID].showState = Define.InteractClickType.HidingState
  for showState, val in pairs(self.interactWndList[objID].interactType) do
    val.containerWnd:SetVisible(false)
  end
end

function WinInteractionClickWnd:showInteractWnd(objID, showState)
  if not self.interactWndList[objID] then
    self.interactWndList[objID] = {}
    self.interactWndList[objID].showState = Define.InteractClickType.HidingState
    self.interactWndList[objID].interactType = {}
  end
  for showState, val in pairs(self.interactWndList[objID].interactType) do
    val.containerWnd:SetVisible(false)
  end
  self.interactWndList[objID].showState = showState
  self.interactWndList[objID].createTime = os.time()
  local giveItemId, giveIcon
  if showState == Define.InteractClickType.ActionShow then
    local inUseProp = Me:getInUseProp()
    if inUseProp then
      local propCfg = PropsConfig:getCfgById(inUseProp.itemId)
      if propCfg and propCfg.canGive then
        giveItemId = inUseProp.itemId
        giveIcon = propCfg.icon
      end
    end
    if not giveItemId then
      giveItemId = 0
      giveIcon = World.cfg.interaction_uiSetting.multipleParams.sendGiftImage
    end
  end
  if not self.interactWndList[objID].interactType[showState] then
    self:createInteractWnd(objID, showState, giveItemId)
  else
    self.interactWndList[objID].interactType[showState].containerWnd:SetVisible(true)
  end
  if showState == Define.InteractClickType.ActionShow then
    for key, val in pairs(self.interactWndList) do
      if key ~= objID and val.showState == Define.InteractClickType.ActionShow then
        self:hideInteractWnd(key)
      end
    end
    local multipleParams = World.cfg.interaction_uiSetting.multipleParams
    if giveItemId then
      self.interactWndList[objID].interactType[showState].giveItemId = giveItemId
      self.interactWndList[objID].interactType[showState].propItem:SetVisible(true)
      self.interactWndList[objID].interactType[showState].propItem:invoke("image", giveIcon)
      if giveItemId == 0 then
        self.interactWndList[objID].interactType[showState].propItem:invoke("background", "")
        self.interactWndList[objID].interactType[showState].propItem:invoke("text", multipleParams.sendGiftTitle)
      else
        self.interactWndList[objID].interactType[showState].propItem:invoke("background", multipleParams.propsBackground)
        self.interactWndList[objID].interactType[showState].propItem:invoke("text", multipleParams.sendNormalTitle)
      end
    else
      self.interactWndList[objID].interactType[showState].propItem:SetVisible(false)
    end
  end
end

function WinInteractionClickWnd:onHide()
  UI:closeWnd("interactionClickWnd")
end

function WinInteractionClickWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("interactionClickWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinInteractionClickWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinInteractionClickWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinInteractionClickWnd
