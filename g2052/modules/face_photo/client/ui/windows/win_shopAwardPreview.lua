local WinShopAwardPreview = M
local AppearanceConfig = T(Config, "AppearanceConfig")
local PetConfig = T(Config, "PetConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinShopAwardPreview:init()
  WinBase.init(self, "ShopAwardPreview.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinShopAwardPreview:initUI()
  self.lytMask = self:child("ShopAwardPreview-mask")
  self.lytWnd = self:child("ShopAwardPreview-wnd")
  self.imgWndBg = self:child("ShopAwardPreview-wnd_bg")
  self.imgTopImg = self:child("ShopAwardPreview-topImg")
  self.txtTitle = self:child("ShopAwardPreview-title")
  self.btnClose = self:child("ShopAwardPreview-close")
  self.imgCloseImg = self:child("ShopAwardPreview-closeImg")
  self.imgFrame = self:child("ShopAwardPreview-frame")
  self.imgIcon = self:child("ShopAwardPreview-icon")
  self.itemActor = self:child("ShopAwardPreview-modelShow")
end

function WinShopAwardPreview:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinShopAwardPreview:subscribeEvent()
end

function WinShopAwardPreview:initView(params)
  if params then
    self.txtTitle:SetText(Lang:toText(params.name))
    if not params.frameImg then
      local quality = params.quality or 1
      self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
    else
      self.imgFrame:SetImage(params.frameImg)
    end
    self.imgIcon:SetImage(params.icon)
    self:UpdateActorModelShow(params.giftContent[1])
  end
end

function WinShopAwardPreview:UpdateActorModelShow(awardId)
  local giftItemCfgs = LimitedTimeGiftItemConfig:getAllCfgs() or {}
  local goodsCfg = giftItemCfgs[awardId]
  local goodsType = goodsCfg.awardType
  if goodsType == Define.BUSINESS_ITEM_TYPE.Dress then
    Me:setShapeInfoClient(Me:getShapeInfo())
    local sex = Me:checkSex()
    local actorName = sex == 1 and "g2052_boy.actor" or "g2052_girl.actor"
    self.itemActor:SetActor1(actorName, "idle")
    local appearanceCfg = AppearanceConfig:getCfgById(goodsCfg.itemId)
    local changeSkinData, shapeInfoRemove = Me:parseNewSkinDataClient(Lib.copyTable1(appearanceCfg.parts))
    local originalData = Me:getOriginalSkin()
    local mySkin = Lib.copyTable1(Me:data("skins"))
    local skinData = Lib.copyTable1(originalData)
    if skinData.custom_head == nil then
      skinData.custom_head = ""
    end
    if skinData.custom_bag == nil then
      skinData.custom_bag = ""
    end
    for k, v in pairs(mySkin) do
      skinData[k] = v
    end
    for k, v in pairs(changeSkinData) do
      skinData[k] = v
    end
    for k, v in pairs(skinData) do
      if k == "skin_color" then
        self.itemActor:SetActorCustomColor(v)
      elseif EntityClient.getPartDyeColor and GUIActorWindow.UseBodyPartDyeColor then
        local color = Me:getPartDyeColor(k, v)
        self.itemActor:UseBodyPartDyeColor(k, v, color or "")
      else
        self.itemActor:UseBodyPart(k, v)
      end
    end
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.Pet then
    local petCfg = PetConfig:getCfgById(goodsCfg.itemId)
    self.itemActor:SetActor1(petCfg.actorName, "idle")
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.Car then
    self.itemActor:SetActor1(goodsCfg.actorName, "idle")
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.House then
    self.itemActor:SetActor1(goodsCfg.actorName, "idle")
  end
  self.itemActor:SetVisible(true)
  self.itemActor:SetActorScale(goodsCfg.actorScale or 1)
  self.itemActor:SetRotateY(goodsCfg.actorRotateY)
  self.itemActor:SetRotateX(goodsCfg.actorRotateX)
  self.itemActor:SetXPosition({
    0,
    goodsCfg.actorUIOffset.x
  })
  self.itemActor:SetYPosition({
    0,
    goodsCfg.actorUIOffset.y
  })
  self.itemActor:UpdateSelf(1)
end

function WinShopAwardPreview:onHide()
  UI:closeWnd("shopAwardPreview")
end

function WinShopAwardPreview:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("shopAwardPreview")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinShopAwardPreview:onOpen(params)
  self:initView(params)
  self:subscribeEvent()
end

function WinShopAwardPreview:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinShopAwardPreview
