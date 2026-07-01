local M = _ENV.M

function M:init()
  WinBase.init(self, "PokemonSwapResult.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonSwapResultContent = self:child("PokemonSwapResult-Content")
  self.imgPokemonSwapResultTitle = self:child("PokemonSwapResult-Title")
  self.txtPokemonSwapResultTitleText = self:child("PokemonSwapResult-Title-Text")
  self.imgPokemonSwapResultHeadBg = self:child("PokemonSwapResult-Head-Bg")
  self.imgPokemonSwapResultHeadBorder = self:child("PokemonSwapResult-Head-Border")
  self.imgPokemonSwapResultHeadIcon = self:child("PokemonSwapResult-Head-Icon")
  self.txtPokemonSwapResultLevel = self:child("PokemonSwapResult-Level")
  self.txtPokemonSwapResultName = self:child("PokemonSwapResult-Name")
  self.imgPokemonSwapResultStarLevelImg = self:child("PokemonSwapResult-Star-Level-Img")
  self.lytPokemonSwapResultAttrLayout = self:child("PokemonSwapResult-Attr-Layout")
  self.imgPokemonSwapResultHpIcon = self:child("PokemonSwapResult-Hp-Icon")
  self.txtPokemonSwapResultHpText = self:child("PokemonSwapResult-Hp-Text")
  self.imgPokemonSwapResultPAtkIcon = self:child("PokemonSwapResult-PAtk-Icon")
  self.txtPokemonSwapResultPAtkText = self:child("PokemonSwapResult-PAtk-Text")
  self.imgPokemonSwapResultPDefIcon = self:child("PokemonSwapResult-PDef-Icon")
  self.txtPokemonSwapResultPDefText = self:child("PokemonSwapResult-PDef-Text")
  self.imgPokemonSwapResultSpeedIcon = self:child("PokemonSwapResult-Speed-Icon")
  self.txtPokemonSwapResultSpeedText = self:child("PokemonSwapResult-Speed-Text")
  self.imgPokemonSwapResultSAtkIcon = self:child("PokemonSwapResult-SAtk-Icon")
  self.txtPokemonSwapResultSAtkText = self:child("PokemonSwapResult-SAtk-Text")
  self.imgPokemonSwapResultSDefIcon = self:child("PokemonSwapResult-SDef-Icon")
  self.txtPokemonSwapResultSDefText = self:child("PokemonSwapResult-SDef-Text")
  self.lytPokemonSwapResultBottom = self:child("PokemonSwapResult-Bottom")
  self.btnPokemonSwapResultOpenPacket = self:child("PokemonSwapResult-OpenPacket")
  self.btnPokemonSwapResultContinue = self:child("PokemonSwapResult-Continue")
  self.widget_item = UIMgr:new_widget("pokemon_packet_item_cell")
  self.widget_lua_item = self.widget_item:invoke("getLuaCell")
  self.widget_item:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.widget_lua_item.txtPokemonPacketItemCellLevelBg:SetVisible(false)
  self.imgPokemonSwapResultHeadIcon:AddChildWindow(self.widget_item)
  self.txtPokemonSwapResultTitleText:SetText(Lang:toText("gui.swap.title.result"))
  self.btnPokemonSwapResultOpenPacket:SetText(Lang:toText("gui.btn.open.packet"))
  self.btnPokemonSwapResultContinue:SetText(Lang:toText("gui.btn.sure"))
end

function M:initEvent()
  self:subscribe(self.btnPokemonSwapResultOpenPacket, UIEvent.EventButtonClick, function()
    self:onHide()
    local ui = UI:getWnd("pokemonPacket")
    ui:onShow("packet")
    ui:selectPacketItem(self.cur_pokemon)
  end)
  self:subscribe(self.btnPokemonSwapResultContinue, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView()
  if not self.cur_pokemon then
    return
  end
  local pokemon = self.cur_pokemon
  self.widget_lua_item:updateInfo(pokemon)
  self.imgPokemonSwapResultStarLevelImg:SetImage("set:g2038_pokemon_star.json image:img_0_bigrareness" .. pokemon:getStarLevel())
  self.txtPokemonSwapResultLevel:SetText("Lv." .. pokemon:getLevel())
  self.txtPokemonSwapResultName:SetText(pokemon:getName())
  self.txtPokemonSwapResultHpText:SetText(pokemon:getMaxHp())
  self.txtPokemonSwapResultSpeedText:SetText(pokemon:getSpeed())
  self.txtPokemonSwapResultPAtkText:SetText(pokemon:getPhysicalAtk())
  self.txtPokemonSwapResultPDefText:SetText(pokemon:getPhysicalDef())
  self.txtPokemonSwapResultSAtkText:SetText(pokemon:getSpecialAtk())
  self.txtPokemonSwapResultSDefText:SetText(pokemon:getSpecialDef())
end

function M:onHide()
  UI:closeWnd("pokemonSwapResult")
end

function M:onOpen(pokemon)
  self.cur_pokemon = pokemon
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
