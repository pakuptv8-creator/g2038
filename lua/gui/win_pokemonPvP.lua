function M:init()
  WinBase.init(self, "PokemonPvP.json", false)
  
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.npcId = -1
end

function M:initWnd()
  self.btnClose = self:child("PokemonPvP-BtnClose")
  self.btnRefresh = self:child("PokemonPvP-BtnRefresh")
  self.btnRefresh:SetVisible(false)
  self.btnAdd = self:child("PokemonPvP-BtnRefresh")
  self.btnAdd:SetVisible(false)
  self.btnChallenge = self:child("PokemonPvP-BtnChallenge")
  self.btnChallengeText = self:child("PokemonPvP-BtnChallenge-Text")
  self.btnChallengeText:SetText(Lang:toText("gui.gym.pvp.challenge"))
  self.stRefreshTime = self:child("PokemonPvP-Refresh-Time")
  self.stRefreshTime:SetVisible(false)
  self.stChallengeInfo = self:child("PokemonPvP-Challenge-Text")
  self.stPlayerTitle = self:child("PokemonPvP-Player-Title")
  self.stPlayerName = self:child("PokemonPvP-Player-Name")
  self.siPlayerAvatar = self:child("PokemonPvP-Player-Avatar")
  self.siPlayerMedal = self:child("PokemonPvP-Player-Medal")
  self.siPlayerMedal:SetVisible(false)
  self.ltPlayerPokemonList = self:child("PokemonPvP-Player-Pokemon-List")
  self.player_pokemon_grid_view = UIMgr:new_widget("grid_view")
  self.player_pokemon_grid_view:SetMoveAble(false)
  self.player_pokemon_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.player_pokemon_grid_view:InitConfig(11, 0, 4)
  self.ltPlayerPokemonList:AddChildWindow(self.player_pokemon_grid_view)
  self.stPlayerPokemonPower = self:child("PokemonPvP-Player-Pokemon-Power")
  self.stRivalTitle = self:child("PokemonPvP-Rival-Title")
  self.stRivalName = self:child("PokemonPvP-Rival-Name")
  self.siRivalAvatar = self:child("PokemonPvP-Rival-Avatar")
  self.siRivalMedal = self:child("PokemonPvP-Rival-Medal")
  self.siRivalMedal:SetVisible(false)
  self.ltRivalPokemonList = self:child("PokemonPvP-Rival-Pokemon-List")
  self.rival_pokemon_grid_view = UIMgr:new_widget("grid_view")
  self.rival_pokemon_grid_view:SetMoveAble(false)
  self.rival_pokemon_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.rival_pokemon_grid_view:InitConfig(11, 0, 4)
  self.ltRivalPokemonList:AddChildWindow(self.rival_pokemon_grid_view)
  self.stRivalPokemonPower = self:child("PokemonPvP-Rival-Pokemon-Power")
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnChallenge, UIEvent.EventButtonClick, function()
    local packet = {
      pid = "npcEnterBattle",
      npcId = self.npcId,
      objId = self.objId
    }
    Lib.logDebug("dialog npcEnterBattle packet = ", Lib.v2s(packet))
    Me:sendPacket(packet)
    self:onHide()
    Me:resetDialog()
  end)
  Lib.subscribeEvent(Event.EVENT_GET_PVP_NPC_POKEMONS, function(isnpc, npcId, userId, power, name, pokemons)
    if isnpc == true then
      local rivalName = "npc_" .. self.npcId .. "_name"
      self.stRivalName:SetText(Lang:toText(rivalName))
    else
      self.stRivalName:SetText(name)
      AsyncProcess.GetUserDetail(userId, function(data)
        Lib.logDebug("GetUserDetail data = ", Lib.v2s(data))
        if data and data.picUrl and #data.picUrl > 0 then
          self.siRivalAvatar:SetImageUrl(data.picUrl)
        end
      end)
    end
    self.stPlayerName:SetText(Me.name or Me.nickName or "")
    AsyncProcess.GetUserDetail(Me.platformUserId, function(data)
      Lib.logDebug("GetUserDetail data = ", Lib.v2s(data))
      if data and data.picUrl and #data.picUrl > 0 then
        self.siPlayerAvatar:SetImageUrl(data.picUrl)
      end
    end)
    Me:getBattlePokemon(function(pokemonList)
      Lib.logDebug("player pokemonList  = ", Lib.v2s(pokemonList))
      self:updatePlayerPokemonList(self.player_pokemon_grid_view, pokemonList)
    end)
    Me:getPlayerPower(function(cp)
      self.stPlayerPokemonPower:SetText("CP:    " .. cp)
    end)
    self:updateNpcPokemonList(self.rival_pokemon_grid_view, pokemons)
    self.stRivalPokemonPower:SetText("CP:    " .. power)
    self.btnChallenge:SetEnabled(true)
    self.btnChallenge:SetTouchable(true)
  end)
end

function M:onShow(npcId, objId)
  self.btnChallenge:SetEnabled(false)
  self.btnChallenge:SetTouchable(false)
  self.player_pokemon_grid_view:RemoveAllItems()
  self.rival_pokemon_grid_view:RemoveAllItems()
  self.npcId = npcId
  self.objId = objId
  local count = Me:getNpcChallenge(self.npcId)
  Lib.logDebug("getNpcChallenge count = ", count)
  self.stChallengeInfo:SetText(Lang:toText({
    "gui.gym.pvp.challenge.info",
    count
  }))
  Me:sendPacket({
    pid = "GetPVPGymPokemons",
    npcId = self.npcId
  })
  UI:openWnd("pokemonPvP")
end

function M:updatePlayerPokemonList(grid_view, pokemonList)
  for index, pokemon in ipairs(pokemonList) do
    local cell = UIMgr:new_widget("pokemon_packet_item_cell")
    cell:SetWidth({0, 96})
    cell:SetHeight({0, 96})
    grid_view:AddItem(cell)
    cell:invoke("updateInfo", pokemon)
  end
end

function M:updateNpcPokemonList(grid_view, pokemonList)
  for index, pokemon in ipairs(pokemonList) do
    local cell = UIMgr:new_widget("pokemon_packet_item_cell")
    cell:SetWidth({0, 96})
    cell:SetHeight({0, 96})
    grid_view:AddItem(cell)
    cell:invoke("initView", pokemon)
  end
end

function M:onHide()
  UI:closeWnd("pokemonPvP")
end

function M:onOpen()
end

function M:onClose()
end

return M
