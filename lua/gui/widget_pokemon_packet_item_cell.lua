local PokemonConfig = T(Config, "PokemonConfig")
local NPCPokemonConfig = T(Config, "NPCPokemonConfig")
local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")

function M:init()
  widget_base.init(self, "pokemon_packet_item_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonPacketItemCellMainLayout = self:child("pokemon_packet_item_cell-MainLayout")
  self.imgPokemonPacketItemCellIcon = self:child("pokemon_packet_item_cell-Icon")
  self.imgPokemonPacketItemCellRaceIcon = self:child("pokemon_packet_item_cell-RaceIcon")
  self.txtPokemonPacketItemCellLevel = self:child("pokemon_packet_item_cell-Level")
  self.txtPokemonPacketItemCellLevelBg = self:child("pokemon_packet_item_cell-Level-Bg")
  self.imgPokemonPacketItemCellInTeam = self:child("pokemon_packet_item_cell-InTeam")
  self.lytPokemonPacketItemCellLocked = self:child("pokemon_packet_item_cell-lock")
  self.imgPokemonPacketItemCellSelected = self:child("pokemon_packet_item_cell-Selected")
  self.imgPokemonPacketItemFrame = self:child("pokemon_packet_item_cell-frame")
  self.txtInTeam = self:child("pokemon_packet_item_cell-InTeamTxt")
  self.txtInTeam:SetText(Lang:toText("gui.inTeam"))
  self.imgPokemonPacketItemStarLevel = self:child("pokemon_packet_item_cell-Star-Level")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.itemStarLevel:invoke("setGreyStarVisible", true)
  self.imgPokemonPacketItemStarLevel:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", -0.5)
  self.redPoint = UIRedDotMgr:createOneRedNodeSignal(nil, self._root, 2, -2)
  self.redPoint:SetVisible(false)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemon_packet_item_cell _root event : EventWindowClick", self._root, UIEvent.EventWindowClick, function()
    if self.pokemon then
      self.pokemon:setIsNewRedPointShow(false)
    end
    if self.clickCallBack then
      self.clickCallBack(self)
      return
    end
  end)
  self.dataChangeFunc = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_packet_item_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if self.pokemon and tostring(objId) == tostring(self.pokemon:getObjId()) then
      self:updateInfo(self.pokemon)
    end
  end)
end

function M:getPokemon()
  return self.pokemon
end

function M:getLevelItem()
  return self.txtPokemonPacketItemCellLevel
end

function M:onDataChanged(data)
  self.checkCanBless = data.checkCanBless
  self.clickCallBack = data.clickCallBack
  self:updateInfo(data.pokemon)
  self:onChecked(data.isChecked or false)
  if data.checkInTeam then
    self:checkInTeam()
  end
  if data.checkLocked then
    self:checkLocked()
  end
  if data.checkIsNew and data.pokemon then
    self:checkIsNew(data.pokemon)
  end
  if data.checkCanBless and data.pokemon then
    self:checkShowBlessRedPoint(data.pokemon)
  end
end

function M:onChecked(isChecked)
  self.imgPokemonPacketItemCellSelected:SetVisible(isChecked)
end

function M:checkInTeam()
  self.imgPokemonPacketItemCellInTeam:SetVisible(false)
  local battlePetList = Me:getValue("battlePetList")
  for _, objId in pairs(battlePetList) do
    if objId == self.pokemon:getObjId() then
      self.imgPokemonPacketItemCellInTeam:SetVisible(true)
      break
    end
  end
end

function M:checkIsNew(pokemon)
  self.redPoint:SetVisible(pokemon:getIsNewRedPointShow())
end

function M:checkShowBlessRedPoint(pokemon)
  self.redPoint:SetVisible(pokemon:getCanBlessRedPointShow())
end

function M:checkLocked()
  self.lytPokemonPacketItemCellLocked:SetVisible(not Me:isInTeam(self.pokemon:getObjId()) and self.pokemon:isLocked())
end

function M:updateInfo(pokemon)
  self.pokemon = pokemon
  self.imgPokemonPacketItemCellMainLayout:SetVisible(self.pokemon ~= nil)
  if not self.pokemon then
    self.redPoint:SetVisible(false)
    return
  end
  self.txtPokemonPacketItemCellLevel:SetText("Lv." .. tostring(self.pokemon:getLevel()))
  self.imgPokemonPacketItemCellIcon:SetImage(self.pokemon:getIcon())
  self.imgPokemonPacketItemCellRaceIcon:SetImage(RaceConfig:getClassifyIcon(self.pokemon:getRace()))
  self.imgPokemonPacketItemFrame:SetImage(self.pokemon:getIconFrame())
  self.itemStarLevel:invoke("updateUI", self.pokemon:getStarLevel(), self.pokemon:getWake(), 1)
  self.lytPokemonPacketItemCellLocked:SetVisible(false)
  self.redPoint:SetVisible(self.checkCanBless and pokemon and pokemon:getCanBlessRedPointShow() or false)
  local FontSize = ""
  local textViewHeight = self.txtPokemonPacketItemCellLevel:GetPixelSize().y
  if textViewHeight < 12 then
    FontSize = "PKM8"
  elseif textViewHeight < 15 then
    FontSize = "PKM10"
  elseif textViewHeight < 18 then
    FontSize = "PKM12"
  elseif textViewHeight < 22 then
    FontSize = "PKM14"
  else
    FontSize = "PKM16"
  end
  self.txtPokemonPacketItemCellLevel:SetFontSize(FontSize)
end

function M:initView(pokemon)
  Lib.logDebug("initView pokemon = ", Lib.v2s(pokemon))
  self.imgPokemonPacketItemStarLevel:SetVisible(true)
  self.imgPokemonPacketItemCellIcon:SetVisible(true)
  self.txtPokemonPacketItemCellLevelBg:SetVisible(true)
  self.imgPokemonPacketItemCellInTeam:SetVisible(false)
  self.txtPokemonPacketItemCellLevel:SetText("Lv." .. tostring(pokemon.level))
  local pokemon_config = PokemonConfig:getConfigById(pokemon.cfgId)
  self.imgPokemonPacketItemCellIcon:SetImage(pokemon_config.icon)
  self.imgPokemonPacketItemStarLevel:SetImage("set:g2038_pokemon_star.json image:img_0_rareness" .. pokemon.star)
  if pokemon.npcCfgId then
    local npc_pokemon_config = NPCPokemonConfig:getPokemonById(pokemon.npcCfgId)
    local star = npc_pokemon_config.npc_star
    local wake = npc_pokemon_config.npc_wake
    self.itemStarLevel:invoke("updateUI", star, wake, 1)
  end
end

function M:getLuaCell()
  return self
end

function M:onDestroy()
  self.dataChangeFunc()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
