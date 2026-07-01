local WinPokemonGloryHall = M
local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")
local LuaTimer = T(Lib, "LuaTimer")
local setting = require("common.setting")
local PokemonConfig = T(Config, "PokemonConfig")

function WinPokemonGloryHall:init()
  WinBase.init(self, "PokemonGloryHall.json")
  self:initUI()
  self:initEvent()
end

function WinPokemonGloryHall:initUI()
  self.imgMask = self:child("PokemonGloryHall-Mask")
  self.lytContent = self:child("PokemonGloryHall-content")
  self.imgBg = self:child("PokemonGloryHall-Bg")
  self.imgTopBg = self:child("PokemonGloryHall-topBg")
  self.imgBottomBg = self:child("PokemonGloryHall-bottomBg")
  self.imgTitleBg = self:child("PokemonGloryHall-titleBg")
  self.txtTitleTxt = self:child("PokemonGloryHall-TitleTxt")
  self.btnCloseBtn = self:child("PokemonGloryHall-closeBtn")
  self.imgRuleBg1 = self:child("PokemonGloryHall-ruleBg1")
  self.imgRuleBg2 = self:child("PokemonGloryHall-ruleBg2")
  self.txtRuleTitle = self:child("PokemonGloryHall-ruleTitle")
  self.imgRuleBg3 = self:child("PokemonGloryHall-ruleBg3")
  self.imgRuleBg4 = self:child("PokemonGloryHall-ruleBg4")
  self.txtAwardTitle = self:child("PokemonGloryHall-awardTitle")
  self.lytAwardList = self:child("PokemonGloryHall-awardList")
  self.imgRightBg = self:child("PokemonGloryHall-rightBg")
  self.txtRightTitle = self:child("PokemonGloryHall-rightTitle")
  self.imgRightIconBg = self:child("PokemonGloryHall-rightIconBg")
  self.imgRightShadow = self:child("PokemonGloryHall-rightShadow")
  self.txtTimeTxt = self:child("PokemonGloryHall-timeTxt")
  self.txtTimeDesc = self:child("PokemonGloryHall-timeDesc")
  self.btnEnterBtn = self:child("PokemonGloryHall-enterBtn")
  self.imgEnterEffect = self:child("PokemonGloryHall-enterEffect")
  self.txtEnterTxt = self:child("PokemonGloryHall-enterTxt")
  self.lytDescPanel = self:child("PokemonGloryHall-descPanel")
  self.txtDescTxt = self:child("PokemonGloryHall-descTxt")
  self.gvDescTxt = UIMgr:new_widget("grid_view")
  self.lytDescPanel:AddChildWindow(self.gvDescTxt)
  self.gvDescTxt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDescTxt:SetAutoColumnCount(false)
  self.gvDescTxt:InitConfig(0, 5, 1)
  self.gvDescTxt:AddItem(self.txtDescTxt)
  self.txtDescTxt:SetText(Lang:toText("gui_glory_hall_rule_desc"))
  self.gvGiftList = UIMgr:new_widget("grid_view")
  self.lytAwardList:AddChildWindow(self.gvGiftList)
  self.gvGiftList:SethScorllMoveAble(true)
  self.gvGiftList:SetvScorllMoveAble(false)
  self.gvGiftList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvGiftList:InitConfig(0, 0, 1)
  self.giftCells = {}
  self.lytIconList = self:child("PokemonGloryHall-iconList")
  self.gvIconList = UIMgr:new_widget("grid_view")
  self.lytIconList:AddChildWindow(self.gvIconList)
  self.gvIconList:SethScorllMoveAble(true)
  self.gvIconList:SetvScorllMoveAble(false)
  self.gvIconList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvIconList:InitConfig(0, 0, 1)
  self.iconCells = {}
  self.txtTitleTxt:SetText(Lang:toText("gui_glory_hall_view_title"))
  self.txtRuleTitle:SetText(Lang:toText("gui_glory_hall_rule_title"))
  self.txtAwardTitle:SetText(Lang:toText("gui_glory_hall_award_title"))
  self.txtRightTitle:SetText(Lang:toText("gui_glory_hall_open_title"))
  self.txtTimeDesc:SetText(Lang:toText("gui_glory_hall_open_next"))
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytContent, 1013, 670)
end

function WinPokemonGloryHall:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnEnterBtn, UIEvent.EventButtonClick, function()
    local map = World.CurMap
    if map.name == World.cfg.gloryHallMap then
      if Me:isJoinTeam() then
        Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_enter_glory"), 60)
      else
        Me:sendPacket({
          pid = "requestLeaveGloryHall"
        })
      end
    else
      if self.remainTime <= 3 then
        return
      end
      if Me:isJoinTeam() then
        Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_enter_glory"), 60)
      else
        Me.disableControl = true
        Me.gloryDoorEntityNum = 0
        Me:sendPacket({
          pid = "requestEnterGloryHall"
        })
      end
    end
    self:onHide()
  end)
end

function WinPokemonGloryHall:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PUSH_CUR_SERVER_TIME, function(curServerTime)
    self.curDistanceTime = curServerTime - os.time()
    self:updateViewShow()
  end)
end

function WinPokemonGloryHall:initView()
  local map = World.CurMap
  if map.name == World.cfg.gloryHallMap then
    self.txtEnterTxt:SetText(Lang:toText("gui_glory_hall_leave_btn"))
  else
    self.txtEnterTxt:SetText(Lang:toText("gui_glory_hall_enter_btn"))
  end
  Me:sendPacket({
    pid = "requestCurServerTime"
  })
  self.curDistanceTime = 0
  self:updateViewShow()
end

function WinPokemonGloryHall:updateViewShow()
  self.curServerTime = os.time() + self.curDistanceTime
  self.curWeekDay = os.date("%w", self.curServerTime)
  self:updateAwardListShow()
  self:updateGymIconShow()
  self:startUpdateTime()
end

function WinPokemonGloryHall:startUpdateTime()
  if self.downTimer then
    LuaTimer:cancel(self.downTimer)
    self.downTimer = nil
  end
  self.remainTime = Lib.getDayEndTime(self.curServerTime) - self.curServerTime
  local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(self.remainTime))
  local remainDay = math.floor(self.remainTime / 3600 / 24)
  if remainDay <= 0 then
    self.txtTimeTxt:SetText(text)
  else
    self.txtTimeTxt:SetText(remainDay .. "D  " .. text)
  end
  self.downTimer = LuaTimer:scheduleTimer(function()
    self.remainTime = self.remainTime - 1
    local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(self.remainTime))
    local remainDay = math.floor(self.remainTime / 3600 / 24)
    if remainDay <= 0 then
      self.txtTimeTxt:SetText(text)
    else
      self.txtTimeTxt:SetText(remainDay .. "D  " .. text)
    end
    if self.remainTime < 0 then
      self.txtTimeTxt:SetText("00:00:00")
      self:updateViewShow()
    end
  end, 1000, -1)
end

function WinPokemonGloryHall:updateAwardListShow()
  local data = PokemonGloryHallConfig:getAwardByOpenDay(self.curWeekDay)
  if data and type(data) == "table" then
    self.gvGiftList:InitConfig(10, 0, #data)
    for i, cell in pairs(self.giftCells or {}) do
      if i > #data then
        self.gvGiftList:RemoveItem(cell)
        self.giftCells[i] = nil
      end
    end
    self:sortGloryAwardList(data)
    for index, value in ipairs(data or {}) do
      if not self.giftCells[index] then
        local cell = UIMgr:new_widget("pokemon_glory_award_item")
        cell:invoke("updateInfo", value)
        self.gvGiftList:AddItem(cell)
        self.giftCells[index] = cell
      else
        self.giftCells[index]:invoke("updateInfo", value)
      end
    end
  end
end

function WinPokemonGloryHall:sortGloryAwardList(data)
  table.sort(data, function(a, b)
    if a.awardType == b.awardType then
      if a.awardType == 1 then
        local qualityA = PokemonConfig:getConfigById(a.pkmId).quality
        local qualityB = PokemonConfig:getConfigById(b.pkmId).quality
        return qualityA > qualityB
      elseif a.awardType == 2 then
        local rarityA = setting:fetch("item", a.fullName).rarity
        local rarityB = setting:fetch("item", b.fullName).rarity
        return rarityA > rarityB
      else
        return a.awardType < b.awardType
      end
    else
      return a.awardType < b.awardType
    end
  end)
end

function WinPokemonGloryHall:updateGymIconShow()
  local data = PokemonGloryHallConfig:getCfgByOpenDay(self.curWeekDay)
  if data and type(data) == "table" then
    self.gvIconList:InitConfig(10, 0, #data)
    for i, cell in pairs(self.iconCells or {}) do
      if i > #data then
        self.gvIconList:RemoveItem(cell)
        self.iconCells[i] = nil
      end
    end
    for index, value in pairs(data or {}) do
      if not self.iconCells[index] then
        local cell = UIMgr:new_widget("pokemon_glory_gym_item")
        cell:invoke("updateInfo", value.gymIcon)
        self.gvIconList:AddItem(cell)
        self.iconCells[index] = cell
      else
        self.iconCells[index]:invoke("updateInfo", value.gymIcon)
      end
    end
  end
end

function WinPokemonGloryHall:onHide()
  UI:closeWnd("pokemonGloryHall")
end

function WinPokemonGloryHall:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonGloryHall")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPokemonGloryHall:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function WinPokemonGloryHall:onClose()
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

return WinPokemonGloryHall
