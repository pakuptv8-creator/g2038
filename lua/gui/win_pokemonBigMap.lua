local MapConfig = T(Config, "MapConfig")
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonBigMap.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.curSelectMap = -1
end

function M:initWnd()
  self.btnClose = self:child("PokemonBigMap-BtnClose")
  self.ltRegion1 = self:child("PokemonBigMap-Region-1")
  self.stRegion1Selected = self:child("PokemonBigMap-Region-1-Selected")
  self.stRegion1Lock = self:child("PokemonBigMap-Region-1-Lock")
  self.ltRegion2 = self:child("PokemonBigMap-Region-2")
  self.stRegion2Selected = self:child("PokemonBigMap-Region-2-Selected")
  self.stRegion2Lock = self:child("PokemonBigMap-Region-2-Lock")
  self.ltRegion3 = self:child("PokemonBigMap-Region-3")
  self.stRegion3Selected = self:child("PokemonBigMap-Region-3-Selected")
  self.stRegion3Lock = self:child("PokemonBigMap-Region-3-Lock")
  self.ltRegion4 = self:child("PokemonBigMap-Region-4")
  self.stRegion4Selected = self:child("PokemonBigMap-Region-4-Selected")
  self.stRegion4Lock = self:child("PokemonBigMap-Region-4-Lock")
  self.ltRegion5 = self:child("PokemonBigMap-Region-5")
  self.stRegion5Selected = self:child("PokemonBigMap-Region-5-Selected")
  self.stRegion5Lock = self:child("PokemonBigMap-Region-5-Lock")
  self.ltRegion6 = self:child("PokemonBigMap-Region-6")
  self.stRegion6Selected = self:child("PokemonBigMap-Region-6-Selected")
  self.stRegion6Lock = self:child("PokemonBigMap-Region-6-Lock")
  self.stTitle = self:child("PokemonBigMap-Info-Title")
  self.stLevel = self:child("PokemonBigMap-Info-Level")
  self.stDesc = self:child("PokemonBigMap-Info-Desc")
  self.stOutputTitle = self:child("PokemonBigMap-Output-Title")
  self.stOutputPokemon = self:child("PokemonBigMap-Output-Pokemon")
  self.lyItem = self:child("PokemonBigMap-Item-Layout")
  self.item_grid_view = UIMgr:new_widget("grid_view")
  self.item_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.item_grid_view:InitConfig(26, 0, 4)
  self.item_grid_view:SetMoveAble(false)
  self.lyItem:AddChildWindow(self.item_grid_view)
  self.stPokemonTitle = self:child("PokemonBigMap-Pokemon-Title")
  self.lyPokemon = self:child("PokemonBigMap-Pokemon-Layout")
  self.pokemon_grid_view = UIMgr:new_widget("grid_view")
  self.pokemon_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.pokemon_grid_view:InitConfig(26, 0, 4)
  self.pokemon_grid_view:SetMoveAble(true)
  self.pokemon_grid_view:SetvScorllMoveAble(false)
  self.pokemon_grid_view:SethScorllMoveAble(true)
  self.lyPokemon:AddChildWindow(self.pokemon_grid_view)
  self.btnTelegraph = self:child("PokemonBigMap-BtnTelegraph")
  self.stTelegraph = self:child("PokemonBigMap-TextTelegraph")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap btnClose event : EventButtonClick", self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap btnTelegraph event : EventButtonClick", self.btnTelegraph, UIEvent.EventButtonClick, function()
    if Me:isJoinTeam() then
      if Me:isTeamCaptain() then
        Me:sendPacket({
          pid = "CheckTeamateTelegraph",
          mapId = self.curSelectMap
        })
      else
        Lib.logDebug("cannot telegraph")
      end
    else
      local status = Me:getMapUnlock(self.curSelectMap)
      if status == 1 then
        UI:getWnd("pokemonTransitionMap"):onShow()
        Me:sendPacket({
          pid = "TelegraphToMap",
          mapId = self.curSelectMap
        })
      end
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap ltRegion1 event : EventWindowClick", self.ltRegion1, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("change_scene")
    Lib.logDebug("ltRegion1")
    self:selectMap(1)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap ltRegion2 event : EventWindowClick", self.ltRegion2, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("change_scene")
    Lib.logDebug("ltRegion2")
    self:selectMap(2)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap ltRegion3 event : EventWindowClick", self.ltRegion3, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("change_scene")
    Lib.logDebug("ltRegion3")
    self:selectMap(3)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap ltRegion4 event : EventWindowClick", self.ltRegion4, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("change_scene")
    Lib.logDebug("ltRegion4")
    self:selectMap(4)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap ltRegion5 event : EventWindowClick", self.ltRegion5, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("change_scene")
    Lib.logDebug("ltRegion5")
    self:selectMap(5)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonBigMap ltRegion6 event : EventWindowClick", self.ltRegion6, UIEvent.EventWindowClick, function()
    Me:playSoundByKey("change_scene")
    Lib.logDebug("ltRegion6")
    self:selectMap(6)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBigMap Lib event : EVENT_PLAYER_LEVEL_UP", Event.EVENT_PLAYER_LEVEL_UP, function(lv, unlockMod)
    self.btnTelegraph:SetVisible(unlockMod[Define.MODULE_TYPE.MAP_TRANSFER])
  end)
