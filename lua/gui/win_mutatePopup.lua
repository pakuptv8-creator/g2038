local SkillConfig = T(Config, "SkillConfig")

function M:init()
  WinBase.init(self, "MutatePopup.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytMutatePopupMutationLayout = self:child("MutatePopup-MutationLayout")
  self.txtMutatePopupTitleTxt = self:child("MutatePopup-TitleTxt")
  self.btnMutatePopupCloseBtn = self:child("MutatePopup-CloseBtn")
  self.txtMutatePopupHPAdd = self:child("MutatePopup-HPAdd")
  self.txtMutatePopupCurHP = self:child("MutatePopup-CurHP")
  self.txtMutatePopupSpeedAdd = self:child("MutatePopup-SpeedAdd")
  self.txtMutatePopupCurSpeed = self:child("MutatePopup-CurSpeed")
  self.txtMutatePopupPAtkAdd = self:child("MutatePopup-PAtkAdd")
  self.txtMutatePopupCurPAtk = self:child("MutatePopup-CurPAtk")
  self.txtMutatePopupPDefAdd = self:child("MutatePopup-PDefAdd")
  self.txtMutatePopupCurPDef = self:child("MutatePopup-CurPDef")
  self.txtMutatePopupMAtkAdd = self:child("MutatePopup-MAtkAdd")
  self.txtMutatePopupCurMAtk = self:child("MutatePopup-CurMAtk")
  self.txtMutatePopupMAtkAdd = self:child("MutatePopup-MAtkAdd")
  self.txtMutatePopupCurMDef = self:child("MutatePopup-CurMDef")
  self.txtMutatePopupMDefAdd = self:child("MutatePopup-MDefAdd")
  self.txtMutatePopupFeatureName = self:child("MutatePopup-FeatureName")
  self.txtMutatePopupFeatureRarity = self:child("MutatePopup-FeatureRarity")
  self.txtMutatePopupFeatureDescribe = self:child("MutatePopup-FeatureDescribe")
  self.actorMutatePopupEntityWindow = self:child("MutatePopup-EntityWindow")
  self.MutatePopupItemIcon = self:child("MutatePopup-Item")
  self.txtMutatePopupItemCount = self:child("MutatePopup-ItemCount")
  self.btnMutatePopupMutateBtn = self:child("MutatePopup-MutateBtn")
  self.btnMutatePopupConfirmBtn = self:child("MutatePopup-ConfirmBtn")
  self.lytSuccessWin = self:child("MutatePopup-MutateSuccess")
  self.actSuccessEntityWindow = self:child("MutatePopup-SuccessEntityWindow")
  self.imgBuyMask = self:child("MutatePopup-BuyMask")
  self.lytNotEnough = self:child("MutatePopup-ItemNotEnough")
  self.btnMutatePopupBuyBtn = self:child("MutatePopup-BuyBtn")
  self.btnMutatePopupNotBuyBtn = self:child("MutatePopup-NotBuyBtn")
  self.txtPromptText = self:child("MutatePopup-NotEnoughText")
  self.txtPromptTitle = self:child("MutatePopup-NotEnoughTitleTxt")
  self.btnMutatePopupMutateBtn:SetText(Lang:toText("mutate_title"))
  self.txtMutatePopupTitleTxt:SetText(Lang:toText("mutate_title"))
  self.txtPromptTitle:SetText(Lang:toText("prompt_title"))
  self.lytAttributes = self:child("MutatePopup-AttributesLayout")
  self.mutateAttributesItem = UIMgr:new_widget("pokemonAttributes")
  self.mutateAttributesItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytAttributes:AddChildWindow(self.mutateAttributesItem)
  self.costItem = UIMgr:new_widget("pokemon_item_cell")
  self.costItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.MutatePopupItemIcon:AddChildWindow(self.costItem)
end

function M:initEvent()
  self:subscribe(self.btnMutatePopupCloseBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnMutatePopupConfirmBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnMutatePopupMutateBtn, UIEvent.EventButtonClick, function()
    if not self.isEnough then
      self:showNotEnoughWindow(true)
      self.txtPromptText:SetText(Lang:toText("prompt_text"))
      return
    end
    Me:MutatePokemon({
      objId = self.cur_pokemon:getObjId()
    }, function(res)
      if not res then
        UI:getWnd("battle_dialog"):showDialogText({
          text = "\229\164\177\232\180\165",
          yesCb = function()
          end
        })
      elseif res then
        self.lytSuccessWin:SetVisible(true)
        self.lytMutatePopupMutationLayout:SetVisible(false)
        self:updateEntityWindow(self.actSuccessEntityWindow)
      end
    end)
  end)
  self:subscribe(self.btnMutatePopupBuyBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
    UI:getWnd("pokemon_Shop"):onShow(true)
  end)
  self:subscribe(self.btnMutatePopupNotBuyBtn, UIEvent.EventButtonClick, function()
    self:showNotEnoughWindow(false)
  end)
  Lib.subscribeEvent(Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if self.cur_pokemon and tostring(self.cur_pokemon:getObjId()) == tostring(objId) then
      self:updateUI()
    end
  end)
end

function M:subscribeEvent()
end

function M:initView()
  self.lytMutatePopupMutationLayout:SetVisible(true)
  self.lytSuccessWin:SetVisible(false)
  self:showNotEnoughWindow(false)
  self:updateUI()
end

function M:updateUI()
  self:updateEntityWindow(self.actorMutatePopupEntityWindow)
  self:updateFeature()
  self:updateAttributes()
  self:updateInteraction()
end

function M:showNotEnoughWindow(show)
  self.lytNotEnough:SetVisible(show)
  self.imgBuyMask:SetVisible(show)
end

function M:updateEntityWindow(entityWin)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local pokemon_config = self.cur_pokemon:getCfg()
  local entity_cfg = Entity.GetCfg(pokemon_config.mutateFullName)
  entityWin:SetActor1(entity_cfg.actorName, "idle")
  entityWin:SetActorScale(pokemon_config.uiScale)
  if getmetatable(entityWin).SetActorOffset then
    entityWin:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  entityWin:SetYPosition({
    pokemon_config.uiOffsetY,
    0
  })
  entityWin:SetRotateY(-40)
  entityWin:SetRotateX(10)
end

function M:updateFeature()
  local feature_config = SkillConfig:getConfigById(self.cur_pokemon:getMutateFeature()) or {}
  self.txtMutatePopupFeatureName:SetText(Lang:toText(feature_config.name or "FeatureName"))
  self.txtMutatePopupFeatureDescribe:SetText(Lang:toText(feature_config.describe or "FeatureDesc"))
  self.txtMutatePopupFeatureRarity:SetText(Lang:toText("special_feature"))
end

function M:updateAttributes()
  self.mutateAttributesItem:invoke("updateUIByType", self.cur_pokemon, "isMutated")
end

function M:updateInteraction()
  self.isEnough = true
  local mutateItem = self.cur_pokemon:getMutateItem()
  local fullName = Me:getItemFullNameByItemId(mutateItem[1])
  local hasNum = Me:getTrayItemCountByFullName(fullName)
  local costNum = tonumber(mutateItem[2])
  if hasNum < costNum then
    self.isEnough = false
  end
  self.txtMutatePopupItemCount:SetText((hasNum or 0) .. "/" .. (costNum or 999))
  self.costItem:invoke("initViewDataWithoutAdapter", fullName, hasNum, function(_, dx, dy)
    UI:getWnd("pokemonItemDetail"):onShow(fullName, dx, dy)
  end)
end

function M:onHide()
  UI:closeWnd("mutatePopup")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      self.cur_pokemon = isShow
      UI:openWnd("mutatePopup")
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
