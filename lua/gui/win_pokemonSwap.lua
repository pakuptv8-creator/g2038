local M = _ENV.M
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "PokemonSwap.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonSwapContent = self:child("PokemonSwap-Content")
  self.imgPokemonSwapTitleBg = self:child("PokemonSwap-Title-Bg")
  self.txtPokemonSwapTitle = self:child("PokemonSwap-Title")
  self.btnPokemonSwapClose = self:child("PokemonSwap-Close")
  self.lytPokemonSwapPlayersLayout = self:child("PokemonSwap-Players-Layout")
  self.lytPokemonSwapMyInfo = self:child("PokemonSwap-My-Info")
  self.imgPokemonSwapMyInfoHead = self:child("PokemonSwap-My-Info-Head")
  self.txtPokemonSwapMyInfoName = self:child("PokemonSwap-My-Info-Name")
  self.txtPokemonSwapMyInfoLevel = self:child("PokemonSwap-My-Info-Level")
  self.lytPokemonSwapYourInfo = self:child("PokemonSwap-Your-Info")
  self.imgPokemonSwapYourInfoHead = self:child("PokemonSwap-Your-Info-Head")
  self.txtPokemonSwapYourInfoName = self:child("PokemonSwap-Your-Info-Name")
  self.txtPokemonSwapYourInfoLevel = self:child("PokemonSwap-Your-Info-Level")
  self.lytPokemonSwapPokemonLayout = self:child("PokemonSwap-Pokemon-Layout")
  self.lytPokemonSwapMyPokemonBg = self:child("PokemonSwap-My-Pokemon-Bg")
  self.imgPokemonSwapMyPokemonTip = self:child("PokemonSwap-My-Pokemon-Tip")
  self.imgPokemonSwapMyPokemonTipIcon = self:child("PokemonSwap-My-Pokemon-Tip-Icon")
  self.txtPokemonSwapMyPokemonTipText = self:child("PokemonSwap-My-Pokemon-Tip-Text")
  self.lytPokemonSwapMyPokemon = self:child("PokemonSwap-My-Pokemon")
  self.btnPokemonSwapMyPokemonBtn = self:child("PokemonSwap-My-Pokemon-Btn")
  self.lytPokemonSwapYourPokemonBg = self:child("PokemonSwap-Your-Pokemon-Bg")
  self.imgPokemonSwapYourPokemonTip = self:child("PokemonSwap-Your-Pokemon-Tip")
  self.txtPokemonSwapYourPokemonTipText1 = self:child("PokemonSwap-Your-Pokemon-Tip-Text_1")
  self.txtPokemonSwapYourPokemonTipText2 = self:child("PokemonSwap-Your-Pokemon-Tip-Text_2")
  self.lytPokemonSwapYourPokemon = self:child("PokemonSwap-Your-Pokemon")
  self.btnPokemonSwapYourPokemonBtn = self:child("PokemonSwap-Your-Pokemon-Btn")
  self.imgPokemonSwapSwapImg = self:child("PokemonSwap-Swap-Img")
  self.txtPokemonSwapTipText = self:child("PokemonSwap-Tip-Text")
  self.imgPokemonSwapTipIcon = self:child("PokemonSwap-Tip-Icon")
  self.btnPokemonSwapCancel = self:child("PokemonSwap-Cancel")
  self.btnPokemonSwapSure = self:child("PokemonSwap-Sure")
  self.imgPokemonSwapMyInfoLock = self:child("PokemonSwap-My-Info-Lock")
  self.imgPokemonSwapYourInfoLock = self:child("PokemonSwap-Your-Info-Lock")
  self.myPokemonItem = UIMgr:new_widget("pokemon_swap_cell")
  self.myPokemonItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPokemonSwapMyPokemon:AddChildWindow(self.myPokemonItem)
  self.yourPokemonItem = UIMgr:new_widget("pokemon_swap_cell")
  self.yourPokemonItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPokemonSwapYourPokemon:AddChildWindow(self.yourPokemonItem)
  self.txtPokemonSwapTitle:SetText(Lang:toText("gui.swap.title"))
  self.txtPokemonSwapMyPokemonTipText:SetText(Lang:toText("gui.swap.tip.click"))
  self.txtPokemonSwapYourPokemonTipText1:SetText(Lang:toText("gui.swap.tip.empty"))
  self.txtPokemonSwapYourPokemonTipText2:SetText(Lang:toText("gui.swap.tip.no.choice"))
  self.btnPokemonSwapMyPokemonBtn:SetText(Lang:toText("gui.swap.btn.delete"))
  self.btnPokemonSwapYourPokemonBtn:SetText(Lang:toText("gui.swap.btn.detail"))
  self.btnPokemonSwapCancel:SetText(Lang:toText("gui.btn.cancel"))
  self.btnPokemonSwapSure:SetText(Lang:toText("gui.btn.sure"))
  local showText = Lang:toText("gui.swap.tip")
  self.txtPokemonSwapTipText:SetText(showText)
  local textLen = self.txtPokemonSwapTipText:GetFont():GetTextExtent(showText, 1.0)
  self.txtPokemonSwapTipText:SetWidth({0, textLen})
end

function M:initEvent()
  self:subscribe(self.btnPokemonSwapClose, UIEvent.EventButtonClick, function()
    self:quitSwap()
  end)
  self:subscribe(self.btnPokemonSwapCancel, UIEvent.EventButtonClick, function()
    self:quitSwap()
  end)
  self:subscribe(self.btnPokemonSwapSure, UIEvent.EventButtonClick, function()
    self:sureSwap()
  end)
  self:subscribe(self.btnPokemonSwapMyPokemonBtn, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "selectSwapPokemon",
      objId = 0
    }, function(results)
      if not results.success then
        Me:showChatShopDialog({
          titleText = "gui.tip.title",
          msgText = results.lang
        })
      end
    end)
  end)
  self:subscribe(self.btnPokemonSwapYourPokemonBtn, UIEvent.EventButtonClick, function()
    local pokemon = self.yourPokemonItem:invoke("getPokemon")
    if pokemon then
      self:showPokemonDetail(pokemon)
    end
  end)
end

function M:subscribeEvent()
  self._allEvent = {}
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PLAYER_SWAP_SURE, function(isSure, targetId)
    if targetId == Me.objID then
      self.isLock = isSure
      self.myPokemonItem:invoke("setLock", isSure)
      self.btnPokemonSwapMyPokemonBtn:SetEnabled(not isSure)
      self.imgPokemonSwapMyInfoLock:SetVisible(isSure)
      if isSure then
        self.lytPokemonSwapMyPokemonBg:SetBackImage("set:pokemon_swap.json image:img_9_displayframe2")
      else
        self.lytPokemonSwapMyPokemonBg:SetBackImage("set:pokemon_swap.json image:img_9_displayframe")
      end
      self:updateSureButtonStatus()
    end
    if targetId == self.targetID then
      self.yourPokemonItem:invoke("setLock", isSure)
      self.imgPokemonSwapYourInfoLock:SetVisible(isSure)
      if isSure then
        self.lytPokemonSwapYourPokemonBg:SetBackImage("set:pokemon_swap.json image:img_9_displayframe2")
      else
        self.lytPokemonSwapYourPokemonBg:SetBackImage("set:pokemon_swap.json image:img_9_displayframe")
      end
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PLAYER_SWAP_POKEMON_CHANGE, function(pokemonObjId, targetId)
    if targetId == Me.objID then
      Me:getPokemon(pokemonObjId, function(pokemon)
        self.btnPokemonSwapMyPokemonBtn:SetVisible(pokemon ~= nil)
        self.myPokemonItem:invoke("setPokemon", pokemon)
        self:lockSureButton()
      end)
    end
    if targetId == self.targetID then
      Me:getPokemon(pokemonObjId, function(pokemon)
        self.btnPokemonSwapYourPokemonBtn:SetVisible(pokemon ~= nil)
        self.yourPokemonItem:invoke("setPokemon", pokemon)
        self:lockSureButton()
      end)
    end
  end)
