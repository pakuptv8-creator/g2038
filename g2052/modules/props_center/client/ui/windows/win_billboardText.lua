local WinBillboardText = M
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WinBillboardText:init()
  WinBase.init(self, "BillboardText.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinBillboardText:initUI()
  self.txtContent = self:child("BillboardText-Content")
end

function WinBillboardText:initEvent()
end

function WinBillboardText:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_BILLBOARD_INFO, function(objID)
    if objID == self.objID then
      self:updateContentInfo()
    end
  end)
end

function WinBillboardText:initView(objID)
  self.objID = objID
  self:updateContentInfo()
  self:updateContentSize()
end

function WinBillboardText:updateContentInfo()
  local entity = World.CurWorld:getEntity(self.objID)
  if not entity or not entity:isValid() then
    return
  end
  local billboardInfo = entity:getBillboardInfo()
  if billboardInfo then
    self.txtContent:SetText(entity:getBillboardInfo())
  end
  local billboardColor = entity:getBillboardColor()
  if billboardColor then
    self.txtContent:SetTextColor(Lib.getTextColor(billboardColor))
  end
end

function WinBillboardText:updateContentSize()
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

function WinBillboardText:onHide()
  UI:closeWnd("billboardText")
end

function WinBillboardText:onOpen(objID)
  self:initView(objID)
  self:subscribeEvent()
end

function WinBillboardText:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinBillboardText
