local WinGameMain = M
local GameTimes = T(Lib, "GameTimes")
local RedDotConfig = T(Config, "RedDotConfig")
local HouseConfig = T(Config, "HouseConfig")
local ProfessionRecommendConfig = T(Config, "ProfessionRecommendConfig")
local DramaClientHelper = T(Lib, "DramaClientHelper")
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local BusinessHelper = T(Lib, "BusinessHelper")
local OFFSET_RIGHT_TOP = 104
local OFFSET_RIGHT_ITEM_HEIGHT = 74
local OFFSET_RIGHT_GAP = 5
local notifyPartyDisplayTime = World.cfg.dramaSetting.notifyPartyDisplayTime or 3
local showMainBtnList = World.cfg.showMainBtnList or {}
local vignetteStrengthMax = World.cfg.vignetteStrengthMax or 1.0
local RIGHT_FUNC_CONFIG = {
  [Define.BTN_SORT.ROLE] = {
    key = "appearance",
    redDotKey = RedDotConfig.RD_KEY.AppearanceEntrance,
    btnTxt = "g2052.gui.appearance.title",
    icon = "set:g2052_main.json image:icon_0_main_character",
    callBack = function()
      local horseId = 0
      local entityId = 0
      local partId = 0
      local baseAction = Me:getBaseAction()
      local hasRide = false
      local hasRidePartVehicle = false
      if horseId == 0 and entityId == 0 and partId == 0 and baseAction ~= "jump_fall" and string.find(baseAction, "swim") == nil and not hasRide and not hasRidePartVehicle then
        Me:openGuideUI("role")
      elseif baseAction == "jump_fall" then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.appearance.forbid.jump.fall"))
      elseif string.find(baseAction, "swim") then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.appearance.forbid.swim"))
      else
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.appearance.forbid"))
      end
    end,
    hideBtnCallback = function()
      UI:closeWnd("role")
    end
  },
  [Define.BTN_SORT.HOUSE] = {
    key = "house",
    redDotKey = RedDotConfig.RD_KEY.HouseEntrance,
    btnTxt = "g2052.gui.house.title",
    icon = "set:g2052_main.json image:icon_0_house",
    callBack = function()
      if Me:doIOwnAHouse() then
        Me:openGuideUI("house")
      else
        Me:previewAllHouse()
      end
    end,
    hideBtnCallback = function()
      UI:closeWnd("house")
    end
  },
  [Define.BTN_SORT.CAR] = {
    key = "vehicle",
    redDotKey = RedDotConfig.RD_KEY.VehicleEntrance,
    btnTxt = "g2052.gui.car.title",
    icon = "set:g2052_main.json image:icon_0_carriers",
    callBack = function()
      Me:openGuideUI("car")
    end,
    hideBtnCallback = function()
      UI:closeWnd("car")
    end
  },
  [Define.BTN_SORT.PROFESSION] = {
    key = "profession",
    btnTxt = "g2052.gui.profession.main_title",
    icon = "set:g2052_main.json image:icon_0_occupation",
    callBack = function()
      Me:openGuideUI("professionWnd")
    end,
    hideBtnCallback = function()
      UI:closeWnd("professionWnd")
    end
  },
  [Define.BTN_SORT.BAG] = {
    key = "bag",
    redDotKey = RedDotConfig.RD_KEY.BagEntrance,
    btnTxt = "g2052.gui.bag.title",
    icon = "set:g2052_main.json image:icon_0_backpack",
    callBack = function()
      Me:openGuideUI("g2052Bag")
    end,
    hideBtnCallback = function()
      UI:closeWnd("g2052Bag")
    end
  },
  [Define.BTN_SORT.ACTION] = {
    key = "action",
    btnTxt = "g2052.gui.dance.dance_title",
    icon = "set:g2052_main.json image:icon_0_action",
    callBack = function()
      Me:openGuideUI("dance")
    end,
    hideBtnCallback = function()
      UI:closeWnd("dance")
    end
  },
  [Define.BTN_SORT.BABY] = {
    key = "partner",
    btnTxt = "g2052.gui.partner.title",
    icon = "set:g2052_main.json image:icon_0_children",
    callBack = function()
      Me:openGuideUI("partner")
    end,
    hideBtnCallback = function()
      UI:closeWnd("partner")
    end
  }
}

function WinGameMain:init()
  WinBase.init(self, "G2052GameMain.json")
  self._funcBtnGroup = {}
  self:initData()
  self:initUI()
  self:initEvent()
  self:tryOpenModMapOperator()
end

function WinGameMain:initData()
  self.ratio = UIMgr.UIShowManage:getAdapterRatio()
end

function WinGameMain:initUI()
  self.btnSetting = self:child("GameMain-btnSetting")
  self.btnDanceStop = self:child("GameMain-DanceStop")
  self.lytTimePanel = self:child("GameMain-TimePanel")
  self.txtTimeContent = self:child("GameMain-TimeContent")
  self.txtDayContent = self:child("GameMain-dayContent")
  self.btnHouseScan = self:child("GameMain-HouseScan")
  self.lytRightPanel = self:child("GameMain-RightPanel")
  self.imgRightPanelBg = self:child("GameMain-RightPanelBg")
  self.lytTopRight = self:child("GameMain-TopRight")
  self.btnDanceStop:SetVisible(false)
  self.btnShop = self:child("GameMain-btnShop")
  self.shopRed = self:child("GameMain-shopRed")
  self.shopRed:SetVisible(false)
  self.btnDrama = self:child("GameMain-btnDrama")
  self.btnDrama:SetVisible(true)
  self.imgDramaNew = self:child("GameMain-DramaNew")
  self.imgDramaNew:SetVisible(false)
  self.btnAdvertisement = self:child("GameMain-btnAdvertisement")
  self.btnAdvertisement:SetVisible(true)
  self.btnSubscription = self:child("GameMain-btnSubscription")
  self.lytActivityPanel = self:child("GameMain-ActivityPanel")
  self.btnCameraView = self:child("GameMain-CameraView")
  self.btnCancelHeld = self:child("GameMain-CancelHeld")
  self.btnCancelHeld:SetVisible(false)
  self.btnDebark = self:child("GameMain-DebarkBtn")
  self.btnChat = self:child("GameMain-btnChat")
  self.imgChatIcon = self:child("GameMain-ChatIcon")
  self.imgChatRedIcon = self:child("GameMain-ChatRedIcon")
  self.txtChatRedNum = self:child("GameMain-ChatRedNum")
  self.btnWorld = self:child("GameMain-btnWorld")
  self.imgWorldIcon = self:child("GameMain-WorldIcon")
  self.imgWorldRedIcon = self:child("GameMain-WorldRedIcon")
  self.imgWorldRedIcon:SetVisible(false)
  self.btnFriend = self:child("GameMain-btnFriend")
  self.imgFriendRedIcon = self:child("GameMain-FriendRedIcon")
  self.txtFriendRedNum = self:child("GameMain-FriendRedNum")
  self.friendRedInfo = {}
  self.imgGuideEffect = self:child("GameMain-guideEffect")
  self:child("GameMain-guideTitle"):SetText(Lang:toText("guide_guide_script"))
  self.imgGuideEffect:SetVisible(false)
  self.btnVideo = self:child("GameMain-btnVideo")
  self.imgVideoIcon = self:child("GameMain-VideoIcon")
  self.btnModEditor = self:child("GameMain-modEditor")
  self.btnGoEditor = self:child("GameMain-goEditor")
  self.btnPeakDay = self:child("GameMain-btnPeakDay")
  self.btnRideOff = self:child("GameMain-RideOff")
  self.btnRideOff:SetVisible(false)
  self.btnRideOffPet = self:child("GameMain-RideOffPet")
  self.btnRideOffPet:SetVisible(false)
  self.transformEffect = self:child("GameMain-transformEffect")
  self.btnBtnEmail = self:child("GameMain-btnEmail")
  self.lytMaskPanel = self:child("GameMain-MaskPanel")
  self.lytLeftItemPanel = self:child("GameMain-LeftItemPanel")
  self.btnPhoneBtn = self:child("GameMain-phoneBtn")
  self.imgCallEffect = self:child("GameMain-CallEffect")
  self.btnBillboardBtn = self:child("GameMain-BillboardBtn")
  self:updateBillboardBtnShow(false)
  self.btnGraffitiBtn = self:child("GameMain-GraffitiBtn")
  self.isUseGraffitiItem = false
  self.isInGraffitiCD = false
  self:updateGraffitiBtnShow()
  self.llMainNotifyParty = self:child("GameMain-notify_party")
  self.btnMainJoinParty = self:child("GameMain-join_party")
  self:child("GameMain-join_text"):SetText(Lang:toText("g2052.gui.drama.join"))
  self.listMainPartyInfo = self:child("GameMain-party_info")
  self.listMainPartyInfo:SetMoveAble(false)
  self.llMainNotifyParty:SetVisible(false)
  self.notifyParty = {}
  self.notifyPartyCell = {}
  self.imgVisionMask = self:child("GameMain-visionMask")
  Blockman.instance.gameSettings:setVignetteStrengthMax(vignetteStrengthMax)
  self.btnGmTest = self:child("GameMain-GmTest")
  self:addGM()
  self:addTestGM()
  self:updateChatRedShow(0)
  self:updateFriendRedShow()
  self:initRightFuncPanel()
  self:updateChatBtnImage(true)
  self:updateMaskPanelShow(false)
  self:updateEmailBtnShow()
  self:updateVideoViewShow(false)
  self:updatePhoneBtnShow(false)
  self:updateCallEffectShow(false)
  self:updateWorldBtnImage(false)
  self:updateWorldRedShow(0)
  self:initClickLike()
  self:initPetSpeedUp()
  self:initHalloweenCandyNum()
end

function WinGameMain:updateMaskPanelShow(value)
  self.lytMaskPanel:SetVisible(value)
end

function WinGameMain:updatePhoneBtnShow(value)
  self.btnPhoneBtn:SetVisible(value)
  self:updateCallEffectPos()
end

function WinGameMain:updateCallEffectShow(value)
  if self.callEffectTimer then
    self.callEffectTimer()
    self.callEffectTimer = nil
  end
  if value then
    self.imgCallEffect:SetVisible(true)
    local time = World.cfg.phoneProfession.callLeftTime * 20
    self.callEffectTimer = World.Timer(time, function()
      self.imgCallEffect:SetVisible(false)
      self.callEffectTimer = nil
    end)
  else
    self.imgCallEffect:SetVisible(false)
  end
end

function WinGameMain:tryOpenModMapOperator()
  if Lib.isG2052Mod() then
    self.modOpPanel = UIMgr:new_widget("modMapOperator")
    self:root():AddChildWindow(self.modOpPanel)
    self.modOpPanel:invoke("reload")
  end
end

function WinGameMain:addTestGM()
  self.btnGmTest:SetVisible(false)
end

function WinGameMain:addGM()
  if not World.gameCfg.gm then
    return
  end
  local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "Button_GM")
  btn:SetNormalImage("set:add_sub.json image:add")
  btn:SetPushedImage("set:add_sub.json image:add")
  btn:SetArea({0.5, 0}, {0, 100}, {0, 50}, {0, 50})
  self:root():AddChildWindow(btn)
  self:subscribe(btn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end)
end

function WinGameMain:initRightFuncPanel()
  local count = 0
  for i, v in ipairs(RIGHT_FUNC_CONFIG) do
    if showMainBtnList[i] then
      local btn = UIMgr:new_widget("gameMainRightFuncBtn", v)
      self.lytRightPanel:AddChildWindow(btn)
      btn:SetYPosition({
        0,
        OFFSET_RIGHT_TOP + count * (OFFSET_RIGHT_ITEM_HEIGHT + OFFSET_RIGHT_GAP)
      })
      count = count + 1
      self._funcBtnGroup[i] = btn
      if v.redDotKey then
        Plugins.CallPluginFunc("linkRedDotAction", v.redDotKey, function(show)
          btn:invoke("updateRedDotVisible", show ~= 0)
        end)
      end
    end
  end
end

function WinGameMain:showRightBtn(btn, i)
  if not btn then
    local v = RIGHT_FUNC_CONFIG[i]
    btn = UIMgr:new_widget("gameMainRightFuncBtn", v)
    self.lytRightPanel:AddChildWindow(btn)
    self._funcBtnGroup[i] = btn
    if v.redDotKey then
      Plugins.CallPluginFunc("linkRedDotAction", v.redDotKey, function(show)
        btn:invoke("updateRedDotVisible", show ~= 0)
      end)
    end
  end
  btn:SetVisible(true)
  return btn
end

function WinGameMain:hideRightBtn(btn)
  if btn then
    btn:SetVisible(false)
  end
end

function WinGameMain:updateRightBtnList(updateList)
  updateList = updateList or {}
  local count = 0
  for i, v in ipairs(RIGHT_FUNC_CONFIG) do
    local btn = self._funcBtnGroup[i]
    local isShow = updateList[i]
    if isShow == nil then
      isShow = showMainBtnList[i]
    end
    if isShow then
      btn = self:showRightBtn(btn, i)
      btn:SetYPosition({
        0,
        OFFSET_RIGHT_TOP + count * (OFFSET_RIGHT_ITEM_HEIGHT + OFFSET_RIGHT_GAP)
      })
      count = count + 1
    else
      self:hideRightBtn(btn)
      if v.hideBtnCallback then
        v.hideBtnCallback()
      end
    end
  end
end

function WinGameMain:setBtnHouseScanVisible(visible)
end