end

function M:onShow(pokemon)
  if Me:isJoinTeam() and Me:isTeamCaptain() then
    Me:sendPacket({
      pid = "ShowViewMapTip"
    })
  end
  local playerPosition = Me:getPosition()
  Lib.logDebug("getMapUnlockByPos playerPosition = ", playerPosition)
  local mapIndex = Lib.getCurMapIndex(playerPosition)
  self.curSelectMap = mapIndex
  self:selectMap(self.curSelectMap)
  UI:openWnd("pokemonBigMap")
end

function M:onHide()
  UI:closeWnd("pokemonBigMap")
end

function M:selectMap(mapId)
  self.curSelectMap = mapId
  self:hideAlllSelected()
  if self.curSelectMap == 1 then
    self.stRegion1Selected:SetVisible(true)
  elseif self.curSelectMap == 2 then
    self.stRegion2Selected:SetVisible(true)
  elseif self.curSelectMap == 3 then
    self.stRegion3Selected:SetVisible(true)
  elseif self.curSelectMap == 4 then
    self.stRegion4Selected:SetVisible(true)
  elseif self.curSelectMap == 5 then
    self.stRegion5Selected:SetVisible(true)
  elseif self.curSelectMap == 6 then
    self.stRegion6Selected:SetVisible(true)
  end
  local map_config = MapConfig:getMapById(mapId)
  Lib.logDebug("map_config = ", Lib.v2s(map_config))
  self.stTitle:SetText(Lang:toText(map_config.title or ""))
  if 1 < mapId then
    self.stLevel:SetText(Lang:toText({
      "map_recommended_level",
      map_config.level[1],
      map_config.level[2]
    }))
  else
    self.stLevel:SetText("")
    self.stOutputPokemon:SetText("")
  end
  self.stOutputTitle:SetText(Lang:toText("map_output"))
  self.stPokemonTitle:SetText(Lang:toText("map_pokemon"))
  self.stDesc:SetText(Lang:toText(map_config.desc or ""))
  self.stTelegraph:SetText(Lang:toText("ui_telegraph"))
  self.pokemon_grid_view:RemoveAllItems()
  for i = 1, #map_config.pokemon_list do
    local pokemon_id = map_config.pokemon_list[i]
    local node = UIMgr:new_widget("pokemon_icon_cell")
    node:invoke("initById", pokemon_id)
    self.pokemon_grid_view:InitConfig(26, 0, #map_config.pokemon_list)
    self.pokemon_grid_view:AddItem(node, true)
    for _, index in pairs(map_config.pokemon_list_effect) do
      if i == index then
        node:invoke("showEffect", true)
      end
    end
  end
  self.item_grid_view:RemoveAllItems()
  for i = 1, #map_config.item_list do
    local item_full_name = map_config.item_list[i]
    local node = UIMgr:new_widget("pokemon_item_cell")
    node:invoke("initViewDataWithoutAdapter", item_full_name, "")
    self.item_grid_view:InitConfig(13, 0, #map_config.item_list)
    local itemWidth = 60
    node:SetArea({0, 0}, {0, 0}, {0, itemWidth}, {0, itemWidth})
    print("itemWidthitemWidth:", itemWidth)
    self.item_grid_view:AddItem(node, true)
    for _, index in pairs(map_config.item_list_effect) do
      if i == index then
        node:invoke("showEffect", true)
      end
    end
  end
  if not Me:isJoinTeam() or Me:isJoinTeam() and Me:isTeamCaptain() then
    self:checkTelegraph()
  else
    self.btnTelegraph:SetEnabled(false)
    self.btnTelegraph:SetTouchable(false)
  end
end

function M:checkTelegraph()
  local status = Me:getMapUnlock(self.curSelectMap)
  if status == 0 then
    self.btnTelegraph:SetEnabled(false)
    self.btnTelegraph:SetTouchable(false)
  elseif status == 1 then
    self.btnTelegraph:SetEnabled(true)
    self.btnTelegraph:SetTouchable(true)
  end
end

function M:hideAlllSelected()
  self.stRegion1Selected:SetVisible(false)
  self.stRegion2Selected:SetVisible(false)
  self.stRegion3Selected:SetVisible(false)
  self.stRegion4Selected:SetVisible(false)
  self.stRegion5Selected:SetVisible(false)
  self.stRegion6Selected:SetVisible(false)
end

function M:onOpen()
  for i = 1, 6 do
    local status = Me:getMapUnlock(i)
    Lib.logDebug("map status = ", status)
    if status == 0 then
      if i == 1 then
        self.stRegion1Lock:SetVisible(true)
        self.ltRegion1:SetDrawColor({
          0.49019607843137253,
          0.49019607843137253,
          0.49019607843137253,
          1
        })
      elseif i == 2 then
        self.stRegion2Lock:SetVisible(true)
        self.ltRegion2:SetDrawColor({
          0.49019607843137253,
          0.49019607843137253,
          0.49019607843137253,
          1
        })
      elseif i == 3 then
        self.stRegion3Lock:SetVisible(true)
        self.ltRegion3:SetDrawColor({
          0.49019607843137253,
          0.49019607843137253,
          0.49019607843137253,
          1
        })
      elseif i == 4 then
        self.stRegion4Lock:SetVisible(true)
        self.ltRegion4:SetDrawColor({
          0.49019607843137253,
          0.49019607843137253,
          0.49019607843137253,
          1
        })
      elseif i == 5 then
        self.stRegion5Lock:SetVisible(true)
        self.ltRegion5:SetDrawColor({
          0.49019607843137253,
          0.49019607843137253,
          0.49019607843137253,
          1
        })
      elseif i == 6 then
        self.stRegion6Lock:SetVisible(true)
        self.ltRegion6:SetDrawColor({
          0.49019607843137253,
          0.49019607843137253,
          0.49019607843137253,
          1
        })
      end
    elseif status == 1 then
      if i == 1 then
        self.stRegion1Lock:SetVisible(false)
        self.ltRegion1:SetDrawColor({
          1.0,
          1.0,
          1.0,
          1
        })
      elseif i == 2 then
        self.stRegion2Lock:SetVisible(false)
        self.ltRegion2:SetDrawColor({
          1.0,
          1.0,
          1.0,
          1
        })
      elseif i == 3 then
        self.stRegion3Lock:SetVisible(false)
        self.ltRegion3:SetDrawColor({
          1.0,
          1.0,
          1.0,
          1
        })
      elseif i == 4 then
        self.stRegion4Lock:SetVisible(false)
        self.ltRegion4:SetDrawColor({
          1.0,
          1.0,
          1.0,
          1
        })
      elseif i == 5 then
        self.stRegion5Lock:SetVisible(false)
        self.ltRegion5:SetDrawColor({
          1.0,
          1.0,
          1.0,
          1
        })
      elseif i == 6 then
        self.stRegion6Lock:SetVisible(false)
        self.ltRegion6:SetDrawColor({
          1.0,
          1.0,
          1.0,
          1
        })
      end
    end
  end
end

function M:onClose()
  self.curSelectMap = -1
  if Me:isJoinTeam() and Me:isTeamCaptain() then
    Me:sendPacket({
      pid = "HideViewMapTip"
    })
  end
end

return M
