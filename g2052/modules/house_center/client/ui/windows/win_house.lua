local WinHouse = M
local HouseConfig = T(Config, "HouseConfig")
local switchHouseTimer = World.cfg.switchHouseTimer or 20
local createHouseCd = World.cfg.createHouseCd or 60

function WinHouse:init()
  WinBase.init(self, "House.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinHouse:initData()
  self._allEvent = {}
  self.houseInfo = {}
  self.curSelectInfo = nil
  self.houseData = HouseConfig:getAllHouseByLandName("land")
  self.curLandName = "land"
end

function WinHouse:initUI()
  self.lytMask = self:child("House-mask")
  self.imgInterface = self:child("House-Interface")
  self.imgTitleBg = self:child("House-titleBg")
  self.txtTitle = self:child("House-HouseTitle")
  self.lytInterfaceDataList = self:child("House-Interface-Data-List")
  self.btnClose = self:child("House-Close")
  self.btnOperationBtn1 = self:child("House-operationBtn_1")
  self.btnOperationBtn2 = self:child("House-operationBtn_2")
  self.btnOperationBtn3 = self:child("House-operationBtn_3")
  self.txtCountDown = self:child("House-count_down")
  self.txtAdTips = self:child("House-AdTips")
  self.txtAdTips:SetText(Lang:toText("g2052.advertisement.use.car.tips"))
  self.txtTitle:SetText(Lang:toText("g2052.gui.house.title"))
  self.txtCountDown:SetText("")
  self:initHouseList()
end

function WinHouse:initHouseList()
  self.houseGridView = GridViewHelper.new({
    name = "houseGridView",
    xCellNum = 2,
    xDis = 6,
    yDis = 4,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    widgetWidth = 142,
    widgetHeight = 142,
    widgetJson = "HouseItem.json",
    widgetName = "houseItem",
    gvParent = self.lytInterfaceDataList,
    cellSelectedCb = function(data, dx, dy, index)
      self.curSelectInfo = data
      if self.oldTargetId then
        self:beginApplyHouse(data)
        return
      end
      if not self.houseInfo or data.cfgName ~= self.houseInfo.houseName then
        local houseName = self.houseInfo.houseName
        if not houseName then
          if not self.targetId then
            return
          end
          if Me:getInteractPlayerHorseID() > 0 then
            Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.transfer.fail")
            return
          end
          Me:sendPacket({
            pid = "OnApplyHouse",
            params = {
              cfgName = data.cfgName,
              targetId = self.targetId
            }
          }, function(ret)
            if not ret then
              print("--no choice location--")
            end
          end)
        else
          UI:getWnd("commonDialog"):onShow(true, {
            title = "g2052.gui.house.remould",
            desc = "g2052.gui.house.remould.dec",
            confirmCallback = function()
              Me:sendPacket({
                pid = "OnOperationHouse",
                params = {
                  cfgName = data.cfgName,
                  isSwitch = true
                }
              }, function(ret)
                if not ret then
                  print("--no choice location--")
                end
              end)
            end,
            cancelCallback = function()
            end
          })
        end
      end
    end
  })
end

function WinHouse:beginApplyHouse(data)
  UI:getWnd("commonDialog"):onShow(true, {
    title = "g2052.gui.house.move",
    desc = "g2052.gui.house.move.dec",
    confirmCallback = function()
      Me:sendPacket({
        pid = "OnApplyHouse",
        params = {
          cfgName = data.cfgName,
          targetId = self.oldTargetId,
          newTargetId = self.targetId
        }
      }, function(ret)
        if not ret then
          print("--no choice location--")
        end
      end)
    end,
    cancelCallback = function()
    end
  })
end

function WinHouse:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    self:onHide()
  end)
  self:subscribe(self.btnOperationBtn1, UIEvent.EventWindowClick, function()
    UI:getWnd("commonDialog"):onShow(true, {
      title = "g2052.gui.house.dismantle",
      desc = "g2052.gui.house.dismantle.dec",
      confirmCallback = function()
        Me:sendPacket({
          pid = "OnOperationHouse",
          params = {isDismantle = true}
        }, function(ret)
          if ret then
            self:onHide()
          else
            print("--no choice location--")
          end
        end)
      end,
      cancelCallback = function()
      end
    })
  end)
  self:subscribe(self.btnOperationBtn2, UIEvent.EventWindowClick, function()
    if Me:getInteractPlayerHorseID() > 0 then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.transfer.fail")
      return
    end
    if self.houseInfo.initPosInfo then
      Me:sendPacket({
        pid = "clientInitiatesTransfer",
        params = self.houseInfo.initPosInfo
      })
    end
  end)
  self:subscribe(self.btnOperationBtn3, UIEvent.EventWindowClick, function()
    Me:previewAllHouse()
  end)
  Lib.subscribeEvent(Event.EVENT_WATCH_AD_UPDATE, function()
    self.houseGridView:getAdapter():notifyDataChange()
  end)
end

function WinHouse:subscribeEvent()
end

function WinHouse:updateHouseInfo()
  local isShow = false
  if self.houseInfo and self.houseInfo.houseId then
    isShow = true
  end
  self.btnOperationBtn1:SetVisible(isShow)
  self.btnOperationBtn2:SetVisible(isShow)
  self.btnOperationBtn3:SetVisible(isShow)
end

function WinHouse:updateHouseData()
  if self.houseInfo then
    for i, v in pairs(self.houseData) do
      v.inUse = false
      if v.cfgName == self.houseInfo.houseName and self.oldTargetId ~= self.houseInfo.id then
        v.inUse = true
      end
    end
  end
  self.houseGridView:setData(self.houseData, -1, nil, true)
end

function WinHouse:initView(targetId, oldTargetId, landName)
  self.curSelectInfo = nil
  self.targetId = targetId
  self.oldTargetId = oldTargetId
  if not landName then
    if self.houseInfo then
      landName = self.houseInfo.landName
    else
      landName = "land"
    end
  end
  if self.curLandName ~= landName then
    self.houseData = HouseConfig:getAllHouseByLandName(landName)
    self.curLandName = landName
  end
  self:updateOwnHouseInfo()
end

function WinHouse:updateOwnHouseInfo(param)
  if param then
    self.houseInfo = param
    Lib.emitEvent(Event.EVENT_RECEIVE_HOUSE_INFO, param)
    UI:getWnd("houseBgmWnd"):updateHouseInfo(param)
  end
  self:updateHouseData()
  self:updateHouseInfo()
  self:updateHouseCreateCD()
end

function WinHouse:updateHouseCreateCD()
  local createTime = self.houseInfo.createTime
  if createTime and os.time() - createTime <= createHouseCd then
    self.txtCountDown:SetText("")
    if self.countDownTimer then
      self.countDownTimer()
      self.countDownTimer = nil
    end
    local time = createHouseCd - (os.time() - createTime)
    time = time > createHouseCd and createHouseCd or time
    self.txtCountDown:SetText(Lang:toText({
      "g2052.gui.house.create.cd",
      time
    }))
    self.countDownTimer = Me:timer(5, function()
      time = createHouseCd - (os.time() - createTime)
      time = time > createHouseCd and createHouseCd or time
      if time < 0 then
        self.txtCountDown:SetText("")
        self.countDownTimer = nil
        return
      end
      self.txtCountDown:SetText(Lang:toText({
        "g2052.gui.house.create.cd",
        time
      }))
      return true
    end)
  end
end

function WinHouse:onHide()
  UI:closeWnd("house")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinHouse:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("house")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinHouse:hasScanAllNewHouse()
  local newHouses = HouseConfig:getNewHouses()
  if #newHouses == 0 then
    return
  end
  if Me.newHouseRecord == nil then
    return
  end
  for _, v in ipairs(newHouses) do
    HouseConfig:updateIsNewStatusById(v.id)
    Me.newHouseRecord[tostring(v.id)] = 1
    for _, d in pairs(self.houseData) do
      if d.id == v.id then
        d.isNew = 0
        break
      end
    end
  end
  Me:updateHouseRedDotStatus()
  Me:saveNewHouseRecord()
end

function WinHouse:onOpen(targetId, oldTargetId, landName)
  Me:uiMutualExclusion("house")
  self:initView(targetId, oldTargetId, landName)
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
end

function WinHouse:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Me:sendPacket({
    pid = "InformCloseHouseUi"
  })
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
  self:hasScanAllNewHouse()
end

return WinHouse
