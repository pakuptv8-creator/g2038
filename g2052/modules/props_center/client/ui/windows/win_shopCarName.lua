local WinShopCarName = M
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WinShopCarName:init()
  WinBase.init(self, "BillboardText.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinShopCarName:initUI()
  self.txtContent = self:child("BillboardText-Content")
end

function WinShopCarName:initEvent()
end

function WinShopCarName:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_SHOP_CAR_NAME, function(objID)
    if objID == self.objID then
      self:updateContentInfo()
    end
  end)
end

function WinShopCarName:initView(objID)
  self.objID = objID
  self:updateContentInfo()
  self:updateContentSize()
end

function WinShopCarName:updateContentInfo()
  local entity = World.CurWorld:getEntity(self.objID)
  if not entity or not entity:isValid() then
    return
  end
  local billboardInfo = entity:getShopCarName()
  if billboardInfo then
    self.txtContent:SetText(billboardInfo)
  end
  local billboardColor = entity:getShopCarNameColor()
  if billboardColor then
    self.txtContent:SetTextColor(Lib.getTextColor(billboardColor))
  end
end

function WinShopCarName:updateContentSize()
  local entity = World.CurWorld:getEntity(self.objID)
  if not entity or not entity:isValid() then
    return
  end
  local shapeScale = 1
  if DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    shapeScale = entity:getGiantShape() or 1
  else
    shapeScale = entity:getShapeScale() or 1
  end
  local cfg = World.cfg.sceneBillUI
  self._root:SetWidth({
    0,
    cfg.width * shapeScale
  })
  self._root:SetHeight({
    0,
    cfg.height * shapeScale
  })
  local fontSize = math.floor(cfg.textSize * shapeScale)
  if fontSize % 2 == 1 then
    fontSize = fontSize - 1
  end
  if fontSize < 6 then
    fontSize = 6
  end
  local posX = 7 + (shapeScale - 1) * 20
  self.txtContent:SetXPosition({0, posX})
  self.txtContent:SetFontSize("HT" .. fontSize)
end

function WinShopCarName:onHide()
  UI:closeWnd("shopCarName")
end

function WinShopCarName:onOpen(objID)
  self:initView(objID)
  self:subscribeEvent()
end

function WinShopCarName:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinShopCarName
