local WinG2052Marketing = M
local itemInfo = {
  [1] = {
    icon = "set:g2052_main.json image:icon_0_house",
    tag = "set:g2052_main.json image:icon_0_vip",
    name = "g2052.gui.marketing.item.name1",
    pos = {-180, 27}
  },
  [2] = {
    icon = "set:g2052_main.json image:icon_0_carriers",
    tag = "set:g2052_main.json image:icon_0_vip",
    name = "g2052.gui.marketing.item.name2",
    pos = {-60, 27}
  },
  [3] = {
    icon = "set:g2052_main.json image:icon_0_main_character",
    tag = "set:g2052_main.json image:icon_0_vip",
    name = "g2052.gui.marketing.item.name3",
    pos = {60, 27}
  },
  [4] = {
    icon = "set:g2052_store.json image:icon_0_plots",
    tag = "",
    name = "g2052.gui.marketing.item.name4",
    pos = {-180, 140}
  },
  [5] = {
    icon = "set:g2052_function.json image:icon_0_turntable",
    tag = "",
    name = "g2052.gui.marketing.item.name5",
    pos = {-60, 140}
  },
  [6] = {
    icon = "set:g2052_function.json image:icon_0_painting",
    tag = "",
    name = "g2052.gui.marketing.item.name6",
    pos = {60, 140}
  },
  [7] = {
    icon = "set:g2052_main.json image:btn_0_chat",
    tag = "set:g2052_main.json image:icon_0_vip",
    name = "g2052.gui.marketing.item.name7",
    pos = {180, 140}
  },
  [8] = {
    icon = "set:g2052_main.json image:icon_0_children",
    tag = "set:g2052_main.json image:icon_0_vip",
    name = "g2052.gui.marketing.item.name8",
    pos = {180, 27}
  }
}

function WinG2052Marketing:init()
  WinBase.init(self, "G2052Marketing.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinG2052Marketing:initUI()
  self.imgBg = self:child("G2052Marketing-bg")
  self.txtTitle1 = self:child("G2052Marketing-title1")
  self.txtTitle2 = self:child("G2052Marketing-title2")
  self.imgLabel = self:child("G2052Marketing-label")
  self.imgPrice = self:child("G2052Marketing-price")
  self.lytWnd = self:child("G2052Marketing-wnd")
  self.lytList = self:child("G2052Marketing-list")
  self.btnBuy = self:child("G2052Marketing-buy")
  self.btnBuy:SetText(Lang:toText("g2052.gui.marketing.buy"))
  self.btnClose = self:child("G2052Marketing-close")
  self.itemArr = {}
  self.itemIconArr = {}
  self.itemTextArr = {}
  self.itemTagArr = {}
  for i = 1, 8 do
    self.itemArr[i] = self:child("G2052Marketing-item_" .. i)
    self.itemIconArr[i] = self:child("G2052Marketing-icon_" .. i)
    self.itemTextArr[i] = self:child("G2052Marketing-name_" .. i)
    self.itemTagArr[i] = self:child("G2052Marketing-tag_" .. i)
  end
  self.txtHint = self:child("G2052Marketing-hint")
  self.txtTitle1:SetText(Lang:toText("g2052.gui.marketing.super.gift"))
  self.txtTitle2:SetText(Lang:toText("gui.shop.vip.name"))
end

function WinG2052Marketing:initEvent()
  self:subscribe(self.btnBuy, UIEvent.EventButtonClick, function()
    Me:showBuyPrivilegeDialog(Define.PRIVILEGE_TYPE.VIP)
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinG2052Marketing:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    if Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", Me.platformUserId, Define.PRIVILEGE_TYPE.VIP) then
      self:onHide()
    end
  end)
end

function WinG2052Marketing:initView(productType, subType)
  if productType and subType then
    local info = Me:getMarketData()
    if not info[productType] then
      info[productType] = {}
    end
    info[productType][subType] = os.time()
    Me:setMarketData(info)
  end
  for i, v in pairs(itemInfo) do
    if self.itemArr[i] then
      self.itemArr[i]:SetArea({
        0,
        v.pos[1]
      }, {
        0,
        v.pos[2]
      }, {0, 96}, {0, 96})
    end
    if self.itemIconArr[i] then
      self.itemIconArr[i]:SetImage(v.icon)
    end
    if self.itemTextArr[i] then
      self.itemTextArr[i]:SetText(Lang:toText(v.name))
    end
    if self.itemTagArr[i] then
      self.itemTagArr[i]:SetImage(v.tag)
    end
  end
  local hint = Lang:toText("g2052.gui.marketing.hint")
  local length = self.txtHint:GetFont():GetTextExtent(hint, 1.0)
  self.txtHint:SetWidth({0, length})
  self.txtHint:SetText(hint)
end

function WinG2052Marketing:onHide()
  UI:closeWnd("g2052Marketing")
end

function WinG2052Marketing:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052Marketing")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinG2052Marketing:onOpen(productType, subType)
  self:initView(productType, subType)
  self:subscribeEvent()
end

function WinG2052Marketing:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinG2052Marketing
