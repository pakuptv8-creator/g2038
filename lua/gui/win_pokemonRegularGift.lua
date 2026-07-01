local RegularGiftConfig = T(Config, "RegularGiftConfig")
local LuaTimer = T(Lib, "LuaTimer")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local regularTabList = {
  [1] = Define.REGULAR_GIFT_TAB.DayRegular,
  [2] = Define.REGULAR_GIFT_TAB.WeekRegular,
  [3] = Define.REGULAR_GIFT_TAB.MonthRegular
}

function M:init()
  WinBase.init(self, "PokemonRegularGift.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonRegularGiftMask = self:child("PokemonRegularGift-Mask")
  self.lytPokemonRegularGiftBg = self:child("PokemonRegularGift-Bg")
  self.txtPokemonRegularGiftTitle = self:child("PokemonRegularGift-Title")
  self.btnPokemonRegularGiftClose = self:child("PokemonRegularGift-Close")
  self.imgPokemonRegularGiftLeftBg = self:child("PokemonRegularGift-left-bg")
  self.imgPokemonRegularGiftTouIcon = self:child("PokemonRegularGift-touIcon")
  self.lytPokemonRegularGiftTabPanel = self:child("PokemonRegularGift-tabPanel")
  self.lytPokemonRegularGiftTabDayBtn = self:child("PokemonRegularGift-tabDayBtn")
  self.imgPokemonRegularGiftTabDaySelect = self:child("PokemonRegularGift-tabDaySelect")
  self.imgPokemonRegularGiftTabDayUnSel = self:child("PokemonRegularGift-tabDayUnSel")
  self.txtPokemonRegularGiftTabDayTxt = self:child("PokemonRegularGift-tabDayTxt")
  self.lytPokemonRegularGiftTabWeekBtn = self:child("PokemonRegularGift-tabWeekBtn")
  self.imgPokemonRegularGiftTabWeekSelect = self:child("PokemonRegularGift-tabWeekSelect")
  self.imgPokemonRegularGiftTabWeekUnSel = self:child("PokemonRegularGift-tabWeekUnSel")
  self.txtPokemonRegularGiftTabWeekTxt = self:child("PokemonRegularGift-tabWeekTxt")
  self.lytPokemonRegularGiftTabMonthBtn = self:child("PokemonRegularGift-tabMonthBtn")
  self.imgPokemonRegularGiftTabMonthSelect = self:child("PokemonRegularGift-tabMonthSelect")
  self.imgPokemonRegularGiftTabMonthUnSel = self:child("PokemonRegularGift-tabMonthUnSel")
  self.txtPokemonRegularGiftTabMonthTxt = self:child("PokemonRegularGift-tabMonthTxt")
  self.txtPokemonRegularGiftTitle:SetText(Lang:toText("gui_regular_gift_title"))
  self.txtPokemonRegularGiftTabDayTxt:SetText(Lang:toText("gui_regular_day_tab"))
  self.txtPokemonRegularGiftTabWeekTxt:SetText(Lang:toText("gui_regular_week_tab"))
  self.txtPokemonRegularGiftTabMonthTxt:SetText(Lang:toText("gui_regular_month_tab"))
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED, self.lytPokemonRegularGiftTabDayBtn, 0, 0, "RegularGiftTabDayBtn")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED, self.lytPokemonRegularGiftTabWeekBtn, 0, 0, "RegularGiftTabWeekBtn")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED, self.lytPokemonRegularGiftTabMonthBtn, 0, 0, "RegularGiftTabMonthBtn")
  self.lytPokemonRegularGiftContentList = {}
  self.isInitTabItem = {}
  self.contentItemList = {}
  for _, tab in ipairs(regularTabList) do
    self.lytPokemonRegularGiftContentList[tab] = self:child("PokemonRegularGift-contentList" .. tab)
    self.isInitTabItem[tab] = false
  end
  self.selectTab = 0
  self.curServerDisTime = 0
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytPokemonRegularGiftBg, 1252, 642)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonRegularGift btnPokemonRegularGiftClose event : EventButtonClick", self.btnPokemonRegularGiftClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonRegularGift lytPokemonRegularGiftTabDayBtn event : EventWindowClick", self.lytPokemonRegularGiftTabDayBtn, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("tab_click")
    self:updateTabViewShow(regularTabList[1])
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonRegularGift lytPokemonRegularGiftTabWeekBtn event : EventWindowClick", self.lytPokemonRegularGiftTabWeekBtn, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("tab_click")
    self:updateTabViewShow(regularTabList[2])
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonRegularGift lytPokemonRegularGiftTabMonthBtn event : EventWindowClick", self.lytPokemonRegularGiftTabMonthBtn, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("tab_click")
    self:updateTabViewShow(regularTabList[3])
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonRegularGift Lib event : EVENT_UPDATE_REGULAR_BUY_INFO", Event.EVENT_UPDATE_REGULAR_BUY_INFO, function()
    self.isBuyingRegularTime = 0
    self:onUpdateItemCount()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonRegularGift Lib event : EVENT_UPDATE_REGULAR_BUY_TIME", Event.EVENT_UPDATE_REGULAR_BUY_TIME, function(value)
    self.isBuyingRegularBtn = false
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonRegularGift Lib event : EVENT_UPDATE_REGULAR_SERVER_TIME", Event.EVENT_UPDATE_REGULAR_SERVER_TIME, function(curServerTime)
    self.curServerDisTime = os.time() - curServerTime
    self:updateDownTime()
  end)
end

function M:initView(tabType)
  local selectTab = tabType or Define.REGULAR_GIFT_TAB.DayRegular
  self:updateTabViewShow(selectTab)
end

function M:initTabItemList(tabType)
  if not self.isInitTabItem[tabType] then
    self.isInitTabItem[tabType] = true
    self.contentItemList[tabType] = {}
    local giftList = RegularGiftConfig:getAllConfig()
    for key, val in pairs(giftList) do
      if val.tabId == tabType then
        local regularItem = UIMgr:new_widget("pokemonRegularItem")
        regularItem:invoke("initRegularGiftItem", val)
        self.lytPokemonRegularGiftContentList[tabType]:AddItem(regularItem)
        table.insert(self.contentItemList[tabType], regularItem)
      end
    end
    self:onUpdateItemCount()
  end
end

function M:onUpdateItemCount()
  local buyInfo = Me:getRegularBuyInfo()
  for tabType, val in pairs(self.isInitTabItem) do
    if self.isInitTabItem[tabType] then
      for _, item in pairs(self.contentItemList[tabType]) do
        if item then
          local itemId = item:invoke("getItemId")
          if buyInfo[tostring(itemId)] then
            item:invoke("updateRemainCounts", buyInfo[tostring(itemId)].curBuyNum)
          else
            item:invoke("updateRemainCounts", 0)
          end
        end
      end
    end
  end
  UIRedDotMgr:updateRegularGiftRedShow()
end

function M:updateTabViewShow(tabType)
  if self.selectTab ~= tabType then
    self.selectTab = tabType
    self:initTabItemList(tabType)
    if self.selectTab == Define.REGULAR_GIFT_TAB.DayRegular then
      self.imgPokemonRegularGiftTabDaySelect:SetVisible(true)
      self.imgPokemonRegularGiftTabDayUnSel:SetVisible(false)
      self.imgPokemonRegularGiftTabWeekSelect:SetVisible(false)
      self.imgPokemonRegularGiftTabWeekUnSel:SetVisible(true)
      self.imgPokemonRegularGiftTabMonthSelect:SetVisible(false)
      self.imgPokemonRegularGiftTabMonthUnSel:SetVisible(true)
    elseif self.selectTab == Define.REGULAR_GIFT_TAB.WeekRegular then
      self.imgPokemonRegularGiftTabDaySelect:SetVisible(false)
      self.imgPokemonRegularGiftTabDayUnSel:SetVisible(true)
      self.imgPokemonRegularGiftTabWeekSelect:SetVisible(true)
      self.imgPokemonRegularGiftTabWeekUnSel:SetVisible(false)
      self.imgPokemonRegularGiftTabMonthSelect:SetVisible(false)
      self.imgPokemonRegularGiftTabMonthUnSel:SetVisible(true)
    elseif self.selectTab == Define.REGULAR_GIFT_TAB.MonthRegular then
      self.imgPokemonRegularGiftTabDaySelect:SetVisible(false)
      self.imgPokemonRegularGiftTabDayUnSel:SetVisible(true)
      self.imgPokemonRegularGiftTabWeekSelect:SetVisible(false)
      self.imgPokemonRegularGiftTabWeekUnSel:SetVisible(true)
      self.imgPokemonRegularGiftTabMonthSelect:SetVisible(true)
      self.imgPokemonRegularGiftTabMonthUnSel:SetVisible(false)
    end
    for _, tab in ipairs(regularTabList) do
      self.lytPokemonRegularGiftContentList[tab]:SetVisible(tab == self.selectTab)
      self.lytPokemonRegularGiftContentList[tab]:SetScrollOffset(0)
    end
  end
end

function M:updateDownTime()
  local curTime = os.time() - self.curServerDisTime
  for tabType, val in pairs(self.isInitTabItem) do
    if self.isInitTabItem[tabType] then
      for _, item in pairs(self.contentItemList[tabType]) do
        if item then
          item:invoke("updateRefreshTime", curTime)
        end
      end
    end
  end
end

function M:onHide()
  UI:closeWnd("pokemonRegularGift")
end

function M:onShow(isShow, tabType)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonRegularGift", tabType)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(tabType)
  self._allEvent = {}
  self:subscribeEvent()
  self.selectTab = 0
  self:initView(tabType)
  self.isBuyingRegularTime = 0
  self.isBuyingRegularBtn = false
  self.downTimer = LuaTimer:scheduleTimer(function()
    self:updateDownTime()
  end, 1000, -1)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.downTimer then
    LuaTimer:cancel(self.downTimer)
    self.downTimer = nil
  end
end

return M
