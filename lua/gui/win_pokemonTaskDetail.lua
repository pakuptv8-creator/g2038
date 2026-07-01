local PokemonTaskConfig = T(Config, "PokemonTaskConfig")

function M:init()
  WinBase.init(self, "PokemonTaskDetail.json", false)
  self:initData()
  self:initUI()
  self:initEvent()
end

function M:initData()
  self.config = {}
end

function M:initUI()
  self.mid_x = self._root:GetPixelSize().x / 2
  self.mid_y = self._root:GetPixelSize().y / 2
  self.ltClickPosition = self:child("PokemonTaskDetail-Click-Position")
  self.ltContent = self:child("PokemonTaskDetail-Content")
  self.stTitle = self:child("PokemonTaskDetail-Title")
  self.stDesc = self:child("PokemonTaskDetail-Desc")
  self.ltList = self:child("PokemonTaskDetail-List-Layout")
  self.grid_view = UIMgr:new_widget("grid_view")
  self.grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.grid_view:InitConfig(0, 19, 1)
  self.grid_view:SetMoveAble(false)
  self.ltList:AddChildWindow(self.grid_view)
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function M:onShow(id, status, dx, dy)
  self.grid_view:RemoveAllItems()
  self.config = PokemonTaskConfig:getTaskById(id)
  self.ltClickPosition:SetXPosition({0, dx})
  self.ltClickPosition:SetYPosition({0, dy})
  if dx < self.mid_x then
    self.ltContent:SetHorizontalAlignment(0)
  else
    self.ltContent:SetHorizontalAlignment(2)
  end
  if dy < self.mid_y then
    self.ltContent:SetVerticalAlignment(0)
  else
    self.ltContent:SetVerticalAlignment(2)
  end
  self.stTitle:SetText(Lang:toText(self.config.name))
  self.stDesc:SetText(Lang:toText(self.config.desc))
  for i = 1, #self.config.targets do
    local target = self.config.targets[i]
    local target_id = target[1]
    for j = 1, #status.targets do
      Lib.logDebug("status.targets[j][1] = ", status.targets[j][1])
      Lib.logDebug("target_id = ", target_id)
      if status.targets[j][1] == target_id then
        Lib.logDebug("found task finished = ", status.targets[j][3])
        local node = UIMgr:new_widget("pokemon_task_detail_cell")
        node:invoke("initViewDataWithoutAdapter", id, self.config.type, target, self.config.map[i], self.config.pos[i], status.targets[j][3])
        self.grid_view:AddItem(node, true)
      end
    end
  end
  UI:openWnd("pokemonTaskDetail")
end

function M:onHide()
  UI:closeWnd("pokemonTaskDetail")
end

function M:onOpen()
end

function M:onClose()
  self.config = {}
end

return M
