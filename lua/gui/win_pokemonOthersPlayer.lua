local GloryConfig = T(Config, "GloryConfig")
local gloryBg = {
  "set:player.json image:img_9_titlebg_blue",
  "set:player.json image:img_9_titlebg_green",
  "set:player.json image:img_9_titlebg_orange",
  "set:player.json image:img_9_titlebg_purple",
  "set:player.json image:img_9_titlebg_red"
}

function M:init()
  WinBase.init(self, "PokemonOthersPlayer.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonOthersPlayerMask = self:child("PokemonOthersPlayer-Mask")
  self.lytPokemonOthersPlayerBg = self:child("PokemonOthersPlayer-Bg")
  self.imgPokemonOthersPlayerBgTitle = self:child("PokemonOthersPlayer-BgTitle")
  self.txtPokemonOthersPlayerTitle = self:child("PokemonOthersPlayer-Title")
  self.txtPokemonOthersPlayerTitle:SetText(Lang:toText("player_dialog_title"))
  self.btnPokemonOthersPlayerClose = self:child("PokemonOthersPlayer-Close")
  self.imgPokemonOthersPlayerHeadFrame = self:child("PokemonOthersPlayer-HeadFrame")
  self.imgPokemonOthersPlayerHeadIcon = self:child("PokemonOthersPlayer-HeadIcon")
  self.txtPokemonOthersPlayerPlayerName = self:child("PokemonOthersPlayer-PlayerName")
  self.txtPokemonOthersPlayerCPVal = self:child("PokemonOthersPlayer-CPVal")
  self.lytPokemonOthersPlayerTitleContent = self:child("PokemonOthersPlayer-TitleContent")
  self.imgPokemonOthersPlayerMark = self:child("PokemonOthersPlayer-Mark")
  self.txtPokemonOthersPlayerPkmTitle = self:child("PokemonOthersPlayer-PkmTitle")
  self.txtPokemonOthersPlayerPkmTitle:SetText(Lang:toText("ui_pet_battle_queue"))
  self.lytPokemonOthersPlayerListContent = self:child("PokemonOthersPlayer-ListContent")
  self.imgPokemonOthersPlayerLvBg = self:child("PokemonOthersPlayer-LvBg")
  self.txtPokemonOthersPlayerLvTxt = self:child("PokemonOthersPlayer-LvTxt")
  self.imgPokemonOthersPlayerTitleBg = self:child("PokemonOthersPlayer-TitleBg")
  self.txtPokemonOthersPlayerTitleTxt = self:child("PokemonOthersPlayer-TitleTxt")
  self.imgPokemonOthersPlayerTitleIcon = self:child("PokemonOthersPlayer-TitleIcon")
  self.btnPokemonOthersPlayerAddFriend = self:child("PokemonOthersPlayer-AddFriend")
  self.btnPokemonOthersPlayerAddFriend:SetText(Lang:toText("gui_interactionUI_add_friend"))
  self.gvBattlePKMList = UIMgr:new_widget("grid_view")
  self.gvBattlePKMList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBattlePKMList:InitConfig(20, 0, 4)
  self.lytPokemonOthersPlayerListContent:AddChildWindow(self.gvBattlePKMList)
  local width = self.lytPokemonOthersPlayerListContent:GetPixelSize().x
  self.battlePKMAdapter = UIMgr:new_adapter("pokemonOthersItem", 90, 116)
  self.gvBattlePKMList:invoke("setAdapter", self.battlePKMAdapter)
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytPokemonOthersPlayerBg, 537, 584)
end

function M:initEvent()
  self:subscribe(self.btnPokemonOthersPlayerClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.imgPokemonOthersPlayerMask, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPokemonOthersPlayerAddFriend, UIEvent.EventButtonClick, function()
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.function.not.open"
    }, function()
    end)
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_OTHERS_POWER, function(packet)
    self:updateOtherPlayerPower(packet)
  end)
end

function M:initView(targetObjID)
  self.targetObjID = targetObjID
  Me:sendPacket({
    pid = "getOtherPlayerPower",
    targetID = targetObjID
  })
  self.curTarget = World.CurWorld:getEntity(self.targetObjID)
  if not self.curTarget or not self.curTarget:isValid() then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 40)
    self:onHide()
    return
  end
  self.txtPokemonOthersPlayerPlayerName:SetText(self.curTarget.name)
  self.txtPokemonOthersPlayerLvTxt:SetText("LV" .. self.curTarget:getPlayerLevel())
  if not self.headPicUrl then
    print("not self.headPicUrl ")
    AsyncProcess.GetUserDetail(self.curTarget.platformUserId, function(data)
      if data and data.picUrl and #data.picUrl > 0 then
        self.headPicUrl = data.picUrl
        print("data.picUrl:", data.picUrl)
        self.imgPokemonOthersPlayerHeadIcon:SetImageUrl(data.picUrl)
      end
    end)
  else
    print("has self.headPicUrl:", self.headPicUrl)
    self.imgPokemonOthersPlayerHeadIcon:SetImageUrl(self.headPicUrl)
  end
  local showGlory = GloryConfig:getGloryById(self.curTarget:getCurSelGlory())
  self.txtPokemonOthersPlayerTitleTxt:SetText(Lang:toText(showGlory and showGlory.name or "title_none"))
  self.imgPokemonOthersPlayerTitleBg:SetImage(gloryBg[showGlory and showGlory.rare or 1])
  if showGlory then
    self.imgPokemonOthersPlayerTitleIcon:SetVisible(true)
    self.imgPokemonOthersPlayerTitleIcon:SetImage(showGlory.icon)
  else
    self.imgPokemonOthersPlayerTitleIcon:SetVisible(false)
  end
end

function M:updateOtherPlayerPower(packet)
  self.txtPokemonOthersPlayerCPVal:SetText("CP:" .. packet.power)
  self.battlePKMAdapter:setData(packet.battleIconList)
end

function M:onHide()
  UI:closeWnd("pokemonOthersPlayer")
end

function M:onShow(isShow, targetObjID)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonOthersPlayer", targetObjID)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(targetObjID)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(targetObjID)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