function WinGameMain:initEvent()
  self:subscribe(self.btnBtnEmail, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("tendering_land", "openMayorEmailWnd")
  end)
  self:subscribe(self.btnModEditor, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("mod_editor", "openModEditorWnd", "modMain", true)
  end)
  self:subscribe(self.btnSetting, UIEvent.EventButtonClick, function()
    UI:openWnd("setting")
  end)
  self:subscribe(self.btnVideo, UIEvent.EventButtonClick, function()
    self:updateVideoViewShow(not UI:isOpen("videoMode"))
  end)
  self:subscribe(self.btnGraffitiBtn, UIEvent.EventButtonClick, function()
    local success = Me:useDoodle()
    if success then
      self:updateGraffitiCD()
    end
  end)
  self:subscribe(self.btnChat, UIEvent.EventButtonClick, function()
    UI:getWnd("chatMini"):onShow(true)
  end)
  self:subscribe(self.btnWorld, UIEvent.EventButtonClick, function()
    UI:getWnd("worldChatWnd"):onShow(true)
  end)
  self:subscribe(self.btnFriend, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("friend", "openCloseFriendWnd", true)
  end)
  self:subscribe(self.btnDanceStop, UIEvent.EventButtonClick, function()
    self:stopDance()
  end)
  self:subscribe(self.btnShop, UIEvent.EventButtonClick, function()
    UI:openWnd("g2052Shop")
  end)
  self:subscribe(self.btnSubscription, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("subscribe_vip", "UpdateSubscribeVipUIOpen", true)
  end)
  self:subscribe(self.btnDrama, UIEvent.EventButtonClick, function()
    UI:openWnd("dramaMain")
    Lib.emitEvent(Event.EVENT_TRIGGER_GUIDE_OPERATION, false)
    self.btnDramaIsClick = true
    self:updateDramaNewShow()
  end)
  self:subscribe(self.btnCameraView, UIEvent.EventButtonClick, function()
    if Me.isInteractCarEnterID and Me.isInteractCarEnterID ~= "" then
      return
    end
    Me:startCameraMode()
  end)
  self:subscribe(self.btnCancelHeld, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("interaction_ui", "cancelInteractiveAction")
  end)
  self:subscribe(self.btnPhoneBtn, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("profession", "openCallProfessionWnd")
  end)
  self:subscribe(self.btnRideOff, UIEvent.EventButtonClick, function()
    local inUseCar = Me:getInUseCar()
    if inUseCar then
      local function operationCar()
        local params = {
          id = inUseCar.id
        }
        Me:sendPacket({
          pid = "OnOperationCar",
          params = params
        }, function(ret)
          if not ret then
            print("--win gameMain no choice item--")
          end
        end)
      end
      
      local isSkateEntity = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_ENTITY", inUseCar.id)
      if isSkateEntity then
        local canLeaveSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_CAN_LEAVE_SKATE_MODE")
        if not canLeaveSkateMode then
          return
        end
        operationCar()
      else
        operationCar()
      end
    end
  end)
  self:subscribe(self.btnRideOffPet, UIEvent.EventButtonClick, function()
    local objId_pet = Me:getCurCarryPetObjId()
    local pet = World.CurWorld:getObject(objId_pet)
    if not pet or not pet:isValid() then
      return
    end
    if Me.rideOnId ~= objId_pet then
      return
    end
    Me:sendPacket({
      pid = "rideOffFromPet"
    })
  end)
  self:subscribe(self.btnDebark, UIEvent.EventButtonClick, function()
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
  end)
  self:subscribe(self.btnGoEditor, UIEvent.EventButtonClick, function()
    CGame.instance:restartGame(CGame.Instance():getGameRootDir(), World.GameName, 1, true)
  end)
  self:subscribe(self.btnHouseScan, UIEvent.EventButtonClick, function()
    Me:previewAllHouse()
  end)
  self:subscribe(self.btnBillboardBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.BillboardData)
  end)
  self:subscribe(self.btnPeakDay, UIEvent.EventButtonClick, function()
    UI:getWnd("peakDay"):onShow()
    Plugins.CallTargetPluginFunc("report", "report", "peakday_openUI", {}, Me)
  end)
  self:subscribe(self.btnMainJoinParty, UIEvent.EventWindowClick, function()
    if not self.notifyParty[1] then
      return
    end
    local partyId = self.notifyParty[1].partyId
    if partyId then
      Me:requestJoinDrama(partyId, true)
    end
  end)
  self:subscribe(self.btnAdvertisement, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain")
  end)
end

function WinGameMain:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TRANSFORM_START, function()
    self.transformEffect:SetVisible(true)
    self.transformEffect:PrepareEffect()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TRANSFORM_END, function()
    self.transformEffect:SetVisible(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_PERSONVIEW, function()
    self:updatePerspeceIcon()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(objID)
    if Me.objID ~= objID then
      return
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_OFF, function(objID)
    if Me.objID ~= objID then
      return
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_IN_USE_CAR, function(inUseCarInfo, objID)
    if objID ~= Me.objID then
      return
    end
    if inUseCarInfo and Me:checkVehicleIsPrimary(inUseCarInfo.id) then
      self.btnRideOff:SetVisible(true)
    else
      self.btnRideOff:SetVisible(false)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PET_RIDE_STATUS_CHANGE, function(isRideOn)
    self.btnRideOffPet:SetVisible(isRideOn)
    self:setPetSpeedUpVisible(isRideOn)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, function(value)
    self:updateRightPanelShow(value)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_OPERATION_PANEL_VISIBLE, function(visible)
    self:setClickLikeVisible(not visible)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_FRIEND_UPDATE_RED_NUM, function(type, redNum)
    self.friendRedInfo[type] = redNum
    self:updateFriendRedShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_CHAT_ICON, function(isShow)
    self:updateChatBtnImage(isShow)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_CHAT_RED, function(redNum)
    self:updateChatRedShow(redNum)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_PERSONVIEW, function()
    self:updatePerspeceIcon()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_TENDERING_INFO, function()
    self:updateEmailBtnShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_CALL_EFFECT, function(isShow)
    self:updateCallEffectShow(isShow)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MAIN_ITEM_BTN, function(isShow, itemKey)
    self:updatePhoneBtnShow(false)
    self:updateBillboardBtnShow(false)
    self.isUseGraffitiItem = false
    if isShow then
      if itemKey == World.cfg.phoneProfession.phoneItemId then
        self:updatePhoneBtnShow(true)
      elseif itemKey == World.cfg.graffitiSetting.graffitiItemId then
        self.isUseGraffitiItem = true
      elseif itemKey == Define.ThrowObjType.Billboard then
        self:updateBillboardBtnShow(true)
      end
    end
    self:updateGraffitiBtnShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PEAK_DAY_BTN, function(visible)
    self.btnPeakDay:SetVisible(visible)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_WORLD_ICON_SHOW, function(isShow)
    self:updateWorldBtnImage(isShow)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_WORLD_RED_SHOW, function(num)
    self:updateWorldRedShow(num)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_MESSAGE_NOTICE, function(data)
    self:showMessageNotice(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    self:updateDramaBtnShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_CUR_DETAIL, function()
    self:updateDramaBtnShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PROFESSION_UPDATE_CAREER, function(isFromScene)
    self:updateProfessionRecommend(isFromScene)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PROFESSION_WIN_OPEN, function()
    self:updateProfessionRecommend(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TRIGGER_GUIDE_OPERATION, function(isShow)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, function()
    print("----------------------- receive  EVENT_HALLOWEEN_OPEN_STATE_UPDATE ", HalloweenHelperCommon:isHalloweenDay())
    self:initHalloweenCandyNum()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GUIDE_DATA_UPDATE, function()
    self:updateDramaNewShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_BUSINESS_RED, function()
    self:updateShopRedShow()
  end)
end

function WinGameMain:updateDramaBtnShow()
  if Lib.isGameDrama() then
    self.imgGuideEffect:SetVisible(false)
    Blockman.instance.gameSettings:setEnableVignette(DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.FOG))
  end
end

function WinGameMain:updateWorldRedShow(num)
  self.imgWorldRedIcon:SetVisible(0 < num)
end

function WinGameMain:updateWorldBtnImage(isShow)
  if isShow then
    self.imgWorldIcon:SetImage("set:g2052_main.json image:btn_0_world01")
  else
    self.imgWorldIcon:SetImage("set:g2052_main.json image:btn_0_world")
  end
end

function M:updateEmailBtnShow()
  local showEmail = Plugins.CallTargetPluginFunc("tendering_land", "checkIsCanSendMayorEmail", Me.platformUserId)
  self.btnBtnEmail:SetVisible(showEmail)
end

function M:updateBillboardBtnShow(isShow)
  self.btnBillboardBtn:SetVisible(isShow)
end

function M:updateGraffitiCD()
  local cd = World.cfg.graffitiSetting.UseSprayCdTime
  self.isInGraffitiCD = true
  self:updateGraffitiBtnShow()
  self._timer[#self._timer + 1] = Me:timer(20, function()
    cd = cd - 1
    if cd < 0 then
      self.isInGraffitiCD = false
      self:updateGraffitiBtnShow()
      return false
    else
      return true
    end
  end)
end

function M:updateGraffitiBtnShow()
  if self.isUseGraffitiItem then
    self.btnGraffitiBtn:SetVisible(true)
    if self.isInGraffitiCD then
      self.btnGraffitiBtn:SetEnabled(false)
      self.btnGraffitiBtn:SetTouchable(false)
    else
      self.btnGraffitiBtn:SetEnabled(true)
      self.btnGraffitiBtn:SetTouchable(true)
    end
  else
    self.btnGraffitiBtn:SetVisible(false)
  end
end

function M:updateFriendRedShow()
  local num = 0
  for _, val in pairs(self.friendRedInfo) do
    num = num + val
  end
  self.txtFriendRedNum:SetText(num)
  self.imgFriendRedIcon:SetVisible(0 < num)
end

function M:updateChatRedShow(num)
  self.txtChatRedNum:SetText(num)
  self.imgChatRedIcon:SetVisible(0 < num)
end

function WinGameMain:initView()
  self._timer[#self._timer + 1] = Me:timer(5, function()
    local tbTime = GameTimes:GetTime()
    local min = tbTime.min >= 10 and tostring(tbTime.min) or "0" .. tbTime.min
    local time = tbTime.hour .. ":" .. min
    self.txtTimeContent:SetText(time)
    self.txtDayContent:SetText(Lang:toText(Define.GameTimeDay[tbTime.day]))
    return true
  end)
  self.btnGoEditor:SetVisible(Me:checkIsMobileEditor())
  self.btnChat:SetVisible(not Me:checkIsMobileEditor())
  self.btnFriend:SetVisible(not Me:checkIsMobileEditor())
  self:updateDramaBtnShow()
  self:updateDramaNewShow()
  self:updateShopRedShow()
end

function WinGameMain:updateShopRedShow()
  local needShow = BusinessHelper:getMainShopRedShowState()
  self.shopRed:SetVisible(needShow)
end

function WinGameMain:updateDramaNewShow()
  if self.btnDramaIsClick then
    self.imgDramaNew:SetVisible(false)
  else
    local guideData = Me:getGuideData()
    if not guideData.dramaMain then
      self.imgDramaNew:SetVisible(true)
    else
      self.imgDramaNew:SetVisible(false)
    end
  end
end

function WinGameMain:updateVideoViewShow(value)
  if value then
    self:updateModBtnShow(false)
    Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", true)
  else
    self:updateModBtnShow(true)
    Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
  end
end

function WinGameMain:updateModBtnShow(value)
  if value then
    local isG2052Editor = Lib.isG2052ModEditor()
    self.btnModEditor:SetVisible(not isG2052Editor)
  else
    self.btnModEditor:SetVisible(false)
  end
  if not World.cfg.showModBtnOnGameMain then
    self.btnModEditor:SetVisible(false)
  end
  if self.btnModEditor:IsVisible() then
    self.lytLeftItemPanel:SetXPosition({0, 100})
  else
    self.lytLeftItemPanel:SetXPosition({0, 10})
  end
  self:updateCallEffectPos()
end

function WinGameMain:updateCallEffectPos()
  if self.btnPhoneBtn:IsVisible() then
    self.imgCallEffect:SetXPosition({0, 80})
  else
    self.imgCallEffect:SetXPosition({0, 0})
  end
end

function WinGameMain:updateRightPanelShow(value)
  self.rightPanelShow = not value
  self.lytRightPanel:SetVisible(value)
  self.imgRightPanelBg:SetVisible(value)
  self.lytTopRight:SetVisible(value)
  self:setClickLikeVisible(value)
end

function M:updateCancelInteractiveShow(isShow)
  self.btnCancelHeld:SetVisible(isShow)
end

function WinGameMain:updateRideOffBtnShow(value)
  if value == false then
    self.btnRideOff:SetVisible(false)
  else
    local inUseCar = Me:getInUseCar()
    if inUseCar and Me:checkVehicleIsPrimary(inUseCar.id) then
      self.btnRideOff:SetVisible(true)
    else
      self.btnRideOff:SetVisible(false)
    end
  end
end

function WinGameMain:updateRideOffPetBtnShow(value)
  if value == false then
    self.btnRideOffPet:SetVisible(false)
    self:setPetSpeedUpVisible(false)
  else
    local objId_pet = Me:getCurCarryPetObjId()
    if Me.rideOnId > 0 and objId_pet == Me.rideOnId then
      self.btnRideOffPet:SetVisible(true)
      self:setPetSpeedUpVisible(true)
    else
      self.btnRideOffPet:SetVisible(false)
      self:setPetSpeedUpVisible(false)
    end
  end
end

function WinGameMain:updatePerspeceIcon()
  local view = Blockman.instance:getCurrPersonView()
  Me:sendPacket({
    pid = "SyncViewInfo",
    view = view
  })
  Me:setValue("playerPersonView", view)
end

function WinGameMain:stopDance()
  self.btnDanceStop:SetVisible(false)
  Plugins.CallTargetPluginFunc("interaction_ui", "stopDanceAction")
end

function WinGameMain:updateStopDanceBtnShow(isAdd, actionTime)
  if self.danceTimer then
    self.danceTimer()
    self.danceTimer = nil
  end
  if not isAdd then
    self.btnDanceStop:SetVisible(false)
  else
    local actionTime = tonumber(actionTime or -1)
    if actionTime ~= -1 then
      self.danceTimer = World.Timer(actionTime, function()
        self:stopDance()
      end)
    end
    self.btnDanceStop:SetVisible(true)
  end
end

function WinGameMain:updateChatBtnImage(isShow)
  if isShow then
    self.imgChatIcon:SetImage("set:g2052_main.json image:btn_0_chat01")
  else
    self.imgChatIcon:SetImage("set:g2052_main.json image:btn_0_chat")
  end
end

function WinGameMain:showMessageNotice(data)
  if data.white then
    if not self.widgetMessageNoticeWhite then
      self.widgetMessageNoticeWhite = UIMgr:new_widget("messageNotice2")
      if self.widgetMessageNoticeWhite then
        self:root():AddChildWindow(self.widgetMessageNoticeWhite)
      end
    end
    if self.widgetMessageNoticeWhite then
      self.widgetMessageNoticeWhite:invoke("reset", data)
    end
  else
    if not self.widgetMessageNotice then
      self.widgetMessageNotice = UIMgr:new_widget("messageNotice")
      if self.widgetMessageNotice then
        self:root():AddChildWindow(self.widgetMessageNotice)
      end
    end
    if self.widgetMessageNotice then
      self.widgetMessageNotice:invoke("reset", data)
    end
  end
end

function WinGameMain:showNotifyParty(content)
  local name = ""
  local str = ""
  if content then
    table.insert(self.notifyParty, content)
  end
  if self.notifyTimer then
    if self.notifyParty[2] and self.notifyPartyCell[2] then
      local nameColor = self.notifyParty[2].isVip and "       \226\150\162FFF6CC08" or "\226\150\162FF3CB3FF"
      name = nameColor .. World.getEntityOriginalName(self.notifyParty[2].name)
      str = name .. "\226\150\162FFFFFFFF" .. Lang:toText({
        "g2052.gui.notify.party.create",
        "g2052.gui.drama.template.name" .. self.notifyParty[2].partyType
      })
      self.notifyPartyCell[2]:invoke("updateInfo", str, self.notifyParty[2].isVip)
    end
    return
  end
  if not self.notifyParty[1] then
    self.llMainNotifyParty:SetVisible(false)
    return
  end
  for i = 1, 2 do
    if not self.notifyPartyCell[i] then
      local cell = UIMgr:new_widget("notify_cell")
      self.listMainPartyInfo:AddItem(cell)
      cell:SetYPosition({
        0,
        (i - 1) * 44
      })
      self.notifyPartyCell[i] = cell
    else
      self.notifyPartyCell[i]:SetYPosition({
        0,
        (i - 1) * 44
      })
      self.notifyPartyCell[i]:SetXPosition({0, 0})
    end
  end
  local textLen
  if self.notifyParty[1] and self.notifyPartyCell[1] then
    local nameColor = self.notifyParty[1].isVip and "       \226\150\162FFF6CC08" or "\226\150\162FF3CB3FF"
    name = nameColor .. World.getEntityOriginalName(self.notifyParty[1].name)
    str = name .. "\226\150\162FFFFFFFF" .. Lang:toText({
      "g2052.gui.notify.party.create",
      "g2052.gui.drama.template.name" .. self.notifyParty[1].partyType
    })
    self.llMainNotifyParty:SetVisible(true)
    textLen = self.notifyPartyCell[1]:invoke("updateInfo", str, self.notifyParty[1].isVip)
  end
  if self.notifyParty[2] and self.notifyPartyCell[2] then
    local nameColor = self.notifyParty[2].isVip and "       \226\150\162FFF6CC08" or "\226\150\162FF3CB3FF"
    name = nameColor .. World.getEntityOriginalName(self.notifyParty[2].name)
    str = name .. "\226\150\162FFFFFFFF" .. Lang:toText({
      "g2052.gui.notify.party.create",
      "g2052.gui.drama.template.name" .. self.notifyParty[2].partyType
    })
    self.notifyPartyCell[2]:invoke("updateInfo", str, self.notifyParty[2].isVip)
  end
  local time = 0
  local offset = textLen - self.listMainPartyInfo:GetPixelSize().x
  local speed = 0
  if 0 < offset then
    speed = -1 * offset / (notifyPartyDisplayTime * 20)
  end
  local lineSpeed = -2.2
  self.listMainPartyInfo:SetScrollOffset(0)
  self.notifyTimer = World.LightTimer("notify_party_row,", 1, function()
    time = time + 1
    if speed ~= 0 then
      self.notifyPartyCell[1]:SetXPosition({
        0,
        speed * time
      })
    end
    if time == notifyPartyDisplayTime * 20 then
      if self.lineTimer then
        self.lineTimer()
      end
      if self.notifyParty[2] then
        local lineTime = 0
        self.lineTimer = World.LightTimer("notify_party_row,", 1, function()
          lineTime = lineTime + 1
          self.listMainPartyInfo:SetScrollOffset(lineSpeed * lineTime)
          if lineTime == 20 then
            table.remove(self.notifyParty, 1)
            self.notifyTimer = nil
            self:showNotifyParty()
            return false
          else
            return true
          end
        end)
        return false
      end
      table.remove(self.notifyParty, 1)
      self.notifyTimer = nil
      self:showNotifyParty()
      return false
    else
      return true
    end
  end)
end

function WinGameMain:initClickLike()
  if Lib.isGameDrama() then
    self.widgetDramaClickLike = UIMgr:new_widget("dramaClickLike")
    if self.widgetDramaClickLike then
      self:root():AddChildWindow(self.widgetDramaClickLike)
    end
  end
end

function WinGameMain:setClickLikeVisible(show)
  local operationPanelShow = false
  local win = UI:getWnd("houseAndCarOperation", true)
  if win then
    operationPanelShow = win:isOperationPanelShowed()
  end
  local visible = show and not self.rightPanelShow and not operationPanelShow
  if self.widgetDramaClickLike then
    self.widgetDramaClickLike:SetVisible(visible)
  end
end

function WinGameMain:updateProfessionRecommend(isFromScene)
  if World.cfg.NoProfessionRecommend then
    return
  end
  local professionId = Me:getProfessionId()
  if not professionId or professionId == Define.CareerType.Base then
    UI:getWnd("professionRecommend"):onHide()
    return
  end
  local recommendList = ProfessionRecommendConfig:getRecommendListById(professionId)
  if not recommendList or next(recommendList) == nil then
    UI:getWnd("professionRecommend"):onHide()
    return
  end
  UI:getWnd("professionRecommend"):onShow(isFromScene)
end

function WinGameMain:initPetSpeedUp()
  self.widgetPetSpeedUp = UIMgr:new_widget("petSpeedUp")
  if self.widgetPetSpeedUp then
    self:root():AddChildWindow(self.widgetPetSpeedUp)
    self:setPetSpeedUpVisible(false)
  end
end

function WinGameMain:setPetSpeedUpVisible(show)
  if not self.widgetPetSpeedUp then
    return
  end
  self.widgetPetSpeedUp:SetVisible(show)
end

function WinGameMain:initHalloweenCandyNum()
  print(">>>>>>>>>>>>>>>>>>>>> initHalloweenCandyNum(),isHalloweenDay ", HalloweenHelperCommon:isHalloweenDay())
  if HalloweenHelperCommon:isHalloweenDay() then
    self.widgetHalloweenCandyNum = UIMgr:new_widget("halloweenCandyNum")
    if self.widgetHalloweenCandyNum then
      self:root():AddChildWindow(self.widgetHalloweenCandyNum)
    end
  elseif self.widgetHalloweenCandyNum then
    self.widgetHalloweenCandyNum:SetVisible(false)
  end
end

function WinGameMain:onHide()
  UI:closeWnd("gameMain")
end

function WinGameMain:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("gameMain")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGameMain:onOpen()
  self._allEvent = {}
  self._timer = {}
  self:subscribeEvent()
  self:initView()
end

function WinGameMain:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self._timer then
    for k, fun in pairs(self._timer) do
      fun()
    end
  end
  if self.danceTimer then
    self.danceTimer()
  end
  if self.callEffectTimer then
    self.callEffectTimer()
    self.callEffectTimer = nil
  end
end

return WinGameMain
