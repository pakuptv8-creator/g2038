local WinPokemonLearnSkill = M
local SkillConfig = T(Config, "SkillConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local RaceConfig = T(Config, "RaceConfig")
local LuaTimer = T(Lib, "LuaTimer")

function WinPokemonLearnSkill:init()
  WinBase.init(self, "PokemonLearnSkill.json")
  self:initUI()
  self:initEvent()
end

function WinPokemonLearnSkill:initUI()
  self.imgMask = self:child("PokemonLearnSkill-Mask")
  self.lytLeftLayout = self:child("PokemonLearnSkill-LeftLayout")
  self.imgLeftBG = self:child("PokemonLearnSkill-LeftBG")
  self.imgLeftTopBar = self:child("PokemonLearnSkill-LeftTopBar")
  self.txtLeftTitle = self:child("PokemonLearnSkill-LeftTitle")
  self.lytPetsList = self:child("PokemonLearnSkill-PetsList")
  self.lytRightLayout = self:child("PokemonLearnSkill-RightLayout")
  self.imgRightBG = self:child("PokemonLearnSkill-RightBG")
  self.imgRightTopBar = self:child("PokemonLearnSkill-RightTopBar")
  self.txtRightTitle = self:child("PokemonLearnSkill-RightTitle")
  self.btnCloseBtn = self:child("PokemonLearnSkill-CloseBtn")
  self.lytSkillLayout = self:child("PokemonLearnSkill-SkillLayout")
  self.lytSkillDetail = self:child("PokemonLearnSkill-SkillDetail")
  self.lytSkill1 = self:child("PokemonLearnSkill-Skill_1")
  self.lytSkill2 = self:child("PokemonLearnSkill-Skill_2")
  self.lytSkill3 = self:child("PokemonLearnSkill-Skill_3")
  self.lytSkill4 = self:child("PokemonLearnSkill-Skill_4")
  self.lytItemDetailLayout = self:child("PokemonLearnSkill-ItemDetailLayout")
  self.imgItemIconFrame = self:child("PokemonLearnSkill-ItemIconFrame")
  self.imgItemIcon = self:child("PokemonLearnSkill-ItemIcon")
  self.txtItemName = self:child("PokemonLearnSkill-ItemName")
  self.txtItemQuality = self:child("PokemonLearnSkill-ItemQuality")
  self.imgRiceIcon = self:child("PokemonLearnSkill-RiceIcon")
  self.imgSkillType = self:child("PokemonLearnSkill-SkillType")
  self.txtSkillTypeTxt = self:child("PokemonLearnSkill-SkillTypeTxt")
  self.txtSkillIntroductionTxt = self:child("PokemonLearnSkill-SkillIntroductionTxt")
  self.imgSkillAtkIcon = self:child("PokemonLearnSkill-SkillAtkIcon")
  self.txtSkillAtkNumber = self:child("PokemonLearnSkill-SkillAtkNumber")
  self.imgSkillSpeedIcon = self:child("PokemonLearnSkill-SkillSpeedIcon")
  self.txtSkillSpeedNumber = self:child("PokemonLearnSkill-SkillSpeedNumber")
  self.imgSkillHitIcon = self:child("PokemonLearnSkill-SkillHitIcon")
  self.txtSkillHitNumber = self:child("PokemonLearnSkill-SkillHitNumber")
  self.imgSkillDescribBG = self:child("PokemonLearnSkill-SkillDescribBG")
  self.txtSkillDescribTxt = self:child("PokemonLearnSkill-SkillDescribTxt")
  self.btnLearnBtn = self:child("PokemonLearnSkill-LearnBtn")
  self.lytSuccess = self:child("PokemonLearnSkill-LearnSuccessPopup")
  self.maskExchange = self:child("PokemonLearnSkill-ExchangeMask")
  self:child("PokemonLearnSkill-SuccessText"):SetText(Lang:toText("gui.learn.success"))
  self.txtRightTitle:SetText(Lang:toText("gui.learn.newSkill.title"))
  self.txtLeftTitle:SetText(Lang:toText("gui.newSkill.suitablePokemon.title"))
  self.btnLearnBtn:SetText(Lang:toText("gui.btn.learn"))
  self:initAdapter()
  self:initCurSkills()
end

function WinPokemonLearnSkill:initAdapter()
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPacketList:InitConfig(10, 10, 3)
  self.lytPetsList:AddChildWindow(self.gvPacketList)
  local width = self.lytPetsList:GetPixelSize().x
  local itemWidth = (width - 20) / 3
  self.adapter = UIMgr:new_adapter("pokemon_packet", math.floor(itemWidth), math.floor(itemWidth))
  self.gvPacketList:invoke("setAdapter", self.adapter)
end

function WinPokemonLearnSkill:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnLearnBtn, UIEvent.EventButtonClick, function()
    local skillList = self.cur_pokemon:getSkillList()
    if #skillList < 4 then
      self:sendStudyPacket(#skillList + 1)
      return
    end
    self.maskExchange:SetVisible(true)
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.skill.exchange.sure"
    }, function(sure)
      if sure then
        self:sendStudyPacket(self.selectSkillIndex)
      else
        self.maskExchange:SetVisible(false)
      end
    end)
  end)
end

function WinPokemonLearnSkill:subscribeEvent()
end

function WinPokemonLearnSkill:initView()
  self:refreshItemInfo()
  self:refreshPokemonList()
  self:refreshCurSkills()
  self.lytSuccess:SetVisible(false)
  self.maskExchange:SetVisible(false)
end

function WinPokemonLearnSkill:sendStudyPacket(pos)
  Me:sendPacket({
    pid = "OnPetTargetUseItem",
    type = Define.ITEM_TYPE.SKILL,
    params = {
      fullName = self.selectItem:full_name(),
      slot = self.selectItem._slot,
      objId = self.cur_pokemon:getObjId(),
      skill_pos = pos
    }
  }, function()
    self.maskExchange:SetVisible(false)
    self:showSuccessPopup()
    self:subscribe(self.lytSuccess, UIEvent.EventWindowClick, function()
      self:onHide()
    end)
    Me:playSoundByKey("learn_skill")
  end)
end

function WinPokemonLearnSkill:showSuccessPopup()
  self.lytSuccess:SetVisible(true)
  self.popupTimer = LuaTimer:scheduleTimer(function()
    self:onHide()
  end, 2000)
end

function WinPokemonLearnSkill:initCurSkills()
  self.skillItems = {}
  self.descItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.descItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.descItem:invoke("setType")
  self.lytSkillDetail:AddChildWindow(self.descItem)
  for index = 1, 4 do
    local item = UIMgr:new_widget("pokemon_skill_cell")
    self:child("PokemonLearnSkill-Skill_" .. index):AddChildWindow(item)
    item:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
    self.skillItems[index] = item
    self:lightSubscribe("error!!!!! script_client win_pokemonLearnSkill pokemon_skill_cell-index=" .. index .. " event : EventWindowClick", item, UIEvent.EventWindowClick, function()
      self:selectSkillItem(item)
    end)
  end
end

function WinPokemonLearnSkill:selectSkillItem(skillItem)
  local skill = skillItem:invoke("getSkill")
  if skill.skillId == 0 then
    return
  end
  for index, item in pairs(self.skillItems) do
    item:invoke("onChecked", false)
    if skillItem == item then
      self.selectSkillIndex = index
      item:invoke("onChecked", true)
      self.descItem:invoke("updateInfo", skill)
    end
  end
end

function WinPokemonLearnSkill:refreshCurSkills()
  local pokemon = self.cur_pokemon
  local skillList = pokemon:getSkillList()
  for index, item in pairs(self.skillItems) do
    item:invoke("updateInfo", skillList[index])
  end
  self:selectSkillItem(self.skillItems[1])
end

function WinPokemonLearnSkill:selectPokemon(pokemon)
  self.cur_pokemon = pokemon
  for _, data in pairs(self.showPokemonList) do
    data.isChecked = data.pokemon == self.cur_pokemon
  end
  self:refreshCurSkills()
  self.adapter:setData(self.showPokemonList)
  local learnBefore
  local skillList = pokemon:getSkillList()
  for _, cfg in pairs(skillList) do
    if tostring(cfg.skillId) == tostring(self.selectSkillId) then
      learnBefore = true
      break
    end
  end
  self.btnLearnBtn:SetText(Lang:toText(not learnBefore and "gui.btn.learn" or "gui.skill.learnBefore"))
  self.btnLearnBtn:SetEnabled(not learnBefore)
end

function WinPokemonLearnSkill:refreshPokemonList()
  self.showPokemonList = {}
  local pokemonList = Me:getSkillSuitablePokemon(self.skillCfg)
  for _, pokemon in pairs(pokemonList) do
    table.insert(self.showPokemonList, {
      pokemon = pokemon,
      clickCallBack = function()
        self:selectPokemon(pokemon)
      end,
      checkInTeam = true,
      isChecked = false
    })
  end
  self.adapter:setData(self.showPokemonList)
  self.adapter:setScrollOffset(0)
  self:selectPokemon(self.showPokemonList[1] and self.showPokemonList[1].pokemon)
end

function WinPokemonLearnSkill:refreshItemInfo()
  self.imgItemIcon:SetImage(self.cfg.icon)
  self.txtItemName:SetText(Lang:toText(self.cfg.itemName))
  self.imgItemIconFrame:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", self.cfg.rarity))
  self.txtItemQuality:SetText(Lang:toText("title_quality") .. Lang:toText(string.format("ui_item_rarity_%d", self.cfg.rarity)))
  self.imgRiceIcon:SetImage(RaceConfig:getClassifyIcon(self.skillCfg.race))
  self.txtSkillTypeTxt:SetText(Lang:toText("gui.skill.positive"))
  self.txtSkillIntroductionTxt:SetText(Lang:toText("item.desc"))
  self.txtSkillAtkNumber:SetText(self.skillCfg.hurt)
  self.txtSkillSpeedNumber:SetText(self.skillCfg.skill_speed)
  self.txtSkillHitNumber:SetText(self.skillCfg.accuracy)
  self.txtSkillDescribTxt:SetText(Lang:toText(self.skillCfg.describe or "DescText"))
end

function WinPokemonLearnSkill:onHide()
  UI:closeWnd("pokemonLearnSkill")
end

function WinPokemonLearnSkill:onShow(selectItem)
  if selectItem then
    self.selectItem = selectItem
    self.cfg = self.selectItem._cfg
    self.selectSkillId = self.cfg.skillId
    self.skillCfg = SkillConfig:getConfigById(self.selectSkillId) or {}
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLearnSkill")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPokemonLearnSkill:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function WinPokemonLearnSkill:onClose()
  self:unsubscribe(self.lytSuccess, UIEvent.EventWindowClick)
  if self.popupTimer then
    LuaTimer:cancel(self.popupTimer)
    self.popupTimer = nil
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPokemonLearnSkill
