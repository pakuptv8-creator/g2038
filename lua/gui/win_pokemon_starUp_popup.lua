local PokemonConfig = T(Config, "PokemonConfig")
local LuaTimer = T(Lib, "LuaTimer")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local costMap
local showPokemonCount = 0

function M:init()
  WinBase.init(self, "pokemon_starup_popup.json", false)
  self.selectItemList = {}
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonStarUpPopupMask = self:child("pokemon_starUp_popup-mask")
  self.lytPokemonStarUpPopupStarPetSelectLyt = self:child("pokemon_starUp_popup-starPetSelectLyt")
  self.imgPokemonStarUpPopupSelectLytBG = self:child("pokemon_starUp_popup-selectLytBG")
  self.imgPokemonStarUpPopupSelectLytTopBar = self:child("pokemon_starUp_popup-selectLytTopBar")
  self.txtPokemonStarUpPopupSelectLytTitle = self:child("pokemon_starUp_popup-selectLytTitle")
  self.btnPokemonStarUpPopupSelectLytBtn = self:child("pokemon_starUp_popup-SelectLytBtn")
  self.lytPokemonStarUpPopupPetsSelectLyt = self:child("pokemon_starUp_popup-petsSelectLyt")
  self.lytTipPopup = self:child("pokemon_starUp-LockPopup")
  self.lytPokemonStarUpPopupPetsShowList = self:child("pokemon_starUp_popup-petsShowList")
  self.imgPokemonStarUpPopupSelectLytBottomBar = self:child("pokemon_starUp_popup-selectLytBottomBar")
  self.btnPokemonStarUpPopupYesBtn = self:child("pokemon_starUp_popup-yesBtn")
  self.btnAutoSelect = self:child("pokemon_starUp_popup-autoSelectBtn")
  self.btnAutoSelect = self:child("pokemon_starUp_popup-autoSelectBtn")
  self.lytSuccess = self:child("starUpPopup-starUpSuccess")
  self.btnConfirm = self:child("starUpPopup-ConfirmBtn")
  self.actSuccessEntity = self:child("starUpPopup-SuccessEntityWindow")
  self.lytStarShow = self:child("pokemon_starUp_popup-starShowLyt")
  self.txtSuccessTitle = self:child("starUpPopup-SuccessTxt")
  self.txtSuccessTitle:SetText(Lang:toText("gui.starUp.success"))
  self.txtPokemonStarUpPopupSelectLytTitle:SetText(Lang:toText("gui.starUp.select"))
  self.btnAutoSelect:SetText(Lang:toText("gui.starUp.material.autoSelect"))
  self:child("pokemon_starUp-LockTip"):SetText(Lang:toText("gui.starUp.noMaterial.autoSelect"))
  for index = 1, 5 do
    local item = UIMgr:new_widget("pokemonSelectCell")
    UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, item:invoke("root"), -5, 5, index)
    item:invoke("setData", nil, nil)
    item:SetArea({0, 0}, {0, 0}, {0, 80}, {0, 80})
    table.insert(self.selectItemList, item)
  end
  self.gvPetsList = UIMgr:new_widget("grid_view")
  self.gvPetsList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPetsList:InitConfig(25, 10, 6)
  self.lytPokemonStarUpPopupPetsShowList:AddChildWindow(self.gvPetsList)
  local width = self.lytPokemonStarUpPopupPetsShowList:GetPixelSize().x
  local itemWidth = (width - 180) / 6
  local adapter = UIMgr:new_adapter("pokemon_packet", itemWidth, itemWidth)
  self.gvPetsList:invoke("setAdapter", adapter)
  self.showPokemonList = {}
  adapter:setData(self.showPokemonList)
  adapter:setScrollOffset(0)
  for _ = 1, World.cfg.maxBoxPetsCnt do
    table.insert(self.showPokemonList, {})
  end
  self:updateAdapterUI()
end

function M:initEvent()
  self:subscribe(self.btnPokemonStarUpPopupSelectLytBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnAutoSelect, UIEvent.EventButtonClick, function()
    self:autoSelect()
  end)
  self:subscribe(self.btnPokemonStarUpPopupYesBtn, UIEvent.EventButtonClick, function()
    local hasHighQuality
    for _, pokemon in pairs(self.selectPokemonList) do
      if pokemon:isHighQuality() then
        hasHighQuality = true
        break
      end
    end
    if hasHighQuality then
      Me:showSpecialChatDialog({
        titleText = "gui.tip.title",
        msgText = "gui.release.high.quality",
        popupKey = "starUpHighQuality"
      }, function(sure)
        if not sure then
          return
        end
        if self.yesCb then
          self.yesCb(self.selectPokemonList)
        end
        UI:closeWnd(self)
      end)
    else
      if self.yesCb then
        self.yesCb(self.selectPokemonList)
      end
      UI:closeWnd(self)
    end
  end)
end

function M:subscribeEvent()
end

function M:initView()
  self:showWndByType(self.toSelect)
  if self.toSelect then
    self:initPokemonShowList(self.cur_pokemon, self.pokemonList)
    self:removeSelectPokemonFromShowList()
    self:initSelectCell()
    self:updateSelectShowUI()
    self:updateAdapterUI()
  else
    Me:playSoundByKey("starUp_success")
    self:updateEntityWindow(self.cur_pokemon)
    self:showSuccessStars(self.cur_pokemon)
  end
end

function M:initPokemonList()
  self.battlePokemonObjIds = Me:getValue("battlePetList")
  local packetPokemonObjIds = Me:getValue("packetPetList")
  packetPokemonObjIds = Me:filterLockPokemonToEnd(packetPokemonObjIds)
  Me:getPokemonList(self.battlePokemonObjIds, function(pokemonList)
    for _, pokemon in pairs(pokemonList) do
      table.insert(self.pokemonList, pokemon)
    end
  end)
  Me:getPokemonList(packetPokemonObjIds, function(pokemonList)
    for _, pokemon in pairs(pokemonList) do
      table.insert(self.pokemonList, pokemon)
    end
  end)
end

function M:initSelectCell()
  local items = {}
  for index = 1, costMap[1] do
    table.insert(items, self.selectItemList[index])
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, self.cur_pokemon:getCanStarUpRedShow(), nil, nil, index)
    self.selectItemList[index]:SetVisible(true)
  end
  for index = costMap[1] + 1, 5 do
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, false, nil, nil, index)
    self.selectItemList[index]:SetVisible(false)
  end
  local selectAutoLayout = UIMgr:new_widget("autoLayout")
  selectAutoLayout:invoke("initLayout", items, self.lytPokemonStarUpPopupPetsSelectLyt)
  selectAutoLayout:invoke("setHInterval", 0.35)
end

function M:updateAdapterUI()
  local adapter = self.gvPetsList:invoke("getAdapter")
  adapter:notifyDataChange()
end

function M:selectPokemon(pokemon, autoSelect)
  for i = 1, costMap[1] do
    if self.selectPokemonList[i] ~= nil and self.selectPokemonList[i]:getObjId() == pokemon:getObjId() then
      if not autoSelect then
        self:unSelectPokemon(pokemon)
      end
      return
    end
  end
  for _, objId in pairs(self.battlePokemonObjIds) do
    if objId == pokemon:getObjId() then
      return
    end
  end
  for i = 1, costMap[1] do
    if self.selectPokemonList[i] == nil then
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, false, nil, nil, i)
      if not UIRedDotMgr:getRedShowStateByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_BTN) then
        self.cur_pokemon:setCanStarUpRedShow(false)
        self:hideStarUpRedPoint()
      end
      self.selectPokemonList[i] = pokemon
      self:selectFromShowList(pokemon)
      self:updateSelectShowUI()
      break
    end
  end
  self:updateAdapterUI()
end

function M:unSelectPokemon(pokemon)
  for i = 1, costMap[1] do
    if self.selectPokemonList[i] ~= nil and self.selectPokemonList[i]:getObjId() == pokemon:getObjId() then
      table.remove(self.selectPokemonList, i)
      self:unSelectFromShowList(pokemon)
      self:updateSelectShowUI()
      break
    end
  end
  self:updateAdapterUI()
end

function M:removeSelectPokemonFromShowList()
  for index, pokemon in pairs(self.selectPokemonList) do
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, false, nil, nil, index)
    self:selectFromShowList(pokemon)
  end
end

function M:autoSelect()
  local showListCount = #self.selectPokemonList
  for _, data in pairs(self.showPokemonList) do
    if #self.selectPokemonList == tonumber(costMap[1]) then
      return
    end
    if not data.pokemon then
      if showListCount == #self.selectPokemonList then
        if self.tipTimer then
          LuaTimer:cancel(self.tipTimer)
        end
        self.lytTipPopup:SetVisible(true)
        self.tipTimer = LuaTimer:schedule(function()
          self.lytTipPopup:SetVisible(false)
        end, 2000)
      end
      return
    end
    if data.pokemon:getQuality() == Define.POKEMON_QUALITY.EPIC and not data.pokemon:isLocked() then
      self:selectPokemon(data.pokemon, true)
    end
  end
end

function M:selectFromShowList(pokemon)
  for index, data in pairs(self.showPokemonList) do
    if data.pokemon:getObjId() == pokemon:getObjId() then
      self.showPokemonList[index].isChecked = true
      return
    end
  end
end

