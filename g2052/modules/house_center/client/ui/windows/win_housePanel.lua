local WinHousePanel = M
local HouseConfig = T(Config, "HouseConfig")

function WinHousePanel:init()
  WinBase.init(self, "HousePanel.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinHousePanel:initUI()
  self.lytBg = self:child("HousePanel-bg")
  self.imgHead = self:child("HousePanel-head")
  self.tetDec = self:child("HousePanel-dec")
  self.txtOwnerName = self:child("HousePanel-ownerName")
  self.txtIndex = self:child("HousePanel-index")
  self.imgBg = self:child("HousePanel-bgImg")
end

function WinHousePanel:initEvent()
end

function WinHousePanel:subscribeEvent()
end

function WinHousePanel:initView(params)
  self.params = params
  self.txtIndex:SetText(params and "#" .. params.landIndex)
  self:updateOwnerName()
end

function WinHousePanel:updateOwnerName()
  local player = Game.GetPlayerByUserId(self.params.ownerId) or {}
  if self.params and self.params.ownerId then
    self.imgBg:SetVisible(true)
    if self.params.doorplateText then
      self.tetDec:SetText(self.params.doorplateText)
    end
    local color = "#FFFFFF"
    if self.params.doorplateTextColor then
      color = self.params.doorplateTextColor
    end
    self.tetDec:SetTextColor(Lib.getTextColor(color))
  else
    self.imgBg:SetVisible(false)
    self.tetDec:SetText("")
  end
  self:updateNameShow(player, self.params.ownerName)
end

function WinHousePanel:updateNameShow(player, ownerName)
  local landPanelLang = "g2052.gui.create"
  if self.params and self.params.landName then
    local landInfo = HouseConfig:getLandInfo(self.params.landName) or {}
    landPanelLang = landInfo.landPanelLang and landInfo.landPanelLang or landPanelLang
  end
  local text = ownerName or Lang:toText(landPanelLang)
  if player.objID then
    text = player.name
  end
  self.txtOwnerName:SetText(text)
end

function WinHousePanel:onHide()
  UI:closeWnd("housePanel")
end

function WinHousePanel:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("housePanel")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinHousePanel:onOpen(params)
  self:initView(params)
  self:subscribeEvent()
end

function WinHousePanel:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinHousePanel
