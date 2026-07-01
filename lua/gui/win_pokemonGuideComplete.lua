local PlayerExpConfig = T(Config, "PlayerExpConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")

function M:init()
  WinBase.init(self, "PokemonGuideComplete.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
end

function M:initWnd()
  self.stTitle = self:child("PokemonGuideComplete-Title")
  self.stTitle:SetText(Lang:toText("gui_task_complete_title"))
  self.ltTaskList = self:child("PokemonGuideComplete-Task-List")
  self.detail_grid_view = UIMgr:new_widget("grid_view")
  self.detail_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.detail_grid_view:InitConfig(0, 17, 1)
  self.detail_grid_view:SetMoveAble(false)
  self.ltTaskList:AddChildWindow(self.detail_grid_view)
  self.ltRewardList = self:child("PokemonGuideComplete-Reward-List")
  self.item_grid_view = UIMgr:new_widget("grid_view")
  self.item_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.item_grid_view:InitConfig(74, 0, 3)
  self.item_grid_view:SetMoveAble(false)
  self.ltRewardList:AddChildWindow(self.item_grid_view)
  self.btnConfirm = self:child("PokemonGuideComplete-BtnConfirm")
end

function M:initEvent()
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.FINISH_WAKE_POKEMON then
      UI:getWnd("pokemon_recharge_award"):onShow(true)
    end
    Me:gotoNextGuide()
    self:onHide()
  end)
end

function M:onShow(details, items)
  Lib.logDebug("guide complete details = ", Lib.v2s(details))
  self.detail_grid_view:RemoveAllItems()
  local playerLevel = Me:getPlayerLevel()
  local playerLevelDetail = {}
  table.insert(playerLevelDetail, 1)
  table.insert(playerLevelDetail, Me:getPlayerExLevel())
  table.insert(playerLevelDetail, playerLevel)
  local playerNode = UIMgr:new_widget("pokemon_guide_complete_cell")
  playerNode:invoke("initItem", playerLevelDetail)
  playerNode:SetArea({0, 0}, {0, 0}, {0, 760}, {0, 60})
  self.detail_grid_view:AddItem(playerNode, true)
  local pokemonLevelDetail = {}
  table.insert(pokemonLevelDetail, 2)
  table.insert(pokemonLevelDetail, Me:getPlayerExLevel())
  table.insert(pokemonLevelDetail, playerLevel)
  local pokemonNode = UIMgr:new_widget("pokemon_guide_complete_cell")
  pokemonNode:invoke("initItem", pokemonLevelDetail)
  pokemonNode:SetArea({0, 0}, {0, 0}, {0, 760}, {0, 60})
  self.detail_grid_view:AddItem(pokemonNode, true)
  local unlockDetail = PlayerExpConfig:getPresentUnlockModByLv(playerLevel)
  Lib.logDebug("unlockDetail = ", Lib.v2s(unlockDetail))
  if 0 < #unlockDetail then
    table.insert(unlockDetail, 1, 3)
    Lib.logDebug("unlock_detail = ", Lib.v2s(unlockDetail))
    local unlockNode = UIMgr:new_widget("pokemon_guide_complete_cell")
    unlockNode:invoke("initItem", unlockDetail)
    unlockNode:SetArea({0, 0}, {0, 0}, {0, 760}, {0, 60})
    self.detail_grid_view:AddItem(unlockNode, true)
  end
  Lib.logDebug("guide complete items = ", Lib.v2s(items))
  self.item_grid_view:RemoveAllItems()
  for i = 1, #items do
    local item_data = items[i]
    local item_name = "myplugin/" .. item_data[1]
    Lib.logDebug("item_name = ", item_name)
    local item_count = item_data[2]
    Lib.logDebug("item_count = ", item_count)
    local node = UIMgr:new_widget("pokemon_item_cell")
    node:invoke("initViewDataWithoutAdapter", item_name, item_count, function(_, dx, dy)
      UI:getWnd("pokemonItemDetail"):onShow(item_name, dx, dy)
    end)
    self.item_grid_view:InitConfig(74, 0, #items)
    local itemWidth = 114
    node:SetArea({0, 0}, {0, 0}, {0, itemWidth}, {0, itemWidth})
    self.item_grid_view:AddItem(node, true)
  end
  Me:playSoundByKey("mission_complete")
  UI:openWnd("pokemonGuideComplete")
end

function M:onHide()
  UI:closeWnd("pokemonGuideComplete")
end

function M:onOpen()
end

function M:onClose()
end

return M
