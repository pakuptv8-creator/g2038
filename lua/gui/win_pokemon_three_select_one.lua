local PokemonConfig = T(Config, "PokemonConfig")
local TriggerGiftConfig = T(Config, "TriggerGiftConfig")

function M:init()
  WinBase.init(self, "pokemon_three_select_one.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonThreeSelectOneMask = self:child("pokemon_three_select_one-Mask")
  self.imgPokemonThreeSelectOneBg = self:child("pokemon_three_select_one-Bg")
  self.txtPokemonThreeSelectOneTitle = self:child("pokemon_three_select_one-Title")
  self.txtPokemonThreeSelectOneTitle:SetText(Lang:toText("gui_three_select_one"))
  self.lytPets = self:child("pokemon_three_select_one-petContent")
  self.gvPokemonThreeSelectOnePetList = UIMgr:new_widget("grid_view")
  self.gvPokemonThreeSelectOnePetList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPokemonThreeSelectOnePetList:InitConfig(25, 10, 3)
  self.lytPets:AddChildWindow(self.gvPokemonThreeSelectOnePetList)
  self.pokemonListAdapter = UIMgr:new_adapter("pokemon_book", 120, 150)
  self.gvPokemonThreeSelectOnePetList:invoke("setAdapter", self.pokemonListAdapter)
  self.btnPokemonThreeSelectOneSelect = self:child("pokemon_three_select_one-select")
  self:root():SetAlwaysOnTop(true)
end

function M:initEvent()
  self:subscribe(self.btnPokemonThreeSelectOneSelect, UIEvent.EventButtonClick, function()
    if self.isJustShow then
      self:onHide()
      return
    end
    if self.selectPet then
      if not self.isJustShow then
        Me:sendSelectThreeSelOne(self.selectPet)
      end
      self:onHide()
    end
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd("pokemon_three_select_one")
end

function M:onShow(targetGiftId, isJustShow)
  local pokemonList, starLevel
  if type(targetGiftId) == "number" then
    pokemonList, starLevel = self:getGiftItemsInfo(targetGiftId)
  elseif type(targetGiftId) == "table" then
    pokemonList = targetGiftId
  end
  if pokemonList then
    if not UI:isOpen(self) then
      self.adapter_data = {}
      self.selectPet = false
      for idx, petId in pairs(pokemonList) do
        local config = PokemonConfig:getConfigById(petId)
        if config.bookId ~= 0 then
          table.insert(self.adapter_data, {
            cfg = config,
            select = false,
            lock = false,
            starLevel = starLevel,
            clickCallBack = function()
              if self.isJustShow then
                UI:getWnd("pokemonLuckyDetails"):onShow(true, petId)
              else
                self:selectActivePet(petId, idx)
              end
            end
          })
        end
      end
      self.pokemonListAdapter:setData(self.adapter_data)
      self.isJustShow = isJustShow
      UI:openWnd("pokemon_three_select_one")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:getGiftItemsInfo(targetGiftId)
  local giftItemsInfo = TriggerGiftConfig:getGiftItemsInfoById(targetGiftId)
  local pokemonList, starLevel
  for i, info in pairs(giftItemsInfo) do
    if info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.PET and type(info.item) == "table" then
      pokemonList = info.item
      starLevel = info.petStarLevel
    end
  end
  return pokemonList, starLevel
end

function M:selectActivePet(petId, idx)
  self.selectPet = petId
  for _, data in pairs(self.adapter_data) do
    data.select = false
  end
  self.adapter_data[idx].select = true
  self.pokemonListAdapter:setData(self.adapter_data)
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
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
