local MonitorHelper = T(Lib, "MonitorHelper")
local AppearanceConfig = T(Config, "AppearanceConfig")
local WinRole = M
local bm = Blockman:Instance()
local PAGE_CONFIG = {
  [1] = {widget_path = "rolePage1"},
  [2] = {widget_path = "rolePage1"},
  [3] = {widget_path = "rolePage2"},
  [4] = {widget_path = "rolePage3"}
}

function WinRole:init()
  WinBase.init(self, "Role.json")
  self._pages = {}
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:initCategoryView()
end

function WinRole:initUI()
  self.lytMask = self:child("Role-mask")
  self.imgInterface = self:child("Role-Interface")
  self.imgTitleBg = self:child("Role-titleBg")
  self.txtTitle = self:child("Role-RoleTitle")
  self.txtTitle:SetText(Lang:toText("g2052.gui.appearance.title"))
  self.imgWhiteBg = self:child("Role-WhiteBg")
  self.lytTopTabContainer = self:child("Role-TopTabContainer")
  self.lytContent = self:child("Role-Content")
  self.btnClose = self:child("Role-Close")
  self.lytLeftTab = self:child("Role-leftTab")
  self.btnResetBtn = self:child("Role-ResetBtn")
  self.lytRotateControl = self:child("Role-RotateControl")
  self.txtAdTips = self:child("Role-AdTips")
  self.txtAdTips:SetText(Lang:toText("g2052.advertisement.use.car.tips"))
end

function WinRole:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnResetBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("commonDialog"):onShow(true, {
      title = "g2052.gui.dress.reset",
      desc = "g2052.gui.dress.reset.dec",
      confirmCallback = function()
        Me.dressId = nil
        local opOrder = Me:getChangeSkinOpOrder()
        Me:sendPacket({
          pid = "roleResetSkin",
          opOrder = opOrder
        })
        Me:doResetRoleSkinClient(opOrder)
      end,
      cancelCallback = function()
      end
    })
  end)
  self:lightSubscribe("error!!!!! : win_role dragMove event : EventWindowTouchMove", self.lytRotateControl, UIEvent.EventWindowTouchMove, function(window, dx, dy)
    self:onDragTouchMove(window, dx, dy)
  end)
  self:lightSubscribe("error!!!!! : win_role dragDown event : EventWindowTouchDown", self.lytRotateControl, UIEvent.EventWindowTouchDown, function(window, dx, dy)
    self:onDragTouchDown(window, dx, dy)
  end)
end

function WinRole:onDragTouchMove(window, dx, dy)
  local horseId = Me:getInteractPlayerHorseID()
  local entityId = Me:getInteractPlayerUpID()
  local partId = Me:getInteractionPartID()
  if horseId ~= 0 or entityId ~= 0 or partId ~= "" then
    return
  end
  if not self.m_lastXPosition then
    return
  end
  local delta = dx - self.m_lastXPosition
  self.m_lastXPosition = dx
  local old = Me:getRotationYaw()
  Me:setRotationYaw(old - delta)
end

function WinRole:onDragTouchDown(window, dx, dy)
  self.m_lastXPosition = dx
end

function WinRole:subscribeEvent()
end

function WinRole:initView(categoryId, pageId, dressId)
  local roleSetting = AppearanceConfig:getAllCfgs()
  if categoryId and roleSetting[categoryId] then
    self.firstPageId = pageId
    self.firstDressId = dressId
    self._categoryGridView:setClickByOrder(categoryId)
    self:updateCategoryPage(roleSetting[categoryId])
    self:updateScanRecord()
    self.lastCategory = roleSetting[categoryId].category
  end
end

function WinRole:initCategoryView()
  self.lytTopTabContainer:CleanupChildren()
  local roleSetting = AppearanceConfig:getAllCfgs()
  local count = #roleSetting
  if count <= 4 then
  end
  self._categoryGridView = GridViewHelper.new({
    name = "categoryGridView",
    xCellNum = count,
    xDis = 10,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    vScorllMoveAble = false,
    hScorllMoveAble = true,
    widgetWidth = 74,
    widgetHeight = 34,
    widgetJson = "CategoryItem.json",
    widgetName = "categoryItem",
    gvParent = self.lytTopTabContainer,
    cellSelectedCb = function(data, dx, dy, index)
      self:updateCategoryPage(data)
      self:updateScanRecord()
      self.lastCategory = data.category
    end
  })
  self._categoryGridView:setData(roleSetting, 1, nil, false)
end

function WinRole:updateScanRecord(isClose)
  if self.lastCategory then
    local widget = self._pages[self.lastCategory]
    local status, lastIndex = pcall(function()
      return widget:invoke("getLastIndex")
    end)
    if status and lastIndex then
      Me:scanDressItemsByIndex(lastIndex)
      if isClose then
        widget:invoke("updateSelf")
      end
    end
  end
