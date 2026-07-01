local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
local setting = require("common.setting")

function M:init()
  WinBase.init(self, "pokemon_recharge_award.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.isStart = true
  self.status = 0
  self.items = {}
  self.lytRechargeAward = self:child("recharge_award")
  self.lytRechargeAwardGradient = self:child("recharge_award-gradient")
  self.imgRechargeAwardBg = self:child("recharge_award-bg")
  self.imgRechargeAwardTitle = self:child("recharge_award-title")
  self.txtRechargeAwardTitleTxt = self:child("recharge_award-titleTxt")
  self.txtRechargeAwardDetailTxt = self:child("recharge_award-detailTxt")
  self.imgRechargeAwardValueBg = self:child("recharge_award-valueBg")
  self.txtRechargeAwardValueTitle = self:child("recharge_award-value-title")
  self.imgRechargeAwardValueDia = self:child("recharge_award-value-dia")
  self.txtRechargeAwardValueTxt = self:child("recharge_award-value-txt")
  self.btnRechargeAwardRechargeBtn = self:child("recharge_award-rechargeBtn")
  self.btnRechargeAwardReceiveBtn = self:child("recharge_award-receiveBtn")
  self.lytRechargeAwardItemBox = self:child("recharge_award-itemBox")
  self.imgRechargeAwardAwardItem1 = self:child("recharge_award-awardItem_1")
  self.imgRechargeAwardItemBg1 = self:child("recharge_award-itemBg_1")
  self.imgRechargeAwardItemIcon1 = self:child("recharge_award-itemIcon_1")
  self.imgRechargeAwardItemHighlight1 = self:child("recharge_award-itemHighlight_1")
  self.txtRechargeAwardCount1 = self:child("recharge_award-count_1")
  self.imgRechargeAwardAwardItem2 = self:child("recharge_award-awardItem_2")
  self.imgRechargeAwardItemBg2 = self:child("recharge_award-itemBg_2")
  self.imgRechargeAwardItemIcon2 = self:child("recharge_award-itemIcon_2")
  self.imgRechargeAwardItemHighlight2 = self:child("recharge_award-itemHighlight_2")
  self.txtRechargeAwardCount2 = self:child("recharge_award-count_2")
  self.imgRechargeAwardAwardItem3 = self:child("recharge_award-awardItem_3")
  self.imgRechargeAwardItemBg3 = self:child("recharge_award-itemBg_3")
  self.imgRechargeAwardItemIcon3 = self:child("recharge_award-itemIcon_3")
  self.imgRechargeAwardItemHighlight3 = self:child("recharge_award-itemHighlight_3")
  self.txtRechargeAwardCount3 = self:child("recharge_award-count_3")
  self.imgRechargeAwardBatBg = self:child("recharge_award-batBg")
  self.txtRechargeAwardBarTitle = self:child("recharge_award-bar-title")
  self.imgRechargeAwardBarDia = self:child("recharge_award-bar-dia")
  self.txtRechargeAwardBarTxt = self:child("recharge_award-bar-txt")
  self.btnRechargeAwardCloseBtn = self:child("recharge_award-closeBtn")
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.imgRechargeAwardBg, 924, 550)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemon_recharge_award btnRechargeAwardRechargeBtn event : EventButtonClick", self.btnRechargeAwardRechargeBtn, UIEvent.EventButtonClick, function()
    Interface.onRecharge(1)
    Me:gameBehaviorReport("firstRecharge_click", 1)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_recharge_award btnRechargeAwardReceiveBtn event : EventButtonClick", self.btnRechargeAwardReceiveBtn, UIEvent.EventButtonClick, function()
    if os.time() - self.lastReceiveTime <= 5 then
      return
    end
    self.lastReceiveTime = os.time()
    local awardType = self.status + 1
    Me:sendPacket({
      pid = "getRechargeAward",
      awardType = awardType,
      awardStatus = self.status
    })
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemon_recharge_award btnRechargeAwardCloseBtn event : EventButtonClick", self.btnRechargeAwardCloseBtn, UIEvent.EventButtonClick, function()
    if Me:getGainFirstOrangePet() == 1 then
      Me:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.TIME)
    end
    self:onHide()
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemon_recharge_award Lib event : EVENT_PLAYER_RECHARGE_SUM", Event.EVENT_PLAYER_RECHARGE_SUM, function()
    self:upDataWinInfo(self.status)
  end)
  local i = 1
  for _, item in pairs(self.items or {}) do
    if 3 < i then
      break
    end
    self._allEvent[#self._allEvent + 1] = self:lightSubscribe("error!!!!! script_client win_pokemon_recharge_award btnRechargeAwardCloseBtn event : EventButtonClick", self["imgRechargeAwardAwardItem" .. i], UIEvent.EventWindowClick, function(window, dx, dy)
      if item.goodType == 1 then
        UI:getWnd("pokemonLuckyDetails"):onShow(true, item.pkmId)
      elseif item.goodType == 2 then
      elseif item.goodType == 3 and item.fullName then
        UI:getWnd("pokemonItemDetail"):onShow(item.fullName, dx, dy)
      end
    end)
    i = i + 1
  end
end

function M:initView()
  self.lastReceiveTime = 0
  self.txtRechargeAwardTitleTxt:SetText(Lang:toText("gui_recharge_title"))
  self.txtRechargeAwardDetailTxt:SetText(Lang:toText("gui_recharge_fight"))
  self.txtRechargeAwardValueTitle:SetText(Lang:toText("gui_recharge_total_value"))
  self.btnRechargeAwardRechargeBtn:SetText(Lang:toText("gui_recharge_recharge_btn"))
  self.btnRechargeAwardReceiveBtn:SetText(Lang:toText("gui_recharge_receive_btn"))
  self.txtRechargeAwardBarTitle:SetText(Lang:toText("gui_recharge_conditions"))
  self:upDataWinInfo(self.status)
end

function M:upDataWinInfo(status)
  self.status = status
  local rechargeSum = Me:getRechargeSum()
  local rewardType = self.status + 1
  local items, condition, totalValue = RechargeAwardConfig:getRewardTypeItems(rewardType)
  if not condition then
    self.btnRechargeAwardReceiveBtn:SetEnabled(false)
    self.btnRechargeAwardReceiveBtn:SetTouchable(false)
    self.btnRechargeAwardReceiveBtn:SetText(Lang:toText("gui_recharge_received"))
    return
  else
    self.btnRechargeAwardReceiveBtn:SetText(Lang:toText("gui_recharge_receive_btn"))
  end
  self.items = items
  if 1 <= rechargeSum / condition then
    self.btnRechargeAwardRechargeBtn:SetVisible(false)
    self.btnRechargeAwardReceiveBtn:SetVisible(true)
    self.txtRechargeAwardBarTxt:SetText(condition)
  else
    self.btnRechargeAwardRechargeBtn:SetVisible(true)
    self.btnRechargeAwardReceiveBtn:SetVisible(false)
    self.txtRechargeAwardBarTxt:SetText(rechargeSum .. "/" .. condition)
  end
  self.txtRechargeAwardValueTxt:SetText(totalValue)
  self:upDataItemInfo()
end

function M:upDataItemInfo()
  local i = 1
  for _, item in pairs(self.items or {}) do
    if 3 < i then
      break
    end
    self["imgRechargeAwardItemBg" .. i]:SetImage("set:pokemonRechargeAward.json image:img_0_item_board")
    if item.goodType == 1 then
      self["imgRechargeAwardItemBg" .. i]:SetImage(item.icon)
      self["imgRechargeAwardItemIcon" .. i]:SetImage("")
    elseif item.icon ~= "" then
      self["imgRechargeAwardItemIcon" .. i]:SetImage(item.icon)
    elseif item.fullName ~= "" then
      local cfg = setting:fetch("item", item.fullName)
      if cfg then
        self["imgRechargeAwardItemIcon" .. i]:SetImage(cfg.icon)
      end
    else
      self["imgRechargeAwardItemIcon" .. i]:SetImage("")
    end
    self["txtRechargeAwardCount" .. i]:SetText("X" .. tostring(BigInteger.Create(item.count or 0)))
    i = i + 1
  end
end

function M:onHide()
  UI:closeWnd("pokemon_recharge_award")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemon_recharge_award")
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
