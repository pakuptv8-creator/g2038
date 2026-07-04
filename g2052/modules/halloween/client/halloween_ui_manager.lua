local HalloweenUIManager = T(Lib, "HalloweenUIManager")
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local HalloweenExchangeConfig = T(Config, "HalloweenExchangeConfig")

function HalloweenUIManager:init()
  self.differTime = 0
  self.partEntityTop = {}
end

function HalloweenUIManager:updateMapPartUI(mapName)
  for signKey, info in pairs(self.partEntityTop) do
    if info.uiParams and info.uiParams.mapName ~= mapName then
      self:destroyPartTipsUI(signKey)
    end
  end
  self:startCheckDistanceTick()
end

function HalloweenUIManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("HalloweenUIManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("HalloweenUIManager/checkDistanceTick")
    return true
  end)
end

function HalloweenUIManager:checkDistanceTick()
  local playerPos = Me:getPosition()
  for signKey, info in pairs(self.partEntityTop) do
    local uiParams = info.uiParams
    local entity = World.CurWorld:getEntity(info.objID)
    local entityIsValid = entity and entity:isValid()
    if uiParams and uiParams.viewDistance > 0 then
      local isInRange = Lib.getPosDistance(playerPos, uiParams.position) <= uiParams.viewDistance
      local needShow = entityIsValid and isInRange and World.CurMap.name == uiParams.mapName and HalloweenHelperCommon:isHalloweenDay()
      if info.topUI and not needShow then
        self:hidePartTipsUI(signKey)
      elseif not info.topUI and needShow then
        self:showPartTipsUI(signKey)
      end
    end
  end
end

function HalloweenUIManager:destroyPartTipsUI(signKey)
  local signInfo = self.partEntityTop[signKey]
  if not signInfo then
    return
  end
  UI:closeGUIFollowWnd(signInfo.objID)
  self.partEntityTop[signKey] = nil
end

function HalloweenUIManager:createPartTipsUI(signKey)
  local signInfo = self.partEntityTop[signKey]
  if not signInfo then
    return
  end
  local partTipUI = UIMgr:new_widget(signInfo.uiParams.uiName)
  partTipUI:invoke("initPartTipsInfo", signInfo.cfg, self.differTime)
  local width = 300
  local height = 50
  local maxScale = signInfo.cfg.maxScale
  local minScale = signInfo.cfg.minScale
  local minDis = signInfo.cfg.stadia[1]
  local midDis = signInfo.cfg.stadia[2]
  local maxDis = signInfo.cfg.stadia[3]
  local offsetPos = signInfo.cfg.showOffset
  UI:openGUIFollowWnd(signInfo.objID, partTipUI, width, height, maxScale, minScale, minDis, midDis, maxDis, offsetPos, {
    x = 0,
    y = 0,
    z = 0
  })
  return partTipUI
end

function HalloweenUIManager:createPartTipsInfo(signKey, uiParams, cfg, objID)
  self.partEntityTop[signKey] = {
    uiParams = uiParams,
    topUI = nil,
    cfg = cfg,
    objID = objID
  }
end

function HalloweenUIManager:showPartTipsUI(signKey)
  local signInfo = self.partEntityTop[signKey]
  if not signInfo then
    return
  end
  if signInfo.topUI then
    return
  end
  self.partEntityTop[signKey].topUI = self:createPartTipsUI(signKey)
end

function HalloweenUIManager:hidePartTipsUI(signKey)
  local signInfo = self.partEntityTop[signKey]
  if not signInfo then
    return
  end
  if not signInfo.topUI then
    return
  end
  UI:closeGUIFollowWnd(signInfo.objID)
  self.partEntityTop[signKey].topUI = nil
end

function HalloweenUIManager:updateHalloweenSceneUIInfo(mapName, partUIData, serverTime, resetTime)
  self.differTime = serverTime - os.time()
  self:updateMapPartUI(mapName)
  for partId, info in pairs(partUIData or {}) do
    local cfg = HalloweenExchangeConfig:getCfgById(info.awardId)
    if cfg then
      local signKey = partId
      if resetTime and self.partEntityTop[signKey] and self.partEntityTop[signKey].topUI then
        self.partEntityTop[signKey].topUI:invoke("initPartTipsInfo", cfg, self.differTime)
      else
        local uiParams = {
          viewDistance = cfg.showRange,
          position = info.pos,
          mapName = mapName,
          signKey = signKey,
          uiName = "halloweenAwardInfo",
          objID = info.objID
        }
        self:createPartTipsInfo(signKey, uiParams, cfg, info.objID)
      end
    end
  end
end

function HalloweenUIManager:removeAllHalloweenUI()
  for signKey, info in pairs(self.partEntityTop) do
    self:destroyPartTipsUI(signKey)
  end
  if self.tickTimer then
    self.tickTimer()
    self.tickTimer = nil
  end
  self.partEntityTop = {}
end

HalloweenUIManager:init()