end

function WinRole:onHide()
  UI:closeWnd("role")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinRole:onOpen(categoryId, pageId, dressId)
  Me:setShapeInfoClient(Me:getShapeInfo())
  Me:uiMutualExclusion("role")
  self.oldYaw = Me:getRotationYaw()
  self:initView(categoryId, pageId, dressId)
  self:subscribeEvent()
  local targetPos = self:getTargetPos()
  local cameraPos = self:getCameraPos(World.cfg.appearanceSetting.cameraDistance or 3)
  self:activateLookCamera(cameraPos, targetPos)
  self:updateOtherUI(true)
  UI:closeWnd("playerInteractPop")
  Lib.emitEvent(Event.EVENT_CLOSE_INTERACT_ACTION_WND)
  if not self.showOthersUI then
    self.showOthersUI = UI:hideOpenedWnd({"role"})
  end
end

function WinRole:getTargetPos()
  local dis = 1
  local rotateYaw = Me:getRotationYaw() - 90
  local yaw = math.rad(rotateYaw)
  local pos = Me:getEyePos()
  pos.x = pos.x - dis * math.sin(yaw)
  pos.z = pos.z + dis * math.cos(yaw)
  return Lib.tov3(pos)
end

function WinRole:getCameraPos(dis)
  local rotateYaw = Me:getRotationYaw() - 10
  local yaw = math.rad(rotateYaw)
  local pos = Me:getEyePos()
  pos.x = pos.x - dis * math.sin(yaw)
  pos.z = pos.z + dis * math.cos(yaw)
  pos.x = math.floor(pos.x) + 0.5
  pos.z = math.floor(pos.z) + 0.5
  return Lib.tov3(pos)
end

function WinRole:updateCategoryPage(data)
  local category = data.category
  for i, widget in pairs(self._pages) do
    if i == category then
      widget:SetVisible(true)
    else
      widget:SetVisible(false)
    end
  end
  if not self._pages[category] and PAGE_CONFIG[category] then
    local widget = UIMgr:new_widget(PAGE_CONFIG[category].widget_path, data)
    self.lytContent:AddChildWindow(widget)
    self._pages[category] = widget
  end
  if self.firstPageId and self._pages[category] then
    self._pages[category]:invoke("openTabIndex", self.firstPageId, self.firstDressId)
    self.firstPageId = nil
    self.firstDressId = nil
  end
end

function WinRole:onClose()
  if self.showOthersUI then
    self.showOthersUI()
    self.showOthersUI = nil
  end
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.oldYaw ~= Me:getRotationYaw() then
    local horseId = Me:getInteractPlayerHorseID()
    local entityId = Me:getInteractPlayerUpID()
    local partId = Me:getInteractionPartID()
    if horseId ~= 0 or entityId ~= 0 or partId ~= 0 then
      Me:setRotationYaw(Me:getRotationYaw())
    else
      Me:setRotationYaw(self.oldYaw)
    end
  end
  self:deactivateLookCamera()
  self:updateOtherUI(false)
  self:updateScanRecord(true)
end

function WinRole:updateOtherUI(isShow)
  UI:getWnd("gameMain"):updateRightPanelShow(not isShow)
  UI:getWnd("actionControl"):child("Main-Jump-Controls"):SetVisible(not isShow)
  UI:getWnd("actionControl"):child("Main-DragControl"):SetVisible(not isShow)
  UI:getWnd("g2052HandBag"):onShow(not isShow)
end

function WinRole:isUsingVehicle()
  return 0 < (Me.rideOnInstanceId or 0)
end

function WinRole:activateLookCamera(cameraPos, targetPos, direction)
  if self:isUsingVehicle() then
    return
  end
  if not cameraPos or not targetPos and not direction then
    return
  end
  Me.disableControl = true
  self.oldCamera = {
    pos = bm:getViewerPos(),
    yaw = bm:getViewerYaw(),
    pitch = bm:getViewerPitch(),
    distance = bm:viewerRenderDistance(1)
  }
  bm:setViewerPos(cameraPos)
  local distance = self.oldCamera.distance
  if targetPos then
    distance = (targetPos - cameraPos):len()
  end
  bm:addCameraDistance(-self.oldCamera.distance + distance)
  bm:setViewerLookAt(targetPos or cameraPos + direction * self.oldCamera.distance)
end

function WinRole:deactivateLookCamera()
  if self:isUsingVehicle() then
    return
  end
  Me.disableControl = false
  local old = self.oldCamera
  if old then
    bm:changeCameraView(old.pos, old.yaw, old.pitch, old.distance, 0)
    client_event("changeCameraDistance", old.distance)
  end
end

return WinRole
