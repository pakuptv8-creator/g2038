local RaceConfig = T(Config, "RaceConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local SkillConfig = T(Config, "SkillConfig")

function M:init()
  WinBase.init(self, "PokemonLuckyDetails.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytBG = self:child("PokemonLuckyDetails-BG")
  self.lytContent = self:child("PokemonLuckyDetails-content")
  self.imgTopBg = self:child("PokemonLuckyDetails-topBg")
  self.txtTitle = self:child("PokemonLuckyDetails-title")
  self.btnCloseBtn = self:child("PokemonLuckyDetails-CloseBtn")
  self.lytLeftLayout = self:child("PokemonLuckyDetails-LeftLayout")
  self.lytHeadLayout = self:child("PokemonLuckyDetails-head-Layout")
  self.imgHeadLBG = self:child("PokemonLuckyDetails-headLBG")
  self.lytAttributeLayout = self:child("PokemonLuckyDetails-AttributeLayout")
  self.imgAttributesBG = self:child("PokemonLuckyDetails-AttributesBG")
  self.lytDetailAttrLayout = self:child("PokemonLuckyDetails-Detail-Attr-Layout")
  self.txtDetailHpText = self:child("PokemonLuckyDetails-Detail-Hp-Text")
  self.imgDetailHpIcon = self:child("PokemonLuckyDetails-Detail-Hp-Icon")
  self.txtDetailHpTitle = self:child("PokemonLuckyDetails-Detail-Hp-Title")
  self.txtDetailSpeedText = self:child("PokemonLuckyDetails-Detail-Speed-Text")
  self.imgDetailSpeedIcon = self:child("PokemonLuckyDetails-Detail-Speed-Icon")
  self.txtDetailSpeedTitle = self:child("PokemonLuckyDetails-Detail-Speed-Title")
  self.txtDetailPAtkText = self:child("PokemonLuckyDetails-Detail-PAtk-Text")
  self.imgDetailPAtkIcon = self:child("PokemonLuckyDetails-Detail-PAtk-Icon")
  self.txtDetailPAtkTitle = self:child("PokemonLuckyDetails-Detail-PAtk-Title")
  self.txtDetailPDefText = self:child("PokemonLuckyDetails-Detail-PDef-Text")
  self.imgDetailPDefIcon = self:child("PokemonLuckyDetails-Detail-PDef-Icon")
  self.txtDetailPDefTitle = self:child("PokemonLuckyDetails-Detail-PDef-Title")
  self.txtDetailSAtkText = self:child("PokemonLuckyDetails-Detail-SAtk-Text")
  self.imgDetailSAtkIcon = self:child("PokemonLuckyDetails-Detail-SAtk-Icon")
  self.txtDetailSAtkTitle = self:child("PokemonLuckyDetails-Detail-SAtk-Title")
  self.txtDetailSDefText = self:child("PokemonLuckyDetails-Detail-SDef-Text")
  self.imgDetailSDefIcon = self:child("PokemonLuckyDetails-Detail-SDef-Icon")
  self.txtDetailSDefTitle = self:child("PokemonLuckyDetails-Detail-SDef-Title")
  self.lytRightLayout = self:child("PokemonLuckyDetails-RightLayout")
  self.lytSkillLayout = self:child("PokemonLuckyDetails-SkillLayout")
  self.imgSkillBG = self:child("PokemonLuckyDetails-SkillBG")
  self.lytPassiveTopBar = self:child("PokemonLuckyDetails-PassiveTopBar")
  self.chkActiveSkill = self:child("PokemonLuckyDetails-ActiveSkill")
  self.chkPassiveSkill = self:child("PokemonLuckyDetails-PassiveSkill")
  self.lytActiveSkillLayout = self:child("PokemonLuckyDetails-ActiveSkill-Layout")
  self.lytPassiveSkillLayout = self:child("PokemonLuckyDetails-PassiveSkill-Layout")
  self.lytDetailLayout = self:child("PokemonLuckyDetails-Detail-Layout")
  self.lytPassiveList = self:child("PokemonLuckyDetails-Passive-List")
  self.lytPassiveDesc = self:child("PokemonLuckyDetails-Passive-Desc")
  self.imgPassiveDescIconBg = self:child("PokemonLuckyDetails-Passive-Desc-Icon-Bg")
  self.txtPassiveDescName = self:child("PokemonLuckyDetails-Passive-Desc-Name")
  self.imgPassiveDescBg = self:child("PokemonLuckyDetails-Passive-Desc-Bg")
  self.txtPassiveDescText = self:child("PokemonLuckyDetails-Passive-Desc-Text")
  self.lytActiveSkillDetailLayout = self:child("PokemonLuckyDetails-ActiveSkillDetail-Layout")
  self.actEntityWnd = self:child("PokemonLuckyDetails-EntityWindow")
  self.imgPokemonLuckyDetailsClassifyTypeImg = self:child("PokemonLuckyDetails-ClassifyTypeImg")
  self.txtPokemonLuckyDetailsPetName = self:child("PokemonLuckyDetails-PetName")
  self.iconList = {}
  self.iconBGList = {}
  self.selectList = {}
  self.layoutList = {}
  self.starLytList = {}
  self.starsList = {}
  self.iconList[1] = self:child("PokemonLuckyDetails-Level0Icon")
  self.iconBGList[1] = self:child("PokemonLuckyDetails-Level0IconBG")
  self.selectList[1] = self:child("PokemonLuckyDetails-Level0Select")
  self.iconList[2] = self:child("PokemonLuckyDetails-Level1Icon")
  self.iconBGList[2] = self:child("PokemonLuckyDetails-Level1IconBG")
  self.selectList[2] = self:child("PokemonLuckyDetails-Level1Select")
  self.iconList[3] = self:child("PokemonLuckyDetails-Level2Icon")
  self.iconBGList[3] = self:child("PokemonLuckyDetails-Level2IconBG")
  self.selectList[3] = self:child("PokemonLuckyDetails-Level2Select")
  self.lytEvolutionLayout = self:child("PokemonLuckyDetails-EvolutionYellowBG")
  self.layoutList[1] = self:child("PokemonLuckyDetails-Level0Layout")
  self.layoutList[2] = self:child("PokemonLuckyDetails-Level1Layout")
  self.layoutList[3] = self:child("PokemonLuckyDetails-Level2Layout")
  self.starLytList[1] = self:child("PokemonLuckyDetails-Level0StarLyt")
  self.starLytList[2] = self:child("PokemonLuckyDetails-Level1StarLyt")
  self.starLytList[3] = self:child("PokemonLuckyDetails-Level2StarLyt")
  self.txtPokemonLuckyDetailsEvolutionTitle = self:child("PokemonLuckyDetails-EvolutionTitle")
  self.txtPokemonLuckyDetailsEvolutionTitle:SetText(Lang:toText("evolution_title"))
  self.txtTitle:SetText(Lang:toText("gui_pkm_detail_title_txt"))
  self.chkActiveSkill:SetText(Lang:toText("gui.skill.initiative"))
  self.chkPassiveSkill:SetText(Lang:toText("passive_title"))
  self.lytAttributeLayout:SetVisible(false)
  self.lytActiveSkillDetailLayout:SetVisible(false)
  self:adapterUIShow()
  self:initSkillDetail()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytContent, 1015, 656)
end

function M:initSkillDetail()
  local ratio = UIMgr.UIShowManage:getAdapterRatio()
  self.itemActiveSkillDetail = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.itemActiveSkillDetail:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytActiveSkillDetailLayout:AddChildWindow(self.itemActiveSkillDetail)
  self.gvActiveSkill = UIMgr:new_widget("grid_view")
  self.gvActiveSkill:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvActiveSkill:InitConfig(0, 6, 1)
  self.lytActiveSkillLayout:AddChildWindow(self.gvActiveSkill)
  local itemWidth = self.lytActiveSkillLayout:GetPixelSize().x * ratio
  local itemHeight = math.floor((self.lytActiveSkillLayout:GetPixelSize().y * ratio - 24 * ratio) / 5)
  self.active_adapter = UIMgr:new_adapter("pokemon_active_skill", itemWidth, itemHeight)
  self.gvActiveSkill:invoke("setAdapter", self.active_adapter)
  self.passiveItems = {}
  self.stPassiveDescIcon = UIMgr:new_widget("pokemon_passive_cell")
  self.stPassiveDescIcon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.imgPassiveDescIconBg:AddChildWindow(self.stPassiveDescIcon)
  local width = self.lytPassiveList:GetPixelSize().x
  local itemWidth = (width - 42) / 4 * ratio
  local itemHeight = itemWidth * ratio
  local positionY = 0
  local positionX = 0
  for index = 1, 8 do
    local item = UIMgr:new_widget("pokemon_passive_cell")
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lytPassiveList:AddChildWindow(item)
    self.passiveItems[index] = item
    positionX = positionX + itemWidth + 12 * ratio
    if index % 4 == 0 then
      positionX = 0
      positionY = positionY + itemHeight + 8 * ratio
    end
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectPassiveItem(item)
    end)
  end
  self.chkActiveSkill:SetChecked(true)
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
      self.txtPassiveDescName:SetText(Lang:toText(skill_config.name or "SkillName"))
      self.txtPassiveDescText:SetText(Lang:toText(skill_config.describe or "DescText"))
      self.stPassiveDescIcon:invoke("updateInfo", skillId, false)
    end
  end
end

function M:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.chkActiveSkill, UIEvent.EventCheckStateChanged, function()
    local isChecked = self.chkActiveSkill:GetChecked()
    self.lytActiveSkillLayout:SetVisible(isChecked)
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
  self:subscribe(self.lytContent, UIEvent.EventWindowClick, function()
    self.lytActiveSkillDetailLayout:SetVisible(false)
  end)
end

function M:subscribeEvent()
end

function M:initView(pokemonId, poolId)
  local curPoolId = poolId or 2
  local LuckyCardPoolTopRes = {
    [1] = "set:pokemon_lucky_egg.json image:img_9_boxtop_red",
    [2] = "set:pokemon_lucky_egg.json image:img_9_boxtop_yellow",
    [3] = "set:pokemon_lucky_egg.json image:img_9_boxtop_blue"
  }
  if LuckyCardPoolTopRes[curPoolId] then
    self.imgTopBg:SetImage(LuckyCardPoolTopRes[curPoolId])
  end
  self:setEvolutionLyt(pokemonId)
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
    xPosition[2] + width[2] + 3
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
  self.txtPokemonLuckyDetailsPetName:SetText(Lang:toText(pokemon:getName()))
  self.imgPokemonLuckyDetailsClassifyTypeImg:SetImage(RaceConfig:getClassifyIcon(pokemon:getRace()))
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
  local ratio = UIMgr.UIShowManage:getAdapterRatio()
  self.actEntityWnd:SetYPosition({
    pokemon_config.uiOffsetY * ratio,
    0
  })
  self.actEntityWnd:SetRotateY(-15)
  self.actEntityWnd:SetRotateX(10)
  self.txtDetailHpText:SetText(pokemon:getMaxHp())
  self.txtDetailSpeedText:SetText(pokemon:getSpeed())
  self.txtDetailPAtkText:SetText(pokemon:getPhysicalAtk())
  self.txtDetailPDefText:SetText(pokemon:getPhysicalDef())
  self.txtDetailSAtkText:SetText(pokemon:getSpecialAtk())
  self.txtDetailSDefText:SetText(pokemon:getSpecialDef())
  self:updateSkillInfoShow(pokemon)
end

function M:updateSkillInfoShow(pokemon)
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
    return a.skill.unlockLevel < b.skill.unlockLevel
  end)
  self.active_adapter = self.gvActiveSkill:invoke("getAdapter")
  self.active_adapter:setData(self.showActiveSkillData)
  self.active_adapter:setScrollOffset(0)
  local isChecked = self.chkPassiveSkill:GetChecked()
  self.lytPassiveSkillLayout:SetVisible(isChecked)
  local isChecked = self.chkActiveSkill:GetChecked()
  self.lytActiveSkillLayout:SetVisible(isChecked)
end

function M:selectActiveSkill(skill)
  self.lytActiveSkillDetailLayout:SetVisible(true)
  for _, data in pairs(self.showActiveSkillData) do
    data.select = data.skill.skillId == skill.skillId
  end
  self.active_adapter:setData(self.showActiveSkillData)
  self.itemActiveSkillDetail:invoke("updateInfo", skill)
end

function M:onHide()
  UI:closeWnd("pokemonLuckyDetails")
end

function M:onShow(isShow, pokemonId, poolId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLuckyDetails", tonumber(pokemonId), poolId)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(pokemonId, poolId)
  self._allEvent = {}
  self:subscribeEvent()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(1)
  self:initView(pokemonId, poolId)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
