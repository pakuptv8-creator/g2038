local PokemonConfig = T(Config, "PokemonConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local hInterval = 12
local vInterval = 7
local itemWidth = 128
local itemHeight = 141
local M = _ENV.M

function M:init()
  WinBase.init(self, "PetsBook.json", false)
  self:initUI()
  self:initBookList()
  self:initEvent()
  self:selectBookItem(self.adapter_data[1].cfg)
end

function M:initUI()
  self.lytPokemonBook = self:child("PokemonBook")
  self.imgPokemonBookBG = self:child("PokemonBook-BG")
  self.lytPokemonBookPetsLayout = self:child("PokemonBook-PetsLayout")
  self.imgPokemonBookPetsLayoutBG = self:child("PokemonBook-PetsLayoutBG")
  self.lytPokemonBookPetsList = self:child("PokemonBook-PetsList")
  self.btnPokemonBookBack = self:child("PokemonBook-Back")
  self.txtPokemonBookBackTxt = self:child("PokemonBook-BackTxt")
  self.lytPokemonBookProgressLayout = self:child("PokemonBook-ProgressLayout")
  self.lytPokemonBookPetsShowLayout = self:child("PokemonBook-PetsShowLayout")
  self.lytPokemonBookLeftLayout = self:child("PokemonBook-LeftLayout")
  self.lytPokemonBookRightLayout = self:child("PokemonBook-RightLayout")
  self.txtPokemonProgressTxt = self:child("PokemonBook-ProgressTxt")
  self.txtPokemonProgressNumTxt = self:child("PokemonBook-ProgressNumTxt")
  self.txtPokemonProgressTxt:SetText(Lang:toText("progress_title") .. " :")
  self.actEntityWindow = self:child("PokemonBook-EntityWindow")
  self.imgShadow = self:child("PokemonBook-Shadow")
  self.btnSeeDetails = self:child("PokemonBook-SeeDetailsBtn")
  self.btnNotObtained = self:child("PokemonBook-NotObtainedBtn")
  self.txtNoPokemon = self:child("PokemonBook-NoPokemonTxt")
  self.imgNoPokemon = self:child("PokemonBook-NoPokemonImg")
  self.txtNoPokemon:SetText(Lang:toText("no_pokemon_tip"))
  self.btnSeeDetails:SetText(Lang:toText("see_details"))
  self.btnNotObtained:SetText(Lang:toText("not_obtained"))
  self.petsGv = UIMgr:new_widget("grid_view")
  self.lytPokemonBookPetsList:AddChildWindow(self.petsGv)
  self.petsGv:SetAutoColumnCount(false)
  self.petsGv:SetItemAlignment(1)
  self.petsGv:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.adapter = UIMgr:new_adapter("pokemon_book", itemWidth, itemHeight)
  self.petsGv:invoke("setAdapter", self.adapter)
  self.txtPokemonBookBackTxt:SetText(Lang:toText("book_title"))
end

function M:initBookList()
  local width = self.lytPokemonBookPetsList:GetPixelSize().x
  local itemCount = math.floor((width + hInterval) / (itemWidth + hInterval))
  self.petsGv:InitConfig(hInterval, vInterval, itemCount)
  self.adapter_data = {}
  local pokemon_configs = PokemonConfig:getAllConfig()
  for _, config in pairs(pokemon_configs) do
    if config.bookId ~= 0 then
      table.insert(self.adapter_data, {
        cfg = config,
        select = false,
        lock = true,
        isPetBookWnd = true,
        clickCallBack = function()
          self:selectBookItem(config)
        end
      })
    end
  end
  table.sort(self.adapter_data, function(a, b)
    return a.cfg.bookId < b.cfg.bookId
  end)
  self.adapter:setData(self.adapter_data)
  self:updateBookList(Me:getValue("bookRecord"))
end

function M:initEvent()
  self:subscribe(self.btnPokemonBookBack, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnSeeDetails, UIEvent.EventButtonClick, function()
    for _, data in pairs(self.adapter_data) do
      if data.select then
        UI:openWnd("bookDetails", data.cfg.id)
        break
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_GET_PET_COLLECT, function(bookRecord)
    self:updateBookList(bookRecord)
  end)
end

function M:updateBookList(bookRecord)
  local unLockCount = 0
  for _, data in pairs(self.adapter_data) do
    local pokemon_config = data.cfg
    if bookRecord[tostring(pokemon_config.id)] then
      data.lock = false
      unLockCount = unLockCount + 1
    end
  end
  self.txtPokemonProgressNumTxt:SetText(unLockCount .. "/" .. #self.adapter_data)
  self.adapter:notifyDataChange()
end

function M:onHide()
  UI:closeWnd("petsBook")
end

function M:updatePetShowItem(pokemon)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(pokemon.fullName)
  local pokemon_config = PokemonConfig:getConfigById(pokemon.id)
  self.actEntityWindow:SetActor1(entity_cfg.actorName, "idle")
  self.actEntityWindow:SetActorScale(pokemon_config.uiScale)
  self.actEntityWindow:SetRotateY(-40)
  self.actEntityWindow:SetRotateX(10)
  if getmetatable(self.actEntityWindow).SetActorOffset then
    self.actEntityWindow:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
end

function M:selectBookItem(pokemon_config)
  for _, data in pairs(self.adapter_data) do
    data.select = data.cfg == pokemon_config
  end
  UIRedDotMgr.petBookItemRedState[pokemon_config.id] = 1
  self.adapter:notifyDataChange()
  self:updatePetShowItem(pokemon_config)
end

return M
