local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local bagCellHorizontalInterval = 13
local bagCellVerticalInterval = 10
local bagCellCount = 4
local bagMinCount = 30
local recordTimerCallback
local hurtAbilityImg = {
  [0] = "set:pokemon_pet_attribute.json image:img_0_attribute_special",
  [1] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicalattacks",
  [2] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellattacks",
  [3] = "set:pokemon_pet_attribute.json image:img_0_attribute_special"
}

function M:init()
  WinBase.init(self, "PokemonBagStudySkill.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonBagStudySkillWin = self:child("PokemonBagStudySkill-win")
  self.imgPokemonBagStudySkillTitle = self:child("PokemonBagStudySkill-title")
  self.lytPokemonBagStudySkillTabList = self:child("PokemonBagStudySkill-tab_list")
  self.imgPokemonBagStudySkillBagBg = self:child("PokemonBagStudySkill-bag_bg")
  self.lytPokemonBagStudySkillBagList = self:child("PokemonBagStudySkill-bag_list")
  self.btnPokemonBagStudySkillClose = self:child("PokemonBagStudySkill-close")
  self.imgPokemonBagStudySkillDetailBg = self:child("PokemonBagStudySkill-detail_bg")
  self.imgPokemonBagStudySkillDetailLayout = self:child("PokemonBagStudySkill-detail_layout")
  self.btnPokemonBagStudySkillUse = self:child("PokemonBagStudySkill-use_btn")
  self:child("PokemonBagStudySkill-use_text"):SetText(Lang:toText("ui_ues"))
  self.gvBagList = UIMgr:new_widget("grid_view")
  self.btnPokemonBagStudySkillDetailHolp = self:child("PokemonBagStudySkill-detail_holp")
  self.imgPokemonBagStudySkillDetailRaceIcon = self:child("PokemonBagStudySkill-detail_race_icon")
  self.txtPokemonBagStudySkillDetailItemName = self:child("PokemonBagStudySkill-detail_item_name")
  self:child("PokemonBagStudySkill-detail_item_rarity"):SetText(Lang:toText("rarity"))
  self.txtPokemonBagStudySkillDetailItemRarity = self:child("PokemonBagStudySkill-detail_item_rarity_text")
  self.imgPokemonBagStudySkillDetailIconFrame = self:child("PokemonBagStudySkill-detail_icon_frame")
  self.lyPokemonBagStudySkillDetailInfo = self:child("PokemonBagStudySkill-detail_info")
  self.imgPokemonBagStudySkillDetailIcon = self:child("PokemonBagStudySkill-detail_icon")
  self.txtPokemonBagStudySkillDetailItemNum = self:child("PokemonBagStudySkill-detail_item_num")
  self.lyPokemonBagStudySkillDetailSkillType = self:child("PokemonBagStudySkill-detail_skill_type")
  self.txtPokemonBagStudySkillDetailInfoTitle = self:child("PokemonBagStudySkill-detail_info_title")
  self.lyPokemonBagStudySkillDetailSkillInfo = self:child("PokemonBagStudySkill-detail_skill_info")
  self.lyPokemonBagStudySkillDetailSkillInfo_1 = self:child("PokemonBagStudySkill-skill_info_num_1")
  self.lyPokemonBagStudySkillDetailSkillInfo_2 = self:child("PokemonBagStudySkill-skill_info_num_2")
  self.lyPokemonBagStudySkillDetailSkillInfo_3 = self:child("PokemonBagStudySkill-skill_info_num_3")
  self.lyPokemonBagStudySkillDetailTextList = self:child("PokemonBagStudySkill-detail_text_list")
  self.txtPokemonBagStudySkillDetailSkillTypeText = self:child("PokemonBagStudySkill-detail_skill_type_text")
  self.stTitleText = self:child("PokemonBagStudySkill-title_text")
  self.stTitleText:SetText(Lang:toText("gui.title.study_skill"))
  self.skillInfoIcon = {}
  self.skillInfoNum = {}
  for i = 1, 3 do
    self.skillInfoIcon[i] = self:child(string.format("PokemonBagStudySkill-skill_info_%d", i))
    self.skillInfoNum[i] = self:child(string.format("PokemonBagStudySkill-skill_info_num_%d", i))
  end
  self.txtPokemonBagStudySkillDetailText = self:child("PokemonBagStudySkill-detail_text")
  self.gvDecText = UIMgr:new_widget("grid_view")
  self:initList()
end

function M:initList()
  self.lyPokemonBagStudySkillDetailTextList:AddChildWindow(self.gvDecText)
  self.gvDecText:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDecText:InitConfig(0, 0, 1)
  self.gvDecText:AddItem(self.txtPokemonBagStudySkillDetailText)
  self.lytPokemonBagStudySkillBagList:AddChildWindow(self.gvBagList)
  self.gvBagList:SetAutoColumnCount(false)
  self.gvBagList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBagList:InitConfig(bagCellHorizontalInterval, bagCellVerticalInterval, bagCellCount)
  local width = self.lytPokemonBagStudySkillBagList:GetPixelSize().x
  local itemWidth = (width - bagCellHorizontalInterval * (bagCellCount - 1)) / bagCellCount
  self.bagAdapter = UIMgr:new_adapter("pokemon_bag", itemWidth, itemWidth)
  self.gvBagList:invoke("setAdapter", self.bagAdapter)
  self:initSkillDetail()
end

function M:initEvent()
  self:subscribe(self.btnPokemonBagStudySkillClose, UIEvent.EventButtonClick, function()
    if recordTimerCallback ~= nil and type(recordTimerCallback) == "function" then
      recordTimerCallback()
    end
    UI:closeWnd("pokemonBagStudySkill")
  end)
  self:subscribe(self.btnPokemonBagStudySkillUse, UIEvent.EventButtonClick, function()
    if #self.skillList == 4 then
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.skill.exchange.sure"
      }, function(sure)
        if sure then
          self:sendStudyPacket()
        end
      end)
      return
    end
    self:sendStudyPacket()
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_ITEM_MODIFY, function()
    if not UI:isOpen(self) then
      return
    end
    self:onOpen(self.cur_pokemon)
  end)
end

function M:initSkillDetail()
  self.skillItems = {}
  self.stSkillList = self:child("PokemonBagStudySkill-Detail-Skill-List")
  self.stSkillDescIcon = self:child("PokemonBagStudySkill-Detail-Skill-Desc-Icon")
  self.stSkillDescName = self:child("PokemonBagStudySkill-Detail-Skill-Desc-Name")
  self.stSkillDescText = self:child("PokemonBagStudySkill-Detail-Skill-Desc-Text")
  self.stSkillDescAtkText = self:child("PokemonBagStudySkill-Detail-Skill-Desc-Atk-Text")
  self.stSkillDescSpeedText = self:child("PokemonBagStudySkill-Detail-Skill-Desc-Speed-Text")
  self.stSkillDescAccuracyText = self:child("PokemonBagStudySkill-Detail-Skill-Desc-Accuracy-Text")
  self.lySkillDetail = self:child("PokemonBagStudySkill-Detail-Skill-Desc")
  self.descItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.descItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.descItem:invoke("setType")
  self.lySkillDetail:AddChildWindow(self.descItem)
  local itemWidth = self.stSkillList:GetPixelSize().x
  local height = self.stSkillList:GetPixelSize().y
  local itemHeight = (height - 30) / 4
  local positionY = 0
  for index = 1, 4 do
    local item = UIMgr:new_widget("pokemon_skill_cell")
    item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.stSkillList:AddChildWindow(item)
    self.skillItems[index] = item
    positionY = positionY + itemHeight + 10
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectSkillItem(item)
    end)
  end
end

function M:subscribeEvent()
end

function M:initView()
  local itemsArr = Me:getBagItemsByBagType(Define.BAG_TYPE.SKILL)
  self:updateBagData(itemsArr)
end

function M:updateBagData(itemsArr)
  local canStudyMap = self.cur_pokemon:getSkillStudyMap()
  self.itemList = {}
  local sortAnArray = {}
  for _, item in pairs(itemsArr) do
    local skillId = item._cfg.skillId
    if skillId and canStudyMap[tostring(skillId)] then
      table.insert(sortAnArray, item)
    end
  end
  table.sort(sortAnArray, function(a, b)
    return a._cfg.itemId < b._cfg.itemId
  end)
  table.insert(sortAnArray, 1, "add")
  local maxCellCount = 30
  if #self.itemList > bagMinCount and #self.itemList % 5 ~= 0 then
    maxCellCount = #self.itemList + (5 - #self.itemList % 5)
  end
  for i = 1, maxCellCount do
    self.itemList[i] = {
      select = false,
      itemId = i,
      item = sortAnArray[i],
      clickCallBack = function()
        self:selectSKillBagItem(i)
      end
    }
  end
  self.bagAdapter:setData(self.itemList)
  self:selectSKillBagItem(2)
end

function M:selectSKillBagItem(itemId)
  if itemId == 1 then
    UI:getWnd("pokemon_Shop"):onShow(6)
    self:onHide()
    return
  end
  local curItem = self.itemList[itemId]
  for _, item in pairs(self.itemList) do
    item.select = item.itemId == itemId
  end
  self.bagAdapter:notifyDataChange()
  if curItem then
    self:updateItemInfoView(curItem)
  end
end

