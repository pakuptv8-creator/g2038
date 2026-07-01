local LuaTimer = T(Lib, "LuaTimer")
local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local M = _ENV.M

function M:init()
  WinBase.init(self, "PokemonCapture.json", false)
  self:initWnd()
end

function M:initWnd()
  self.cur_pokemon = nil
  self.btnJoin = self:child("PokemonCapture-Join")
  self.btnRelease = self:child("PokemonCapture-Release")
  self.stName = self:child("PokemonCapture-Name-Text")
  self.siRaceIcon = self:child("PokemonCapture-Race-Icon")
  self.awActor = self:child("PokemonCapture-Actor")
  self.llActor = self:child("PokemonCapture-Actor-Layout")
  self.stLevelText = self:child("PokemonCapture-Level-Text")
  self.siStarLevel = self:child("PokemonCapture-Star-Level-Img")
  self.stTitleText = self:child("PokemonCapture-Title-Text")
  self.siTitleTextBg = self:child("PokemonCapture-Title-Bg")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.siStarLevel:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", 0.1)
  local titleText = Lang:toText("gui.title.capture")
  self.stTitleText:SetText(titleText)
  local textLen = self.stTitleText:GetFont():GetTextExtent(titleText, 1.0)
  self.siTitleTextBg:SetWidth({
    0,
    textLen + 40
  })
  self.btnJoin:SetText(Lang:toText("gui.btn.capture.join"))
  self.btnRelease:SetText(Lang:toText("gui.btn.capture.release"))
  self:initTabs()
  self:initActiveDetail()
  self:initPassiveDetail()
  self:initGrowDetail()
  self:initFeaturesDetail()
  self:initEvent()
end

function M:initTabs()
  self.chkPassiveSkill = self:child("PokemonCapture-Passive-Tab")
  self.chkActiveSkill = self:child("PokemonCapture-Active-Tab")
  self.chkPassiveSkill:SetText(Lang:toText("gui.text.passive"))
  self.chkActiveSkill:SetText(Lang:toText("gui.skill.initiative"))
end

function M:initGrowDetail()
  self.stGrowthTitle = self:child("PokemonCapture-Growth-Title")
  self.stGrowthTitle:SetText(Lang:toText("gui.text.growth"))
  self.btnQuestion = self:child("PokemonCapture-Growth-Question")
  self.btnReName = self:child("PokemonCapture-ReName-Btn")
  self.stScoreName = self:child("PokemonCapture-Score-Name")
  self.stScoreNum = self:child("PokemonCapture-Score-Num")
  self.stHpNum = self:child("PokemonCapture-Growth-Hp-Num")
  self.stSpeedNum = self:child("PokemonCapture-Growth-Speed-Num")
  self.stPAtkNum = self:child("PokemonCapture-Growth-PAtk-Num")
  self.stPDefNum = self:child("PokemonCapture-Growth-PDef-Num")
  self.stSAtkNum = self:child("PokemonCapture-Growth-SAtk-Num")
  self.stSDefNum = self:child("PokemonCapture-Growth-SDef-Num")
  self.stHpTitle = self:child("PokemonCapture-Growth-Hp-Text")
  self.stSpeedTitle = self:child("PokemonCapture-Growth-Speed-Text")
  self.stPAtkTitle = self:child("PokemonCapture-Growth-PAtk-Text")
  self.stPDefTitle = self:child("PokemonCapture-Growth-PDef-Text")
  self.stSAtkTitle = self:child("PokemonCapture-Growth-SAtk-Text")
  self.stSDefTitle = self:child("PokemonCapture-Growth-SDef-Text")
  self.stHpTitle:SetText(Lang:toText("gui.text.hp"))
  self.stSpeedTitle:SetText(Lang:toText("gui.text.speed"))
  self.stPAtkTitle:SetText(Lang:toText("gui.text.pAtk"))
  self.stPDefTitle:SetText(Lang:toText("gui.text.pDef"))
  self.stSAtkTitle:SetText(Lang:toText("gui.text.sAtk"))
  self.stSDefTitle:SetText(Lang:toText("gui.text.sDef"))
end

function M:initActiveDetail()
  self.skillItems = {}
  self.lyActive = self:child("PokemonCapture-Active-Skill-Content")
  self.lyActiveList = self:child("PokemonCapture-Active-List")
  self.lyActiveDetail = self:child("PokemonCapture-Active-Detail")
  self.itemActiveSkillDetail = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.itemActiveSkillDetail:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lyActiveDetail:AddChildWindow(self.itemActiveSkillDetail)
  local itemWidth = self.lyActiveList:GetPixelSize().x
  local height = self.lyActiveList:GetPixelSize().y
  local itemHeight = (height - 15) / 4
  local positionY = 0
  for index = 1, 4 do
    local item = UIMgr:new_widget("pokemon_skill_cell")
    item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lyActiveList:AddChildWindow(item)
    self.skillItems[index] = item
    positionY = positionY + itemHeight + 5
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectActiveSkill(item)
    end)
  end
  self.lyActive:SetVisible(false)
end

function M:initPassiveDetail()
  self.passiveItems = {}
  self.lyPassive = self:child("PokemonCapture-Passive-Skill-Content")
  self.lyPassiveList = self:child("PokemonCapture-Passive-List")
  local width = self.lyPassiveList:GetPixelSize().x
  local itemWidth = (width - 42) / 4
  local itemHeight = itemWidth
  local positionY = 0
  local positionX = 0
  for index = 1, 8 do
    local item = UIMgr:new_widget("pokemon_passive_cell")
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lyPassiveList:AddChildWindow(item)
    self.passiveItems[index] = item
    positionX = positionX + itemWidth + 14
    if index % 4 == 0 then
      positionX = 0
      positionY = positionY + itemHeight + 8
    end
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectPassiveItem(item)
    end)
  end
  self.stPassiveDescIconBg = self:child("PokemonCapture-Desc-Icon-Bg")
  self.stPassiveDescIcon = UIMgr:new_widget("pokemon_passive_cell")
  self.stPassiveDescIcon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.stPassiveDescIconBg:AddChildWindow(self.stPassiveDescIcon)
  self.stPassiveDescName = self:child("PokemonCapture-Desc-Name")
  self.stPassiveDescText = self:child("PokemonCapture-Desc-Text")
  self.lyPassive:SetVisible(false)
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

function M:initFeaturesDetail()
  self.stFeatureTitle = self:child("PokemonCapture-Features-Title")
  self.stFeatureTitle:SetText(Lang:toText("gui.text.feature"))
  self.stFeatureDesc = self:child("PokemonCapture-Features-Desc")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonCapture btnReName event : EventButtonClick", self.btnReName, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonRename"):onShow(self.cur_pokemon)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonCapture btnJoin event : EventButtonClick", self.btnJoin, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_PUT_BALL then
      Lib.logDebug("btnjoin close the guide")
      UI:getWnd("pokemonGuide"):onShow(false)
    end
    local battlePetList = Me:getValue("packetPetList")
    if #battlePetList >= World.cfg.maxBoxPetsCnt then
      UI:getWnd("pokemonCaptureRelease"):onShow(self.newPokemon)
      return
    end
    Me:sendPacket({
      pid = "gainPokemonFromClient",
      objId = self.cur_pokemon:getObjId()
    })
    UI:closeWnd(self)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonCapture btnRelease event : EventButtonClick", self.btnRelease, UIEvent.EventButtonClick, function()
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.capture.release.sure"
    }, function(sure)
      if sure then
        self:releasePet()
      end
    end)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonCapture Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if (self:isvisible() or Me.needShowCapture) and self.cur_pokemon and tostring(objId) == tostring(self.cur_pokemon:getObjId()) then
      self:selectPokemon(self.cur_pokemon)
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonCapture Lib event : EVENT_UPDATE_CAPTURE_POKEMON_LIST", Event.EVENT_UPDATE_CAPTURE_POKEMON_LIST, function(capturePokemonIds)
    print("EVENT_UPDATE_CAPTURE_POKEMON_LIST:", capturePokemonIds)
    if 0 < #capturePokemonIds then
      self.cur_objId = capturePokemonIds[1]
      if not Me:isInBattle() then
        self:onShow()
      end
    end
  end)
  self:subscribe(self.chkActiveSkill, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkActiveSkill:GetChecked()
    self.lyActive:SetVisible(isChecked)
    if isChecked then
      self.chkPassiveSkill:SetChecked(false)
    end
    self.chkActiveSkill:SetTouchable(not isChecked)
  end)
  self:subscribe(self.chkPassiveSkill, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkPassiveSkill:GetChecked()
    self.lyPassive:SetVisible(isChecked)
    if isChecked then
      self.chkActiveSkill:SetChecked(false)
    end
    self.chkPassiveSkill:SetTouchable(not isChecked)
  end)
end

function M:releasePet()
  Me:sendPacket({
    pid = "setPokemonFreeFromClient",
    objId = self.cur_pokemon:getObjId()
  })
  UI:closeWnd(self)
end

function M:onShow(closeCallBack)
  if closeCallBack then
    self.closeCallBack = closeCallBack
  else
    function self.closeCallBack()
    end
  end
  Me:getPokemon(self.cur_objId, function(pokemon)
    if pokemon then
      self.newPokemon = pokemon
      self:selectPokemon(pokemon)
      UI:openWnd("pokemonCapture")
      self:sendCaptureWorldTips(pokemon)
    else
      Me.needShowCapture = false
      self.closeCallBack()
    end
  end)
end

function M:sendCaptureWorldTips(pokemon)
  local packet = {
    pid = "sendCaptureWorldTips",
    quality = pokemon:getQuality(),
    pkmName = pokemon:getCfg().name,
    starLevel = pokemon:getStarLevel()
  }
  Me:sendPacket(packet)
end

function M:selectPokemon(pokemon)
  self.cur_pokemon = pokemon
  local feature_config = SkillConfig:getConfigById(pokemon:getFeatures()) or {}
  self.stFeatureDesc:SetText(Lang:toText(feature_config.describe or "FeatureDesc"))
  self.stLevelText:SetText("Lv." .. tostring(pokemon:getLevel()))
  self.itemStarLevel:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake(), 0)
  local color = RaceConfig:getColorBg(pokemon:getRace())
  self._root:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
  self.stHpNum:SetText(pokemon:getMaxHp())
  self.stSpeedNum:SetText(pokemon:getSpeed())
  self.stPAtkNum:SetText(pokemon:getPhysicalAtk())
  self.stPDefNum:SetText(pokemon:getPhysicalDef())
  self.stSAtkNum:SetText(pokemon:getSpecialAtk())
  self.stSDefNum:SetText(pokemon:getSpecialDef())
  self.stScoreNum:SetText(pokemon:getFightPower())
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(pokemon:getCfgFullName())
  local pokemon_config = PokemonConfig:getConfigById(pokemon:getCfgId())
  self.stName:SetText(pokemon:getName())
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
  self.awActor:SetRotateY(-40)
  self.awActor:SetRotateX(10)
  local passiveRule = pokemon:getCfg().passiveRule
  for index, item in pairs(self.passiveItems) do
    local passiveTable = passiveRule[index] or {}
    local skillId = tonumber(passiveTable[1] or 0)
    local unlockWake = tonumber(passiveTable[2] or 0)
    item:invoke("updateInfo", skillId, unlockWake > pokemon:getWake())
  end
  self:selectPassiveItem(self.passiveItems[1])
  local skillList = pokemon:getSkillList()
  for index, item in pairs(self.skillItems) do
    item:invoke("updateInfo", skillList[index])
  end
  self:selectActiveSkill(self.skillItems[1])
  self.chkPassiveSkill:SetChecked(true)
end

function M:selectActiveSkill(selectItem)
  local skill = selectItem:invoke("getSkill")
  if skill.skillId == 0 then
    return
  end
  for _, item in pairs(self.skillItems) do
    item:invoke("onChecked", false)
    if selectItem == item then
      item:invoke("onChecked", true)
      self.itemActiveSkillDetail:invoke("updateInfo", skill)
    end
  end
end

function M:onOpen()
  local itemWidth = self.llActor:GetPixelSize().x
  local itemHeight = self.llActor:GetPixelSize().y
  if itemWidth * 6 < itemHeight * 5 then
    itemHeight = itemWidth / 5 * 6
  else
    itemWidth = itemHeight / 6 * 5
  end
  self.awActor:SetWidth({0, itemWidth})
  self.sid = Me:playSoundByKey("pkm_catch")
  self:root():SetAlwaysOnTop(true)
  if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_PUT_BALL then
    UI:getWnd("pokemonGuide"):onShow(true, Me:getCurGuideIndex())
    Lib.emitEvent(Event.EVENT_HIDE_BLOCK_INPUT)
  end
end

function M:onClose()
  if self.closeCallBack then
    self.closeCallBack()
  end
  self.cur_objId = 0
  if self.sid then
    Me:stopSound(self.sid)
  end
  print("onCloseonCloseonCloseonClose and  close")
  Me.needShowCapture = false
end
