local PokemonLuckyPkmConfig = T(Config, "PokemonLuckyPkmConfig")
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  WinBase.init(self, "PokemonLuckyPool.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgMask = self:child("PokemonLuckyPool-Mask")
  self.lytBg = self:child("PokemonLuckyPool-Bg")
  self.imgTopBg = self:child("PokemonLuckyPool-topBg")
  self.txtTitle = self:child("PokemonLuckyPool-Title")
  self.imgListBg = self:child("PokemonLuckyPool-listBg")
  self.lytPkmList = self:child("PokemonLuckyPool-pkmList")
  self.btnCloseBtn = self:child("PokemonLuckyPool-closeBtn")
  self.imgPooTab1 = self:child("PokemonLuckyPool-pooTab1")
  self.txtTabTitle1 = self:child("PokemonLuckyPool-tabTitle1")
  self.imgPooTab2 = self:child("PokemonLuckyPool-pooTab2")
  self.txtTabTitle2 = self:child("PokemonLuckyPool-tabTitle2")
  self.imgPooTab3 = self:child("PokemonLuckyPool-pooTab3")
  self.txtTabTitle3 = self:child("PokemonLuckyPool-tabTitle3")
  self.txtTitle:SetText(Lang:toText("gui_lucky_egg_card_pool_title"))
  self.txtTabTitle1:SetText(Lang:toText("gui_lucky_egg_card_pool_tab1"))
  self.txtTabTitle2:SetText(Lang:toText("gui_lucky_egg_card_pool_tab2"))
  self.txtTabTitle3:SetText(Lang:toText("gui_lucky_egg_card_pool_tab3"))
  self.pkmGridView = UIMgr:new_widget("grid_view", self.lytPkmList)
  self.pkmGridView:SetAutoColumnCount(false)
  self.pkmGridView:InitConfig(78, 29, 4)
  self.pkmAdapter = UIMgr:new_adapter("pokemonLuckyPoolItem", 136, 170)
  self.pkmGridView:invoke("setAdapter", self.pkmAdapter)
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytBg, 910, 577)
end

function M:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.imgPooTab1, UIEvent.EventWindowClick, function()
    self.curSelectTab = 1
    self:updateTabViewShow()
  end)
  self:subscribe(self.imgPooTab2, UIEvent.EventWindowClick, function()
    self.curSelectTab = 2
    self:updateTabViewShow()
  end)
  self:subscribe(self.imgPooTab3, UIEvent.EventWindowClick, function()
    self.curSelectTab = 3
    self:updateTabViewShow()
  end)
end

function M:subscribeEvent()
end

function M:initView(poolId)
  self.curPoolId = poolId
  local LuckyCardPoolTopRes = {
    [1] = "set:pokemon_lucky_egg.json image:img_9_boxtop_red",
    [2] = "set:pokemon_lucky_egg.json image:img_9_boxtop_yellow",
    [3] = "set:pokemon_lucky_egg.json image:img_9_boxtop_blue"
  }
  self.imgTopBg:SetImage(LuckyCardPoolTopRes[poolId])
  self:initTabPkmList(poolId)
  self.curSelectTab = 3
  self:updateTabViewShow()
end

function M:initTabPkmList(poolId)
  self.pkmQualityList = {}
  local allPkmList = PokemonLuckyPkmConfig:getDataByPoolId(poolId)
  for key, val in pairs(allPkmList) do
    local config = Lib.copy(PokemonConfig:getConfigById(val.pkm_id))
    if not self.pkmQualityList[config.quality] then
      self.pkmQualityList[config.quality] = {}
    end
    if val.star and val.star > 0 then
      config.newStar = val.star
    end
    table.insert(self.pkmQualityList[config.quality], config)
  end
end

function M:updateTabViewShow()
  local LuckyCardPoolTabRes = {
    [1] = "set:pokemon_lucky_egg.json image:tgl_0_right_",
    [2] = "set:pokemon_lucky_egg.json image:tgl_0_mid_",
    [3] = "set:pokemon_lucky_egg.json image:tgl_0_left_"
  }
  for i = 1, 3 do
    if i == self.curSelectTab then
      self["imgPooTab" .. i]:SetImage(LuckyCardPoolTabRes[i] .. "over")
    else
      self["imgPooTab" .. i]:SetImage(LuckyCardPoolTabRes[i] .. "on")
    end
  end
  local pkmList = self.pkmQualityList[self.curSelectTab] or {}
  self.pkmAdapter:clearItems()
  self.pkmGridView:ResetPos()
  for _, data in pairs(pkmList) do
    self.pkmAdapter:addItem(data)
  end
end

function M:onHide()
  UI:closeWnd("pokemonLuckyPool")
end

function M:onShow(isShow, poolId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLuckyPool", poolId)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(poolId)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(poolId)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
