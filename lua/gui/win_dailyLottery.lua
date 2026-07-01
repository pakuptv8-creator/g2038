local DailyLotteryConfig = T(Config, "DailyLotteryConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local LuaTimer = T(Lib, "LuaTimer")
local setting = require("common.setting")

function M:init()
  self._allEvent = {}
  WinBase.init(self, "DailyLottery.json", false)
  self:initWnd()
end

function M:initWnd()
  self.close = self:child("dailyLottery-close")
  self.startBtn = self:child("dailyLottery-start_btn")
  self.buyBtn = self:child("dailyLottery-buyBtn")
  self.gotoShopBtnText = self:child("dailyLottery-gotoshopBtnText")
  self.gotoShopBtnText:SetText(Lang:toText("gui_gui_daily_lottery_goto_shop"))
  self.stateTextBg = self:child("dailyLottery-stateBg")
  self.stateText = self:child("dailyLottery-stateText")
  self.stateText:SetVisible(false)
  self.stateTextBg:SetVisible(false)
  self.decTitleText = self:child("dailyLottery-title")
  self.decDetailText = self:child("dailyLottery-detailDec")
  self.decTitleText:SetText(Lang:toText("gui_daily_lottery_dec_title"))
  self.decDetailText:SetText(Lang:toText("gui_daily_lottery_dec_detail"))
  self.lotteryCountText = self:child("dailyLottery-remainCount")
  self.lotteryCountText:SetText("X 0")
  self.startGuide = self:child("dailyLottery-startGuide")
  self.startGuide:SetVisible(false)
  self.itemList = {}
  for i = 1, World.cfg.dailyLotteryMaxItemNum do
    local item = {}
    item.itemCell = self:child("dailyLottery-item_" .. i)
    item.itemIcon = self:child("dailyLottery-item" .. i .. "Icon")
    item.itemIcon:SetTouchable(false)
    item.itemNum = self:child("dailyLottery-item" .. i .. "Num")
    item.itemNum:SetTouchable(false)
    item.itemName = self:child("dailyLottery-item" .. i .. "Name")
    item.itemName:SetTouchable(false)
    item.pickMask = self:child("dailyLottery-item" .. i .. "Mask")
    item.pickMask:SetTouchable(false)
    item.itemEffect = self:child("dailyLottery-item" .. i .. "Effect")
    item.itemEffect:SetTouchable(false)
    item.itemQuality = self:child("dailyLottery-item" .. i .. "Quality")
    item.itemQuality:SetTouchable(false)
    item.itemEdgeEffect = self:child("dailyLottery-item" .. i .. "EdgeEffect")
    item.itemEdgeEffect:SetTouchable(false)
    self.itemList[i] = item
    self.itemList[i].pickMask:SetVisible(false)
    self.itemList[i].itemEffect:SetVisible(false)
    self.itemList[i].itemEdgeEffect:SetVisible(false)
  end
  self:initEvent()
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self:child("dailyLottery-mask"), 1280, 720)
end

function M:initEvent()
  self:subscribe(self.close, UIEvent.EventButtonClick, function()
    if Me:getGainFirstOrangePet() == 1 then
      Me:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.TIME)
    end
    UI:closeWnd(self)
  end)
  self:subscribe(self.startBtn, UIEvent.EventButtonClick, function()
    self.startGuide:SetVisible(false)
    Me:gameBehaviorReport("LukeyPan_click", 1)
    self:tryDoLottery()
  end)
  self:subscribe(self.buyBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
    UI:getWnd("pokemonRegularGift"):onShow(true)
    Me:gameBehaviorReport("RegularGift_openByLottery", 1)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DAILY_LOTTERY_RESPONE, function(index, crlcle, pickList)
    self:doLottery(index, crlcle, pickList)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DAILY_LOTTERY_NUM_CHANGE, function(value)
  end)
end

function M:doLottery(index, curCircle, curPickList)
  curPickList = curPickList or {}
  
  local function getAblePickList()
    local pickList = {}
    for i = 1, World.cfg.dailyLotteryMaxItemNum do
      local isCanPick = true
      for j = 1, #curPickList do
        if i == curPickList[j] and i ~= index then
          isCanPick = false
        end
      end
      if isCanPick then
        table.insert(pickList, i)
      end
    end
    return pickList
  end
  
  local ablePickList = getAblePickList()
  local item = DailyLotteryConfig:getItemData(curCircle, index)
  
  local function showPickEffect(itemIndex, time)
    if time >= World.cfg.dailyLotteryEffectShowTimes then
      self:playEffect(itemIndex, 2)
      if self.itemList[itemIndex] and self.itemList[itemIndex].pickMask then
        self.itemList[itemIndex].pickMask:SetVisible(true)
      end
      World.Timer(25, function()
        UI:getWnd("pokemonBlockInputEvents"):onHide()
        self:showUIData(true)
        if item then
          local itemData = {
            count = item.itemNum,
            itemName = item.itemName,
            itemIcon = item.itemIcon,
            fullName = item.fullName,
            petId = item.petId,
            type = item.type
          }
          Me:playSoundByKey("lottery_show")
          UI:getWnd("get_item_tip"):onShow(true, itemData)
        end
      end)
    else
      local randomKey = math.random(1, #ablePickList)
      local randomIndex = ablePickList[randomKey]
      table.remove(ablePickList, randomKey)
      if #ablePickList <= 0 then
        ablePickList = getAblePickList()
      end
      self:playEffect(randomIndex, 1)
      World.Timer(World.cfg.dailyLotteryEffectShowInterval, function()
        showPickEffect(itemIndex, time + 1)
      end)
    end
  end
  
  Me:gameBehaviorReport("LukeyPan_success", 1)
  UI:getWnd("pokemonBlockInputEvents"):onShow()
  showPickEffect(index, 1)
end

function M:showUIData(isOpenUI)
  local curCircle = Me:getCurLotteryCircle()
  local lotteryCfg = DailyLotteryConfig:getConfigById(curCircle)
  local curPickList = Me:getCurLotteryPickList()
  for i = 1, World.cfg.dailyLotteryMaxItemNum do
    if self.itemList[i] and lotteryCfg and lotteryCfg.items and lotteryCfg.items[i] and lotteryCfg.items[i].itemIcon then
      self.itemList[i].itemIcon:SetImage(lotteryCfg.items[i].itemIcon)
      self.itemList[i].itemNum:SetText("x " .. lotteryCfg.items[i].itemNum)
      self.itemList[i].itemName:SetText(Lang:toText(lotteryCfg.items[i].itemName))
      local cfg
      self:unsubscribe(self.itemList[i].itemCell)
      if lotteryCfg.items[i].type == 1 then
        cfg = setting:fetch("item", lotteryCfg.items[i].fullName)
        if cfg then
          self.itemList[i].itemQuality:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
          self.itemList[i].itemIcon:SetImage(cfg.icon)
          if cfg.rarity == 5 then
            self.itemList[i].itemEdgeEffect:SetVisible(true)
          end
          self:subscribe(self.itemList[i].itemCell, UIEvent.EventWindowClick, function(window, dx, dy)
            UI:getWnd("pokemonItemDetail"):onShow(lotteryCfg.items[i].fullName, dx, dy)
          end)
        end
      elseif lotteryCfg.items[i].type == 2 then
        cfg = PokemonConfig:getConfigById(lotteryCfg.items[i].petId)
        if cfg then
          self.itemList[i].itemQuality:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.quality + 2))
          self.itemList[i].itemIcon:SetImage(cfg.icon)
          if cfg.quality == 3 then
            self.itemList[i].itemEdgeEffect:SetVisible(true)
          end
          self:subscribe(self.itemList[i].itemCell, UIEvent.EventWindowClick, function(window, dx, dy)
            UI:getWnd("pokemonLuckyDetails"):onShow(true, lotteryCfg.items[i].petId)
          end)
        end
      end
      if isOpenUI then
        local isPick = false
        for j = 1, #curPickList do
          if i == curPickList[j] then
            isPick = true
          end
        end
        if isPick then
          self.itemList[i].pickMask:SetVisible(true)
          self.itemList[i].itemEdgeEffect:SetVisible(false)
        else
          self.itemList[i].pickMask:SetVisible(false)
        end
      end
    end
  end
  local curlotteryNum = Me:getCurLotteryNum()
  if curlotteryNum <= 0 then
    self.startGuide:SetVisible(false)
    self.lotteryCountText:SetText("X 0")
    self.startBtn:SetNormalImage("set:dailylottery.json image:start_btn_not")
    self.startBtn:SetPushedImage("set:dailylottery.json image:start_btn_not")
    local lastAddTime = Me:getLastAddLotteryChanceTime()
    local curTime = os.time()
    print("curTime :", curTime)
    print("  lastAddTime:", lastAddTime)
    print("curTime - lastAddTime:", curTime - lastAddTime)
    print("World.cfg.dailyLotteryRTInterval * 60 * 60:", World.cfg.dailyLotteryRTInterval * 60 * 60)
    if curTime - lastAddTime > World.cfg.dailyLotteryRTInterval * 60 * 60 then
      self.startBtn:SetEnabled(true)
      self.stateText:SetVisible(false)
      self.stateTextBg:SetVisible(false)
    else
      self.startBtn:SetEnabled(false)
      self.stateText:SetVisible(true)
      self.stateTextBg:SetVisible(true)
      self:countdownBegin()
    end
  else
    self.startBtn:SetNormalImage("set:dailylottery.json image:start_btn")
    self.startBtn:SetPushedImage("set:dailylottery.json image:start_btn")
    self.startGuide:SetVisible(true)
    self.lotteryCountText:SetText("X " .. curlotteryNum)
    if self.showTimer then
      LuaTimer:cancel(self.showTimer)
      self.showTimer = nil
    end
    self.startBtn:SetEnabled(true)
    self.stateText:SetVisible(false)
    self.stateTextBg:SetVisible(false)
  end
