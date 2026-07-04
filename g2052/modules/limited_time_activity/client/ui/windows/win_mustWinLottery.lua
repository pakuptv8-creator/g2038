local WinMustWinLottery = M
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local MustWinLotteryAwardConfig = T(Config, "MustWinLotteryAwardConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local MustWinLotteryConfig = T(Config, "MustWinLotteryConfig")

function WinMustWinLottery:init()
  WinBase.init(self, "MustWinLottery.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinMustWinLottery:initData()
  self.awardData = LimitedTimeGiftItemConfig:getAllCfgs() or {}
end

function WinMustWinLottery:initUI()
  self.lytPrizePool = self:child("MustWinLottery-prizePool")
  self.btnPlay = self:child("MustWinLottery-play")
  self.textPlayText = self:child("MustWinLottery-playText")
  self.textFree = self:child("MustWinLottery-free")
  self.textPlayText:SetText(Lang:toText("gui.limit.time.activity.fishing"))
  self.textFree:SetText(Lang:toText("gui.limit.time.activity.free"))
  self.txtPlayText = self:child("MustWinLottery-playText")
  self.imgCurrency = self:child("MustWinLottery-currency")
  self.imgCurrency:SetImage(Coin:iconByCoinName("gDiamonds"))
  self.txtCurrencyNum = self:child("MustWinLottery-currency_num")
  self.txtTip = self:child("MustWinLottery-tip")
  self.imgDialogue = self:child("MustWinLottery-dialogue")
  self.txtDialogueTip = self:child("MustWinLottery-dialogue_tip")
  self.txtTip:SetText(Lang:toText("gui.limit.time.activity.must.win.lottery"))
  self.imgBtnRedDot = self:child("MustWinLottery-red_dot")
  self.btnHelp = self:child("MustWinLottery-help")
  self:child("MustWinLottery-title"):SetText(Lang:toText("gui.limit.time.activity.fisherman.gift"))
  self.imgItems = {}
  self.imgIcons = {}
  self.imgMasks = {}
  self.txtNums = {}
  for i = 1, 12 do
    self.imgItems[i] = self:child("MustWinLottery-item_" .. i)
    self.imgIcons[i] = self:child("MustWinLottery-icon_" .. i)
    self.imgMasks[i] = self:child("MustWinLottery-mask_" .. i)
    self.txtNums[i] = self:child("MustWinLottery-num_" .. i)
  end
end

function WinMustWinLottery:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.activity.must.win.lottery.help"
    })
  end)
  self:subscribe(self.btnPlay, UIEvent.EventButtonClick, function()
    Me:playMustWinLottery(self.params)
  end)
  for i, v in pairs(self.imgItems) do
    self:subscribe(v, UIEvent.EventWindowClick, function()
      if self.mustWinLotteryAwards[i] then
        local item = self.mustWinLotteryAwards[i]
        if item.icon and item.dec and item.icon == "" and item.dec == "" and item.giftContent and item.giftContent[1] then
          local award = self.awardData[item.giftContent[1]]
          if award then
            local info = LimitedTimeActivityGameMgr:getItemInfo(award)
            item.icon = info.itemIcon
            item.dec = info.showDesc or info.dec
          end
        end
        local reportData = {
          limit_mus_award_id = item.id
        }
        Plugins.CallTargetPluginFunc("report", "report", "fish_event_preview", reportData, Me)
        UI:openWnd("shopAwardPreview", item)
      end
    end)
  end
end

function WinMustWinLottery:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_MUST_WIN_LOTTERY, function()
    self:updateView()
  end)
end

function WinMustWinLottery:initView()
  LimitTimeClientHelper:updateMustFishClick(true)
  self:updateView()
  local reportData = {
    limit_activityId = self.params.id or 0
  }
  Plugins.CallTargetPluginFunc("report", "report", "fish_event_enter", reportData, Me)
  local mustWinLotteryData = Me:getMustWinLotteryData()
  local haveData = {}
  if self.params and self.params.id then
    haveData = mustWinLotteryData[self.params.id] or {}
  end
  if #haveData <= 0 then
    local reportData = {
      limit_activityId = self.params.id or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "newplayer_fish_enter", reportData, Me)
  end
end

function WinMustWinLottery:updateView()
  self.params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
  self.mustWinLotteryAwards = MustWinLotteryAwardConfig:getCfgByActivityId(self.params.id)
  local mustWinLotteryData = Me:getMustWinLotteryData()
  local haveData = {}
  if self.params and self.params.id then
    haveData = mustWinLotteryData[self.params.id] or {}
  end
  local info = MustWinLotteryConfig:getCfgByCount(#haveData + 1) or {}
  self.imgBtnRedDot:SetVisible(false)
  local clickBtnTip = ""
  self.textFree:SetVisible(false)
  if info.price then
    local price = info.price
    self.imgCurrency:SetVisible(0 < price)
    self.txtCurrencyNum:SetText(price)
    self.btnPlay:SetEnabled(true)
    self.btnPlay:SetTouchable(true)
    if price == 0 then
      self.imgBtnRedDot:SetVisible(true)
      clickBtnTip = "gui.limit.time.activity.click.button.btn.tip1"
      self.textFree:SetVisible(true)
    else
      clickBtnTip = "gui.limit.time.activity.click.button.btn.tip2"
    end
    self.imgDialogue:SetVisible(true)
  else
    self.btnPlay:SetEnabled(false)
    self.btnPlay:SetTouchable(false)
    self.imgCurrency:SetVisible(false)
    self.imgDialogue:SetVisible(false)
  end
  self.txtDialogueTip:SetText(Lang:toText(clickBtnTip))
  for i, v in pairs(self.imgItems or {}) do
    if self.mustWinLotteryAwards[i] then
      v:SetVisible(true)
      self:updateAwardInfo(i, self.mustWinLotteryAwards[i], haveData)
    else
      v:SetVisible(false)
    end
  end
end

function WinMustWinLottery:updateAwardInfo(i, item, haveData)
  local isHave = false
  for _, awardId in pairs(haveData) do
    if item.id == awardId then
      isHave = true
      break
    end
  end
  self.imgItems[i]:SetEffectName(item.quality == 5 and "fisherman_gift_gold.effect")
  if item.quality then
    self.imgItems[i]:SetImage("set:must_win_lottery.json image:img_0_quality0" .. item.quality)
  end
  self.imgIcons[i]:SetImage(item.icon)
  self.imgMasks[i]:SetVisible(isHave)
  local str = ""
  if item.giftContent and item.giftContent[1] then
    local award = self.awardData[item.giftContent[1]]
    if item.icon == "" and award then
      award = LimitedTimeActivityGameMgr:getItemInfo(award)
      self.imgIcons[i]:SetImage(award.itemIcon)
    end
    if award and 1 < award.itemCount then
      str = str .. "x" .. award.itemCount
    end
  end
  self.txtNums[i]:SetText(str)
end

function WinMustWinLottery:onHide()
  UI:closeWnd("mustWinLottery")
end

function WinMustWinLottery:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mustWinLottery")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMustWinLottery:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinMustWinLottery:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinMustWinLottery
