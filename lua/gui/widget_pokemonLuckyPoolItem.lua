local RaceConfig = T(Config, "RaceConfig")
local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "PokemonLuckyPoolItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPanel = self:child("PokemonLuckyPoolItem-Panel")
  self.imgBg = self:child("PokemonLuckyPoolItem-Bg")
  self.imgBbg = self:child("PokemonLuckyPoolItem-bbg")
  self.imgPkmIcon = self:child("PokemonLuckyPoolItem-pkmIcon")
  self.imgFrame = self:child("PokemonLuckyPoolItem-frame")
  self.imgRaceIcon = self:child("PokemonLuckyPoolItem-raceIcon")
  self.imgStarIcon = self:child("PokemonLuckyPoolItem-starIcon")
  self.txtPkmName = self:child("PokemonLuckyPoolItem-pkmName")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgStarIcon:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", -0.5)
end

function M:initEvent()
  self:subscribe(self.lytPanel, UIEvent.EventWindowClick, function()
    if not self.pkmInfo then
      return
    end
    UI:getWnd("pokemonLuckyDetails"):onShow(true, self.pkmInfo.id, UI:getWnd("pokemonLuckyEgg").curSelectTab)
  end)
end

function M:updateView(pkmInfo)
  self.txtPkmName:SetText(Lang:toText(pkmInfo.name))
  local qualityIconFrame = {
    "set:pokemon_pet_frame.json image:img_0_frame_blue",
    "set:pokemon_pet_frame.json image:img_0_frame_purple",
    "set:pokemon_pet_frame.json image:img_0_frame_orange"
  }
  self.imgFrame:SetImage(qualityIconFrame[pkmInfo.quality])
  self.imgPkmIcon:SetImage(pkmInfo.icon)
  self.imgRaceIcon:SetImage(RaceConfig:getClassifyIcon(pkmInfo.race))
end

function M:onDataChanged(pkmInfo)
  self.pkmInfo = pkmInfo
  self:updateView(pkmInfo)
  self.itemStarLevel:invoke("updateUI", pkmInfo.newStar or pkmInfo.starLevel, pkmInfo.maxWake, 1)
end

function M:setSpecialModel(pkmInfo)
  self:updateView(pkmInfo)
  self._root:SetTouchable(false)
  self.lytPanel:SetTouchable(false)
  self.txtPkmName:SetText()
  self.itemStarLevel:invoke("updateUI", pkmInfo.newStar or pkmInfo.starLevel, 0, 1)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