function M:unSelectFromShowList(pokemon)
  for index, data in pairs(self.showPokemonList) do
    if data.pokemon:getObjId() == pokemon:getObjId() then
      self.showPokemonList[index].isChecked = false
      return
    end
  end
end

function M:addToShowList(pokemon)
  showPokemonCount = showPokemonCount + 1
  self.showPokemonList[showPokemonCount] = {
    pokemon = pokemon,
    isChecked = false,
    checkInTeam = true,
    checkLocked = true,
    clickCallBack = function()
      if pokemon:isLocked() then
        return
      end
      self:selectPokemon(pokemon)
    end
  }
end

function M:updateSelectShowUI()
  for i = 1, costMap[1] do
    if self.selectPokemonList[i] ~= nil then
      self.selectItemList[i]:invoke("setData", function(pokemon)
        self:unSelectPokemon(pokemon)
      end, self.selectPokemonList[i])
    else
      self.selectItemList[i]:invoke("setData", nil, nil)
    end
  end
end

function M:hideStarUpRedPoint()
  Me:getBattlePokemon(function(battlePokemonList)
    for index, pokemon in pairs(battlePokemonList) do
      if pokemon == self.cur_pokemon then
        UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_STAR_UP, false, nil, nil, index)
        return
      end
    end
  end)
end

function M:onHide()
  UI:closeWnd("pokemon_starUp_popup")
end

function M:onShow(data)
  if data then
    if not UI:isOpen(self) then
      for index = 1, showPokemonCount do
        self.showPokemonList[index] = {}
      end
      showPokemonCount = 0
      local objIds = {}
      for _, pokemon in pairs(data.selectList or {}) do
        table.insert(objIds, pokemon:getObjId())
      end
      Me:getPokemonList(objIds, function(pokemonList)
        self.selectPokemonList = pokemonList
      end)
      self.toSelect = data.toSelect
      self.cur_pokemon = data.cur_pokemon
      self.pokemonList = {}
      self.yesCb = data.yesCb
      self.recordTimerCallback = data.recordTimerCallback
      UI:openWnd("pokemon_starUp_popup")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:initPokemonShowList(cur_pokemon, pokemonList)
  self:initPokemonList()
  self.cur_pokemon = cur_pokemon
  costMap = PokemonConfig:getStarConfig(cur_pokemon:getStar()).starUpCost
  for _, pokemon in pairs(pokemonList) do
    if PokemonConfig:checkMaterial(cur_pokemon, pokemon) then
      self:addToShowList(pokemon)
    end
  end
end

function M:showWndByType(toSelect)
  self.lytPokemonStarUpPopupStarPetSelectLyt:SetVisible(toSelect)
  self.lytSuccess:SetVisible(not toSelect)
end

function M:updateEntityWindow(pokemon)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local pokemon_config = pokemon:getCfg()
  local entity_cfg = Entity.GetCfg(pokemon:getCfgFullName())
  self.actSuccessEntity:SetActor1(entity_cfg.actorName, "idle")
  self.actSuccessEntity:SetActorScale(pokemon_config.uiScale)
  if getmetatable(self.actSuccessEntity).SetActorOffset then
    self.actSuccessEntity:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  self.actSuccessEntity:SetYPosition({
    pokemon_config.uiOffsetY,
    0
  })
  self.actSuccessEntity:SetRotateY(-40)
  self.actSuccessEntity:SetRotateX(10)
end

function M:showSuccessStars(pokemon)
  self.lytStarShow:CleanupChildren()
  self.starAutoLayout = UIMgr:new_widget("autoLayout")
  self.stars = {}
  for _ = 1, 6 do
    local starItem = UIMgr:new_widget("star")
    table.insert(self.stars, starItem)
  end
  self.starAutoLayout:invoke("initLayout", self.stars, self.lytStarShow)
  self.starAutoLayout:invoke("setHInterval", 0.2)
  for index = 1, pokemon:getStar() - 1 do
    self.stars[index]:invoke("updateUI", pokemon:getWake() + 1)
  end
  for index = pokemon:getStar() + 1, 6 do
    self.stars[index]:invoke("updateUI", 0)
  end
  self.stars[pokemon:getStar()]:invoke("updateUI", pokemon:getWake() + 1, true)
end

function M:onOpen()
  local adapter = self.gvPetsList:invoke("getAdapter")
  adapter:setScrollOffset(0)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function M:onClose()
  for index = 1, 5 do
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT, false, nil, nil, index)
  end
  self.cur_pokemon:setCanStarUpRedShow(false)
  self:hideStarUpRedPoint()
  self.lytTipPopup:SetVisible(false)
  if self.tipTimer then
    LuaTimer:cancel(self.tipTimer)
  end
  if self.recordTimerCallback then
    self.recordTimerCallback()
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
