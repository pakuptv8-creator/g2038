local PokemonConfig = T(Config, "PokemonConfig")
local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local M = _ENV.M

function M:init()
  WinBase.init(self, "BookDetails.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.btnBookDetailsBackBtn = self:child("BookDetails-BackBtn")
  self.actEntityWnd = self:child("BookDetails-EntityWindow")
  self.imgBookDetailsClassifyTypeImg = self:child("BookDetails-ClassifyTypeImg")
  self.txtBookDetailsPetName = self:child("BookDetails-PetName")
  self.txtBookDetailsPetId = self:child("BookDetails-PetId")
  self.iconList = {}
  self.iconBGList = {}
  self.selectList = {}
  self.layoutList = {}
  self.starLytList = {}
  self.starsList = {}
  self.iconList[1] = self:child("BookDetails-Level0Icon")
  self.iconBGList[1] = self:child("BookDetails-Level0IconBG")
  self.selectList[1] = self:child("BookDetails-Level0Select")
  self.iconList[2] = self:child("BookDetails-Level1Icon")
  self.iconBGList[2] = self:child("BookDetails-Level1IconBG")
  self.selectList[2] = self:child("BookDetails-Level1Select")
  self.iconList[3] = self:child("BookDetails-Level2Icon")
  self.iconBGList[3] = self:child("BookDetails-Level2IconBG")
  self.selectList[3] = self:child("BookDetails-Level2Select")
  self.lytEvolutionLayout = self:child("BookDetails-EvolutionYellowBG")
  self.layoutList[1] = self:child("BookDetails-Level0Layout")
  self.layoutList[2] = self:child("BookDetails-Level1Layout")
  self.layoutList[3] = self:child("BookDetails-Level2Layout")
  self.starLytList[1] = self:child("BookDetails-Level0StarLyt")
  self.starLytList[2] = self:child("BookDetails-Level1StarLyt")
  self.starLytList[3] = self:child("BookDetails-Level2StarLyt")
  self.txtBookDetailsDetailHpTitle = self:child("BookDetails-Detail-Hp-Title")
  self.txtBookDetailsDetailSpeedTitle = self:child("BookDetails-Detail-Speed-Title")
  self.txtBookDetailsDetailPAtkTitle = self:child("BookDetails-Detail-PAtk-Title")
  self.txtBookDetailsDetailPDefTitle = self:child("BookDetails-Detail-PDef-Title")
  self.txtBookDetailsDetailSAtkTitle = self:child("BookDetails-Detail-SAtk-Title")
  self.txtBookDetailsDetailSDefTitle = self:child("BookDetails-Detail-SDef-Title")
  self.txtBookDetailsDetailHpTitle:SetText(Lang:toText("gui.text.hp"))
  self.txtBookDetailsDetailSpeedTitle:SetText(Lang:toText("gui.text.speed"))
  self.txtBookDetailsDetailPAtkTitle:SetText(Lang:toText("gui.text.pAtk"))
  self.txtBookDetailsDetailPDefTitle:SetText(Lang:toText("gui.text.pDef"))
  self.txtBookDetailsDetailSAtkTitle:SetText(Lang:toText("gui.text.sAtk"))
  self.txtBookDetailsDetailSDefTitle:SetText(Lang:toText("gui.text.sDef"))
  self.txtBookDetailsDetailHpText = self:child("BookDetails-Detail-Hp-Text")
  self.txtBookDetailsDetailSpeedText = self:child("BookDetails-Detail-Speed-Text")
  self.txtBookDetailsDetailPAtkText = self:child("BookDetails-Detail-PAtk-Text")
  self.txtBookDetailsDetailPDefText = self:child("BookDetails-Detail-PDef-Text")
  self.txtBookDetailsDetailSAtkText = self:child("BookDetails-Detail-SAtk-Text")
  self.txtBookDetailsDetailSDefText = self:child("BookDetails-Detail-SDef-Text")
  self.chkCommonBtn = self:child("BookDetails-CommonBtn")
  self.chkSpecialBtn = self:child("BookDetails-SpecialBtn")
  self.chkCommonBtn:SetText(Lang:toText("common_feature"))
  self.chkSpecialBtn:SetText(Lang:toText("special_feature"))
  self.txtFeatureName = self:child("BookDetails-Feature-Name")
  self.txtFeatureDescribe = self:child("BookDetails-Feature-Describe")
  self:initSkillDetail()
  self.txtBookDetailsBackTxt = self:child("BookDetails-BackTxt")
  self.txtBookDetailsBackTxt:SetText(Lang:toText("book_title"))
  self.chkBookDetailsAttributesBtn = self:child("BookDetails-AttributesTitle")
  self.chkBookDetailsAttributesBtn:SetText(Lang:toText("attr_title"))
  self.txtBookDetailsEvolutionTitle = self:child("BookDetails-EvolutionTitle")
  self.txtBookDetailsEvolutionTitle:SetText(Lang:toText("evolution_title"))
end

function M:initSkillDetail()
  self.chkActiveSkill = self:child("BookDetails-ActiveSkill")
  self.chkPassiveSkill = self:child("BookDetails-PassiveSkill")
  self.chkPassiveSkill:SetText(Lang:toText("gui.text.passive"))
  self.chkActiveSkill:SetText(Lang:toText("gui.skill.initiative"))
  self.lytActiveSkillLayout = self:child("BookDetails-ActiveSkill-Layout")
  self.lytPassiveSkillLayout = self:child("BookDetails-PassiveSkill-Layout")
  self.lytActiveSkillDetailLayout = self:child("BookDetails-ActiveSkillDetail-Layout")
  self.itemActiveSkillDetail = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.itemActiveSkillDetail:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytActiveSkillDetailLayout:AddChildWindow(self.itemActiveSkillDetail)
  self.gvActiveSkill = UIMgr:new_widget("grid_view")
  self.gvActiveSkill:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvActiveSkill:InitConfig(0, 6, 1)
  self.lytActiveSkillLayout:AddChildWindow(self.gvActiveSkill)
  local itemWidth = self.lytActiveSkillLayout:GetPixelSize().x
  local itemHeight = math.floor((self.lytActiveSkillLayout:GetPixelSize().y - 24) / 5)
  self.active_adapter = UIMgr:new_adapter("pokemon_active_skill", itemWidth, itemHeight)
  self.gvActiveSkill:invoke("setAdapter", self.active_adapter)
  self.passiveItems = {}
  self.lytBookDetailsPassiveList = self:child("BookDetails-Passive-List")
  self.lyPassiveDetail = self:child("BookDetails-Passive-Desc")
  self.passiveDescItem = UIMgr:new_widget("pokemon_passive_detail_cell")
  self.passiveDescItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lyPassiveDetail:AddChildWindow(self.passiveDescItem)
  self.passiveDescItem:invoke("updateSize")
  local width = self.lytBookDetailsPassiveList:GetPixelSize().x
  local itemWidth = (width - 42) / 4
  local itemHeight = itemWidth
  local positionY = 0
  local positionX = 0
  for index = 1, 8 do
    local item = UIMgr:new_widget("pokemon_passive_cell")
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lytBookDetailsPassiveList:AddChildWindow(item)
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
      self.passiveDescItem:invoke("updateInfo", skillId)
    end
  end
end

function M:initEvent()
  self:subscribe(self.btnBookDetailsBackBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.chkCommonBtn, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkCommonBtn:GetChecked()
    if isChecked then
      self.chkSpecialBtn:SetChecked(false)
      self.isMutated = false
      self:updateFeatureUI()
    end
    self.chkCommonBtn:SetTouchable(not isChecked)
  end)
  self:subscribe(self.chkSpecialBtn, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkSpecialBtn:GetChecked()
    if isChecked then
      self.chkCommonBtn:SetChecked(false)
      self.isMutated = true
      self:updateFeatureUI()
    end
    self.chkSpecialBtn:SetTouchable(not isChecked)
  end)
  self:subscribe(self.chkActiveSkill, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkActiveSkill:GetChecked()
    self.lytActiveSkillLayout:SetVisible(isChecked)
    self.lytActiveSkillDetailLayout:SetVisible(isChecked)
    if isChecked then
      self.chkPassiveSkill:SetChecked(false)
    end
    self.chkActiveSkill:SetTouchable(not isChecked)
  end)
  self:subscribe(self.chkPassiveSkill, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkPassiveSkill:GetChecked()
    self.lytPassiveSkillLayout:SetVisible(isChecked)
    if isChecked then
      self.chkActiveSkill:SetChecked(false)
    end
    self.chkPassiveSkill:SetTouchable(not isChecked)
  end)
  self.chkCommonBtn:SetChecked(true)
  self.chkPassiveSkill:SetChecked(true)
end

function M:initPokemonList()
  for index = 1, 3 do
    local cur_iconItem = self.iconList[index]
    self:unsubscribe(self.iconList[index])
    local pokemon = self.pokemonList[index]
    if pokemon then
      cur_iconItem:SetImage(pokemon:getIcon())
      self:subscribe(self.layoutList[index], UIEvent.EventWindowClick, function()
        self:changePokemonIndex(index)
      end)
    end
  end
end

function M:changePokemonIndex(index)
  for itemIndex = 1, 3 do
    self.selectList[itemIndex]:SetVisible(itemIndex == index)
  end
  self:changePokemon(self.pokemonList[index])
end

function M:changePokemon(pokemon)
  self.cur_pokemon = pokemon
  local idTxt = "NO."
  if pokemon:getBookId() < 10 then
    idTxt = idTxt .. "00"
  elseif pokemon:getBookId() < 100 then
    idTxt = idTxt .. "0"
  end
  idTxt = idTxt .. pokemon:getBookId()
  self.txtBookDetailsPetId:SetText(idTxt)
  self.txtBookDetailsPetName:SetText(Lang:toText(pokemon:getName()))
  self.imgBookDetailsClassifyTypeImg:SetImage(RaceConfig:getClassifyIcon(pokemon:getRace()))
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(pokemon:getCfgFullName())
  local pokemon_config = pokemon:getCfg()
  self.actEntityWnd:SetActor1(entity_cfg.actorName, "idle")
  self.actEntityWnd:SetActorScale(pokemon_config.uiScale)
  self.actEntityWnd:SetRotateY(-40)
  self.actEntityWnd:SetRotateX(10)
  if getmetatable(self.actEntityWnd).SetActorOffset then
    self.actEntityWnd:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  self.txtBookDetailsDetailHpText:SetText(pokemon:getMaxHp())
  self.txtBookDetailsDetailSpeedText:SetText(pokemon:getSpeed())
  self.txtBookDetailsDetailPAtkText:SetText(pokemon:getPhysicalAtk())
  self.txtBookDetailsDetailPDefText:SetText(pokemon:getPhysicalDef())
  self.txtBookDetailsDetailSAtkText:SetText(pokemon:getSpecialAtk())
  self.txtBookDetailsDetailSDefText:SetText(pokemon:getSpecialDef())
  local passiveRule = pokemon:getCfg().passiveRule
  for index, item in pairs(self.passiveItems) do
    local passiveTable = passiveRule[index] or {}
    local skillId = tonumber(passiveTable[1] or 0)
    local unlockWake = tonumber(passiveTable[2] or 0)
    item:invoke("updateInfo", skillId, unlockWake > pokemon:getWake())
  end
  self:selectPassiveItem(self.passiveItems[1])
  local activeStudySKillRule = pokemon:getCfg().studyActiveRule
  self.showActiveSkillData = {}
  for level, skillList in pairs(activeStudySKillRule) do
    for _, skillId in pairs(skillList) do
      local skillConfig = SkillConfig:getConfigById(skillId)
      local skillData = {
        skillId = skillId,
        curTimes = skillConfig.max_number,
        maxTimes = nil,
        unlockLevel = level
      }
      table.insert(self.showActiveSkillData, {
        skill = skillData,
        select = false,
        callBack = function()
          self:selectActiveSkill(skillData)
        end
      })
    end
  end
  table.sort(self.showActiveSkillData, function(a, b)
    return tonumber(a.skill.unlockLevel) < tonumber(b.skill.unlockLevel)
  end)
  self.active_adapter = self.gvActiveSkill:invoke("getAdapter")
  self.active_adapter:setData(self.showActiveSkillData)
  self.active_adapter:setScrollOffset(0)
  self.itemActiveSkillDetail:SetVisible(false)
  self:updateFeatureUI()
end

function M:selectActiveSkill(skill)
  for _, data in pairs(self.showActiveSkillData) do
    data.select = data.skill.skillId == skill.skillId
  end
  self.active_adapter:setData(self.showActiveSkillData)
  self.itemActiveSkillDetail:SetVisible(true)
  self.itemActiveSkillDetail:invoke("updateInfo", skill)
end

function M:updateFeatureUI()
  if not self.cur_pokemon then
    return
  end
  local skill_config = SkillConfig:getConfigById(self.cur_pokemon:getCommonFeature())
  if self.isMutated then
    skill_config = SkillConfig:getConfigById(self.cur_pokemon:getMutateFeature())
  end
  self.txtFeatureName:SetText(Lang:toText(skill_config.name))
  self.txtFeatureDescribe:SetText(Lang:toText(skill_config.describe))
end

function M:onHide()
  UI:closeWnd("bookDetails")
end

function M:setEvolutionLyt(pokemonId)
  local pokemon_configList = PokemonConfig:getEvolutionList(pokemonId)
  self.pokemonList = {}
  for _, pokemon_config in pairs(pokemon_configList) do
    table.insert(self.pokemonList, Me:createTempPokemon(pokemon_config.id, 1))
  end
  local lastLayout = self.layoutList[#pokemon_configList]
  local xPosition = lastLayout:GetXPosition()
  local width = lastLayout:GetWidth()
  self.lytEvolutionLayout:SetWidth({
    0,
    xPosition[2] + width[2] + 2
  })
  self:initPokemonList()
  for index, pokemon in pairs(self.pokemonList) do
    if pokemon:getCfgId() == pokemonId then
      self:changePokemonIndex(index)
      break
    end
  end
  local qualityImg = {
    [1] = "set:pokemon_pet_frame.json image:img_0_frame_blue",
    [2] = "set:pokemon_pet_frame.json image:img_0_frame_purple",
    [3] = "set:pokemon_pet_frame.json image:img_0_frame_orange"
  }
  for index = 1, #pokemon_configList do
    self.iconBGList[index]:SetImage(qualityImg[pokemon_configList[index].quality])
    self.starsList[index] = self.starsList[index] or UIMgr:new_widget("pokemon_star_item_cell")
    self.starLytList[index]:AddChildWindow(self.starsList[index])
    local wakeLevel = pokemon_configList[index - 1] and pokemon_configList[index - 1].evolutionWake or 0
    self.starsList[index]:invoke("updateUI", pokemon_configList[index].starLevel, wakeLevel)
  end
end

function M:onOpen(pokemonId)
  self:setEvolutionLyt(pokemonId)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
