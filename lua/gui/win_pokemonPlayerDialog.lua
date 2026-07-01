local gloryBg = {
  "set:player.json image:img_9_titlebg_blue",
  "set:player.json image:img_9_titlebg_green",
  "set:player.json image:img_9_titlebg_orange",
  "set:player.json image:img_9_titlebg_purple",
  "set:player.json image:img_9_titlebg_red"
}
local GloryConfig = T(Config, "GloryConfig")

function M:init()
  WinBase.init(self, "PokemonPlayerDialog.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonPlayerDialogMask = self:child("PokemonPlayerDialog-Mask")
  self.lytPokemonPlayerDialogBg = self:child("PokemonPlayerDialog-Bg")
  self.imgPokemonPlayerDialogBgTitle = self:child("PokemonPlayerDialog-BgTitle")
  self.txtPokemonPlayerDialogTitle = self:child("PokemonPlayerDialog-Title")
  self.txtPokemonPlayerDialogTitle:SetText(Lang:toText("player_dialog_title"))
  self.btnPokemonPlayerDialogClose = self:child("PokemonPlayerDialog-Close")
  self.imgPokemonPlayerDialogMoc = self:child("PokemonPlayerDialog-Moc")
  self.imgPokemonPlayerDialogHeadFrame = self:child("PokemonPlayerDialog-HeadFrame")
  self.imgPokemonPlayerDialogHeadIcon = self:child("PokemonPlayerDialog-HeadIcon")
  self.txtPokemonPlayerDialogPlayerName = self:child("PokemonPlayerDialog-PlayerName")
  self.txtPokemonPlayerDialogCPVal = self:child("PokemonPlayerDialog-CPVal")
  self.lytPokemonPlayerDialogTitleContent = self:child("PokemonPlayerDialog-TitleContent")
  self.imgPokemonPlayerDialogMark = self:child("PokemonPlayerDialog-Mark")
  self.txtPokemonPlayerDialogGloryTitle = self:child("PokemonPlayerDialog-GloryTitle")
  self.txtPokemonPlayerDialogGloryTitle:SetText(Lang:toText("glory_title"))
  self.lytPokemonPlayerDialogListContent = self:child("PokemonPlayerDialog-ListContent")
  self.prgPokemonPlayerDialogExp = self:child("PokemonPlayerDialog-Exp")
  self.txtPokemonPlayerDialogExp = self:child("PokemonPlayerDialog-ExpTxt")
  self.txtPokemonPlayerDialogLv = self:child("PokemonPlayerDialog-LvTxt")
  self.imgPokemonPlayerDialogTitleBg = self:child("PokemonPlayerDialog-TitleBg")
  self.txtPokemonPlayerDialogTitleTxt = self:child("PokemonPlayerDialog-TitleTxt")
  self.imgPokemonPlayerDialogTitleIcon = self:child("PokemonPlayerDialog-TitleIcon")
  self.gvGloryList = UIMgr:new_widget("grid_view")
  self.gvGloryList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvGloryList:InitConfig(10, 10, 4)
  self.lytPokemonPlayerDialogListContent:AddChildWindow(self.gvGloryList)
  local width = self.lytPokemonPlayerDialogListContent:GetPixelSize().x
  local itemWidth = (width - 28) / 4
  self.gloryAdapter = UIMgr:new_adapter("pokemonGloryItem", itemWidth, itemWidth)
  self.gvGloryList:invoke("setAdapter", self.gloryAdapter)
end

function M:initEvent()
  self:subscribe(self.btnPokemonPlayerDialogClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("pokemonPlayerDialog")
  end)
  self:subscribe(self.imgPokemonPlayerDialogMask, UIEvent.EventWindowClick, function()
    UI:closeWnd("pokemonPlayerDialog")
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PLAYER_LEVEL_UP, function(lv)
    self.txtPokemonPlayerDialogLv:SetText("LV" .. lv)
    local has, need = Me:getExpHasAndNeed()
    self.txtPokemonPlayerDialogExp:SetText(has .. "/" .. need)
    local has, need = Me:getExpHasAndNeed()
    self.prgPokemonPlayerDialogExp:SetProgress(has / need)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PLAYER_EXP_ADD, function(lv)
    local has, need = Me:getExpHasAndNeed()
    self.txtPokemonPlayerDialogExp:SetText(has .. "/" .. need)
    local has, need = Me:getExpHasAndNeed()
    self.prgPokemonPlayerDialogExp:SetProgress(has / need)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_GLORY, function(lv)
    self.gloryAdapter:setData(GloryConfig:getAllData())
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_PLAYER_TITLE, function(lv)
    self.gloryAdapter:setData(GloryConfig:getAllData())
    local showGlory = GloryConfig:getGloryById(Me:getCurSelGlory())
    self.txtPokemonPlayerDialogTitleTxt:SetText(Lang:toText(showGlory and showGlory.name or "title_none"))
    self.imgPokemonPlayerDialogTitleBg:SetImage(gloryBg[showGlory and showGlory.rare or 1])
    if showGlory then
      self.imgPokemonPlayerDialogTitleIcon:SetVisible(true)
      self.imgPokemonPlayerDialogTitleIcon:SetImage(showGlory.icon)
    else
      self.imgPokemonPlayerDialogTitleIcon:SetVisible(false)
    end
  end)
end

function M:initView()
  self.txtPokemonPlayerDialogPlayerName:SetText(Me.name)
  Me:getPlayerPower(function(cp)
    self.txtPokemonPlayerDialogCPVal:SetText("CP:" .. cp)
  end)
  local has, need = Me:getExpHasAndNeed()
  self.txtPokemonPlayerDialogExp:SetText(has .. "/" .. need)
  local has, need = Me:getExpHasAndNeed()
  self.prgPokemonPlayerDialogExp:SetProgress(has / need)
  self.txtPokemonPlayerDialogLv:SetText("LV" .. Me:getPlayerLevel())
  local showGlory = GloryConfig:getGloryById(Me:getCurSelGlory())
  self.txtPokemonPlayerDialogTitleTxt:SetText(Lang:toText(showGlory and showGlory.name or "title_none"))
  self.imgPokemonPlayerDialogTitleBg:SetImage(gloryBg[showGlory and showGlory.rare or 1])
  if showGlory then
    self.imgPokemonPlayerDialogTitleIcon:SetVisible(true)
    self.imgPokemonPlayerDialogTitleIcon:SetImage(showGlory.icon)
  else
    self.imgPokemonPlayerDialogTitleIcon:SetVisible(false)
  end
  if not self.headPicUrl then
    print("not self.headPicUrl ")
    AsyncProcess.GetUserDetail(Me.platformUserId, function(data)
      if data and data.picUrl and #data.picUrl > 0 then
        self.headPicUrl = data.picUrl
        print("data.picUrl:", data.picUrl)
        self.imgPokemonPlayerDialogHeadIcon:SetImageUrl(data.picUrl)
      end
    end)
  else
    print("has self.headPicUrl:", self.headPicUrl)
    self.imgPokemonPlayerDialogHeadIcon:SetImageUrl(self.headPicUrl)
  end
  self.gloryAdapter:setData(GloryConfig:getAllData())
end

function M:onHide()
  UI:closeWnd("pokemonPlayerDialog")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonPlayerDialog")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
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
