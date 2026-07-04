local WinLimitedTimeActivityWnd = M
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local activityList = {}

local function getCountDown(self)
  if not self.curEndTime then
    return 0
  end
  local curTime = LimitedTimeActivityGameMgr:getServerTime()
  local surplus = self.curEndTime - curTime
  if surplus < 0 then
    return 0
  end
  local d = math.floor(surplus / 86400)
  local h, m, s = Lib.timeFormatting(surplus % 86400)
  if 0 < d then
    return d .. "d " .. h .. "hour "
  end
  if 0 < h then
    return h .. "h " .. m .. "min "
  end
  return m .. "min " .. s .. "s "
end

local function getTimeByArray(array)
  local data = {
    year = array[1] or 0,
    month = array[2] or 0,
    day = array[3] or 0,
    hour = array[4] or 0,
    min = array[5] or 0,
    sec = array[6] or 0
  }
  return os.time(data)
end

function WinLimitedTimeActivityWnd:init()
  WinBase.init(self, "LimitedTimeActivityWnd.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeActivityWnd:initData()
  self.screenWnd = {}
  self.activityData = {}
  self.activityBtn = {}
  self.curClickKey = Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY
  local data = LimitedTimeActivityConfig:getSameGroupByCommonWnd(Define.LIMITED_TIME_ACTIVITY_WND.COMMON_WND)
  activityList = data
end

function WinLimitedTimeActivityWnd:initUI()
  self.imgBg = self:child("LimitedTimeActivityWnd-bg")
  self.imgContent = self:child("LimitedTimeActivityWnd-content")
  self.lytScreen = self:child("LimitedTimeActivityWnd-screen")
  self.imgBtnListBg = self:child("LimitedTimeActivityWnd-btnListBg")
  self.lytBtnList = self:child("LimitedTimeActivityWnd-btnList")
  self.imgTop = self:child("LimitedTimeActivityWnd-top")
  self.btnClose = self:child("LimitedTimeActivityWnd-close")
  self.imgCloseIcon = self:child("LimitedTimeActivityWnd-closeIcon")
  self.imgGDiamonds = self:child("LimitedTimeActivityWnd-gDiamonds")
  self.btnGDiamondsAdd = self:child("LimitedTimeActivityWnd-gDiamonds_add")
  self.imgGDiamondsIcon = self:child("LimitedTimeActivityWnd-gDiamonds_icon")
  self.txtGDiamondsNum = self:child("LimitedTimeActivityWnd-gDiamonds_num")
  self.imgToken = self:child("LimitedTimeActivityWnd-token")
  self.btnTokenAdd = self:child("LimitedTimeActivityWnd-token_add")
  self.imgTokenIcon = self:child("LimitedTimeActivityWnd-token_icon")
  self.txtTokenNum = self:child("LimitedTimeActivityWnd-token_num")
  self.imgTime = self:child("LimitedTimeActivityWnd-time")
  self.imgTimeIcon = self:child("LimitedTimeActivityWnd-time_icon")
  self.txtCountDown = self:child("LimitedTimeActivityWnd-count_down")
  self.effectFisherman = self:child("LimitedTimeActivityWnd-fisherman_effect")
  self.ltyNpcDialog = self:child("LimitedTimeActivityWnd-npc_dialog")
  self:child("LimitedTimeActivityWnd-dialog_text"):SetText(Lang:toText("gui.limit.time.activity.fisherman.dec"))
  self.imgDialogNext = self:child("LimitedTimeActivityWnd-dialog_next")
  self:child("LimitedTimeActivityWnd-dialog_next_text"):SetText(Lang:toText("gui.limit.time.activity.continue"))
  self:child("LimitedTimeActivityWnd-fisherman_tip"):SetText(Lang:toText("gui.limit.time.activity.click.skip"))
  self:initBtnList()
end

function WinLimitedTimeActivityWnd:initBtnList()
  self.gvBtnList = UIMgr:new_widget("grid_view")
  self.lytBtnList:AddChildWindow(self.gvBtnList)
  self.gvBtnList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBtnList:InitConfig(0, 0, 1)
  self.gvBtnList:SetMoveAble(false)
  self.gvBtnList:SetAutoColumnCount(false)
  self.gvBtnList:SetClipChild(false)
end

function WinLimitedTimeActivityWnd:changeCurrency()
  local wallet = Me:data("wallet")
  if wallet.gDiamonds then
    self.imgGDiamondsIcon:SetImage(Coin:iconByCoinName("gDiamonds"))
    self.txtGDiamondsNum:SetText(wallet.gDiamonds.count or 0)
  end
  local gameCashCoupon = wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0
  self.txtTokenNum:SetText(gameCashCoupon)
  self.imgToken:SetVisible(true)
  self.imgTokenIcon:SetImage(Coin:iconByCoinName("gameCashCoupon"))
end

function WinLimitedTimeActivityWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnGDiamondsAdd, UIEvent.EventButtonClick, function()
    Interface.onRecharge(1)
  end)
  self:subscribe(self.btnTokenAdd, UIEvent.EventButtonClick, function()
    Interface.onRecharge(5)
  end)
  self:subscribe(self.ltyNpcDialog, UIEvent.EventWindowClick, function()
    if not self.npcDialogTime then
      self.ltyNpcDialog:SetVisible(false)
    end
  end)
  self:subscribe(self.effectFisherman, UIEvent.EventWindowClick, function()
    if self.receiveAwardTimer then
      self.receiveAwardTimer()
      self.receiveAwardTimer = nil
      self.effectFisherman:SetVisible(false)
      Me:stopUiSoundByKey("playMustWinLotterySound")
      UI:closeWnd("limitedTimeActivityAwardPopup")
    end
    if self.mustWinLotteryAddition then
      UI:openWnd("limitedTimeActivityAwardPopup", self.mustWinLotteryAddition)
      Lib.emitEvent(Event.EVENT_UPDATE_MUST_WIN_LOTTERY, self.mustWinLotteryAddition)
    end
  end)
