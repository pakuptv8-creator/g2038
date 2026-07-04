local HouseConfig = T(Config, "HouseConfig")
local MonitorConfig = T(Config, "MonitorConfig")
local garageDoorTime = 0
local widget_base = require("ui.widget.widget_base")
local WidgetHouseOperationItem = Lib.derive(widget_base)

local function getMonitorGroupById(parent, groupId)
  local conf = MonitorConfig:getCfgById(groupId)
  local group = {}
  for _, v in ipairs(conf or {}) do
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
  [2] = {
    callback = function()
      WidgetHouseOperationItem:onClickPaint()
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
  },
  [8] = {
    type = "disasterEvent",
    callback = function()
      UI:openWnd("disasterWnd")
    end
  }
}

function WidgetHouseOperationItem:init(houseInfo)
  widget_base.init(self, "HouseOperationItem.json")
  self._allEvent = {}
  self.houseInfo = houseInfo or {}
  self:initUI()
  self:initEvent()
  self:updateBtnInfo()
end

function WidgetHouseOperationItem:initUI()
  self.lytBtnList = self:child("HouseOperationItem-btnListBg")
  for i = 1, 8 do
    self["btnOperation" .. i] = self:child("HouseOperationItem-OperationBtn" .. i)
    self["btnIcon" .. i] = self:child("HouseOperationItem-icon" .. i)
    self["imgSelectIcon" .. i] = self:child("HouseOperationItem-SelectIcon" .. i)
    self["imgSelectIcon" .. i]:SetVisible(false)
    if OPERATION_CONFIG[i] and OPERATION_CONFIG[i].text then
      self["btnOperation" .. i]:SetText(OPERATION_CONFIG[i].text)
    end
  end
end

function WidgetHouseOperationItem:initEvent()
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
end

function WidgetHouseOperationItem:updateHouseOperationShow(value)
  if value then
    self.lytContentPanel:SetVisible(false)
  else
    self.lytContentPanel:SetVisible(true)
  end
end

function WidgetHouseOperationItem:updateBtnInfo()
  local imgN = "set:g2052_function.json image:img_9_box_bg03"
  local alphaN = 0.2
  local imgP = "set:g2052_function.json image:img_9_box_bg04"
  local alphaP = 1
  if self.houseInfo and self.houseInfo.operatingInfo then
    local houseConfig = HouseConfig:getHouseInfoByCfgName(self.houseInfo.landName, self.houseInfo.houseName)
    if not houseConfig then
      return
    end
    for i, v in pairs(OPERATION_CONFIG) do
      self["imgSelectIcon" .. i]:SetVisible(false)
      if v.type == "window" then
        self["imgSelectIcon" .. i]:SetVisible(self.houseInfo.operatingInfo.window and true or false)
      elseif v.type == "garageDoor" then
        if houseConfig.haveGarage then
          self["btnOperation" .. i]:SetVisible(true)
          self["imgSelectIcon" .. i]:SetVisible(self.houseInfo.operatingInfo.garageDoor and true or false)
        else
          self["btnOperation" .. i]:SetVisible(false)
        end
      elseif v.type == "lock" then
        self["imgSelectIcon" .. i]:SetVisible(self.houseInfo.operatingInfo.inLock and true or false)
      elseif v.type == "disasterEvent" then
        self["btnOperation" .. i]:SetVisible(houseConfig.maxDisasterNum > 0)
      end
    end
  end
end

function WidgetHouseOperationItem:onClickPaint()
  local wndName = "ColorSelect"
  if UI:isOpen(wndName) then
    UI:closeWnd(wndName)
    return
  end
  UI:openWnd(wndName, {
    panelStatus = Me.carColorPanelStatus,
    title = Lang:toText("g2052.gui.vehicle.part.color"),
    leaveCb = function()
      UI:closeWnd(wndName)
    end,
    confirmCb = function(color, panelStatus)
      if color then
        Me.carColorPanelStatus = panelStatus
        Me:sendPacket({
          pid = "reqPaintHouse",
          color = {
            color.r,
            color.g,
            color.b,
            1
          }
        })
      end
    end
  })
end

function WidgetHouseOperationItem:updateHouseInfo(data)
  self.houseInfo = data
  self:updateBtnInfo()
end

function WidgetHouseOperationItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHouseOperationItem
