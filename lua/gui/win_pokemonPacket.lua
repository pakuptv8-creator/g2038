local M = _ENV.M
local LuaTimer = T(Lib, "LuaTimer")
local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local setting = require("common.setting")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local DetailType = {
  Upgrade = 1,
  Initiative = 2,
  StarUp = 3,
  Passive = 4
}
local tabsImage = {
  [DetailType.Upgrade] = "set:pokemon_pet_packet.json image:chb_0_upgrade",
  [DetailType.Initiative] = "set:pokemon_pet_packet.json image:chb_0_initiative",
  [DetailType.StarUp] = "set:pokemon_pet_packet.json image:chb_0_grow",
  [DetailType.Passive] = "set:pokemon_pet_packet.json image:chb_0_passive"
}
local behaviorType = {
  sell = 5,
  replace = 6,
  select = 7,
  name = 8
}
local behaviorName = {
  "level",
  "skill",
  "star",
  "talent",
  "sell",
  "replace",
  "select",
  "name",
  "level_upgrade",
  "skill_learn",
  "star_up",
  "talent_fuse",
  "move"
}
local timer = {}
local curTimerName, curTime
local timerName = {
  "total",
  "level",
  "skill",
  "star",
  "talent",
  "replace",
  "level_upgrade",
  "skill_learn",
  "star_up",
  "talent_fuse"
}
local secondPageTimerName = {
  "level_upgrade",
  "skill_learn",
  "star_up",
  "talent_fuse"
}
local tabTimerName = {
  "level",
  "skill",
  "star",
  "talent"
}
local cfgs

local function getItemIcon(itemId)
  for _, cfg in pairs(cfgs) do
    if tonumber(cfg.itemId) == tonumber(itemId) then
      return cfg.icon
    end
  end
end

function M:init()
  WinBase.init(self, "PokemonPacket.json", false)
  cfgs = setting:modCfgs("item")
  self:initWnd()
end

function M:initWnd()
  self.detail_type = 1
  self.cur_pokemon = nil
  self.battleList = {}
  self.packetList = {}
  self.packetShowList = {}
  self.selectList = {}
  self.selectItemList = {}
  self.maxStar = false
  self.type = "battle"
  self.btnClose = self:child("PokemonPacket-Close")
  self.stTitle = self:child("PokemonPacket-Title")
  self.stDetail = self:child("PokemonPacket-Detail-Text")
  self.llBattleList = self:child("PokemonPacket-Battle-List")
  self.llPacketList = self:child("PokemonPacket-Packet-List")
  self.llBattleContent = self:child("PokemonPacket-Battle-Layout")
  self.llPacketContent = self:child("PokemonPacket-Packet-Layout")
  self.lytSelectShowList = self:child("PokemonPacket-petsSelectLayout")
  self.stTitle = self:child("PokemonPacket-Title-Text")
  self.stName = self:child("PokemonPacket-Name-Text")
  self.siRaceIcon = self:child("PokemonPacket-Race-Icon")
  self.llActor = self:child("PokemonPacket-Center-Layout")
  self.awActor = self:child("PokemonPacket-Actor")
  self.siStarLevel = self:child("PokemonPacket-Star-Level-Img")
  self.imgStarUpArrow = self:child("PokemonPacket-StarUpArrow")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.siStarLevel:AddChildWindow(self.itemStarLevel)
  self.siLock = self:child("PokemonPacket-Lock-Img")
  self.ltyLockPopup = self:child("PokemonPacket-LockPopup")
  self.txtLockPopup = self:child("PokemonPacket-LockTip")
  self.stPowerScore = self:child("PokemonPacket-Power-Score")
  self.btnRename = self:child("PokemonPacket-Packet-Rename")
  self.btnFollowPetRelease = self:child("PokemonPacket-Follow-Pet-Release")
  self.btnMutate = self:child("PokemonPacket-mutateBtn")
  self.cbClassifyOpenCheckBox = self:child("PokemonPacket-Classify-CheckBox")
  self.llClassifyOpenLayout = self:child("PokemonPacket-Classify-Open-Layout")
  self.llClassifyTabList = self:child("PokemonPacket-Classify-Tab-List")
  self.siCurClassifyIcon = self:child("PokemonPacket-CurClassify")
  self.stCurClassifyText = self:child("PokemonPacket-CurClassify-Text")
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPacketList:InitConfig(10, 10, 3)
  self.llPacketList:AddChildWindow(self.gvPacketList)
  local width = self.llPacketList:GetPixelSize().x
  local itemWidth = (width - 20) / 3
  local adapter = UIMgr:new_adapter("pokemon_packet", math.floor(itemWidth), math.floor(itemWidth))
  self.gvPacketList:invoke("setAdapter", adapter)
  self.btnPacketShop = self:child("PokemonPacket-Shop")
  self.btnReplace = self:child("PokemonPacket-Battle-Replace")
  self.btnRelease = self:child("PokemonPacket-Packet-Release")
  self.btnJoin = self:child("PokemonPacket-Packet-Join")
  self.btnFunction_Upgrade = self:child("PokemonPacket-Detail-Function_Upgrade")
  self.btnFunction_Skill = self:child("PokemonPacket-Detail-Function_Skill")
  self.btnFunction_Starup = self:child("PokemonPacket-Detail-Function_Starup")
  self.btnFunction_Wake = self:child("PokemonPacket-Detail-Function_Wake")
  self.btnSwap = self:child("PokemonPacket-Detail-Swap")
  self.btnShowEvolution = self:child("PokemonPacket-EvolutionShowBtn")
  self:child("PokemonPacket-Detail-Exp-Title"):SetText("EXP")
  self.btnReplace:SetText(Lang:toText("gui.btn.replace"))
  self.btnRelease:SetText(Lang:toText("gui.btn.release"))
  self.btnJoin:SetText(Lang:toText("gui.btn.replace"))
  self.upgradeTabRedPoint = UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_TAB, self:child("PokemonPacket-Detail-Tab1"), -5, 5)
  self.upgradeBtnRedPoint = UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_BTN, self.btnFunction_Upgrade, -5, 5)
  self.wakeTabRedPoint = UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_RISE_TAB, self:child("PokemonPacket-Detail-Tab4"), -5, 5)
  self.wakeBtnRedPoint = UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_RISE_BTN, self.btnFunction_Wake, -5, 5)
  self.starUpTabRedPoint = UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_TAB, self:child("PokemonPacket-Detail-Tab3"), -5, 5)
  self.starUpBtnRedPoint = UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_BTN, self.btnFunction_Starup, -5, 5)
  self:initCurrency()
  self.battleItems = {}
  self:initTimer()
  self:initTabs()
  self:upDatePokemonBattleList()
  self:upDatePokemonPacketList()
  self:changeClassifyTab(0)
  self:initEvent()
end

function M:initCurrency()
  self.llCurrencyMoney = self:child("PokemonPacket-Currency-Money")
  self.llGoldDiamond = self:child("PokemonPacket-Gold-Diamond")
  self.llCashCoupon = self:child("PokemonPacket-Cash-Coupon")
  local money_currency = UIMgr:new_widget("common_currency")
  money_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  money_currency:invoke("setCurrencyType", "gold_coin")
  self.llCurrencyMoney:AddChildWindow(money_currency)
  local diamonds_currency = UIMgr:new_widget("common_currency")
  diamonds_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  diamonds_currency:invoke("setCurrencyType", World.cfg.useFDiamonds and "fDiamonds" or "gDiamonds")
  self.llGoldDiamond:AddChildWindow(diamonds_currency)
  local cash_coupon = UIMgr:new_widget("common_currency")
  cash_coupon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  cash_coupon:invoke("setCurrencyType", "gameCashCoupon")
  self.llCashCoupon:AddChildWindow(cash_coupon)
end

function M:initTimer()
  for _, name in pairs(timerName) do
    timer[name] = 0
  end
  timer.total = os.time()
  curTime = os.time()
  curTimerName = tabTimerName[self.detail_type or 1]
end

function M:initTabs()
  self.tabs = {}
  self.layouts = {}
  for _, index in pairs(DetailType) do
    local tab = self:child("PokemonPacket-Detail-Tab" .. tostring(index))
    local layout = self:child("PokemonPacket-Detail-Layout" .. tostring(index))
    self.tabs[index] = tab
    self.layouts[index] = layout
    self:lightSubscribe("error!!!!! script_client win_pokemonPacket PokemonPacket-Detail-Tab" .. tostring(index) .. " event : EventWindowClick", tab, UIEvent.EventWindowClick, function()
      self:selectTab(index)
      self:sendBehaviorReport(index)
      self:changePageTimer(tabTimerName[index])
      if not Me:isGuideFinish() and index == 4 and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_SELECT_TAB then
        Me:gotoNextGuide()
      end
    end)
  end
  self:selectTab(DetailType.Upgrade)
end

function M:initClassifyTabs()
  if self.initClassify then
    return
  end
  self.initClassify = true
  self.classifyTabs = {}
  local raceIds = RaceConfig:getAllRaceId()
  table.insert(raceIds, 1, 0)
  local itemWidth = self.llClassifyTabList:GetPixelSize().x
  local height = self.llClassifyTabList:GetPixelSize().y
  local itemHeight = (height - 10 * (#raceIds - 1)) / #raceIds
  local positionY = 0
  for index, raceId in pairs(raceIds) do
    local tab = UIMgr:new_widget("pokemon_race_tab_cell")
    tab:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    tab:invoke("setRaceId", raceId)
    self.llClassifyTabList:AddChildWindow(tab)
    self.classifyTabs[index] = tab
    self:lightSubscribe("error!!!!! script_client win_pokemonPacket pokemon_race_tab_cell-index=" .. index .. " event : EventCheckStateChanged", tab, UIEvent.EventCheckStateChanged, function()
      if tab:GetChecked() then
        for _, tabCheckBox in pairs(self.classifyTabs) do
          if tabCheckBox:GetChecked() and tabCheckBox ~= tab then
            tabCheckBox:SetChecked(false)
            tabCheckBox:SetTouchable(true)
          end
        end
        tab:SetTouchable(false)
        self:changeClassifyTab(raceId)
      end
    end)
    positionY = positionY + itemHeight + 10
  end
  self:upDateClassifyTab()
  self:selectClassifyTab(1)
end

function M:initUpgradeDetail()
  if self.initUpgrade then
    return
  end
  self.initUpgrade = true
  self.stLevelText = self:child("PokemonPacket-Detail-Level-Text")
  self.stExpText = self:child("PokemonPacket-Detail-Exp-Text")
  self.pbExpBar = self:child("PokemonPacket-Detail-Exp-Bar")
  self.stFeatureTitle = self:child("PokemonPacket-Detail-Feature-Title")
  self.stFeatureName = self:child("PokemonPacket-Detail-Feature-Name")
  self.stFeatureDesc = self:child("PokemonPacket-Detail-Feature-Desc")
  self.stHpText = self:child("PokemonPacket-Detail-Hp-Text")
  self.stSpeedText = self:child("PokemonPacket-Detail-Speed-Text")
  self.stPAtkText = self:child("PokemonPacket-Detail-PAtk-Text")
  self.stPDefText = self:child("PokemonPacket-Detail-PDef-Text")
  self.stSAtkText = self:child("PokemonPacket-Detail-SAtk-Text")
  self.stSDefText = self:child("PokemonPacket-Detail-SDef-Text")
  self.stHpExtra = self:child("PokemonPacket-Detail-Hp-Extra")
  self.stSpeedExtra = self:child("PokemonPacket-Detail-Speed-Extra")
  self.stPAtkExtra = self:child("PokemonPacket-Detail-PAtk-Extra")
  self.stPDefExtra = self:child("PokemonPacket-Detail-PDef-Extra")
  self.stSAtkExtra = self:child("PokemonPacket-Detail-SAtk-Extra")
  self.stSDefExtra = self:child("PokemonPacket-Detail-SDef-Extra")
  self.stHpTitle = self:child("PokemonPacket-Detail-Hp-Title")
  self.stSpeedTitle = self:child("PokemonPacket-Detail-Speed-Title")
  self.stPAtkTitle = self:child("PokemonPacket-Detail-PAtk-Title")
  self.stPDefTitle = self:child("PokemonPacket-Detail-PDef-Title")
  self.stSAtkTitle = self:child("PokemonPacket-Detail-SAtk-Title")
  self.stSDefTitle = self:child("PokemonPacket-Detail-SDef-Title")
  self.stHpTitle:SetText(Lang:toText("gui.text.hp"))
  self.stSpeedTitle:SetText(Lang:toText("gui.text.speed"))
  self.stPAtkTitle:SetText(Lang:toText("gui.text.pAtk"))
  self.stPDefTitle:SetText(Lang:toText("gui.text.pDef"))
  self.stSAtkTitle:SetText(Lang:toText("gui.text.sAtk"))
  self.stSDefTitle:SetText(Lang:toText("gui.text.sDef"))
end

function M:initSkillDetail()
  if self.initSkill then
    return
  end
  self.initSkill = true
  self.skillItems = {}
  self.stSkillList = self:child("PokemonPacket-Detail-Skill-List")
  self.lySkillDetail = self:child("PokemonPacket-Detail-Skill-Desc")
  self.descItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.descItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.descItem:invoke("setType")
  self.lySkillDetail:AddChildWindow(self.descItem)
  local itemWidth = self.stSkillList:GetPixelSize().x
  local height = self.stSkillList:GetPixelSize().y
  local itemHeight = (height - 33) / 4
  local positionY = 0
  for index = 1, 4 do
    local item = UIMgr:new_widget("pokemon_skill_cell")
    item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.stSkillList:AddChildWindow(item)
    self.skillItems[index] = item
    positionY = positionY + itemHeight + 11
    self:lightSubscribe("error!!!!! script_client win_pokemonPacket pokemon_skill_cell-index=" .. index .. " event : EventWindowClick", item, UIEvent.EventWindowClick, function()
      self:selectSkillItem(item)
    end)
  end
end

function M:initStarUpDetail()
  if self.initStarUp then
    return
  end
  self.initStarUp = true
  self.txtStarUpTitle = self:child("PokemonPacket-StarUp-Title")
  self.txtStarUpTitle:SetText(Lang:toText("gui.starUp.title"))
  self.txtStarUpTip = self:child("PokemonPacket-StarUp-UnLockTip")
  self.lytAttributes = self:child("PokemonPacket-Detail-Layout3Attributes")
  self.starUpAttributesItem = UIMgr:new_widget("pokemonAttributes")
  self.starUpAttributesItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytAttributes:AddChildWindow(self.starUpAttributesItem)
  self.lytStars = self:child("PokemonPacket-StarShowLayout")
  self.starAutoLayout = UIMgr:new_widget("autoLayout")
  self.stars = {}
  for _ = 1, 6 do
    local starItem = UIMgr:new_widget("star")
    table.insert(self.stars, starItem)
  end
  self.starAutoLayout:invoke("initLayout", self.stars, self.lytStars)
  self.starAutoLayout:invoke("setHInterval", 0.2)
  self.selectCellItems = {}
  for _ = 1, 5 do
    local cellItem = UIMgr:new_widget("pokemonSelectCell")
    cellItem:SetVisible(false)
    table.insert(self.selectCellItems, cellItem)
  end
end

function M:initPassiveDetail()
  if self.initPassive then
    return
  end
  self.initPassive = true
  self.passiveItems = {}
  self.txtWakeTitle = self:child("PokemonPacket-Detail-Passive-Text")
  self.txtWakeTitle:SetText(Lang:toText("gui.wake.title"))
  self.stPassiveList = self:child("PokemonPacket-Detail-Passive-List")
  self.stPassiveDescIconBg = self:child("PokemonPacket-Detail-Passive-Desc-Icon-Bg")
  self.stPassiveDescIcon = UIMgr:new_widget("pokemon_passive_cell")
  self.stPassiveDescIcon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.stPassiveDescIconBg:AddChildWindow(self.stPassiveDescIcon)
  self.stPassiveDescName = self:child("PokemonPacket-Detail-Passive-Desc-Name")
  self.stPassiveDescText = self:child("PokemonPacket-Detail-Passive-Desc-Text")
  self.stPassiveText = self:child("PokemonPacket-Detail-Passive-Text")
  self.stPassiveText:SetText(Lang:toText("gui.wake.text"))
  self.starLeftLayout = self:child("PokemonPacket-Detail-Passive-Star-Left")
  self.stPassiveStarLeft = UIMgr:new_widget("pokemon_star_item_cell")
  self.starLeftLayout:AddChildWindow(self.stPassiveStarLeft)
  self.starRightLayout = self:child("PokemonPacket-Detail-Passive-Star-Right")
  self.stPassiveStarRight = UIMgr:new_widget("pokemon_star_item_cell")
  self.starRightLayout:AddChildWindow(self.stPassiveStarRight)
  self.siPassiveStarArrow = self:child("PokemonPacket-Detail-Passive-Star-Arrow")
  self.txtEvolutionBtnTxt = self:child("PokemonPacket-ShowEvolutionBtnTxt")
  self.txtEvolutionBtnTxt:SetText(Lang:toText("gui.evolution.preview"))
  local width = self.stPassiveList:GetPixelSize().x
  local itemWidth = (width - 42) / 4
  local itemHeight = itemWidth
  local positionY = 0
  local positionX = 0
  for index = 1, 8 do
    local item = UIMgr:new_widget("pokemon_passive_cell")
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.stPassiveList:AddChildWindow(item)
    self.passiveItems[index] = item
    positionX = positionX + itemWidth + 14
    if index % 4 == 0 then
      positionX = 0
      positionY = positionY + itemHeight + 14
    end
    self:lightSubscribe("error!!!!! script_client win_pokemonPacket pokemon_passive_cell-index=" .. index .. " event : EventWindowClick", item, UIEvent.EventWindowClick, function()
      self:selectPassiveItem(item)
    end)
  end
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnClose event : EventButtonClick", self.btnClose, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() then
      if Me:getCurGuideIndex() == Define.GUIDE_INDEX.UPGRADE_POKEMON_CLOSE_PACKET or Me:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_CLOSE_PACKET or Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_PACKET then
        Me:gotoNextGuide()
      else
        UI:closeWnd(self)
      end
    else
      UI:closeWnd(self)
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket siLock event : EventWindowClick", self.siLock, UIEvent.EventWindowClick, function()
    if self.mode == "swap" or self.lockCD then
      return
    end
    local lockState = self.isLocked
    Me:sendPacket({
      pid = "lockPokemon",
      objId = self.cur_pokemon:getObjId(),
      value = not lockState
    }, function(res)
      if not res then
        return
      end
      self:showLockPopup(lockState and "gui.pet.unLocked" or "gui.pet.isLocked")
    end)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnPacketShop event : EventButtonClick", self.btnPacketShop, UIEvent.EventButtonClick, function()
    self:sendBehaviorReport(behaviorName[self.detail_type])
    UI:getWnd("pokemon_Shop"):onShow(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnRename event : EventButtonClick", self.btnRename, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonRename"):onShow(self.cur_pokemon)
    self:sendBehaviorReport(behaviorType.name)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnReplace event : EventButtonClick", self.btnReplace, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonReplace"):onShow()
    self:sendBehaviorReport(behaviorType.replace)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnShowEvolution event : EventButtonClick", self.btnShowEvolution, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonEvolutionShow"):onShow(self.cur_pokemon)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnRelease event : EventButtonClick", self.btnRelease, UIEvent.EventButtonClick, function()
    local preTimerName = curTimerName
    self:changePageTimer("replace")
    
    local function recordTimerCallback()
      self:changePageTimer(preTimerName)
    end
    
    UI:getWnd("pokemonRelease"):onShow(recordTimerCallback)
    self:sendBehaviorReport(behaviorType.sell)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnJoin event : EventButtonClick", self.btnJoin, UIEvent.EventButtonClick, function()
    local preTimerName = curTimerName
    self:changePageTimer("replace")
    
    local function recordTimerCallback()
      self:changePageTimer(preTimerName)
    end
    
    UI:getWnd("pokemonReplace"):onShow(recordTimerCallback)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnSwap event : EventButtonClick", self.btnSwap, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "selectSwapPokemon",
      objId = self.cur_pokemon:getObjId()
    }, function(results)
      if results.success then
        UI:closeWnd(self)
      else
        Me:showChatShopDialog({
          titleText = "gui.tip.title",
          msgText = results.lang
        })
      end
    end)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnFunction_Upgrade event : EventButtonClick", self.btnFunction_Upgrade, UIEvent.EventButtonClick, function()
    self.cur_pokemon:setCanLevelUpRedPointShow(false)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_BTN, false)
    if self.mode == "battle" then
      for index = 1, 4 do
        local pokemon = self.battleItems[index]:invoke("getPokemon")
        if pokemon and pokemon == self.cur_pokemon then
          self:updateRedListShow(Define.UI_RED_DOT_TYPE.PET_CAN_LEVEL_UP, false, index)
        end
      end
    end
    self:sendBehaviorReport(9)
    local recordTimerCallback = self:getRecordTimerCallback()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.UPGRADE_POKEMON_SELECT_UPGRADE then
      Me:gotoNextGuide()
    else
      UI:getWnd("pokemonPopupUpgrade"):onShow(self.cur_pokemon, recordTimerCallback)
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnFunction_Skill event : EventButtonClick", self.btnFunction_Skill, UIEvent.EventButtonClick, function()
    self:sendBehaviorReport(10)
    local recordTimerCallback = self:getRecordTimerCallback()
    UI:getWnd("pokemonBagStudySkill"):onShow(self.cur_pokemon, recordTimerCallback)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnFunction_Starup event : EventButtonClick", self.btnFunction_Starup, UIEvent.EventButtonClick, function()
    self:sendBehaviorReport(11)
    if self.maxStar then
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.max.star.up"
      }, function()
      end)
      return
    end
    local costMap = PokemonConfig:getStarConfig(self.cur_pokemon:getStar()).starUpCost
    if #self.selectList == tonumber(costMap[1]) then
      if self.pokemonStarUpLock then
        return
      end
      self.pokemonStarUpLock = true
      local selectObjIds = {}
      for _, pokemon in pairs(self.selectList) do
        table.insert(selectObjIds, pokemon:getObjId())
      end
      self.selectList = {}
      Me:sendPacket({
        pid = "pokemonStarUp",
        objId = self.cur_pokemon:getObjId(),
        selectObjIds = selectObjIds
      }, function()
        self.pokemonStarUpLock = false
        UI:getWnd("pokemon_starUp_popup"):onShow({
          toSelect = false,
          cur_pokemon = self.cur_pokemon
        })
      end)
    else
      local recordTimerCallback = self:getRecordTimerCallback()
      UI:getWnd("pokemon_starUp_popup"):onShow({
        toSelect = true,
        cur_pokemon = self.cur_pokemon,
        selectList = self.selectList,
        yesCb = function(selectList)
          self:updateStarUpSelectShow(selectList)
        end,
        recordTimerCallback = recordTimerCallback
      })
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnFunction_Wake event : EventButtonClick", self.btnFunction_Wake, UIEvent.EventButtonClick, function()
    self:sendBehaviorReport(12)
    if self.cur_pokemon:getWake() >= self.cur_pokemon:getMaxWake() then
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.wake.max"
      }, function()
      end)
      return
    end
    local recordTimerCallback = self:getRecordTimerCallback()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_OPEN_WND then
      Me:gotoNextGuide()
    else
      UI:getWnd("pokemonWake"):onShow(self.cur_pokemon, recordTimerCallback, self.mode)
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnMutate event : EventButtonClick", self.btnMutate, UIEvent.EventButtonClick, function()
    UI:getWnd("mutatePopup"):onShow(self.cur_pokemon)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket cbClassifyOpenCheckBox event : EventCheckStateChanged", self.cbClassifyOpenCheckBox, UIEvent.EventCheckStateChanged, function()
    local checked = self.cbClassifyOpenCheckBox:GetChecked()
    if checked then
      self:initClassifyTabs()
    end
    self.llClassifyOpenLayout:SetVisible(checked)
    self:sendBehaviorReport(behaviorType.select)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonPacket Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if self.cur_pokemon and tostring(objId) == tostring(self.cur_pokemon:getObjId()) then
      self:selectPokemon(self.cur_pokemon)
      self:updateBtnFunction(self.detail_type)
      if self.mode == "battle" then
        self:refreshPokemonBattleUI()
      end
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonPacket Lib event : EVENT_CHANGE_BATTLE_PET", Event.EVENT_CHANGE_BATTLE_PET, function(value)
    self:upDatePokemonBattleList(value)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonPacket Lib event : EVENT_CHANGE_PACKET_PET", Event.EVENT_CHANGE_PACKET_PET, function(value)
    self:upDatePokemonPacketList(value)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonPacket btnFollowPetRelease event : EventButtonClick", self.btnFollowPetRelease, UIEvent.EventButtonClick, function()
    if not Me:getFollowPetPrivilege() then
      local cfg = World.cfg.followPetPrivilege
      if cfg then
        if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.OPEN_FOLLOW_PET then
          Me:gotoNextGuide()
        end
        UI:openWnd("followPetPrivilegeTip", cfg)
      end
      return
    end
    Lib.emitEvent(Event.EVENT_SHOW_FOLLOW_PET)
  end)
  Lib.subscribeEvent(Event.EVENT_SHOW_FOLLOW_PET, function()
    Me:sendPacket({
      pid = "ShowFollowPet",
      fullName = self.cur_pokemon:getCfgFullName(),
      objId = self.cur_pokemon:getObjId()
    }, function(results)
      self:setFollowPetBtnByStatus(results)
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_FOLLOW_PET_PRIVILEGE_BTN_CHANGE, function()
    self:setFollowPetBtn()
  end)
  Lib.subscribeEvent(Event.EVENT_CHANGE_BATTLE_PET, function()
    Me:getBattlePokemon(function(battlePokemonList)
      local packetPokemonList = {}
      Me:getPacketPokemon(function(pokemonList)
        packetPokemonList = pokemonList
      end)
      for index, pokemon in pairs(battlePokemonList) do
        local canWake = PokemonConfig:checkCanRise(pokemon, packetPokemonList, battlePokemonList)
        pokemon:setCanWakeRedPointShow(canWake)
        self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE, canWake, index)
        if self.cur_pokemon == pokemon then
          self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT, pokemon:getCanWakeRedPointShow())
        end
      end
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_GAIN_POKEMON, function(wakeRedShowIndexList, starUpShowIndexList)
    self:setCanShowRedPokemon(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE, wakeRedShowIndexList)
    self:setCanShowRedPokemon(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_STAR_UP, starUpShowIndexList)
  end)
  Lib.subscribeEvent(Event.EVENT_GAIN_EXP_ITEM, function(indexList)
    self:setCanShowRedPokemon(Define.UI_RED_DOT_TYPE.PET_CAN_LEVEL_UP, indexList)
  end)
  Lib.subscribeEvent(Event.EVENT_CLICK_WAKE_CONFIRM, function()
    if self.mode ~= "battle" then
      return
    end
    local battlePokemonList
    Me:getBattlePokemon(function(pokemonList)
      battlePokemonList = pokemonList
    end)
    self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM, false)
    local packetPokemonList = {}
    Me:getPacketPokemon(function(pokemonList)
      packetPokemonList = pokemonList
    end)
    for index, battleItem in pairs(self.battleItems) do
      local pokemon = battleItem:invoke("getPokemon")
      if pokemon then
        pokemon:setCanWakeRedPointShow(PokemonConfig:checkCanRise(pokemon, packetPokemonList, battlePokemonList))
        self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE, pokemon:getCanWakeRedPointShow(), index)
        if pokemon == self.cur_pokemon then
          self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT, pokemon:getCanWakeRedPointShow())
        end
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CLICK_STAR_UP_SELECT, function()
    if self.mode ~= "battle" then
      return
    end
    for index, battleItem in pairs(self.battleItems) do
      local pokemon = battleItem:invoke("getPokemon")
      if pokemon == self.cur_pokemon then
        pokemon:setCanStarUpRedShow(false)
        self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_STAR_UP, false, index)
      end
    end
  end)
end

function M:setCanShowRedPokemon(redType, indexList)
  for _, index in pairs(indexList) do
    self:updateRedListShow(redType, true, index)
  end
end

function M:updateRedListShow(redType, show, childKey)
  UIRedDotMgr:updateRedNodeShowByRedType(redType, show, nil, nil, childKey)
end

function M:initRecordTimer()
end

function M:updateStarUpSelectShow(selectList)
  self.selectList = selectList
  local costMap = PokemonConfig:getStarConfig(self.cur_pokemon:getStar()).starUpCost
  for index = 1, costMap[1] do
    self.selectCellItems[index]:invoke("setPokemon", selectList[index])
  end
end

function M:getRecordTimerCallback()
  local preTimerName = curTimerName
  self:changePageTimer(secondPageTimerName[self.detail_type])
  
  local function recordTimerCallback()
    self:changePageTimer(preTimerName)
  end
  
  return recordTimerCallback
end

function M:onShow(type, tabType)
  if Me:isInPreBattleOrBattle() then
    return
  end
  local battlePetList = Me:getValue("battlePetList")
  local packetPetList = Me:getValue("packetPetList")
  if #battlePetList == 0 and #packetPetList == 0 then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.no.pokemon"
    }, function()
    end)
    return
  end
  self.pokemonStarUpLock = false
  self.type = type or self.type
  self.llBattleContent:SetVisible(self.type == "battle")
  self.llPacketContent:SetVisible(self.type == "packet" or self.type == "swap")
  if self.type == "battle" then
    self.mode = "battle"
    Lib.logDebug("battle")
    self.stTitle:SetText(Lang:toText("gui.title.pet.team"))
    self:refreshPokemonBattleUI()
    self:hideSwapModeBtn(false)
  end
  if self.type == "packet" then
    self.mode = "packet"
    Lib.logDebug("packet")
    self.stTitle:SetText(Lang:toText("gui.title.pet.box"))
    self:refreshPokemonPacketUI()
    self:hideSwapModeBtn(false)
  end
  if self.type == "swap" then
    self.mode = "swap"
    Lib.logDebug("swap")
    self.stTitle:SetText(Lang:toText("gui.title.pet.swap"))
    self:refreshPokemonPacketUI()
    self.old_raceId = self.cur_raceId
    self:initClassifyTabs()
    self:selectClassifyTab(1)
    self:hideSwapModeBtn(true)
  end
  if self.mode ~= "battle" then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT, false)
    for index = 1, 5 do
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, false, nil, nil, index)
    end
    self:updateRedListShow(Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_BTN, false)
  end
  self.btnSwap:SetVisible(self.type == "swap")
  self.btnJoin:SetVisible(self.type ~= "swap")
  self.btnRelease:SetVisible(self.type ~= "swap")
  self.btnReplace:SetVisible(self.type ~= "swap")
  self.btnFollowPetRelease:SetVisible(self.type ~= "swap")
  self:selectTab(tabType or self.detail_type)
  UI:openWnd("pokemonPacket")
end

function M:selectSkillItem(selectItem)
  local skill = selectItem:invoke("getSkill")
  if skill.skillId == 0 then
    if self.type ~= "swap" then
      UI:getWnd("pokemonBagStudySkill"):onShow(self.cur_pokemon)
    end
    return
  end
  for _, item in pairs(self.skillItems) do
    item:invoke("onChecked", false)
    if selectItem == item then
      item:invoke("onChecked", true)
      self.descItem:invoke("updateInfo", skill)
    end
  end
end

function M:selectPassiveItem(selectItem)
  local skillId = selectItem:invoke("getSkillId")
  if skillId == 0 then
    return
  end
  for _, item in pairs(self.passiveItems) do
    item:invoke("onChecked", false)
    if selectItem == item then
      item:invoke("onChecked", true)
      local skill_config = SkillConfig:getConfigById(skillId) or {}
      self.stPassiveDescName:SetText(Lang:toText(skill_config.name or "SkillName"))
      self.stPassiveDescText:SetText(Lang:toText(skill_config.describe or "DescText"))
      self.stPassiveDescIcon:invoke("updateInfo", skillId, false)
    end
  end
end

function M:selectPokemon(pokemon)
  self.cur_pokemon = pokemon
  self:updatePokemonState()
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(pokemon:getCfgFullName())
  local pokemon_config = PokemonConfig:getConfigById(pokemon:getCfgId())
  self.stName:SetText(Lang:toText(pokemon:getName()))
  self.siRaceIcon:SetImage(RaceConfig:getClassifyIcon(pokemon:getRace()))
  self.awActor:SetActor1(entity_cfg.actorName, "idle")
  self.awActor:SetActorScale(pokemon_config.uiScale)
  if getmetatable(self.awActor).SetActorOffset then
    self.awActor:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  self.awActor:SetYPosition({
    pokemon_config.uiOffsetY,
    0
  })
  self.awActor:SetRotateY(-15)
  self.awActor:SetRotateX(10)
  self.itemStarLevel:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake(), 0)
  self.siLock:SetImage(self.isLocked and "set:pokemon_pet_packet.json image:btn_0_locked" or "set:pokemon_pet_packet.json image:btn_0_unlocked")
  self.stPowerScore:SetText(Lang:toText("gui.text.cp") .. pokemon:getFightPower())
  self:setFollowPetBtn()
  self.btnRename:SetEnabled(true)
  if self.type == "swap" then
    self.btnSwap:SetEnabled(true)
    self.btnSwap:SetText(Lang:toText("gui.btn.swap"))
    if pokemon:getMasterId() ~= Me.platformUserId then
      self.btnSwap:SetEnabled(false)
      self.btnRename:SetEnabled(false)
      self.btnSwap:SetText(Lang:toText("gui.swap.pokemon.not.me"))
    end
    local isInTeam
    local battlePetList = Me:getValue("battlePetList")
    for _, objId in pairs(battlePetList) do
      if objId == pokemon:getObjId() then
        isInTeam = true
        self.btnSwap:SetEnabled(false)
        self.btnSwap:SetText(Lang:toText("gui.swap.pokemon.in.battle"))
        break
      end
    end
    if not isInTeam and pokemon:isLocked() then
      self.btnSwap:SetEnabled(false)
      self.btnSwap:SetText(Lang:toText("gui.lockedPet.cant.swap"))
    elseif not isInTeam and pokemon:getQuality() == Define.POKEMON_QUALITY.MYTHICAL then
      self.btnSwap:SetEnabled(false)
      self.btnSwap:SetText(Lang:toText("gui.swap.pokemon.is.epic"))
    end
  end
  self:refreshDetail()
  self:updateBtnFunction(self.detail_type)
end

function M:refreshDetail()
  if not self.cur_pokemon then
    return
  end
  if self.detail_type == DetailType.Upgrade then
    self:refreshUpgradeDetail()
  elseif self.detail_type == DetailType.Initiative then
    self:refreshSkillDetail()
  elseif self.detail_type == DetailType.StarUp then
    self:refreshStarUpDetail()
  elseif self.detail_type == DetailType.Passive then
    self:refreshPassiveDetail()
  end
end

function M:refreshUpgradeDetail()
  self:initUpgradeDetail()
  local pokemon = self.cur_pokemon
  local exp_progress = tonumber(pokemon:getCurExp()) / tonumber(pokemon:getMaxExp())
  local color = {
    level = "\226\150\162FF9B0081",
    maxLevel = "\226\150\162FF9F5F9F"
  }
  self.stLevelText:SetText(color.level .. "Lv." .. tostring(pokemon:getLevel()) .. color.maxLevel .. "/" .. tostring(self.maxLevel))
  self.stExpText:SetText(tostring(pokemon:getCurExp()) .. "/" .. tostring(pokemon:getMaxExp()))
  self.pbExpBar:SetProgress(exp_progress)
  pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.Hp)
  local extraHp = pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.Hp)
  local extraSpeed = pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.Speed)
  local extraPAtk = pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.PAtk)
  local extraPDef = pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.PDef)
  local extraSAtk = pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.SAtk)
  local extraSDef = pokemon:getExtraAttrByType(Define.POKEMON_ATTR_TYPE.SDef)
  self.stHpText:SetText(pokemon:getMaxHp())
  self.stSpeedText:SetText(pokemon:getSpeed())
  self.stPAtkText:SetText(pokemon:getPhysicalAtk())
  self.stPDefText:SetText(pokemon:getPhysicalDef())
  self.stSAtkText:SetText(pokemon:getSpecialAtk())
  self.stSDefText:SetText(pokemon:getSpecialDef())
  self.stHpExtra:SetText("(" .. extraHp .. ")")
  self.stSpeedExtra:SetText("(" .. extraSpeed .. ")")
  self.stPAtkExtra:SetText("(" .. extraPAtk .. ")")
  self.stPDefExtra:SetText("(" .. extraPDef .. ")")
  self.stSAtkExtra:SetText("(" .. extraSAtk .. ")")
  self.stSDefExtra:SetText("(" .. extraSDef .. ")")
  local color = RaceConfig:getColorBg(pokemon:getRace())
  self._root:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
  local feature_config = SkillConfig:getConfigById(pokemon:getFeatures()) or {}
  self.stFeatureName:SetText(Lang:toText(feature_config.name or "FeatureName"))
  self.stFeatureDesc:SetText(Lang:toText(feature_config.describe or "FeatureDesc"))
  if pokemon:isMutated() then
    self.stFeatureTitle:SetText(Lang:toText("special_feature"))
  else
    self.stFeatureTitle:SetText(Lang:toText("common_feature"))
  end
  local mutateItem = self.cur_pokemon:getMutateItem()
  self.btnMutate:SetEnabled(mutateItem[1] ~= nil and not pokemon:isMutated())
  self.btnMutate:SetText(pokemon:isMutated() and Lang:toText("mutated_title") or Lang:toText("mutate_title"))
end

function M:refreshSkillDetail()
  self:initSkillDetail()
  local pokemon = self.cur_pokemon
  local skillList = pokemon:getSkillList()
  for index, item in pairs(self.skillItems) do
    item:invoke("updateInfo", skillList[index])
  end
  self:selectSkillItem(self.skillItems[1])
end

function M:refreshStarUpDetail()
  self:initStarUpDetail()
  local pokemon = self.cur_pokemon
  local costMap = PokemonConfig:getStarConfig(self.cur_pokemon:getStar()).starUpCost
  self.txtStarUpTip:SetVisible(not self.maxStar)
  local unLockLevel = PokemonConfig:getStarConfig(self.cur_pokemon:getStar() + 1).levelMax
  self.txtStarUpTip:SetText(string.format(Lang:toText("gui.starUp.unlock"), unLockLevel))
  self.selectList = {}
  local items = {}
  if self.mode ~= "swap" then
    for index = 1, costMap[1] do
      table.insert(items, self.selectCellItems[index])
      self.selectCellItems[index]:SetVisible(true)
      self.selectCellItems[index]:invoke("setData", function()
        local preTimerName = curTimerName
        self:changePageTimer(secondPageTimerName[3])
        
        local function recordTimerCallback()
          self:changePageTimer(preTimerName)
        end
        
        UI:getWnd("pokemon_starUp_popup"):onShow({
          toSelect = true,
          cur_pokemon = self.cur_pokemon,
          selectList = self.selectList,
          yesCb = function(selectList)
            self:updateStarUpSelectShow(selectList)
          end,
          recordTimerCallback = recordTimerCallback
        })
      end, nil)
    end
  end
  for index = costMap[1] + 1, 5 do
    self.selectCellItems[index]:SetVisible(false)
  end
  local selectAutoLayout = UIMgr:new_widget("autoLayout")
  selectAutoLayout:invoke("initLayout", items, self.lytSelectShowList)
  selectAutoLayout:invoke("setHInterval", 0.35)
  for index = 1, 6 do
    self.stars[index]:invoke("updateUI", self.cur_pokemon:getWake() + 1)
    if self.cur_pokemon:getStar() + 1 == index then
      self.stars[index]:invoke("startTick")
    end
  end
  for index = self.cur_pokemon:getStar() + 2, 6 do
    self.stars[index]:invoke("updateUI")
  end
  self.starUpAttributesItem:invoke("updateUIByType", self.cur_pokemon, "star")
end

function M:refreshPassiveDetail()
  self:initPassiveDetail()
  local pokemon = self.cur_pokemon
  self.starLeftLayout:SetHorizontalAlignment(not self.maxWake and 0 or 1)
  local old_width = self.starRightLayout:GetPixelSize().x
  local old_height = self.starRightLayout:GetPixelSize().y
  self.starLeftLayout:SetWidth({
    0,
    not self.maxWake and old_width or old_width * 1.3
  })
  self.starLeftLayout:SetHeight({
    0,
    not self.maxWake and old_height or old_height * 1.3
  })
  self.starRightLayout:SetVisible(not self.maxWake)
  self.siPassiveStarArrow:SetVisible(not self.maxWake)
  self.stPassiveStarLeft:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake())
  self.stPassiveStarRight:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake() + 1)
  self.btnShowEvolution:SetVisible(self.cur_pokemon:getCfg().nextEvolutionId ~= 0)
  local passiveRule = pokemon:getCfg().passiveRule
  for index, item in pairs(self.passiveItems) do
    local passiveTable = passiveRule[index] or {}
    local skillId = tonumber(passiveTable[1] or 0)
    local unlockWake = tonumber(passiveTable[2] or 0)
    item:invoke("updateInfo", skillId, unlockWake > pokemon:getWake())
  end
  self:selectPassiveItem(self.passiveItems[1])
end

function M:selectBattleItem(item)
  local pokemon = item:invoke("getPokemon")
  if not pokemon then
    if UI:isOpen(self) then
      UI:getWnd("pokemonReplace"):onShow()
    end
    return
  end
  if pokemon ~= self.cur_pokemon then
    self:selectPokemon(pokemon)
  end
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT, pokemon:getCanWakeRedPointShow())
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_BTN, pokemon:getCanLevelUpRedPointShow())
  for index = 1, 5 do
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, pokemon:getCanStarUpRedShow(), nil, nil, index)
  end
  for _, battleItem in pairs(self.battleItems) do
    battleItem:invoke("onChecked", item == battleItem)
  end
end

function M:selectFirstPacketItem()
  self:selectPacketItem(self.packetShowList[1].pokemon)
end

function M:selectPacketItem(pokemon)
  if not pokemon then
    return
  end
  local hasPokemon = false
  local adapter = self.gvPacketList:invoke("getAdapter")
  for _, showItem in pairs(self.packetShowList) do
    showItem.isChecked = showItem.pokemon == pokemon
    hasPokemon = hasPokemon or showItem.pokemon == pokemon
  end
  adapter:notifyDataChange()
  if not hasPokemon then
    self:setPacketAdapterData({pokemon})
    self:selectPacketItem(pokemon)
  else
    self:selectPokemon(pokemon)
  end
  self.cbClassifyOpenCheckBox:SetEnabled(hasPokemon)
end

function M:selectTab(index)
  Lib.logDebug("selectTab index = ", index)
  for tabIndex, tabCheckBox in pairs(self.tabs) do
    local imageStr = tabsImage[tabIndex]
    if index == tabIndex then
      imageStr = imageStr .. "_checked"
    end
    tabCheckBox:SetImage(imageStr)
  end
  self:changeTab(index)
end

function M:updateBtnFunction(selectIndex)
  local btnFunctions = {
    "PokemonPacket-Detail-Function_Upgrade",
    "PokemonPacket-Detail-Function_Skill",
    "PokemonPacket-Detail-Function_Starup",
    "PokemonPacket-Detail-Function_Wake"
  }
  for index = 1, 4 do
    self:child(btnFunctions[index]):SetVisible(index == selectIndex)
  end
  self:updateBtnEnabled()
  self:updateBtnText()
end

function M:updateBtnText()
  self.btnFunction_Upgrade:SetText(Lang:toText(self.maxStarLevel and Lang:toText("gui.starUp.to.levelUp") or self.playerLevelLess and Lang:toText("gui.playerLevel.less") or "gui.btn.upgrade"))
  self.btnFunction_Skill:SetText(Lang:toText("gui.btn.learn"))
  self.btnFunction_Starup:SetText(Lang:toText(not self.maxStar and "gui.btn.star.up" or "btn.star.max"))
  self.btnFunction_Wake:SetText(Lang:toText(not self.maxWake and "gui.wake.title" or "btn.wake.max"))
end

function M:updateBtnEnabled()
  self.btnFunction_Upgrade:SetEnabled(not self.maxStarLevel and not self.playerLevelLess)
  self.btnFunction_Skill:SetEnabled(true)
  self.btnFunction_Starup:SetEnabled(not self.maxStar)
  self.btnFunction_Wake:SetEnabled(not self.maxWake)
end

function M:updatePokemonState()
  self.isLocked = self.cur_pokemon:isLocked()
  self.playerLevelLess = self.cur_pokemon:getLevel() >= Me:getPlayerLevel()
  self.maxLevel = PokemonConfig:getStarConfig(self.cur_pokemon:getStar()).levelMax
  self.maxStarLevel = self.cur_pokemon:getLevel() >= self.maxLevel
  local costMap = PokemonConfig:getStarConfig(self.cur_pokemon:getStar()).starUpCost
  self.maxStar = costMap[2] == nil or costMap[2] == 0
  self.maxWake = self.cur_pokemon:getWake() >= self.cur_pokemon:getMaxWake()
  self:updateBtnFunction(self.detail_type)
end

function M:changeTab(selectIndex)
  self.detail_type = selectIndex
  self:refreshDetail()
  for index, layout in ipairs(self.layouts) do
    layout:SetVisible(index == selectIndex)
  end
  self:updateBtnFunction(selectIndex)
end

function M:selectClassifyTab(index)
  self.classifyTabs[index]:SetChecked(true)
end

function M:changeClassifyTab(raceId)
  if raceId == self.cur_raceId then
    return
  end
  self.cur_raceId = raceId
  self.cbClassifyOpenCheckBox:SetChecked(false)
  self.stCurClassifyText:SetText(Lang:toText(RaceConfig:getName(raceId)))
  self.siCurClassifyIcon:SetImage(RaceConfig:getClassifyIcon(raceId))
  self:refreshPokemonPacketUI()
  local adapter = self.gvPacketList:invoke("getAdapter")
  adapter:setScrollOffset(0)
end

function M:upDatePokemonBattleList(objIds)
  objIds = objIds or Me:getValue("battlePetList")
  Me:getPokemonList(objIds, function(battleList)
    if #Me:getValue("battlePetList") ~= #battleList then
      return
    end
    self.battleList = battleList
    if UI:isOpen(self) and self.type == "battle" then
      self:refreshPokemonBattleUI()
    end
  end)
end

function M:upDatePokemonPacketList(objIds)
  objIds = objIds or Me:getValue("packetPetList")
  Me:getPokemonList(objIds, function(packetList)
    if #Me:getValue("packetPetList") ~= #packetList then
      return
    end
    self.packetList = packetList
    self:upDateClassifyTab()
    if UI:isOpen(self) and self.type == "packet" then
      self:refreshPokemonPacketUI()
    end
  end)
end

function M:upDateClassifyTab()
  for _, tab in pairs(self.classifyTabs or {}) do
    local raceId = tab:invoke("getRaceId")
    local pokemonList = self:getPokemonListByRaceId(raceId)
    tab:invoke("setEnabled", 0 < #pokemonList)
  end
end

function M:getPokemonListByRaceId(raceId)
  local showList = {}
  for _, pokemon in pairs(self.battleList) do
    if raceId == 0 or tonumber(pokemon:getRace()) == raceId then
      table.insert(showList, pokemon)
    end
  end
  for _, pokemon in pairs(self.packetList) do
    if raceId == 0 or tonumber(pokemon:getRace()) == raceId then
      table.insert(showList, pokemon)
    end
  end
  return showList
end

function M:filterLockPokemonToEnd(showList)
  local tempList = {}
  local lockList = {}
  for _, pokemon in pairs(showList) do
    table.insert(not Me:isInTeam(pokemon:getObjId()) and pokemon:isLocked() and lockList or tempList, pokemon)
  end
  for _, pokemon in pairs(lockList) do
    if pokemon:isLocked() then
      table.insert(tempList, pokemon)
    end
  end
  return tempList
end

function M:refreshPokemonBattleUI()
  local itemWidth = self.llBattleList:GetPixelSize().x
  local height = self.llBattleList:GetPixelSize().y
  local itemHeight = (height - 60) / 4
  local positionY = 0
  local battleList = self.battleList
  for index = 1, World.cfg.maxHandPetsCnt do
    local item = self.battleItems[index]
    local pokemon = battleList[index]
    if not item then
      item = UIMgr:new_widget("pokemon_head_cell")
      UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE, item:invoke("root"), -5, 5, index)
      UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_CELL_EMPTY, item:invoke("root"), -5, 5, index)
      UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.PET_CAN_LEVEL_UP, item:invoke("root"), -5, 5, index)
      UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_STAR_UP, item:invoke("root"), -5, 5, index)
      if index == 1 then
        item:SetName("guide_pokemon_first_cell")
      elseif index == 2 then
        item:SetName("guide_pokemon_second_cell")
      end
      item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
      item:SetVerticalAlignment(0)
      self.llBattleList:AddChildWindow(item)
      self.battleItems[index] = item
      self:lightSubscribe("error!!!!! script_client win_pokemonPacket pokemon_head_cell-index=" .. index .. " event : EventWindowTouchDown", item, UIEvent.EventWindowTouchDown, function()
        if not Me:isGuideFinish() then
          if index == 1 then
            if Me:getCurGuideIndex() == Define.GUIDE_INDEX.UPGRADE_POKEMON_SELECT_POKEMON then
              Me:gotoNextGuide()
            end
          elseif index == 2 and Me:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_EMPTY then
            Me:gotoNextGuide()
          end
        end
        self:battleItemTouchDown(item)
      end)
      item:invoke("setType", Define.SCENE_TYPE.NOT_BATTLE)
      positionY = positionY + itemHeight + 20
    end
    item:invoke("updateInfo", pokemon)
    local enoughPokemon = 0 < #Me:getValue("packetPetList") and 4 > #Me:getValue("battlePetList")
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE, pokemon and pokemon:getCanWakeRedPointShow() or false, nil, nil, index)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_CELL_EMPTY, not pokemon and enoughPokemon, nil, nil, index)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.PET_CAN_LEVEL_UP, pokemon and pokemon:getCanLevelUpRedPointShow(), nil, nil, index)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_STAR_UP, pokemon and pokemon:getCanStarUpRedShow(), nil, nil, index)
  end
  for _, battleItem in pairs(self.battleItems) do
    local pokemon = battleItem:invoke("getPokemon")
    if pokemon and pokemon == self.cur_pokemon then
      self:selectBattleItem(battleItem)
      return
    end
  end
  self:selectBattleItem(self.battleItems[1])
end

function M:refreshPokemonPacketUI()
  local raceId = self.cur_raceId
  local showPokemonList = self:getPokemonListByRaceId(raceId)
  if self.mode == "swap" then
    showPokemonList = self:filterLockPokemonToEnd(showPokemonList)
  end
  if #showPokemonList == 0 then
    return
  end
  self:setPacketAdapterData(showPokemonList)
  for _, pokemon in pairs(showPokemonList) do
    if pokemon == self.cur_pokemon then
      self:selectPacketItem(pokemon)
      return
    end
  end
  self:selectPacketItem(showPokemonList[1])
end

function M:setPacketAdapterData(showPokemonList)
  local adapter = self.gvPacketList:invoke("getAdapter")
  local showList = {}
  for _, pokemon in pairs(showPokemonList) do
    table.insert(showList, {
      pokemon = pokemon,
      clickCallBack = function()
        if self.mode == "swap" then
          if pokemon:isLocked() then
            self:showLockPopup("gui.pet.isLocked")
          else
            self:hideLockPopup()
          end
        end
        self:selectPacketItem(pokemon)
      end,
      checkInTeam = true,
      checkLocked = self.mode == "swap",
      isChecked = false,
      checkIsNew = UIRedDotMgr:getRedShowStateByRedType(Define.UI_RED_DOT_TYPE.MAIN_PET_RED)
    })
  end
  for index = 1, World.cfg.maxBoxPetsCnt do
    if not showList[index] then
      showList[index] = {pokemon = nil, isChecked = false}
    end
  end
  self.packetShowList = showList
  adapter:setData(showList)
end

function M:showReplace()
  local item = self.battleItems[2]
  self:battleItemTouchDown(item)
end

function M:battleItemTouchDown(item)
  self:selectBattleItem(item)
  
  local function behaviorReport()
    self:sendBehaviorReport(13)
  end
  
  UI:getWnd("pokemonCellMove"):onShow(item, behaviorReport)
end

function M:getCurPokemon()
  return self.cur_pokemon
end

function M:sendBehaviorReport(index, toShop)
  if self.mode == "swap" then
    return
  end
  local key
  if self.mode == "packet" then
    key = "ui_pet"
  else
    key = "ui_queue"
  end
  if toShop ~= nil then
    key = key .. "_shop"
  end
  Me:gameBehaviorReport(key, behaviorName[index])
end

function M:sendBehaviorTimeReport(key, time)
  if self.mode == "swap" then
    return
  end
  local timeValue = self:getTimeIntervalSection(time or 0)
  if self.mode == "packet" then
    Me:gameBehaviorReport("ui_pet_time", key .. "_" .. timeValue)
  else
    Me:gameBehaviorReport("ui_queue_time", key .. "_" .. timeValue)
  end
end

function M:getTimeIntervalSection(dTime)
  if dTime <= 10 then
    return "0_10"
  elseif 10 < dTime and dTime <= 30 then
    return "11_30"
  elseif 30 < dTime and dTime <= 60 then
    return "31_60"
  elseif 60 < dTime and dTime <= 120 then
    return "61_120"
  elseif 120 < dTime then
    return "120up"
  end
end

function M:hideSwapModeBtn(isHide)
  self.btnFunction_Upgrade:SetTouchable(not isHide)
  self.btnFunction_Skill:SetTouchable(not isHide)
  self.btnFunction_Starup:SetTouchable(not isHide)
  self.btnFunction_Wake:SetTouchable(not isHide)
  self.btnMutate:SetVisible(not isHide)
  for index = 1, 5 do
    if self.selectCellItems and self.selectCellItems[index] then
      self.selectCellItems[index]:SetVisible(not isHide)
    end
  end
end

function M:changePageTimer(nextTimerName)
  timer[curTimerName] = timer[curTimerName] + (os.time() - curTime)
  Lib.logDebug(curTimerName .. "\231\149\140\233\157\162\229\129\156\231\149\153" .. os.time() - curTime .. "\231\167\146")
  curTime = os.time()
  curTimerName = nextTimerName
end

function M:setFollowPetBtn()
  if not Me:getFollowPetPrivilege() then
    self:setFollowPetBtnByStatus(Define.FOLLOW_PET_STATUS.UNPAY)
  elseif self.cur_pokemon and self.cur_pokemon:isDead() then
    self:setFollowPetBtnByStatus(Define.FOLLOW_PET_STATUS.DISABLE)
  elseif self.cur_pokemon and tostring(Me:getCurFollowPetId()) == self.cur_pokemon:getObjId() then
    self:setFollowPetBtnByStatus(Define.FOLLOW_PET_STATUS.USE)
  else
    self:setFollowPetBtnByStatus(Define.FOLLOW_PET_STATUS.UNUSE)
  end
end

function M:showLockPopup(tipText)
  self:cancelLockPopupTimer()
  self.txtLockPopup:SetText(Lang:toText(tipText))
  self.ltyLockPopup:SetVisible(true)
  self.lockCD = true
  self.lockPopupTimer = LuaTimer:schedule(function()
    self.ltyLockPopup:SetVisible(false)
    self.lockCD = false
  end, 2000)
end

function M:hideLockPopup()
  self.ltyLockPopup:SetVisible(false)
  self.lockCD = false
  self:cancelLockPopupTimer()
end

function M:cancelLockPopupTimer()
  if self.lockPopupTimer then
    LuaTimer:cancel(self.lockPopupTimer)
    self.lockPopupTimer = nil
  end
end

function M:setFollowPetBtnByStatus(status)
  local pushedImage = ""
  local normalImage = ""
  if status == Define.FOLLOW_PET_STATUS.UNPAY then
    pushedImage = "set:pokemon_pet_packet.json image:icon_follow_unpay"
    normalImage = "set:pokemon_pet_packet.json image:icon_follow_unpay"
  elseif status == Define.FOLLOW_PET_STATUS.DISABLE then
    pushedImage = "set:pokemon_pet_packet.json image:icon_follow_disable"
    normalImage = "set:pokemon_pet_packet.json image:icon_follow_disable"
  elseif status == Define.FOLLOW_PET_STATUS.USE then
    pushedImage = "set:pokemon_pet_packet.json image:icon_follow_using"
    normalImage = "set:pokemon_pet_packet.json image:icon_follow_using"
  elseif status == Define.FOLLOW_PET_STATUS.UNUSE then
    pushedImage = "set:pokemon_pet_packet.json image:icon_follow_enable"
    normalImage = "set:pokemon_pet_packet.json image:icon_follow_enable"
  end
  self.btnFollowPetRelease:SetPushedImage(pushedImage)
  self.btnFollowPetRelease:SetNormalImage(normalImage)
end

function M:openPopupUpgrade()
  Lib.logDebug("openPopupUpgrade")
  if self.cur_pokemon then
    Lib.logDebug("openPopupUpgrade show pokemon")
    UI:getWnd("pokemonPopupUpgrade"):onShow(self.cur_pokemon)
  end
end

function M:hidePopupUpgrade()
  if UI:isOpen("pokemonPopupUpgrade") then
    UI:getWnd("pokemonPopupUpgrade"):onHide()
  end
end

function M:openWake()
  Lib.logDebug("openWake")
  if self.cur_pokemon then
    Lib.logDebug("openWake show pokemon")
    UI:getWnd("pokemonWake"):onShow(self.cur_pokemon)
  end
end

function M:onOpen()
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_PET_RED, false)
  self:initTimer()
  self.btnPacketShop:SetVisible(UI:getWnd("pokemonMain").btnPokemonMainShop:IsVisible())
  local itemWidth = self.llActor:GetPixelSize().x
  local itemHeight = self.llActor:GetPixelSize().y
  if itemWidth * 6 < itemHeight * 5 then
    itemHeight = itemWidth / 5 * 6
  else
    itemWidth = itemHeight / 6 * 5
  end
  self.awActor:SetWidth({0, itemWidth})
  if self.type ~= "swap" then
    Me:sendPacket({
      pid = "forbidPlayerAction"
    })
  end
end

function M:onClose()
  self:hideLockPopup()
  self:changePageTimer(curTimerName)
  timer.total = os.time() - timer.total
  Lib.logDebug(self.mode)
  for k, v in pairs(timer) do
    self:sendBehaviorTimeReport(k, v)
    Lib.logDebug(k, v)
  end
  if self.type == "swap" then
    self.cur_raceId = self.old_raceId
    self:selectClassifyTab(self.cur_raceId + 1)
  else
    Me:sendPacket({
      pid = "finishPlayerAction"
    })
  end
end