end

function M:unsubscribeEvent()
  for _, func in pairs(self._allEvent or {}) do
    func()
  end
end

function M:initView()
  self.btnPokemonSwapMyPokemonBtn:SetVisible(false)
  self.btnPokemonSwapYourPokemonBtn:SetVisible(false)
  self.myPokemonItem:invoke("setPokemon", nil)
  self.yourPokemonItem:invoke("setPokemon", nil)
  self:initPlayerInfo()
  self:initPokemonLayout()
end

function M:initPokemonLayout()
  self.myPokemonItem:invoke("initCell", Me.objID, function(pokemon)
    if self.isLock then
      return
    end
    self:showPokemonDetail(pokemon)
  end)
  self.yourPokemonItem:invoke("initCell", self.targetID)
end

function M:initPlayerInfo()
  local yourPlayer = World.CurWorld:getEntity(self.targetID)
  self.txtPokemonSwapYourInfoLevel:SetText("Lv." .. yourPlayer:getPlayerLevel())
  self.txtPokemonSwapYourInfoName:SetText(yourPlayer.name or yourPlayer.nickName or "")
  AsyncProcess.GetUserDetail(yourPlayer.platformUserId, function(data)
    if data and data.picUrl and #data.picUrl > 0 then
      self.imgPokemonSwapYourInfoHead:SetImageUrl(data.picUrl)
    end
  end)
  self.txtPokemonSwapMyInfoLevel:SetText("Lv." .. Me:getPlayerLevel())
  self.txtPokemonSwapMyInfoName:SetText(Me.name or Me.nickName or "")
  AsyncProcess.GetUserDetail(Me.platformUserId, function(data)
    if data and data.picUrl and #data.picUrl > 0 then
      self.imgPokemonSwapMyInfoHead:SetImageUrl(data.picUrl)
    end
  end)
end

function M:showPokemonDetail(pokemon)
  local ui = UI:getWnd("pokemonPacket")
  ui:onShow("swap")
  if pokemon then
    ui:selectPacketItem(pokemon)
  else
    ui:selectFirstPacketItem()
  end
end

function M:updateSureButtonStatus()
  local haveAnyPokemon = self.yourPokemonItem:invoke("getPokemon") or self.myPokemonItem:invoke("getPokemon")
  self.btnPokemonSwapSure:SetEnabled(not self.isLock and haveAnyPokemon and self.lockButtonTick == 0)
  if self.lockButtonTick == 0 then
    self.btnPokemonSwapSure:SetText(Lang:toText("gui.btn.sure"))
  else
    self.btnPokemonSwapSure:SetText(Lang:toText("gui.btn.sure") .. "(" .. self.lockButtonTick .. ")")
  end
end

function M:lockSureButton()
  self.lockButtonTick = World.cfg.swapSureLockTime
  self:updateSureButtonStatus()
  LuaTimer:cancel(self.timerKeyAuto or 0)
  self.timerKeyAuto = LuaTimer:scheduleTimer(function()
    self.lockButtonTick = self.lockButtonTick - 1
    self:updateSureButtonStatus()
  end, 1000, self.lockButtonTick)
end

function M:quitSwap()
  Me:sendPacket({
    pid = "quitSwap",
    code = Define.SWAP_END_CODE.CANCEL
  })
end

function M:sureSwap()
  if not self.yourPokemonItem:invoke("getPokemon") then
    Me:showChatShopDialog({
      titleText = "gui.tip.title",
      msgText = "gui.your.pokemon.not.select"
    }, function(sure)
      if sure then
        Me:sendPacket({pid = "sureSwap"})
      end
    end)
    return
  end
  Me:sendPacket({pid = "sureSwap"})
end

function M:onHide()
  UI:closeWnd("pokemonSwap")
end

function M:onOpen(targetID)
  self.targetID = targetID
  self.lockButtonTick = 0
  self:subscribeEvent()
  self:initView()
  self:updateSureButtonStatus()
end

function M:onClose()
  self:unsubscribeEvent()
end

return M
