local walletPool = {}
local TCfg = World.cfg.toolBarSetting or {}
local LuaTimer = T(Lib, "LuaTimer")
local subscribeEvent = require("script_client.event_cache")

function M:init()
  WinBase.init(self, "ToolBar.json")
  self.rightStartPoint = -0.277344
  self.settingCheckBox = self:child("ToolBar-Setting")
  self.redPoint = self.settingCheckBox:child("ToolBar-Setting-Red")
  self.btnCamera = self:child("ToolBar-Camara")
  self.btnEmoji = self:child("ToolBar-Emoji")
  self.btnFriend = self:child("ToolBar-Friend")
  self.btnFriend:SetVisible(false)
  self.btnVideo = self:child("ToolBar-Video")
  self.gametime = self:child("ToolBar-GameTime-Info")
  self.currency = self:child("ToolBar-Currency-Money")
  self.goldDiamond = self:child("ToolBar-Gold-Diamond")
  self.cashCoupon = self:child("ToolBar-Cash-Coupon")
  self.redPoint:SetVisible(false)
  self.currency:SetVisible(false)
  self.currencyWidget = {}
  self.countDownTimer = nil
  self:lightSubscribe("error!!!!! script_client win_toolbar settingCheckBox event : EventCheckStateChanged", self.settingCheckBox, UIEvent.EventCheckStateChanged, function()
    self:onCheckSettingChanged()
  end)
  self:lightSubscribe("error!!!!! script_client win_toolbar btnCamera event : EventButtonClick", self.btnCamera, UIEvent.EventButtonClick, function()
    Me:startCameraMode()
  end)
  self:lightSubscribe("error!!!!! script_client win_toolbar btnEmoji event : EventButtonClick", self.btnEmoji, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_ANIMOJI)
  end)
  self:lightSubscribe("error!!!!! script_client win_toolbar btnFriend event : EventButtonClick", self.btnFriend, UIEvent.EventButtonClick, function()
  end)
  self:lightSubscribe("error!!!!! script_client win_toolbar btnFriend event : EventButtonClick", self.btnVideo, UIEvent.EventButtonClick, function()
    if UI:isOpen("videoMode") then
      Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
    else
      Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", true)
    end
  end)
  subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
    self:changeCurrency()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_toolbar Lib event : EVENT_SHOW_RED_POINT", Event.EVENT_SHOW_RED_POINT, function()
    self.redPoint:SetVisible(true)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_toolbar Lib event : EVENT_SHOW_RECHARGE", Event.EVENT_SHOW_RECHARGE, function()
    Interface.onRecharge(1)
  end)
  local btnRecharge = self:child("ToolBar-Gold-Diamond")
  if btnRecharge then
    self:lightSubscribe("error!!!!! script_client win_toolbar btnRecharge event : EventWindowClick", btnRecharge, UIEvent.EventWindowClick, function()
      Me:gameBehaviorReport("ui", "gcube")
      if World.cfg.pauseWhenCharge then
        Lib.emitEvent(Event.EVENT_PAUSE_BY_CLIENT)
      end
      Lib.emitEvent(Event.EVENT_SHOW_RECHARGE)
    end)
    Lib.lightSubscribeEvent("error!!!!! script_client win_toolbar Lib event : EVENT_HIDE_RECHARGE", Event.EVENT_HIDE_RECHARGE, function(hide)
      btnRecharge:SetVisible(not hide)
    end)
  end
  self:lightSubscribe("error!!!!! script_client win_toolbar btnRecharge event : EventWindowClick", self.cashCoupon, UIEvent.EventWindowClick, function()
    Interface.onRecharge(5)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_toolbar Lib event : EVENT_UPDATE_COUNT_DOWN_TIP", Event.EVENT_UPDATE_COUNT_DOWN_TIP, function(msg, icon)
    self:updateCountDownTip(msg, icon)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_toolbar Lib event : EVENT_SHOW_TOOLBAR_BTN", Event.EVENT_SHOW_TOOLBAR_BTN, function(name, show)
    if UI:isOpen(self) then
      self:refreshAlignItem(name, show)
    end
  end)
end

local function fetchItem(msg, iconPath)
  local box = GUIWindowManager.instance:CreateGUIWindow1("Layout")
  box:SetHorizontalAlignment(1)
  box:SetVerticalAlignment(0)
  box:SetArea({0, 0}, {0, 0}, {1, 0}, {0.04167, 0})
  local text = GUIWindowManager.instance:CreateGUIWindow1("StaticText")
  text:SetTouchable(false)
  text:SetHorizontalAlignment(2)
  text:SetVerticalAlignment(1)
  text:SetTextScale(1)
  text:SetWordWrap(true)
  text:SetArea({0, 0}, {0, 0}, {0.9609, 0}, {1, 0})
  text:SetSelfAdaptionArea(true)
  text:SetText(msg)
  local icon = GUIWindowManager.instance:CreateGUIWindow1("StaticImage")
  icon:SetTouchable(false)
  icon:SetHorizontalAlignment(0)
  icon:SetVerticalAlignment(1)
  icon:SetArea({0, 10}, {0, 0}, {0.0234, 0}, {0.04167, 0})
  icon:SetImage(iconPath or "")
  box:AddChildWindow(icon)
  box:AddChildWindow(text)
  return box
end

function M:updateCountDownTip(msg, icon)
  local countDownTipItem = self.countDownTipItem
  if msg == "-1" then
    countDownTipItem:SetVisible(false)
    return
  end
  countDownTipItem:SetVisible(true)
  countDownTipItem:GetChildByIndex(0):SetText(msg)
  countDownTipItem:GetChildByIndex(1):SetImage(icon or "")
end

function M:onCheckSettingChanged()
  local check = self.settingCheckBox:GetChecked()
  Lib.emitEvent(Event.EVENT_CHECKED_MENU, check)
  if check then
    self.redPoint:SetVisible(false)
  end
end

function M:onPerspeceChanged()
  Blockman.instance:switchPersonView()
  PlayerControl.UpdatePersonView()
  local view = Blockman.Instance():getCurrPersonView()
  if view == 0 then
    Lib.emitEvent(Event.FRONTSIGHT_SHOW, 2)
  else
    Lib.emitEvent(Event.FRONTSIGHT_NOT_SHOW, 2)
  end
end

function M:getCurrencyWindow(window, coinName, cfg, index)
  if walletPool[coinName] then
    return walletPool[coinName]
  end
  local wnd = GUIWindowManager.instance:CloneWindow("CloneWindow-" .. coinName, window)
  self:root():AddChildWindow(wnd)
  local addBtn = cfg.addButton
  local broad = addBtn and -0.14 or -0.12
  local start = self.rightStartPoint + (addBtn and -0.02 or 0)
  local x = start + index * broad + (0 < index and -0.002 or 0)
  wnd:SetXPosition({x, 0})
  wnd:SetVisible(true)
  wnd:GetChildByIndex(0):SetImage(Coin:iconByCoinName(coinName))
  self.currencyWidget[coinName] = wnd:GetChildByIndex(0)
  self:unsubscribe(wnd)
  self:lightSubscribe("error!!!!! script_client win_toolbar wnd event : EventWindowClick", wnd, UIEvent.EventWindowClick, function()
    if coinName == "gold_coin" then
      Me:gameBehaviorReport("ui", "coins")
      UI:openWnd("pokemon_gold_exchange")
    end
  end)
  walletPool[coinName] = wnd
  return wnd
end

function M:changeCurrency()
  local wallet = Me:data("wallet")
  local coinCfg = Coin:GetCoinCfg()
  if not World.cfg.noShowCoin then
    if wallet.gDiamonds then
      self.goldDiamond:GetChildByIndex(1):SetText(wallet.gDiamonds.count or 0)
    end
    if World.cfg.useFDiamonds then
      local fDiamondsCount = Coin:countByCoinName(Me, "fDiamonds")
      self.goldDiamond:GetChildByIndex(1):SetText(fDiamondsCount or 0)
    end
    if wallet.gameCashCoupon then
      self.cashCoupon:GetChildByIndex(1):SetText(wallet.gameCashCoupon.count or 0)
    end
    local index = 0
    for _, cfg in pairs(coinCfg) do
      if cfg.showUi ~= false then
        local coinName = cfg.coinName
        local addBtn = cfg.addButton
        local iconWnd = self:getCurrencyWindow(addBtn and self.goldDiamond or self.currency, coinName, cfg, index)
        local count = Coin:countByCoinName(Me, coinName)
        iconWnd:GetChildByIndex(1):SetTextWithJump(tostring(count) or 0, false)
        index = index + 1
      end
    end
  else
    self.goldDiamond:SetVisible(false)
    self.cashCoupon:SetVisible(false)
    self.currency:SetVisible(false)
  end
end

local function insertTable(t, ins_t)
  local res = Lib.copy(t)
  if ins_t.var then
    table.insert(res, (ins_t.insert or 1) + 1, ins_t.var)
  end
  return res
end

function M:setChecked(checked)
  self.settingCheckBox:SetChecked(checked)
end

function M:onOpen()
  self.settingCheckBox:SetChecked(false)
  if World.cfg.hideSetting then
    self.settingCheckBox:SetVisible(false)
  end
end

function M:onReload(reloadArg)
end

function M:openPayShop(type)
  if not type then
    UI:getWnd("payShop"):onShow(true)
    return
  end
  UI:getWnd("payShop"):onShow(true, type)
end

function M:showRightIcons(isShow)
  self.goldDiamond:SetVisible(isShow)
  self.cashCoupon:SetVisible(isShow)
  for _, wdn in pairs(walletPool) do
    wdn:SetVisible(isShow)
  end
end

return M
