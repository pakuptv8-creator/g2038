local operationTime = World.cfg.operationTime
local itemWidth = 353
local itemHeight = 117
local skillCellHeight = 59
local skillCellVerticalInterval = 11
local M = _ENV.M
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "battle_pokemon.json", false)
  self.items = {}
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgBattlePokemonOperationWin = self:child("battle_pokemon-operation_win")
  self.imgBattlePokemonOperationWinLeftBg = self:child("battle_pokemon-operation_win_left_bg")
  self.lytBattlePokemonOperationPetList = self:child("battle_pokemon-operation_pet_list")
  self.btnBattlePokemonClose = self:child("battle_pokemon-close")
  self.btnBattlePokemonReplace = self:child("battle_pokemon-replace")
  self.btnBattlePokemonReplace:SetText(Lang:toText("ui_replace"))
  self.lytBattlePokemonSkillList = self:child("battle_pokemon-skill_list")
  self.gvSkillList = UIMgr:new_widget("grid_view")
  self.lyBattlePokemonSkillDetail = self:child("battle_pokemon-skill_detail")
  self.descItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.descItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lyBattlePokemonSkillDetail:AddChildWindow(self.descItem)
  self.lyBattleTopTime = UIMgr:new_widget("battle_top_time")
  self.lyBattleTopTime:invoke("showInCurrentWnd", self._root, {0, 5})
  self:initList()
end

function M:initEvent()
  self:subscribe(self.btnBattlePokemonClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("battle_pokemon")
  end)
  self:subscribe(self.btnBattlePokemonReplace, UIEvent.EventButtonClick, function()
    self:doBattlePokemonReplace(self.objId)
  end)
end

function M:doBattlePokemonReplace(objId)
  if self:isBattlePokemon(objId) then
    UI:getWnd("battle_dialog"):showDialogText({
      text = Lang:getMessage("ui_pet_in_battle"),
      yesCb = function()
      end
    })
    return
  end
  if self.curHp > 0 and Me:battleAction(Define.BATTLE_ACTION.REPLACE, objId) then
    UI:closeWnd("battle_pokemon")
    local wnd = UI:getWnd("battle_main")
    if wnd then
      wnd:showControlWin(false)
    end
  end
end

function M:subscribeEvent()
end

function M:initView()
  self:upDatePokemonList()
end

function M:initList()
  self.lytBattlePokemonSkillList:AddChildWindow(self.gvSkillList)
  self.gvSkillList:SetAutoColumnCount(false)
  self.gvSkillList:SetMoveAble(false)
  self.gvSkillList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvSkillList:InitConfig(0, skillCellVerticalInterval, 1)
end

function M:updateSkillList(pokemon)
  self.gvSkillList:RemoveAllItems()
  if not pokemon then
    return
  end
  self.skillItem = {}
  local skillList = pokemon:getSkillList()
  local lyHeight = 0
  for i = 1, 4 do
    local cell = UIMgr:new_widget("pokemon_skill_cell")
    self:subscribe(cell, UIEvent.EventWindowClick, function()
      self:onCheckedSkillClick(i)
      self:updateSkillDetail(cell)
    end)
    cell:invoke("updateInfo", skillList[i])
    lyHeight = lyHeight + skillCellVerticalInterval + skillCellHeight
    self.gvSkillList:AddItem(cell)
    self.skillItem[i] = cell
  end
  self.lytBattlePokemonSkillList:SetHeight({0, lyHeight})
  self:updateSkillDetail(self.skillItem[1])
  self:onCheckedSkillClick(1)
end

function M:updateSkillDetail(cell)
  local skill = cell:invoke("getSkill") or {}
  self.descItem:invoke("updateInfo", skill)
end

function M:upDatePokemonList()
  local positionY = 0
  Me:getBattlePokemon(function(pokemonList)
    for i = 1, 4 do
      local item = self.items[i]
      if not item then
        item = UIMgr:new_widget("pokemon_head_cell")
        self.lytBattlePokemonOperationPetList:AddChildWindow(item)
        self.items[i] = item
      end
      self:unsubscribe(item)
      local pokemon = pokemonList[i]
      if pokemon then
        item:invoke("onShowMask", pokemon:getCurHp() <= 0)
        self:subscribe(item, UIEvent.EventWindowClick, function()
          if pokemon:getCurHp() <= 0 then
            return
          end
          self:onCheckedPetClick(i)
          self:showPokemonInfo(pokemon)
          self:updateSkillList(pokemon)
        end)
      end
      item:SetVerticalAlignment(0)
      item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
      item:invoke("setType", Define.SCENE_TYPE.NOT_BATTLE)
      item:invoke("updateInfo", pokemon)
      positionY = positionY + itemHeight + 10
    end
    for index, pokemon in ipairs(pokemonList) do
      if 0 < pokemon:getCurHp() then
        self:onCheckedPetClick(index)
        self:showPokemonInfo(pokemon)
        self:updateSkillList(pokemon)
        break
      end
    end
  end)
end

function M:onCheckedPetClick(index)
  for _index, item in pairs(self.items) do
    if _index == index then
      item:invoke("onChecked", true)
    else
      item:invoke("onChecked", false)
    end
  end
end

function M:onCheckedSkillClick(index)
  for _index, item in pairs(self.skillItem) do
    if _index == index then
      item:invoke("onChecked", true)
    else
      item:invoke("onChecked", false)
    end
  end
end

function M:showPokemonInfo(pokemon)
  self.objId = pokemon.objId
  self.curHp = pokemon:getCurHp()
end

function M:onHide()
  LuaTimer:cancel(self.autoCloseTimer)
  UI:closeWnd("battle_pokemon")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("battle_pokemon")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(canClose, autoClose)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  self.btnBattlePokemonClose:SetVisible(canClose or false)
  LuaTimer:cancel(self.autoCloseTimer)
  if UI:getWnd("battle_main").auto then
    self:doAutoPolicy()
  elseif autoClose then
    local time = operationTime
    self.lyBattleTopTime:invoke("updateTime", operationTime .. "s")
    self.autoCloseTimer = LuaTimer:scheduleTimer(function()
      time = time - 1
      self.lyBattleTopTime:invoke("updateTime", time .. "s")
      if time == 0 then
        self:doAutoPolicy()
      end
    end, 1000, operationTime)
    Lib.logDebug("Start autoCloseTimer")
  end
  self:ChatWndAdapt(false)
end

function M:doAutoPolicy()
  if not Me:isInBattle() then
    return
  end
  Me:getBattlePokemon(function(pokemonList)
    local objId = self.objId
    for _, pokemon in ipairs(pokemonList) do
      if pokemon:getCurHp() > 0 and not self:isBattlePokemon(pokemon.objId) then
        objId = pokemon.objId
        break
      end
    end
    self:doBattlePokemonReplace(objId)
  end)
end

function M:isBattlePokemon(objId)
  local ourQueue = UI:getWnd("battle_main").ourQueue
  for _, pokemon in pairs(ourQueue or {}) do
    if pokemon.objId == objId then
      return true
    end
  end
  return false
end

function M:onClose()
  LuaTimer:cancel(self.autoCloseTimer)
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:ChatWndAdapt(true)
end

function M:ChatWndAdapt(isShow)
  if not Me:isInBattle() then
    return
  end
  UI:getWnd("chatBar"):ShowBar(isShow)
  if not isShow then
    if UI:getWnd("chatMain").isShow then
      self.needRecoverChatWnd = true
      Lib.emitEvent(Event.EVENT_OPEN_CHATBTN, false)
    end
  elseif self.needRecoverChatWnd then
    self.needRecoverChatWnd = false
    Lib.emitEvent(Event.EVENT_OPEN_CHATBTN, true)
  end
end

return M
