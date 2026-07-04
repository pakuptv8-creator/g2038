local WinG2052Shop = M
local BusinessHelper = T(Lib, "BusinessHelper")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local PetConfig = T(Config, "PetConfig")
local CarConfig = T(Config, "CarConfig")
local HouseConfig = T(Config, "HouseConfig")
local LuaTimer = T(Lib, "LuaTimer")
local CurMainTabIndex = -1
local DefaultMainTabIndex = 1
local ShopTabInfo = {
  [1] = {
    goodsType = Define.BUSINESS_ITEM_TYPE.Dress,
    icon = "set:g2052_main.json image:icon_0_main_character",
    isItemShop = true,
    sort = 1
  },
  [2] = {
    goodsType = Define.BUSINESS_ITEM_TYPE.Pet,
    icon = "set:g2052_main.json image:icon_0_children",
    isItemShop = true,
    sort = 5
  },
  [3] = {
    goodsType = Define.BUSINESS_ITEM_TYPE.Car,
    icon = "set:g2052_main.json image:icon_0_carriers",
    isItemShop = true,
    sort = 3
  },
  [4] = {
    goodsType = Define.BUSINESS_ITEM_TYPE.House,
    icon = "set:g2052_main.json image:icon_0_house",
    isItemShop = true,
    sort = 4
  }
}

function WinG2052Shop:init()
  WinBase.init(self, "G2052Shop.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinG2052Shop:initData()
  self._allEvent = {}
  self.privilegeShopInfo = BusinessHelper:getProductCfg(Define.PRODUCT_TYPE.PRIVILEGE) or {}
end

function WinG2052Shop:initUI()
  self.imgBg = self:child("G2052Shop-bg")
  self.lytTop = self:child("G2052Shop-top")
  self.imgTopBg = self:child("G2052Shop-top_bg")
  self.lytShopList = self:child("G2052Shop-shop_list")
  self.btnClose = self:child("G2052Shop-close")
  self.txtTitle = self:child("G2052Shop-title")
  self.lytTabPanel = self:child("G2052Shop-TabPanel")
  self.lytItemPanel = self:child("G2052Shop-ItemPanel")
  self.lytItemList = self:child("G2052Shop-ItemList")
  self.itemActor = self:child("G2052Shop-ItemActor")
  self.txtTitle:SetText(Lang:toText("gui.shop.title"))
  local widget = UIMgr:new_widget("currencyItem", -0.03125, 0.0208333)
  self:root():AddChildWindow(widget, "currencyItem")
  self:initMainTabData()
  self:initCellList()
  self.gvShopTab:setData(self.showTabList, 1, nil, true)
end

function WinG2052Shop:initCellList()
  self.shopCellList = {}
  self.shopAdapter = {}
  self.shopGirdView = {}
  for index, val in pairs(self.showTabList) do
    if val.isItemShop then
      local gvShopItem = self:initCellItemView()
      local itemCfg = BusinessGoodsConfig:getAllByTabType(val.goodsType)
      for key, info in pairs(itemCfg) do
        local data = Me:getBusinessItemIconInfo(info)
        itemCfg[key].icon = data.icon
        itemCfg[key].id = data.id
      end
      gvShopItem:setData(itemCfg, -1, nil, true)
      self.shopCellList[index] = gvShopItem:getGridView()
      self.shopAdapter[index] = gvShopItem:getAdapter()
      self.shopGirdView[index] = gvShopItem
    else
      local widget = UIMgr:new_widget("g2052ShopCell")
      widget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
      self.lytShopList:AddChildWindow(widget)
      self.shopCellList[index] = widget
      self.shopCellList[index]:invoke("updateShowCellShow", val)
    end
  end
end

function WinG2052Shop:initCellItemView()
  local gvShopItem = GridViewHelper.new({
    name = "gvG2052ShopItem",
    xCellNum = 3,
    yDis = 27,
    xDis = 27,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = true,
    widgetWidth = 129,
    widgetHeight = 160,
    widgetJson = "G2052ShopItem.json",
    widgetName = "g2052ShopItem",
    gvParent = self.lytItemList,
    cellSelectedCb = function(data, dx, dy, index)
      self:onShopItemBtnClick(data)
    end
  })
  return gvShopItem
end

function WinG2052Shop:onShopItemBtnClick(goodsCfg)
  if goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.Dress then
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
  elseif goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.Pet then
    local petCfg = PetConfig:getCfgById(goodsCfg.itemId)
    self.itemActor:SetActor1(petCfg.actorName, "idle")
  elseif goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.Car then
    self.itemActor:SetActor1(goodsCfg.actorName, "idle")
  elseif goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.House then
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

function WinG2052Shop:initMainTabData()
  self.gvShopTab = GridViewHelper.new({
    name = "gvG2052ShopTab",
    xCellNum = 1,
    yDis = 40,
    xDis = 0,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = false,
    widgetWidth = 135,
    widgetHeight = 70,
    widgetJson = "G2052ShopTab.json",
    widgetName = "g2052ShopTab",
    gvParent = self.lytTabPanel,
    cellSelectedCb = function(data, dx, dy, index)
      self:onShopTabBtnClick(index)
    end
  })
  self.showTabList = {}
  for key, val in pairs(ShopTabInfo) do
    table.insert(self.showTabList, val)
  end
  for key, val in pairs(self.privilegeShopInfo) do
    table.insert(self.showTabList, val)
  end
  table.sort(self.showTabList, function(a, b)
    return a.sort < b.sort
  end)
end

function WinG2052Shop:onShopTabBtnClick(index)
  if not index then
    return
  end
  for key, info in pairs(self.showTabList) do
    if self.shopCellList[key] then
      self.shopCellList[key]:SetVisible(false)
    end
  end
  if 0 < CurMainTabIndex then
    local shop_goods_type = 5
    if self.showTabList[index].isItemShop then
      shop_goods_type = self.showTabList[index].goodsType
    end
    local reportData = {
      shop_goods_type = shop_goods_type or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "shop_page_click", reportData, Me)
  end
  CurMainTabIndex = index
  if not self.shopCellList[index] then
    return
  end
  if self.showTabList[index].isItemShop then
    self.lytItemPanel:SetVisible(true)
    self.lytShopList:SetVisible(false)
  else
    self.lytShopList:SetVisible(true)
    self.lytItemPanel:SetVisible(false)
  end
  self.shopCellList[index]:SetVisible(true)
  if self.shopGirdView[index] then
    local showKey
    for key, info in pairs(self.shopAdapter[index].data) do
      if showKey == nil then
        showKey = key
      end
      local canUse = Me:checkBusinessItemUnlock(info.goodsType, info.itemId)
      if not canUse then
        showKey = key
        break
      end
    end
    self.shopGirdView[index]:setClickByOrder(showKey)
  end
end

function WinG2052Shop:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinG2052Shop:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function()
    self:updateShopContentInfo()
  end)
end

function WinG2052Shop:initView(goodsId)
  if goodsId == nil then
    self:forceJumpToTab(DefaultMainTabIndex)
    self:updateShopContentInfo()
  else
    local initGoodsCfg = BusinessGoodsConfig:getCfgById(goodsId)
    for index, info in pairs(self.showTabList) do
      if info.goodsType == initGoodsCfg.goodsType then
        self:forceJumpToTab(index)
        self:updateShopContentInfo()
        LuaTimer:scheduleTimer(function()
          self:forceJumpToItem(goodsId)
        end, 500, 1)
        return
      end
    end
    self:forceJumpToTab(DefaultMainTabIndex)
    self:updateShopContentInfo()
  end
end

function WinG2052Shop:forceJumpToTab(index)
  if not index then
    return
  end
  self.gvShopTab:setClickByOrder(index)
end

function WinG2052Shop:forceJumpToItem(goodsId)
  for index, info in pairs(self.shopAdapter[CurMainTabIndex].data) do
    if info.data.goodsId == goodsId then
      self.shopGirdView[CurMainTabIndex]:setClickByOrder(index)
      local offset = -187 * math.floor((index - 1) / 3)
      self.shopCellList[CurMainTabIndex]:SetScrollOffset(offset)
    end
  end
end

function WinG2052Shop:updateShopContentInfo()
  local privilegeInfo = Me:getPrivilegeInfo()
  for index, val in pairs(self.showTabList) do
    if val.isItemShop then
      if self.shopAdapter[index] then
        self.shopAdapter[index]:notifyDataChange()
      end
    else
      if privilegeInfo[val.type] then
        val.isHave = true
      else
        val.isHave = false
      end
      self.shopCellList[index]:invoke("updateShowCellShow", val)
    end
  end
end

function WinG2052Shop:onHide()
  UI:closeWnd("g2052Shop")
end

function WinG2052Shop:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052Shop")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinG2052Shop:onOpen(goodsId)
  self:initView(goodsId)
  self:subscribeEvent()
end

function WinG2052Shop:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinG2052Shop