function M:updateItemInfoView(itemInfo)
  if not itemInfo.item or itemInfo.item == "add" then
    self.imgPokemonBagStudySkillDetailLayout:SetVisible(false)
    return
  end
  self.selectItem = itemInfo.item
  self.imgPokemonBagStudySkillDetailLayout:SetVisible(true)
  self.lyPokemonBagStudySkillDetailSkillType:SetVisible(false)
  self.txtPokemonBagStudySkillDetailInfoTitle:SetVisible(false)
  self.lyPokemonBagStudySkillDetailSkillInfo:SetVisible(false)
  self.imgPokemonBagStudySkillDetailRaceIcon:SetVisible(false)
  self.lyPokemonBagStudySkillDetailTextList:SetHeight({1, 0})
  self.btnPokemonBagStudySkillUse:SetVisible(false)
  local cfg = self.selectItem:cfg()
  if cfg then
    self.txtPokemonBagStudySkillDetailItemName:SetText(Lang:toText(cfg.itemName))
    self.txtPokemonBagStudySkillDetailItemRarity:SetText(Lang:toText(string.format("ui_item_rarity_%d", cfg.rarity)))
    self.imgPokemonBagStudySkillDetailIconFrame:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
    self.imgPokemonBagStudySkillDetailIcon:SetImage(cfg.icon)
    self.txtPokemonBagStudySkillDetailText:SetText(Lang:toText(cfg.desc))
    self.txtPokemonBagStudySkillDetailItemNum:SetText(self.selectItem:stack_count())
    self.lyPokemonBagStudySkillDetailSkillType:SetVisible(true)
    self.txtPokemonBagStudySkillDetailInfoTitle:SetVisible(true)
    if self.sceneType == Define.SCENE_TYPE.BATTLE then
      self.btnPokemonBagStudySkillUse:SetVisible(cfg.battleUse)
    else
      self.btnPokemonBagStudySkillUse:SetVisible(cfg.canUse)
    end
    if cfg.itemType == Define.BAG_TYPE.SKILL then
      local skillId = cfg.skillId
      local skill_config = SkillConfig:getConfigById(skillId) or {}
      self.txtPokemonBagStudySkillDetailText:SetText(Lang:toText(skill_config.describe or "DescText"))
      if skill_config.type == 1 then
        self.txtPokemonBagStudySkillDetailSkillTypeText:SetText(Lang:toText("gui.skill.initiative"))
      else
        self.txtPokemonBagStudySkillDetailSkillTypeText:SetText(Lang:toText("gui.skill.passive"))
      end
      self.imgPokemonBagStudySkillDetailRaceIcon:SetVisible(true)
      self.imgPokemonBagStudySkillDetailRaceIcon:SetImage(RaceConfig:getClassifyIcon(skill_config.race))
      self.skillInfoIcon[1]:SetImage(hurtAbilityImg[skill_config.hurt_type])
      local hurt = (not skill_config.hurt or skill_config.hurt == 0) and "--" or skill_config.hurt
      self.lyPokemonBagStudySkillDetailSkillInfo_1:SetText(hurt)
      self.lyPokemonBagStudySkillDetailSkillInfo_2:SetText(skill_config.skill_speed or "0")
      self.lyPokemonBagStudySkillDetailSkillInfo_3:SetText(skill_config.accuracy or "0")
      self.lyPokemonBagStudySkillDetailSkillInfo:SetVisible(true)
    end
    local h = self.lyPokemonBagStudySkillDetailInfo:GetPixelSize().y - (self.lyPokemonBagStudySkillDetailSkillType:GetPixelSize().y + self.txtPokemonBagStudySkillDetailInfoTitle:GetPixelSize().y + self.lyPokemonBagStudySkillDetailSkillInfo:GetPixelSize().y)
    self.lyPokemonBagStudySkillDetailTextList:SetHeight({0, h})
  end
end

function M:selectSkillItem(selectItem)
  local skill = selectItem:invoke("getSkill")
  if skill.skillId == 0 then
    return
  end
  for index, item in pairs(self.skillItems) do
    item:invoke("onChecked", false)
    if selectItem == item then
      self.select_skill_index = index
      item:invoke("onChecked", true)
      self.descItem:invoke("updateInfo", skill)
    end
  end
end

function M:selectPokemon(pokemon)
  self.cur_pokemon = pokemon
  self.skillList = pokemon:getSkillList()
  for index, item in pairs(self.skillItems) do
    item:invoke("updateInfo", self.skillList[index])
  end
  for _, item in pairs(self.skillItems) do
    local skill = item:invoke("getSkill")
    print(self.study_skillId, skill.skillId)
    if tonumber(self.select_skillId) == tonumber(skill.skillId) then
      self:selectSkillItem(item)
      return
    end
  end
  self:selectSkillItem(self.skillItems[1])
end

function M:sendStudyPacket()
  if not self.selectItem then
    return
  end
  local cfg = self.selectItem:cfg()
  if not cfg then
    return
  end
  self.select_skillId = cfg.skillId
  Me:sendPacket({
    pid = "OnPetTargetUseItem",
    type = Define.ITEM_TYPE.SKILL,
    params = {
      fullName = self.selectItem:full_name(),
      slot = self.selectItem._slot,
      objId = self.cur_pokemon:getObjId(),
      skill_pos = self.select_skill_index
    }
  }, function()
    Me:playSoundByKey("learn_skill")
  end)
end

function M:onHide()
  UI:closeWnd(self)
end

function M:onShow(pokemon, timerCallback)
  UI:openWnd("pokemonBagStudySkill", pokemon)
  recordTimerCallback = timerCallback
end

function M:onOpen(pokemon)
  self._allEvent = {}
  self:subscribeEvent()
  self:selectPokemon(pokemon)
  self:initView()
end

function M:onClose()
  self.select_skillId = 0
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
