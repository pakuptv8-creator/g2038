local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local ProfessionalHelper = T(Lib, "ProfessionalHelper")

function Entity.ValueFunc:professionId(value)
  if self.platformUserId == Me.platformUserId then
    local professionId = UI:getWnd("professionWnd"):getCurProfessionId()
    if not professionId or value.isFromScene then
      UI:getWnd("professionWnd"):setCurProfessionId(value.professionId)
      professionId = value.professionId
    end
    if professionId == value.professionId then
      Lib.emitEvent(Event.EVENT_PROFESSION_UPDATE_CAREER, value.isFromScene)
      ProfessionalHelper:resetMyReceiveCall(value)
    end
    if value.isFromScene then
      self:updateShowName()
    end
  else
    self:updateShowName()
  end
end

function Entity.ValueFunc:nameContent(value)
  if self.platformUserId == Me.platformUserId then
    local content = UI:getWnd("professionWnd"):getNameContent()
    if not content then
      UI:getWnd("professionWnd"):setNameContent(value)
      content = value
      self:updateShowName()
    end
  else
    self:updateShowName()
  end
end

function Entity.ValueFunc:nameColor(value)
  if self.platformUserId == Me.platformUserId then
    local content = UI:getWnd("professionWnd"):getNameColor()
    if not content then
      UI:getWnd("professionWnd"):setNameColor(value)
      content = value
      self:updateShowName()
    end
  else
    self:updateShowName()
  end
end

function Entity.ValueFunc:introduceContent(value)
  if self.platformUserId == Me.platformUserId then
    local content = UI:getWnd("professionWnd"):getIntroduceContent()
    if not content then
      UI:getWnd("professionWnd"):setIntroduceContent(value)
      content = value
      self:updateShowName()
    end
  else
    self:updateShowName()
  end
end

function Entity.ValueFunc:introduceColor(value)
  if self.platformUserId == Me.platformUserId then
    local content = UI:getWnd("professionWnd"):getIntroduceColor()
    if not content then
      UI:getWnd("professionWnd"):setIntroduceColor(value)
      content = value
      self:updateShowName()
    end
  else
    self:updateShowName()
  end
end