end

function WinLimitedTimeActivityWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY, function()
    self:updateTabListShow()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client WinLimitedTimeActivityWnd Lib event : EVENT_CHANGE_CURRENCY", Event.EVENT_CHANGE_CURRENCY, function()
    self:changeCurrency()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PLAY_MUST_WIN_LOTTERY_RESULT, function(addition)
    self:showMustWinLotteryEffect(addition)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_TAB_RED, function(activityType, isShow)
    self:updateBtnRedDot(activityType, isShow)
  end)
end

function WinLimitedTimeActivityWnd:showMustWinLotteryEffect(addition)
  if self.receiveAwardTimer then
    self.receiveAwardTimer()
    self.receiveAwardTimer = nil
    self.effectFisherman:SetVisible(false)
    Me:stopUiSoundByKey("playMustWinLotterySound")
    UI:closeWnd("limitedTimeActivityAwardPopup")
  end
  self.effectFisherman:SetVisible(true)
  self.effectFisherman:PlayEffect()
  Me:playUiSoundByKey("playMustWinLotterySound")
  self.mustWinLotteryAddition = addition
  self.receiveAwardTimer = Me:timer(50, function()
    self.effectFisherman:SetVisible(false)
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
    Lib.emitEvent(Event.EVENT_UPDATE_MUST_WIN_LOTTERY, addition)
    self.mustWinLotteryAddition = false
  end)
end

function WinLimitedTimeActivityWnd:updateBtnRedDot(type, isShow)
  if self.activityBtn[type] then
    self.activityBtn[type]:invoke("updateRedDot", isShow)
  end
end

function WinLimitedTimeActivityWnd:initView()
  if self.activityTimer then
    self.activityTimer()
    self.activityTimer = nil
  end
  if self.receiveAwardTimer then
    self.receiveAwardTimer()
    self.receiveAwardTimer = nil
    self.effectFisherman:SetVisible(false)
  end
  self:updateTabListShow()
  self:changeCurrency()
  self.txtCountDown:SetText(getCountDown(self))
  self.activityTimer = Me:timer(20, function()
    self:updateDownTimeShow()
    if self.curWndName then
      local wnd = UI:getWnd(self.curWndName)
      if wnd.updateDownTimeShow then
        wnd:updateDownTimeShow()
      end
    end
    return true
  end)
end

function WinLimitedTimeActivityWnd:updateDownTimeShow()
  self.txtCountDown:SetText(getCountDown(self))
end

function WinLimitedTimeActivityWnd:updateTabListShow()
  local needHide = true
  local initShowTab, selectShowTab
  local wndCount = 0
  for index, val in ipairs(activityList) do
    local isOpen = LimitTimeClientHelper:checkActiveIsOpen(val.key)
    if isOpen then
      wndCount = wndCount + 1
      if not self.activityBtn[val.key] then
        local cell = UIMgr:new_widget("limitedTimeActivityBtn")
        cell:invoke("updateView", val)
        cell:invoke("setCallBackFunc", function(info)
          if self.curClickKey == info.key then
            return
          end
          self:clickActivityBtn(info)
        end)
        self.gvBtnList:AddItem(cell)
        self.activityBtn[val.key] = cell
      else
        self.activityBtn[val.key]:invoke("updateView", val)
      end
      needHide = false
      initShowTab = initShowTab or val
      if val.key == self.curClickKey then
        selectShowTab = val
      end
    else
      if self.screenWnd[val.key] then
        self.lytScreen:RemoveItem(self.screenWnd[val.key]:root())
        self.screenWnd[val.key] = nil
        UI:closeWnd(val.tabJson)
      end
      if self.activityBtn[val.key] then
        self.gvBtnList:RemoveItem(self.activityBtn[val.key])
        self.activityBtn[val.key] = nil
      end
    end
  end
  self:clickActivityBtn(selectShowTab or initShowTab)
  self.gvBtnList:SetMoveAble(6 < wndCount)
  if needHide then
    self:onHide()
  end
end

function WinLimitedTimeActivityWnd:clickActivityBtn(tabParams)
  if not tabParams then
    return
  end
  if self.curWndName then
    UI:closeWnd(self.curWndName)
    self.curWndName = nil
  end
  self.curClickKey = tabParams.key
  local wndName = tabParams.tabJson
  if not wndName then
    return
  end
  self.curWndName = wndName
  local wnd = UI:openWnd(wndName)
  self.lytScreen:AddChildWindow(wnd:root())
  local params = LimitTimeClientHelper:getParamsByActiveType(tabParams.key)
  if params then
    self.imgTime:SetVisible(true)
    self.curEndTime = nil
    local curTime = LimitedTimeActivityGameMgr:getServerTime()
    local endTime = 0
    if tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT then
      endTime = 0
    else
      endTime = params.contentEndTime and params.contentEndTime or params.endNumTime or getTimeByArray(params.endTime)
    end
    if tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT then
      local realEndTime = Lib.getActivityWeekEndTime(curTime)
      if endTime < realEndTime then
        self.curEndTime = endTime
      else
        self.curEndTime = realEndTime
      end
    elseif tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT then
      local realEndTime = Lib.getMonthEndTime(curTime)
      if endTime < realEndTime then
        self.curEndTime = endTime
      else
        self.curEndTime = realEndTime
      end
    elseif tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT then
      self.curEndTime = params.endNumTime or getTimeByArray(params.endTime)
    elseif tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD then
      self.imgTime:SetVisible(false)
      Me.haveOpenLimitedTimeCardWnd = true
      LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD)
    elseif tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT then
      self.imgTime:SetVisible(false)
    else
      self.curEndTime = endTime
    end
  else
    self.curEndTime = nil
  end
  self:updateDownTimeShow()
  for key, _ in pairs(self.activityBtn) do
    self.activityBtn[key]:invoke("updateSelectState", self.curClickKey == key)
  end
  self.ltyNpcDialog:SetVisible(false)
  self.effectFisherman:SetVisible(false)
  if tabParams.key == Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY then
    local info = Me:getInitialEnterInto()
    if not info[tabParams.key] then
      self.npcDialogTime = true
      self.ltyNpcDialog:SetVisible(true)
      self.imgDialogNext:SetVisible(false)
      self.npcDialogTime = Me:timer(40, function()
        self.imgDialogNext:SetVisible(true)
        self.npcDialogTime = false
      end)
      info[tabParams.key] = true
      Me:setInitialEnterInto(info)
    end
  end
end

function WinLimitedTimeActivityWnd:onHide()
  UI:closeWnd("limitedTimeActivityWnd")
end

function WinLimitedTimeActivityWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeActivityWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeActivityWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLimitedTimeActivityWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.activityTimer then
    self.activityTimer()
    self.activityTimer = nil
  end
  for _, val in pairs(activityList) do
    UI:closeWnd(val.tabJson)
  end
  self.screenWnd = {}
end

return WinLimitedTimeActivityWnd
