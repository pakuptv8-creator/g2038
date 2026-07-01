local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "PokemonPlayerTeamInfo.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonPlayerTeamInfoHeadImg = self:child("PokemonPlayerTeamInfo-HeadImg")
  self.imgPokemonPlayerTeamInfoHeadImgBg = self:child("PokemonPlayerTeamInfo-headImgBg")
  self.txtPokemonPlayerTeamInfoLevel = self:child("PokemonPlayerTeamInfo-Level")
  self.imgPokemonPlayerTeamInfoIdBg = self:child("PokemonPlayerTeamInfo-IdBg")
  self.txtPokemonPlayerTeamInfoId = self:child("PokemonPlayerTeamInfo-Id")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemonPlayerTeamInfo imgPokemonPlayerTeamInfoHeadImgBg event : EventWindowClick", self.imgPokemonPlayerTeamInfoHeadImgBg, UIEvent.EventWindowClick, function()
    UI:getWnd("pokemon_base_interactionUI"):onShow(true, self.targetObjID)
  end)
  self.teamPlayerEvent = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemonPlayerTeamInfo Lib event : EVENT_UPDATE_TEAM_PLAYER_INFO", Event.EVENT_UPDATE_TEAM_PLAYER_INFO, function(targetID)
    self:initViewData(targetID)
  end)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

function M:initViewData(targetID)
  self.targetObjID = targetID
  if self.targetObjID == nil then
    self._root:SetVisible(false)
    return
  else
    self._root:SetVisible(true)
  end
  local target = World.CurWorld:getEntity(self.targetObjID)
  local player = UserInfoCache.GetCache(target.platformUserId)
  if player == nil then
    AsyncProcess.GetUserDetail(target.platformUserId, function(data)
      if data and data.picUrl and #data.picUrl > 0 then
        self.headPicUrl = data.picUrl
        self.imgPokemonPlayerTeamInfoHeadImg:SetImageUrl(data.picUrl)
      else
        self.imgPokemonPlayerTeamInfoHeadImg:SetImage("set:pokemonMain.json image:img_0_defaulthead")
      end
    end)
  elseif #player.picUrl > 0 then
    self.imgPokemonPlayerTeamInfoHeadImg:SetImageUrl(player.picUrl)
  else
    self.imgPokemonPlayerTeamInfoHeadImg:SetImage("set:pokemonMain.json image:img_0_defaulthead")
  end
  self.txtPokemonPlayerTeamInfoLevel:SetText("Lv." .. target:getPlayerLevel())
  self.txtPokemonPlayerTeamInfoId:SetText(target.name or target.nickName or "")
end

function M:onDestroy()
  if self.teamPlayerEvent then
    self.teamPlayerEvent()
  end
end

return M
