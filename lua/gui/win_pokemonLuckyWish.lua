local WinPokemonLuckyWish = M
local PokemonLuckyPkmConfig = T(Config, "PokemonLuckyPkmConfig")
local PokemonConfig = T(Config, "PokemonConfig")

function WinPokemonLuckyWish:init()
  WinBase.init(self, "PokemonLuckyWish.json")
  self:initUI()
  self:initEvent()
end

function WinPokemonLuckyWish:initUI()
  self.imgMask = self:child("PokemonLuckyWish-Mask")
  self.lytBg = self:child("PokemonLuckyWish-Bg")
  self.imgTopBg = self:child("PokemonLuckyWish-topBg")
  self.txtTitle = self:child("PokemonLuckyWish-Title")
  self.imgListBg = self:child("PokemonLuckyWish-listBg")
  self.lytPkmList = self:child("PokemonLuckyWish-pkmList")
  self.btnCloseBtn = self:child("PokemonLuckyWish-closeBtn")
  self.imgPooTab3 = self:child("PokemonLuckyWish-pooTab3")
  self.txtTabTitle3 = self:child("PokemonLuckyWish-tabTitle3")
  self.imgPooTab2 = self:child("PokemonLuckyWish-pooTab2")
  self.txtTabTitle2 = self:child("PokemonLuckyWish-tabTitle2")
  self.imgPooTab1 = self:child("PokemonLuckyWish-pooTab1")
  self.txtTabTitle1 = self:child("PokemonLuckyWish-tabTitle1")
  self.lytDescPanel = self:child("PokemonLuckyWish-descPanel")
  self.txtDescTxt = self:child("PokemonLuckyWish-descTxt")
  self.gvDescTxt = UIMgr:new_widget("grid_view")
  self.lytDescPanel:AddChildWindow(self.gvDescTxt)
  self.gvDescTxt:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvDescTxt:InitConfig(0, 5, 1)
  self.gvDescTxt:AddItem(self.txtDescTxt)
  self.txtTitle:SetText(Lang:toText("gui_lucky_egg_wish_title"))
  self.txtTabTitle1:SetText(Lang:toText("gui_lucky_egg_card_pool_tab1"))
  self.txtTabTitle2:SetText(Lang:toText("gui_lucky_egg_card_pool_tab2"))
  self.txtTabTitle3:SetText(Lang:toText("gui_lucky_egg_card_pool_tab3"))
  self.pkmGridView = UIMgr:new_widget("grid_view", self.lytPkmList)
  self.pkmGridView:SetAutoColumnCount(false)
  self.pkmGridView:InitConfig(20, 11, 6)
  self.pkmAdapter = UIMgr:new_adapter("pokemonLuckyWishItem", 122, 135)
  self.pkmGridView:invoke("setAdapter", self.pkmAdapter)
  self.lytWishSelectItem = {}
  for i = 1, 3 do
    local lytWishSelect = self:child("PokemonLuckyWish-wishSelect" .. i)
    self.lytWishSelectItem[i] = UIMgr:new_widget("pokemonLuckyWishSelect")
    self.lytWishSelectItem[i]:invoke("updateWishState", 1)
    
    local function wishClickCallFunc()
      self:clickWishSelectItem(i)
    end
    
    self.lytWishSelectItem[i]:invoke("initClickCallFunc", wishClickCallFunc)
    lytWishSelect:AddChildWindow(self.lytWishSelectItem[i])
  end
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytBg, 935, 656)
end

