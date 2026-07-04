local WinBusinessAwardPopup = M
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")

function WinBusinessAwardPopup:init()
  WinBase.init(self, "BusinessAwardPopup.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinBusinessAwardPopup:initUI()
  self.imgBg = self:child("BusinessAwardPopup-bg")
  self.imgItemBg = self:child("BusinessAwardPopup-itemBg")
  self.txtTitle = self:child("BusinessAwardPopup-title")
  self.txtTip = self:child("BusinessAwardPopup-tip")
  self.lytItemList = self:child("BusinessAwardPopup-item_list")
  self.txtTip:SetText(Lang:toText("gui.limit.time.activity.click.on.the.screen.to.continue"))
  self.txtTitle:SetText(Lang:toText("gui.limit.time.activity.congratulations"))
  self._timer = {}
  self:initItemList()
end

function WinBusinessAwardPopup:initItemList()
  self.cells = {}
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.lytItemList:AddChildWindow(self.gvItemList)
  self.gvItemList:SetMoveAble(false)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:SetClipChild(false)
  self.itemAdapter = UIMgr:new_adapter("common", 109, 130, "businessAwardItem", "BusinessAwardItem.json")
  self.gvItemList:invoke("setAdapter", self.itemAdapter)
end

function WinBusinessAwardPopup:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinBusinessAwardPopup:subscribeEvent()
end

function WinBusinessAwardPopup:initView(goodsId)
  self.goodsCfg = BusinessGoodsConfig:getCfgById(goodsId)
  if not self.goodsCfg then
    return
  end
  self.imgItemBg:SetVisible(false)
  local count = 1
  local row = 1
  self.gvItemList:InitConfig(20, 20, row)
  self.lytItemList:SetHeight({
    0,
    150 * math.ceil(count / 5)
  })
  self.lytItemList:SetWidth({
    0,
    row * 109 + 20 * (row - 1)
  })
  local data = {}
  data[1] = Me:getBusinessItemIconInfo(self.goodsCfg)
  self.itemAdapter:setData(data)
end

function WinBusinessAwardPopup:onHide()
  UI:closeWnd("businessAwardPopup")
end

function WinBusinessAwardPopup:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("businessAwardPopup")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinBusinessAwardPopup:onOpen(goodsId)
  self:initView(goodsId)
  self:subscribeEvent()
  self:showPerform()
end

function WinBusinessAwardPopup:showPerform()
  local initAlpha = 0.3
  self._root:SetAlpha(initAlpha)
  self._timer[#self._timer + 1] = Me:timer(1, function()
    initAlpha = initAlpha + 0.08
    if 1 <= initAlpha then
      initAlpha = 1
    end
    self._root:SetAlpha(initAlpha)
    return initAlpha ~= 1
  end)
end

function WinBusinessAwardPopup:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self._timer then
    for k, fun in pairs(self._timer) do
      fun()
    end
    self._timer = {}
  end
end

return WinBusinessAwardPopup
