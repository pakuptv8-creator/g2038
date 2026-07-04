local MonitorHelper = T(Lib, "MonitorHelper")
local bm = Blockman:Instance()
local TimeLight = T(Lib, "TimeLight")
local VehicleVirtualCamera = T(Lib, "VehicleVirtualCamera")
local WinCameraSwitch = M

function WinCameraSwitch:init()
  WinBase.init(self, "CameraSwitch.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinCameraSwitch:initUI()
  self.btnClose = self:child("CameraSwitch-close")
  self.btnLeftView = self:child("CameraSwitch-LeftView")
  self.btnRightView = self:child("CameraSwitch-RightView")
  self.btnTransport = self:child("CameraSwitch-Transport")
  self.btnTransport2 = self:child("CameraSwitch-Transport2")
end

function WinCameraSwitch:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    MonitorHelper:deactivate()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnLeftView, UIEvent.EventButtonClick, function()
    self.index = self.index - 1
    if self.index < 1 then
      self.index = self.total
    end
    self:updateView()
  end)
  self:subscribe(self.btnRightView, UIEvent.EventButtonClick, function()
    self.index = self.index + 1
    if self.index > self.total then
      self.index = 1
    end
    self:updateView()
  end)
  self:subscribe(self.btnTransport, UIEvent.EventButtonClick, function()
    self:transport()
  end)
  self:subscribe(self.btnTransport2, UIEvent.EventButtonClick, function()
    self:transport()
  end)
end

function WinCameraSwitch:subscribeEvent()
end

function WinCameraSwitch:transport()
  if Me:getInteractPlayerHorseID() > 0 then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.transfer.fail")
    return
  end
  if UI:isOpen("dyeingColorSelect") then
    return
  end
  MonitorHelper:deactivate()
  self._canRecoverVehicleCamera = false
  UI:closeWnd(self)
  local cameraConf = self.cameraData[self.index]
  if cameraConf.initPosInfo then
    Me:sendPacket({
      pid = "clientInitiatesTransfer",
      params = cameraConf.initPosInfo,
      transportInfo = {
        type = Define.TRANSPORT_TYPE.HOUSE,
        id = cameraConf.landId
      }
    })
  end
end

function WinCameraSwitch:updateView()
  self.btnTransport:SetVisible(self.canTransport)
  self.btnTransport2:SetVisible(self.canTransport)
  local firstConf = self.cameraData[self.index]
  Lib.logDebug("cameraPos: ", Lib.v2s(firstConf.cameraPos))
  Lib.logDebug("targetPos: ", Lib.v2s(firstConf.targetPos))
  if not self.canTransport then
    self.oldCamera = {
      pos = bm:getViewerPos(),
      yaw = bm:getViewerYaw(),
      pitch = bm:getViewerPitch(),
      distance = bm:viewerRenderDistance(1)
    }
    if self.oldCamera.distance < 1 then
      client_event("changeCameraDistance", 15)
    else
      self.oldCamera = nil
    end
  end
  MonitorHelper:activate(firstConf.cameraPos, firstConf.targetPos, firstConf.dir)
  VehicleVirtualCamera:pause()
end

function WinCameraSwitch:onOpen(cameraData, defaultIndex, canTransport, isShowMe, transportType)
  self.cameraData = cameraData
  self.total = #self.cameraData
  self.index = defaultIndex or 1
  self._canRecoverVehicleCamera = true
  self.canTransport = true
  self.transportType = transportType
  if canTransport ~= nil then
    self.canTransport = canTransport
  end
  if not self.cameraData[self.index] then
    return
  end
  self:updateView()
  self:subscribeEvent()
  self:closeOtherFunctionWnd()
  self:updateOtherUI(true)
  if not isShowMe then
    Me:setActorHide(true)
  end
  Me:sendPacket({
    pid = "expandEntityViewDistance"
  })
  Blockman.instance.gameSettings.hideFog = true
  if not self.showOthersUI then
    self.showOthersUI = UI:hideOpenedWnd({
      "cameraSwitch"
    })
  end
end

function WinCameraSwitch:onClose()
  if self.showOthersUI then
    self.showOthersUI()
    self.showOthersUI = nil
  end
  if self.canTransport then
    Me:setLastHouseTransportIndex(self.index)
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:updateOtherUI(false)
  if Me:getOnSlideState() == 1 then
    return
  end
  if Me:getOnSwingState() == 1 then
    return
  end
  Me:setActorHide(false)
  Me:sendPacket({
    pid = "recoveryEntityViewDistance"
  })
  if self.oldCamera then
    local old = self.oldCamera
    bm:changeCameraView(old.pos, old.yaw, old.pitch, old.distance, 0)
    client_event("changeCameraDistance", old.distance)
  end
  if self._canRecoverVehicleCamera and not Me.telescopeCacheInfo then
    VehicleVirtualCamera:recover()
  end
  Blockman.instance.gameSettings.hideFog = TimeLight.closeFog
end

function WinCameraSwitch:updateOtherUI(isShow)
  UI:getWnd("gameMain"):updateRightPanelShow(not isShow)
  UI:getWnd("gameMain"):updateModBtnShow(not isShow)
  UI:getWnd("gameMain"):updateRideOffBtnShow(not isShow)
  UI:getWnd("gameMain"):updateRideOffPetBtnShow(not isShow)
  UI:getWnd("gameMain").lytTimePanel:SetVisible(not isShow)
  UI:getWnd("actionControl"):child("Main-Jump-Controls"):SetVisible(not isShow)
  UI:getWnd("actionControl"):child("Main-DragControl"):SetVisible(not isShow)
  UI:getWnd("g2052HandBag"):onShow(not isShow)
  if Me:data("main").weather == Define.Weather.storm then
    if isShow then
      UI:closeWnd("quickitem")
    else
      UI:openWnd("quickitem", 1005)
    end
  end
end

function WinCameraSwitch:closeOtherFunctionWnd()
  Me:closeRightFunctionWnd()
  UI:closeWnd("playerInteractPop")
  Lib.emitEvent(Event.EVENT_CLOSE_INTERACT_ACTION_WND)
end

return WinCameraSwitch
