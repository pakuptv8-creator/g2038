local PokemonConfig = T(Config, "PokemonConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local recordTimerCallback
local smoothTime = 20
local jumpLevelTime = 3
local color = {
  level = "\226\150\162FF9B0081",
  maxLevel = "\226\150\162FF9F5F9F"
}

function M:init()
  WinBase.init(self, "PokemonPopupUpgrade.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.pokemon = nil
  self.itemDatas = {}
  self.itemNodes = {}
  self:initExpItemInfo()
end

function M:initWnd()
  self.btnClose = self:child("PokemonPopupUpgrade-BtnClose")
  self.stTitle = self:child("PokemonPopupUpgrade-Title")
  self.siAvatar = self:child("PokemonPopupUpgrade-AvatarFrame")
  self.widget_item = UIMgr:new_widget("pokemon_packet_item_cell")
  self.widget_item:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.siAvatar:AddChildWindow(self.widget_item)
  self.llAttr = self:child("PokemonPopupUpgrade-Attr-Layout")
  self.attrItem = UIMgr:new_widget("pokemonAttributes")
  self.attrItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.llAttr:AddChildWindow(self.attrItem)
  self.stName = self:child("PokemonPopupUpgrade-Name")
  self.stLevel = self:child("PokemonPopupUpgrade-Level")
  self.pbExpBar = self:child("PokemonPopupUpgrade-Exp-Bar")
  self.stExp = self:child("PokemonPopupUpgrade-Exp-Text")
  self.txtAttrUpTitle = self:child("PokemonPopupUpgrade-UpgradeAttributesUpTitle")
  self.itemList = self:child("PokemonPopupUpgrade-Item-List")
  self.grid_view = UIMgr:new_widget("grid_view")
  self.grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.grid_view:InitConfig(20, 0, 4)
  self.grid_view:SetMoveAble(false)
  self.itemList:AddChildWindow(self.grid_view)
  self.btnUse = self:child("PokemonPopupUpgrade-BtnUseItem")
  self.btnUpgrade = self:child("PokemonPopupUpgrade-BtnUpgrade")
  self.mask = self:child("PokemonPopupUpgrade-Mask")
  self:child("PokemonPopupUpgrade-Exp-Title"):SetText("EXP")
  self.stTitle:SetText(Lang:toText("gui.title.upgrade"))
  self.btnUse:SetText(Lang:toText("gui.btn.use_one"))
  self.btnUpgrade:SetText(Lang:toText("gui.btn.upgrade_level"))
  self.txtAttrUpTitle:SetText(Lang:toText("gui.upgrade.attributesUp"))
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    if recordTimerCallback ~= nil and type(recordTimerCallback) == "function" then
      recordTimerCallback()
    end
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.UPGRADE_POKEMON_CLOSE_UPGRADE then
      Me:gotoNextGuide()
    else
      UI:closeWnd(self)
    end
  end)
  self:subscribe(self.btnUse, UIEvent.EventButtonClick, function()
    self.copy_pokemon = Me:copyPokemon(self.pokemon)
    Lib.logDebug("click btnUse")
    Me:useExpItem({
      objId = self.pokemon:getObjId(),
      fullName = self.itemDatas[self.selectIndex].fullName,
      type = Define.USE_EXP_ITEM_TYPE.ONCE_ITEM
    }, function(ret)
      if not ret then
        UI:getWnd("battle_dialog"):showDialogText({
          text = Lang:toText("ui_can_not_use"),
          yesCb = function()
          end
        })
      elseif ret == 0 then
        UI:getWnd("battle_dialog"):showDialogText({
          text = Lang:toText("ui_can_not_up"),
          yesCb = function()
          end
        })
      end
    end)
  end)
  self:subscribe(self.btnUpgrade, UIEvent.EventButtonClick, function()
    self.copy_pokemon = Me:copyPokemon(self.pokemon)
    Lib.logDebug("click btnUpgrade")
    if self.itemDatas[self.selectIndex] then
      Me:useExpItem({
        objId = self.pokemon:getObjId(),
        fullName = self.itemDatas[self.selectIndex].fullName,
        type = Define.USE_EXP_ITEM_TYPE.ONCE_LEVEL
      }, function(ret)
        if not ret then
          UI:getWnd("battle_dialog"):showDialogText({
            text = Lang:toText("ui_can_not_use"),
            yesCb = function()
            end
          })
        elseif ret == 0 then
          UI:getWnd("battle_dialog"):showDialogText({
            text = Lang:toText("ui_can_not_up"),
            yesCb = function()
            end
          })
        elseif ret == 1 then
          UI:getWnd("battle_dialog"):showDialogText({
            text = Lang:toText("ui_can_not_up_star_limit")
          })
        end
      end)
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.UPGRADE_POKEMON_CONFIRM_UPGRADE then
        Me:gotoNextGuide()
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_STORE_BATTLE_RESULTS_PACKET, function(packet)
    self.packet = packet
  end)
  Lib.subscribeEvent(Event.EVENT_REFRESH_PLAYER_BAG, function()
    if not UI:isOpen(self) then
      return
    end
    self:refresh()
  end)
  Lib.subscribeEvent(Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if self:isvisible() and tostring(objId) == tostring(self.pokemon:getObjId()) then
      if self.copy_pokemon and self:expIsEqual(self.copy_pokemon, self.pokemon) and self:levelIsEqual(self.copy_pokemon, self.pokemon) then
        return
      end
      self:refresh(true)
    end
  end)
end

function M:onShow(pokemon, timerCallback)
  UI:openWnd("pokemonPopupUpgrade")
  self.pokemon = pokemon
  self.maxLevel = PokemonConfig:getStarConfig(self.pokemon:getStar()).levelMax
  self:refresh(false)
  self.mask:SetTouchable(false)
  recordTimerCallback = timerCallback
  self:onChecked(1)
end

function M:initExpItemInfo()
  local items = Me:getItemsCfgByItemType(Define.ITEM_TYPE.EXP)
  for _, item in pairs(items) do
    table.insert(self.itemDatas, item)
  end
  table.sort(self.itemDatas, function(a, b)
    return a.itemId < b.itemId
  end)
end

function M:refresh(doTick)
  if doTick ~= nil then
    self:updateInfo(doTick)
  end
  for index, item in pairs(self.itemDatas) do
    if not self.itemNodes[index] then
      local node = UIMgr:new_widget("pokemon_item_cell")
      self.grid_view:InitConfig(20, 0, #self.itemDatas)
      self.grid_view:AddItem(node, true)
      self.itemNodes[index] = node
    end
    self.itemNodes[index]:invoke("initViewDataWithoutAdapter", item.fullName, Me:getTrayItemCountByFullName(item.fullName), function(_, dx, dy)
      if self.itemNodes[index]:invoke("isChecked") then
        UI:getWnd("pokemonItemDetail"):onShow(item.fullName, dx, dy)
      end
      self:onChecked(index)
    end)
  end
end

function M:updateInfo(doTick)
  if doTick ~= nil and doTick == true then
    self.copy_pokemon = self.copy_pokemon or self.pokemon
    self:updateExpUI(self.copy_pokemon)
    self:startTick()
    return
  end
  self.stName:SetText(Lang:toText(self.pokemon:getName()))
  self.widget_item:invoke("onDataChanged", {
    pokemon = self.pokemon
  })
  self:updateExpUI(self.pokemon)
  self:updateAttributes()
end

function M:onTick()
  if self.timeWait > 0 then
    self.timeWait = self.timeWait - 1
    return
  end
  local copy_pokemonMaxExp = self.copy_pokemon:getMaxExp()
  local targetExp = self.copy_pokemon:getLevel() == self.pokemon:getLevel() and self.pokemon:getCurExp() or copy_pokemonMaxExp
  local addExp = math.min(copy_pokemonMaxExp / smoothTime, targetExp - self.copy_pokemon:getCurExp())
  self.copy_pokemon:setCurExp(self.copy_pokemon:getCurExp() + addExp)
  if copy_pokemonMaxExp <= self.copy_pokemon:getCurExp() and not self:levelIsEqual(self.copy_pokemon, self.pokemon) then
    self.copy_pokemon:setLevel(self.copy_pokemon:getLevel() + 1)
    self.copy_pokemon:setCurExp(self:levelIsEqual(self.copy_pokemon, self.pokemon) and 0 or self.copy_pokemon:getMaxExp(self.copy_pokemon:getLevel()))
    self:updateAttributes()
    self.timeWait = self:levelIsEqual(self.copy_pokemon, self.pokemon) and 0 or jumpLevelTime
  end
  return self:expIsEqual(self.copy_pokemon, self.pokemon) and self:levelIsEqual(self.copy_pokemon, self.pokemon)
end

function M:startTick()
  self.sid = Me:playSoundByKey("upgrade_bar")
  self.mask:SetTouchable(true)
  self.timeWait = 0
  if self.barTickCancel then
    self.barTickCancel()
  end
  self.barTickCancel = World.Timer(1, function()
    local isTickDone = self:onTick()
    if isTickDone then
      self:onTickDone()
    end
    self:updateExpUI(self.copy_pokemon)
    return not isTickDone
  end)
end

function M:onTickDone()
  self.mask:SetTouchable(false)
  local wnd = UI:getWnd("battle_results")
  if wnd and self.packet then
    self:stopSound()
    local study_skill = self.pokemon:getStudySkillList()
    if 0 < #study_skill then
      wnd:showBattleResult(self.packet)
    end
  end
  self.packet = nil
end

function M:updateExpUI(pokemon)
  local pokemonMaxExp = pokemon:getMaxExp()
  self.pbExpBar:SetProgress(pokemon:getCurExp() / pokemonMaxExp)
  self.stExp:SetText(math.ceil(pokemon:getCurExp()) .. "/" .. pokemonMaxExp)
  self.stLevel:SetText(color.level .. "Lv." .. tostring(pokemon:getLevel()) .. color.maxLevel .. "/" .. self.maxLevel)
end

function M:expIsEqual(copy_pokemon, pokemon)
  return tonumber(copy_pokemon:getCurExp()) == tonumber(pokemon:getCurExp())
end

function M:levelIsEqual(copy_pokemon, pokemon)
  return tonumber(copy_pokemon:getLevel()) == tonumber(pokemon:getLevel())
end

function M:updateAttributes()
  local copy_pokemon = Me:copyPokemon(self.copy_pokemon or self.pokemon)
  self.attrItem:invoke("updateUIByType", copy_pokemon, "level")
end

function M:stopSound()
  if self.sid ~= nil then
    Me:stopSound(self.sid)
    self.sid = nil
  end
end

function M:onChecked(index)
  for _index, item in pairs(self.itemNodes) do
    if _index == index then
      item:invoke("onChecked", true)
    else
      item:invoke("onChecked", false)
    end
  end
  self.selectIndex = index
end

function M:onHide()
  UI:closeWnd("pokemonPopupUpgrade")
end

function M:onOpen()
  Lib.logDebug("onOpen")
end

function M:onClose()
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_BTN, false)
  Me:getBattlePokemon(function(battlePokemonList)
    for index, pokemon in pairs(battlePokemonList) do
      if pokemon and pokemon == self.pokemon then
        pokemon:setCanLevelUpRedPointShow(false)
        UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.PET_CAN_LEVEL_UP, false, index)
      end
    end
  end)
  Lib.logDebug("onClose")
  self.copy_pokemon = nil
  self.pokemon = nil
end

return M