end

function M:countdownBegin()
  if self.showTimer then
    LuaTimer:cancel(self.showTimer)
    self.showTimer = nil
  end
  local remainTime = self:calNextRefreshTime()
  self.stateText:SetText(self:getFormatTime(remainTime))
  self.showTimer = LuaTimer:scheduleTimer(function()
    remainTime = remainTime - 1
    if remainTime <= 0 then
      if self.showTimer then
        LuaTimer:cancel(self.showTimer)
        self.showTimer = nil
      end
      self:showUIData(false)
      return false
    end
    self.stateText:SetText(self:getFormatTime(remainTime))
  end, 1000, -1)
end

function M:getFormatTime(time)
  local seconds = string.format("%02d", math.floor(time % 60))
  local min = string.format("%02d", math.floor(time / 60 % 60))
  local hour = string.format("%02d", math.floor(time / 3600))
  local decTime = hour .. ":" .. min .. ":" .. seconds
  return decTime
end

function M:calNextRefreshTime()
  local curServertime = os.time()
  local tbTime = Lib.getFormatDateTime(curServertime)
  local refreshDay = tbTime.day
  local refreshMonth = tbTime.month
  local refreshyear = tbTime.year
  local refreshHour = tbTime.hour
  local refreshMinute = tbTime.minute
  local refreshSecond = tbTime.second
  local dailyLotteryRT = World.cfg.dailyLotteryRT
  if tbTime.hour > dailyLotteryRT.hour and tbTime.hour < 24 or tbTime.hour == dailyLotteryRT.hour and tbTime.minute > dailyLotteryRT.minute and tbTime.hour < 24 or tbTime.hour == dailyLotteryRT.hour and tbTime.minute == dailyLotteryRT.minute and tbTime.second > dailyLotteryRT.second and tbTime.hour < 24 then
    refreshDay = refreshDay + 1
    local days = os.date("%d", os.time({
      year = os.date("%Y"),
      month = tbTime.month + 1,
      day = 0
    }))
    if tonumber(refreshDay > tonumber(days)) then
      refreshDay = 1
      refreshMonth = refreshMonth + 1
      if tonumber(refreshMonth) > 12 then
        refreshDay = 1
        refreshMonth = 1
        refreshyear = refreshyear + 1
      end
    end
  end
  refreshHour = dailyLotteryRT.hour
  refreshMinute = dailyLotteryRT.minute
  refreshSecond = dailyLotteryRT.second
  local refreshTime = os.time({
    year = refreshyear,
    month = refreshMonth,
    day = refreshDay,
    hour = refreshHour,
    min = refreshMinute,
    sec = refreshSecond
  })
  local remainTime = refreshTime - curServertime
  return remainTime
end

function M:tryDoLottery()
  local curlotteryNum = Me:getCurLotteryNum()
  if curlotteryNum <= 0 then
    local lastAddTime = Me:getLastAddLotteryChanceTime()
    local curTime = os.time()
    if curTime - lastAddTime > World.cfg.dailyLotteryRTInterval * 60 * 60 then
      UI:getWnd("guide_go_to_shop"):onShow(true, Lang:toText("gui_guide_goto_shop_detail_dec"))
    end
    return
  end
  Me:sendPacket({
    pid = "tryDoDailyLottery",
    objID = Me.objID
  })
end

function M:playEffect(id, type)
  if self.itemList[id] and self.itemList[id].itemEffect then
    if type == 1 then
      self.itemList[id].itemEffect:SetVisible(true)
      self.itemList[id].itemEffect:UnprepareEffect()
      self.itemList[id].itemEffect:SetEffectName("g2038_zhuanpan_1.effect")
    elseif type == 2 then
      self.itemList[id].itemEffect:SetVisible(true)
      self.itemList[id].itemEffect:UnprepareEffect()
      self.itemList[id].itemEffect:SetEffectName("g2038_zhuanpan_2.effect")
    end
  end
end

function M:onOpen()
  self:showUIData(true)
end

function M:onClose()
  UI:getWnd("pokemonBlockInputEvents"):onHide()
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
  if self.showTimer then
    LuaTimer:cancel(self.showTimer)
    self.showTimer = nil
  end
end

return M
