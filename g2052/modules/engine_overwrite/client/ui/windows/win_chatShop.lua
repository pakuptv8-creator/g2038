local chatSetting = World.cfg.chatSetting or {}
local VoiceShopConfig = T(Config, "VoiceShopConfig")

function M:init()
  WinBase.init(self, "ChatShop.json", false)
  self._allEvent = {}
  self:initWnd()
  self:initEvent()
end

function M:initWnd()
  self.btnItem1 = self:child("ChatShop-Item-Buy-1")
  self.txtItemCost1 = self:child("ChatShop-Item-Cost-1")
  self.txtItemCnt1 = self:child("ChatShop-Item-Info-1")
  self.btnItem2 = self:child("ChatShop-Item-Buy-2")
  self.txtItemCost2 = self:child("ChatShop-Item-Cost-2")
  self.txtItemCnt2 = self:child("ChatShop-Item-Info-2")
  self.btnItem3 = self:child("ChatShop-Item-Buy-3")
  self.txtItemCost3 = self:child("ChatShop-Item-Cost-3")
  self.txtItemCnt3 = self:child("ChatShop-Item-Info-3")
  self.btnMoon = self:child("ChatShop-Moon")
  self.txtMoonInfo = self:child("ChatShop-Moon-Text")
  self.txtMoonCost = self:child("ChatShop-Moon-Cost")
  self.txtTitle = self:child("ChatShop-Title-Text")
  self.txtTitle:SetText(Lang:toText("ui.chat.shopTitle"))
  self.imgMoonHasTimeBg = self:child("ChatShop-Moon-Time-Bg")
  self.txtMoonHasTime = self:child("ChatShop-Moon-LastTime")
  self.txtVoiceTime = self:child("ChatShop-Moon-VoiceCnt")
  self.btnClose = self:child("ChatShop-Close")
  self.txtDiamondNum = self:child("ChatShop-DiamondNum")
  self.txtDiamondNum:SetText(0)
  self:initData()
  if World.cfg.chatSetting and World.cfg.chatSetting.chatLevel then
    self:root():SetLevel(World.cfg.chatSetting.chatLevel)
  end
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnItem1, UIEvent.EventButtonClick, function()
    self:buyById(1)
  end)
  self:subscribe(self.btnItem2, UIEvent.EventButtonClick, function()
    self:buyById(2)
  end)
  self:subscribe(self.btnItem3, UIEvent.EventButtonClick, function()
    self:buyById(3)
  end)
  self:subscribe(self.btnMoon, UIEvent.EventButtonClick, function()
    self:buyById(4)
  end)
  Lib.subscribeEvent(Event.EVENT_CHAT_CARD_TIME, function(time)
    if -1 < time then
      self.imgMoonHasTimeBg:SetVisible(true)
      local day = math.floor(time / 86400)
      if 0 < day then
        self.txtMoonHasTime:SetText(Lang:toText({
          "ui.chat.moonTime",
          day
        }))
      else
        self.txtMoonHasTime:SetText(Lang:toText("ui.chat.moonLess"))
      end
    else
      self.imgMoonHasTimeBg:SetVisible(false)
      self.txtMoonHasTime:SetText("")
    end
  end)
  Lib.subscribeEvent(Event.EVENT_SOUND_TIME_CHANGE, function(value)
    self.txtVoiceTime:SetText(Lang:toText({
      "ui.chat.hasVoice",
      Me:getSoundTimes()
    }))
  end)
  Lib.subscribeEvent(Event.EVENT_SOUND_MOON_CHANGE, function(value)
    Me:getVoiceCardTime()
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
    self:changeCurrency()
  end)
end

function M:buyById(idx)
  local wallet = Me:data("wallet")
  local cost = VoiceShopConfig:getItemById(idx).cost
  if not cost then
    print("CANT FIND VOICE ITEM PRICE")
    return
  end
  if wallet and wallet.gDiamonds and cost <= wallet.gDiamonds.count then
    local uiParams = {
      titleText = "gui_lang_tip_title",
      msgText = {
        "ui.chat.sureBuy",
        VoiceShopConfig:getItemById(idx).cost
      }
    }
    Me:sendPacket({pid = "BuyVoice", idx = idx})
  else
    Interface.onRecharge(1)
  end
end

function M:changeCurrency()
  local wallet = Me:data("wallet")
  local count = wallet.gDiamonds.count or 0
  self.txtDiamondNum:SetTextWithJump(count, false, 10, 20)
end

function M:initData()
  self.txtItemCost1:SetText(VoiceShopConfig:getItemById(1).cost)
  self.txtItemCost2:SetText(VoiceShopConfig:getItemById(2).cost)
  self.txtItemCost3:SetText(VoiceShopConfig:getItemById(3).cost)
  self.txtMoonCost:SetText(VoiceShopConfig:getItemById(4).cost)
  self.txtVoiceTime:SetText(Lang:toText({
    "ui.chat.hasVoice",
    Me:getSoundTimes()
  }))
  self.txtMoonInfo:SetText(Lang:toText("ui.chat.moonCard"))
  self.txtItemCnt1:SetText("X" .. VoiceShopConfig:getItemById(1).num)
  self.txtItemCnt2:SetText("X" .. VoiceShopConfig:getItemById(2).num)
  self.txtItemCnt3:SetText("X" .. VoiceShopConfig:getItemById(3).num)
  local wallet = Me:data("wallet")
  local count = wallet.gDiamonds.count or 0
  self.txtDiamondNum:SetText(count)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

function M:onOpen()
  self:initData()
  self:subscribeEvent()
  Me:getVoiceCardTime()
end
