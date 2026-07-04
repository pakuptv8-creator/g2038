local Entity = _ENV.Entity

function Entity.ClickProp:openUI(params, from)
  if not from:isValid() or from.objID ~= Me.objID or from.objID == self.objID then
    return
  end
  if self:cfg().entityType == Define.EntityType.Palette then
    UI:openWnd("palette", self:getPaletteData(), self.objID)
  end
end
