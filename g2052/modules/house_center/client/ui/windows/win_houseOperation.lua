local HouseConfig = T(Config, "HouseConfig")
local MonitorConfig = T(Config, "MonitorConfig")
local WinHouseOperation = M
local garageDoorTime = 0

local function getMonitorGroupById(parent, groupId)
  local conf = MonitorConfig:getCfgById(groupId)
  local group = {}
  for _, v in ipairs(conf) do
    local nodes = {}
    local partName = v.partName
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, partName)
    if 0 < #nodes then
      for _, node in ipairs(nodes) do
        group[#group + 1] = node
      end
    end
  end
  return group
end

local OPERATION_CONFIG = {
  [1] = {
    callback = function()
      local function inputCallback(text, color)
        Me:sendPacket({
          pid = "SetDoorplateText",
          
          dec = text,
          color = color
        })
      end
      
      UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.HouseDec, inputCallback)
    end
  },
  [3] = {
    callback = function()
      UI:openWnd("houseBgmWnd")
    end
  },
  [4] = {
    callback = function()
      local isHasHouse, houseInfo = Me:doIOwnAHouse()
      if not isHasHouse then
        return
      end
      local houseConfig = HouseConfig:getHouseInfoByCfgName(houseInfo.landName, houseInfo.houseName)
      local houseInstance = Instance.getByInstanceId(houseInfo.houseId)
      if houseInstance and houseInstance:isValid() then
        local monitorGroup = getMonitorGroupById(houseInstance, houseConfig.monitorId)
        Lib.logDebug("monitor count: ", #monitorGroup)
        if 0 < #monitorGroup then
          local cameraData = {}
          for _, v in ipairs(monitorGroup) do
            local cameraPos = v:getPosition()
            local rotation = v:getRotation()
            local dir = Lib.correctMoveDistance(rotation, Lib.v3(0, 0, -1))
            cameraData[#cameraData + 1] = {cameraPos = cameraPos, dir = dir}
          end
          UI:openWnd("cameraSwitch", cameraData, 1, false, true)
        end
      end
    end
  },
  [5] = {
    type = "lock",
    callback = function()
      Me:sendPacket({
        pid = "SwitchLockState"
      })
    end
  },
  [6] = {
    type = "window",
    callback = function()
      Me:sendPacket({
        pid = "ControlTheWindow"
      })
    end
  },
  [7] = {
    type = "garageDoor",
    callback = function()
      if os.time() - garageDoorTime > 2 then
        Me:sendPacket({
          pid = "ControlGarageDoor"
        })
        garageDoorTime = os.time()
      end
    end
  }
}

function WinHouseOperation:init()
  WinBase.init(self, "HouseOperation.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinHouseOperation:initData()
  self.showBtnList = true
  self.houseInfo = {}
end

function WinHouseOperation:initUI()
  self.lytContentPanel = self:child("HouseOperation-ContentPanel")
  self.btnMainOperation = self:child("HouseOperation-operationBtn")
  self.lytBtnList = self:child("HouseOperation-btnListBg")
  self.txtHouseIndex = self:child("HouseOperation-text")
  for i = 1, 8 do
    self["btnOperation" .. i] = self:child("HouseOperation-OperationBtn" .. i)
    self["btnIcon" .. i] = self:child("HouseOperation-icon" .. i)
    if OPERATION_CONFIG[i] and OPERATION_CONFIG[i].text then
      self["btnOperation" .. i]:SetText(OPERATION_CONFIG[i].text)
    end
  end
end

function WinHouseOperation:initEvent()
  for i = 1, 8 do
    self:subscribe(self["btnOperation" .. i], UIEvent.EventButtonClick, function()
      if OPERATION_CONFIG[i] then
        local callback = OPERATION_CONFIG[i].callback
        if callback then
          callback()
        end
      end
    end)
  end
  self:subscribe(self.btnMainOperation, UIEvent.EventWindowClick, function()
    self.showBtnList = not self.showBtnList
    self:updateBtnInfo()
  end)
end

function WinHouseOperation:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_HOUSE_INFO, function()
  end)
end

function WinHouseOperation:initView()
  self:updateBtnInfo()
  self:updateHouseOperationShow(true)
end

function WinHouseOperation:updateHouseOperationShow(value)
  self.lytContentPanel:SetVisible(value)
end

function WinHouseOperation:updateBtnInfo()
  local btnIcon = "set:g2052_main.json image:btn_0_toggle"
  if self.showBtnList then
    btnIcon = "set:g2052_main.json image:img_0_props_column04"
  end
  self.btnMainOperation:SetImage(btnIcon)
  self.lytBtnList:SetVisible(self.showBtnList)
  local imgN = "set:g2052_function.json image:img_9_box_bg03"
  local alphaN = 0.2
  local imgP = "set:g2052_function.json image:img_9_box_bg04"
  local alphaP = 1
  if self.houseInfo and self.houseInfo.operatingInfo then
    for i, v in pairs(OPERATION_CONFIG) do
      if v.type == "window" then
        self["btnOperation" .. i]:SetNormalImage(self.houseInfo.operatingInfo.window and imgP or imgN)
        self["btnOperation" .. i]:SetAlpha(self.houseInfo.operatingInfo.window and alphaP or alphaN)
      elseif v.type == "garageDoor" then
        self["btnOperation" .. i]:SetNormalImage(self.houseInfo.operatingInfo.garageDoor and imgP or imgN)
        self["btnOperation" .. i]:SetAlpha(self.houseInfo.operatingInfo.garageDoor and alphaP or alphaN)
      elseif v.type == "lock" then
        self["btnOperation" .. i]:SetNormalImage(self.houseInfo.operatingInfo.inLock and imgP or imgN)
        self["btnOperation" .. i]:SetAlpha(self.houseInfo.operatingInfo.inLock and alphaP or alphaN)
      end
      self["btnIcon" .. i]:SetAlpha(alphaP)
    end
    if self.houseInfo.index then
      self.txtHouseIndex:SetText("#" .. self.houseInfo.index)
    end
  end
end

function WinHouseOperation:updateHouseInfo(data)
  self.houseInfo = data
  self:updateBtnInfo()
end

function WinHouseOperation:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinHouseOperation:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinHouseOperation
