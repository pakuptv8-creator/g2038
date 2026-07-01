local GymConfig = T(Config, "GymConfig")
local RegionConfig = T(Config, "RegionConfig")

function M:init()
  WinBase.init(self, "PokemonTelegraph.json", false)
  self:root():SetLevel(2)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
end

function M:initWnd()
  self.btnClose = self:child("PokemonTelegraph-BtnClose")
  self.siTitle = self:child("PokemonTelegraph-Title-Text")
  self.siTitle:SetText(Lang:toText("gui.telegraph.title"))
  self.siTip = self:child("PokemonTelegraph-Tip-Text")
  self.siTip:SetText(Lang:toText("gui.telegraph.tip"))
  self.ltRegionList = self:child("PokemonTelegraph-Region-List")
  self.region_grid_view = UIMgr:new_widget("grid_view")
  self.region_grid_view:SetMoveAble(false)
  self.region_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.region_grid_view:InitConfig(0, 27, 1)
  self.ltRegionList:AddChildWindow(self.region_grid_view)
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:onShow(gyms)
  self.region_grid_view:RemoveAllItems()
  for i = 1, #gyms do
    local gym_id = gyms[i]
    local gym_config = GymConfig:getGymById(gym_id)
    if gym_config then
      local node = UIMgr:new_widget("pokemon_telegraph_detail_cell")
      node:invoke("initViewDataWithoutAdapter", gym_id, gym_config.name, gym_config.in_region_id, gym_config.is_team, gym_config.unlock)
      self.region_grid_view:AddItem(node, true)
    end
  end
  UI:openWnd("pokemonTelegraph")
end

function M:onHide()
  UI:closeWnd("pokemonTelegraph")
end

function M:onOpen()
  Lib.logDebug("onOpen")
end

function M:onClose()
  Lib.logDebug("onClose")
end

return M
