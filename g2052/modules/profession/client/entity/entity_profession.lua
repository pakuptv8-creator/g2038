local Entity = _ENV.Entity
local EntityClient = _ENV.EntityClient
local ProfessionalHelper = T(Lib, "ProfessionalHelper")
local oldUpdateShowName = EntityClient.updateShowName

function EntityClient:updateShowName()
  oldUpdateShowName(self)
  if self.isPlayer then
    local professionId = self:getProfessionId()
    local nameStr = self:getNameContent()
    local nameColor = self:getNameColor()
    local introduceStr = self:getIntroduceContent()
    local introduceColor = self:getIntroduceColor()
    self:updateHeadNameShow(professionId, nameStr, nameColor, introduceStr, introduceColor)
  end
end

function EntityClient:updateHeadNameShow(professionId, nameStr, nameColor, introduceStr, introduceColor)
  local professionId1 = professionId or self:getProfessionId()
  local nameStr1 = nameStr or self:getNameContent()
  local nameColor1 = nameColor or self:getNameColor()
  local introduceStr1 = introduceStr or self:getIntroduceContent()
  local introduceColor1 = introduceColor or self:getIntroduceColor()
  local nameInfo = self:getHeadShowNameText(professionId1, nameStr1, nameColor1, introduceStr1, introduceColor1)
  self:setShowName1(nameInfo, World.cfg.headFont or "HT24", World.cfg.headFontHeight or -0.4)
end

function EntityClient:getHeadShowNameText(professionId, nameStr, nameColor, introduceStr, introduceColor)
  local lineNum = 0
  local nextNum = 0
  local headIcon = false
  local headStr = ""
  local color = "[C=FF" .. nameColor .. "]"
  if nameStr and nameStr ~= "" then
    if lineNum > nextNum then
      nextNum = nextNum + 1
      headStr = headStr .. "\n"
    end
    headStr = headStr .. color .. nameStr
    lineNum = lineNum + 1
  end
  local iColor = "[C=FF" .. introduceColor .. "]"
  if introduceStr and introduceStr ~= "" then
    if nextNum < lineNum then
      nextNum = nextNum + 1
      headStr = headStr .. "\n"
    end
    headStr = headStr .. iColor .. introduceStr
    lineNum = lineNum + 1
  end
  local professionIcon = ProfessionalHelper:getHeadProfessionIcon(professionId)
  if professionIcon ~= "" then
    headStr = headStr .. "\n" .. "[P=" .. professionIcon .. "]"
    headIcon = true
  end
  return headStr
end
