local ActiveRewardConfig = T(Config, "ActiveRewardConfig")
local PokemonTaskConfig = T(Config, "PokemonTaskConfig")

function M:init()
  WinBase.init(self, "PokemonTask.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.active_item_nodes = {}
  self.active_reward_data = {}
  self.task_status_nodes = {}
  self.maxActive = 120
end

function M:initWnd()
  self.btnClose = self:child("PokemonTask-BtnClose")
  self.stUpdateTime = self:child("PokemonTask-UpdateTime")
  self.stTitle = self:child("PokemonTask-Title")
  self.stTitle:SetText(Lang:toText("gui.task.title"))
  self.ltTaskList = self:child("PokemonTask-List-Layout")
  self.task_grid_view = UIMgr:new_widget("grid_view")
  self.task_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.task_grid_view:InitConfig(33, 12, 2)
  self.task_grid_view:SetMoveAble(false)
  self.ltTaskList:AddChildWindow(self.task_grid_view)
  local width = self.task_grid_view:GetPixelSize().x
  self.itemWidth = (width - 33) / 2
  local height = self.task_grid_view:GetPixelSize().y
  self.itemHeight = (height - 36) / 4
  self.stDailyActiveCount = self:child("PokemonTask-DailyActive-Count")
  self.stDailyActiveText = self:child("PokemonTask-DailyActive-Text")
  self.stDailyActiveText:SetText(Lang:toText("gui.task.active"))
  self.ltRewardList = self:child("PokemonTask-DailyActive-Reward-List")
  self.item_grid_view = UIMgr:new_widget("grid_view")
  self.item_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.item_grid_view:InitConfig(79, 0, 6)
  self.item_grid_view:SetMoveAble(false)
  self.ltRewardList:AddChildWindow(self.item_grid_view)
  self.ltTipList = self:child("PokemonTask-DailyActive-Tip-List")
  self.pbDailyActive = self:child("PokemonTask-DailyActive-ProgressBar")
  self.flyEffect = self:child("PokemonTask-Fly-Effect-Bg")
  self.bombEffect = self:child("PokemonTask-Bomb-Effect-Bg")
  self.flyEffect:SetVisible(false)
  self.bombEffect:SetVisible(false)
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  Lib.subscribeEvent(Event.EVENT_GET_DAILY_TASK_STATUS_LIST, function(task_status_list)
    self:refreshTaskList(task_status_list)
  end)
  Lib.subscribeEvent(Event.EVENT_DAILY_TASK_STATUS_CHANGE, function(task_status_list)
    self:updateTaskList(task_status_list)
  end)
  Lib.subscribeEvent(Event.EVENT_GET_DAILY_TASK_ACTIVE_STATUS, function(activeIndex, activePoint)
    Lib.logDebug("EVENT_GET_DAILY_TASK_ACTIVE_STATUS activeIndex and activePoint = ", activeIndex, activePoint)
    self:refreshRewardList(activeIndex, activePoint)
  end)
  Lib.subscribeEvent(Event.EVENT_TASK_POINT_POSITION, function(x, y)
    self.taskPointX = x
    self.taskPointY = y
  end)
  Lib.subscribeEvent(Event.EVENT_ACTIVE_POINT_CHANGE, function(value)
    local x = self.taskPointX or 0
    local y = self.taskPointY or 0
    local moveStart = "0," .. x .. ",0," .. y
    local params = {
      {moveStart = moveStart, moveEnd = "0,84,0,594"}
    }
    self.flyEffect:SetVisible(true)
    local UIAnimationManager = T(UILib, "UIAnimationManager")
    UIAnimationManager:play(self.flyEffect, "TaskPointEffectFly", function()
      self.flyEffect:SetVisible(false)
      self.bombEffect:SetVisible(true)
      self.taskPointX = 0
      self.taskPointY = 0
      UIAnimationManager:play(self.flyEffect, "TaskPointEffectBoom", function()
        self.bombEffect:SetVisible(false)
        self.stDailyActiveCount:SetTextWithJump(value, false, 1, 1)
        Lib.logDebug("EVENT_ACTIVE_POINT_CHANGE value = ", value)
        Lib.logDebug("EVENT_ACTIVE_POINT_CHANGE progress = ", value / self.maxActive)
        self.pbDailyActive:SetProgress(value / self.maxActive)
      end)
    end, params)
  end)
  Lib.subscribeEvent(Event.EVENT_ACTIVE_INDEX_CHANGE, function(value)
    Lib.logDebug("EVENT_ACTIVE_INDEX_CHANGE value = ", value)
    for index, item in pairs(self.active_item_nodes) do
      if index <= value then
        item:invoke("onFinished", true)
      end
    end
    if self.active_item_nodes[value + 1] then
      self:onChecked(value + 1)
    end
  end)
end

function M:onShow()
  self.stUpdateTime:SetText(Lang:toText({
    "gui.task.updatetime",
    World.cfg.offsetTime
  }))
  Me:sendPacket({
    pid = "GetDailyTaskAcitveStatus"
  })
  Me:sendPacket({
    pid = "GetDailyTaskStatusList"
  })
  UI:openWnd("pokemonTask")
end

function M:onChecked(index)
  Lib.logDebug("onChecked index = ", index)
  for _index, item in pairs(self.active_item_nodes) do
    if _index == index then
      item:invoke("onChecked", true)
    else
      item:invoke("onChecked", false)
    end
  end
end

function M:refreshTaskList(task_status_list)
  self.task_grid_view:RemoveAllItems()
  self.task_status_nodes = {}
  for _, task_status in pairs(task_status_list) do
    local task_id = task_status.id
    local task_data = PokemonTaskConfig:getTaskById(task_id)
    local node = UIMgr:new_widget("pokemon_task_cell")
    node:SetArea({0, 0}, {0, 0}, {
      0,
      self.itemWidth
    }, {
      0,
      self.itemHeight
    })
    node:invoke("initView", task_id, task_data, task_status)
    self.task_grid_view:AddItem(node, true)
    self.task_status_nodes[task_id] = node
  end
end

function M:updateTaskList(task_status_list)
  for _, task_status in pairs(task_status_list) do
    local task_id = task_status.id
    local node = self.task_status_nodes[task_id]
    if node then
      node:invoke("updateStatus", task_status)
    end
  end
end

function M:refreshRewardList(activeIndex, activePoint)
  Lib.logDebug("refreshRewardList activeIndex and activePoint = ", activeIndex, activePoint)
  self.item_grid_view:RemoveAllItems()
  self.stDailyActiveCount:SetTextWithJump(activePoint, false)
  self.pbDailyActive:SetProgress(activePoint / self.maxActive)
  self.flyEffect:SetVisible(false)
  self.bombEffect:SetVisible(false)
  self.active_reward_data = ActiveRewardConfig:getRewards(Me:getPlayerLevel())
  Lib.logDebug("refreshRewardList active_reward_data = ", Lib.v2s(self.active_reward_data))
  local xPosition = 0
  for index, data in pairs(self.active_reward_data) do
    local item_node = UIMgr:new_widget("pokemon_item_cell")
    item_node:invoke("initViewDataWithoutAdapter", data.reward[1], data.reward[2], function(_, dx, dy)
      UI:getWnd("pokemonItemDetail"):onShow(data.reward[1], dx, dy)
    end)
    item_node:SetArea({0, 0}, {0, 0}, {0, 92}, {0, 92})
    self.item_grid_view:AddItem(item_node, true)
    self.active_item_nodes[index] = item_node
    if activeIndex >= index then
      item_node:invoke("onFinished", true)
    end
    local tip_node = UIMgr:new_widget("pokemon_active_tip")
    tip_node:invoke("initByCount", data.active)
    tip_node:SetArea({0, xPosition}, {0, 0}, {0, 50}, {0, 30})
    self.ltTipList:AddChildWindow(tip_node)
    xPosition = xPosition + 170
  end
  if self.active_item_nodes[activeIndex + 1] then
    self:onChecked(activeIndex + 1)
  end
end

function M:onHide()
  UI:closeWnd("pokemonTask")
end

function M:onOpen()
  World.Timer(10, function()
    if UI:isOpen(self) then
      for _, node in pairs(self.task_status_nodes) do
        local status = node:data("status")
        if status and status.finished == 1 and status.rewarded == 0 then
          node:child("pokemon_task_cell-ltFunc"):CallHandler(UIEvent.EventWindowClick, 0, 0)
        end
      end
    end
  end)
end

function M:onClose()
  self.active_reward_data = {}
end

return M
