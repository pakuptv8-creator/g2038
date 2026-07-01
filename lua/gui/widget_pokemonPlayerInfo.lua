local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local PlayerExpConfig = T(Config, "PlayerExpConfig")

function M:init()
  widget_base.init(self, "PokemonPlayerInfo.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonPlayerInfoHeadImg = self:child("PokemonPlayerInfo-HeadImg")
  self.imgPokemonPlayerInfoHeadImgBg = self:child("PokemonPlayerInfo-headImgBg")
  self.txtPokemonPlayerInfoLevel = self:child("PokemonPlayerInfo-Level")
  self.imgPokemonPlayerInfoIdBg = self:child("PokemonPlayerInfo-IdBg")
  self.txtPokemonPlayerInfoId = self:child("PokemonPlayerInfo-Id")
  self.lstPokemonPlayerInfoPetList = self:child("PokemonPlayerInfo-PetList")
  self.lytPetListClickCheck = self:child("PokemonPlayerInfo-PetListClickCheck")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemonPlayerInfo imgPokemonPlayerInfoHeadImgBg event : EventWindowClick", self.imgPokemonPlayerInfoHeadImgBg, UIEvent.EventWindowClick, function()
    Me:gameBehaviorReport("ui", "infor")
    UI:openWnd("pokemonPlayerDialog")
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemonPlayerInfo lytPetListClickCheck event : EventWindowTouchDown", self.lytPetListClickCheck, UIEvent.EventWindowClick, function()
    Me:gameBehaviorReport("ui", "queue")
    local unlockMod = UI:getWnd("pokemonMain").unlockMod
    unlockMod = unlockMod or PlayerExpConfig:getUnlockModByLv(Me:getPlayerLevel())
    if not unlockMod[Define.MODULE_TYPE.MAIN_QUEUE] then
      return
    end
    UI:getWnd("pokemonPacket"):onShow("battle")
  end)
  self.lvCallCancel = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemonPlayerInfo Lib event : EVENT_PLAYER_LEVEL_UP", Event.EVENT_PLAYER_LEVEL_UP, function(lv)
    self.txtPokemonPlayerInfoLevel:SetText("Lv." .. lv)
  end)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

function M:initViewData(player)
  AsyncProcess.GetUserDetail(player.platformUserId, function(data)
    if not self or self.deleted then
      return
    end
    if data and data.picUrl and #data.picUrl > 0 then
      self.headPicUrl = data.picUrl
      self.imgPokemonPlayerInfoHeadImg:SetImageUrl(data.picUrl)
    end
  end)
  self.txtPokemonPlayerInfoLevel:SetText("Lv." .. player:getPlayerLevel())
  player:getPlayerPower(function(power)
    self.txtPokemonPlayerInfoId:SetText("CP: " .. power)
  end)
  self.lstPokemonPlayerInfoPetList:InitConfig(0, 0, 5)
  self.lstPokemonPlayerInfoPetList:SetMoveAble(false)
  player:getBattlePokemon(function(packet)
    for objId, pokemon in pairs(packet) do
      local node = UIMgr:new_widget("pokemonPlayerInfoPet")
      node:invoke("initViewData", pokemon)
      self.lstPokemonPlayerInfoPetList:AddItem(node, true)
    end
    if 0 < #packet and #packet < 4 then
      local last = 4 - #packet
      for i = 1, last do
        local node = UIMgr:new_widget("pokemonPlayerInfoPet")
        node:invoke("initViewData")
        self.lstPokemonPlayerInfoPetList:AddItem(node, true)
      end
    end
  end)
end

function M:onDestroy()
  if self.lvCallCancel then
    self.lvCallCancel()
  end
  self.deleted = true
end

return M