function WinPokemonLuckyWish:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:updatePlayerWish()
    self:onHide()
  end)
  self:subscribe(self.imgMask, UIEvent.EventWindowClick, function()
    self:updatePlayerWish()
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

function WinPokemonLuckyWish:subscribeEvent()
end

function WinPokemonLuckyWish:initView(poolId)
  self.curPoolId = poolId
  local LuckyCardPoolTopRes = {
    [1] = "set:pokemon_lucky_egg.json image:img_9_boxtop_red",
    [2] = "set:pokemon_lucky_egg.json image:img_9_boxtop_yellow",
    [3] = "set:pokemon_lucky_egg.json image:img_9_boxtop_blue"
  }
  self.imgTopBg:SetImage(LuckyCardPoolTopRes[poolId])
  self.txtDescTxt:SetText(Lang:toText("gui_lucky_egg_wish_desc" .. poolId))
  self.curWishState = {
    0,
    0,
    0
  }
  self.curWishList = Lib.copy(Me:getLuckyEggWish())[self.curPoolId] or {}
  self:initTabPkmList(poolId)
  self.curSelectTab = 3
  self:updateTabViewShow()
  self:initWishSelectShow()
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
    
    function config.selectCallFunc()
      self:wishItemSelectFunc(val.pkm_id)
    end
    
    table.insert(self.pkmQualityList[config.quality], config)
  end
  self:setReverseTable()
end

function M:setReverseTable()
  for quality, pkmList in pairs(self.pkmQualityList) do
    local tmp = {}
    for i = 1, #pkmList do
      local key = #pkmList + 1 - i
      tmp[i] = pkmList[key]
    end
    self.pkmQualityList[quality] = tmp
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
  self:updatePkmListSelectState()
end

function WinPokemonLuckyWish:initWishSelectShow()
  for key, val in pairs(self.curWishList) do
    self.curWishState[key] = 2
  end
  for wishId = 1, 3 do
    self:updateWishSelectShow(wishId)
  end
  self:updatePkmListSelectState()
end

function WinPokemonLuckyWish:updateWishSelectShow(wishId)
  self.lytWishSelectItem[wishId]:invoke("updateWishState", self.curWishState[wishId])
  if self.curWishState[wishId] == 2 then
    self.lytWishSelectItem[wishId]:invoke("updateWishItemData", self.curWishList[wishId])
  end
end

function WinPokemonLuckyWish:clickWishSelectItem(wishId)
  self.curWishState[wishId] = 1
  self.curWishList[wishId] = nil
  self:updateWishSelectShow(wishId)
  self:updatePkmListSelectState()
end

function WinPokemonLuckyWish:wishItemSelectFunc(id)
  local clickISWished = false
  for wishId = 1, 3 do
    if self.curWishList[wishId] == id then
      clickISWished = wishId
    end
  end
  if clickISWished then
    self.curWishState[clickISWished] = 1
    self.curWishList[clickISWished] = nil
    self:updateWishSelectShow(clickISWished)
    self:updatePkmListSelectState()
  else
    local curWishId = self:getCurNullWishId()
    if not curWishId then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_lucky_egg_wish_full"), 60)
      return
    end
    self.curWishState[curWishId] = 2
    self.curWishList[curWishId] = id
    self:updateWishSelectShow(curWishId)
    self:updatePkmListSelectState()
  end
end

function WinPokemonLuckyWish:updatePkmListSelectState()
  local count = self.pkmGridView:invoke("CHILD_COUNT")
  for i = 1, count do
    local item = self.pkmGridView:invoke("GET_ITEM", i - 1)
    if item then
      item:invoke("updateMaskIcon", false)
      for wishId = 1, 3 do
        if item:invoke("getItemPkmId") == self.curWishList[wishId] then
          item:invoke("updateMaskIcon", true)
        end
      end
    end
  end
end

function WinPokemonLuckyWish:getCurNullWishId()
  for wishId = 1, 3 do
    if self.curWishList[wishId] == nil then
      return wishId
    end
  end
  return false
end

function WinPokemonLuckyWish:updatePlayerWish()
  local initEggWish = Me:getLuckyEggWish()
  for i = 1, 3 do
    if initEggWish[self.curPoolId] and initEggWish[self.curPoolId][i] ~= self.curWishList[i] then
      Me:gameBehaviorReport("Fountain_0" .. i, self.curWishList[i])
    end
  end
  initEggWish[self.curPoolId] = self.curWishList
  Me:setLuckyEggWish(initEggWish)
end

function WinPokemonLuckyWish:onHide()
  UI:closeWnd("pokemonLuckyWish")
end

function WinPokemonLuckyWish:onShow(isShow, poolId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLuckyWish", poolId)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPokemonLuckyWish:onOpen(poolId)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(poolId)
end

function WinPokemonLuckyWish:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPokemonLuckyWish
