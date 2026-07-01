local M = _ENV.M

function M:init()
  WinBase.init(self, "battle_select_target.json", false)
  self:initUI()
  self:initEvent()
end

local CellHorizontalInterval = 45

function M:initUI()
  self.imgBattleSelectTargetBg = self:child("battle_select_target-bg")
  self.imgBattleSelectTargetTitle = self:child("battle_select_target-title")
  self.txtBattleSelectTargetTitleText = self:child("battle_select_target-title_text")
  self.txtBattleSelectTargetTitleText:SetText(Lang:toText("ui_select_target"))
  self.btnBattleSelectTargetClose = self:child("battle_select_target-close")
  self.lytBattleSelectTargetEnemyQueueList = self:child("battle_select_target-enemy_queue_list")
  self.lytBattleSelectTargetOurQueueList = self:child("battle_select_target-our_queue_list")
  self.gvOurQueue = UIMgr:new_widget("grid_view")
  self.gvEnemyQueue = UIMgr:new_widget("grid_view")
  self:initList()
end

function M:initEvent()
  self:subscribe(self.btnBattleSelectTargetClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("battle_select_target")
  end)
end

function M:subscribeEvent()
end

function M:initList()
  self.lytBattleSelectTargetOurQueueList:AddChildWindow(self.gvOurQueue)
  self.gvOurQueue:SetMoveAble(false)
  self.gvOurQueue:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytBattleSelectTargetEnemyQueueList:AddChildWindow(self.gvEnemyQueue)
  self.gvEnemyQueue:SetMoveAble(false)
  self.gvEnemyQueue:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function M:initView()
  self.ourCells = {}
  self.enemyCell = {}
  self.ourQueue = UI:getWnd("battle_main").ourQueue
  self.enemyQueue = UI:getWnd("battle_main").enemyQueue or {}
  local enemyCells = UI:getWnd("battle_main").enemyCells or {}
  self.enemyShow = {}
  for _, cell in ipairs(enemyCells) do
    table.insert(self.enemyShow, cell:IsVisible())
  end
  self.gvOurQueue:RemoveAllItems()
  self.gvEnemyQueue:RemoveAllItems()
  self.gvOurQueue:InitConfig(CellHorizontalInterval, 0, #self.ourQueue)
  self.gvEnemyQueue:InitConfig(CellHorizontalInterval, 0, #self.enemyQueue)
  local ourObjIds = {}
  for i, pokemon in pairs(self.ourQueue or {}) do
    local ourCell = UIMgr:new_widget("pokemon_target_pet_cell")
    ourCell:invoke("updateInfo", pokemon, self.skillRace)
    self:subscribe(ourCell, UIEvent.EventWindowClick, function()
      if self.target ~= Define.BATTLE_TARGET.OUR then
        return
      end
      if self.range == 2 then
        self.fun(ourObjIds)
        self:onHide()
        return
      end
      self.fun(pokemon.objId)
      self:onHide()
    end)
    self.gvOurQueue:AddItem(ourCell)
    self.ourCells[i] = ourCell
    ourObjIds[i] = pokemon.objId
  end
  local enemyObjIds = {}
  for i = #self.enemyQueue, 1, -1 do
    local enemyCell = UIMgr:new_widget("pokemon_target_pet_cell")
    enemyCell:invoke("updateInfo", self.enemyQueue[i], self.skillRace)
    self:subscribe(enemyCell, UIEvent.EventWindowClick, function()
      if self.target ~= Define.BATTLE_TARGET.ENEMY or self.enemyQueue[i]:getCurHp() <= 0 or not self.enemyShow[i] then
        return
      end
      if self.range == 2 then
        self.fun(enemyObjIds)
        self:onHide()
        return
      end
      self.fun(self.enemyQueue[i].objId)
      self:onHide()
    end)
    self.gvEnemyQueue:AddItem(enemyCell)
    self.enemyCell[i] = enemyCell
    enemyObjIds[i] = self.enemyQueue[i].objId
  end
  self:updateCellStatus()
end

function M:updateCellStatus()
  if self.target == Define.BATTLE_TARGET.OUR then
    self:setCellsMask(self.enemyCell)
    if self.range == 2 then
      self:setCellsSelected(self.ourCells)
    end
  elseif self.target == Define.BATTLE_TARGET.ENEMY then
    self:setCellsMask(self.ourCells)
    self:setCellsMaskByHp(self.enemyCell)
    if self.range == 2 then
      self:setCellsSelected(self.enemyCell)
    end
  end
end

function M:setCellsSelected(cells)
  for _, cell in pairs(cells or {}) do
    cell:invoke("setCellSelected", true)
  end
end

function M:setCellsMask(cells)
  for _, cell in pairs(cells or {}) do
    local pokemon = cell:invoke("getPokemon")
    if pokemon then
      cell:invoke("setCellMask", true)
    end
  end
end

function M:setCellsMaskByHp(cells)
  for i, cell in pairs(cells or {}) do
    local pokemon = cell:invoke("getPokemon")
    if pokemon and (pokemon:getCurHp() <= 0 or pokemon.runaway) or not self.enemyShow[i] then
      cell:invoke("setCellMask", true)
    end
  end
end

function M:onHide()
  UI:closeWnd("battle_select_target")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("battle_select_target")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(target, range, fun, skillRace)
  self._allEvent = {}
  self:subscribeEvent()
  self.target = target
  self.range = range
  self.fun = fun
  self.skillRace = skillRace
  self:initView()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
