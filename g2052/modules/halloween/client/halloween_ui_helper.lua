local HalloweenUIHelper = T(Lib, "HalloweenUIHelper")
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local HalloweenExchangeConfig = T(Config, "HalloweenExchangeConfig")

function HalloweenUIHelper:init()
  self.differTime = 0
  self.partTipList = {}
end

function HalloweenUIHelper:updateMapPartUI(mapName)
  for signKey, info in pairs(self.partTipList) do
    if info.uiParams and info.uiParams.mapName ~= mapName then
      self:destroyPartTipsUI(signKey)
    end
  end
  self:startCheckDistanceTick()
end

function HalloweenUIHelper:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("HalloweenUIHelper/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("HalloweenUIHelper/checkDistanceTick")
    return true
  end)
end

function HalloweenUIHelper:checkDistanceTick()
  local playerPos = Me:getPosition()
  for signKey, info in pairs(self.partTipList) do
    local uiParams = info.uiParams
    if uiParams and uiParams.viewDistance > 0 then
      local isInRange = Lib.getPosDistance(playerPos, uiParams.position) <= uiParams.viewDistance
      local needShow = isInRange and World.CurMap.name == uiParams.mapName and HalloweenHelperCommon:isHalloweenDay()
      if info.isShow and not needShow then
        self:hidePartTipsUI(signKey)
      elseif not info.isShow and needShow then
        self:showPartTipsUI(signKey)
      end
    end
  end
end

function HalloweenUIHelper:destroyPartTipsUI(signKey)
  local signInfo = self.partTipList[signKey]
  if not signInfo then
    return
  end
  if signInfo.removeFun then
    signInfo.removeFun()
  end
  self.partTipList[signKey] = nil
end

function HalloweenUIHelper:createPartTipsUI(signKey)
  local signInfo = self.partTipList[signKey]
  if not signInfo then
    return
  end
  local partTipUI = UIMgr:new_widget(signInfo.uiParams.uiName)
  partTipUI:invoke("initPartTipsInfo", signInfo.cfg, self.differTime)
  self.partTipList[signKey].removeFun = UILib.uiFollowInstance(partTipUI, signInfo.uiParams.position, {
    anchor = {x = 0.5, y = 0.5},
    offset = signInfo.cfg.showOffset,
    minScale = signInfo.cfg.minScale,
    maxScale = signInfo.cfg.maxScale,
    autoScale = signInfo.cfg.isAutoScale,
    autoAddDeskop = true,
    canAroundYaw = false
  })
  return partTipUI
end

function HalloweenUIHelper:createPartTipsInfo(signKey, uiParams, cfg)
  self.partTipList[signKey] = {
    uiParams = uiParams,
    isShow = false,
    ui = nil,
    cfg = cfg,
    removeFun = nil
  }
end

function HalloweenUIHelper:showPartTipsUI(signKey)
  local signInfo = self.partTipList[signKey]
  if not signInfo then
    return
  end
  if signInfo.isShow then
    return
  end
  if not self.partTipList[signKey].ui then
    self.partTipList[signKey].ui = self:createPartTipsUI(signKey)
  end
  self.partTipList[signKey].ui:SetVisible(true)
  self.partTipList[signKey].isShow = true
end

function HalloweenUIHelper:hidePartTipsUI(signKey)
  local signInfo = self.partTipList[signKey]
  if not signInfo then
    return
  end
  if not signInfo.isShow then
    return
  end
  if not signInfo.ui then
    return
  end
  self.partTipList[signKey].ui:SetVisible(false)
  self.partTipList[signKey].isShow = false
end

function HalloweenUIHelper:updateHalloweenSceneUIInfo(mapName, partUIData, serverTime)
  self.differTime = serverTime - os.time()
  self:updateMapPartUI(mapName)
  for partId, info in pairs(partUIData or {}) do
    local cfg = HalloweenExchangeConfig:getCfgById(info.awardId)
    if cfg then
      local signKey = partId
      local uiParams = {
        viewDistance = cfg.showRange,
        position = info.pos,
        mapName = mapName,
        signKey = signKey,
        uiName = "halloweenAwardInfo"
      }
      self:createPartTipsInfo(signKey, uiParams, cfg)
    end
  end
end

function HalloweenUIHelper:removeAllHalloweenUI()
  for signKey, info in pairs(self.partTipList) do
    self:destroyPartTipsUI(signKey)
  end
  if self.tickTimer then
    self.tickTimer()
    self.tickTimer = nil
  end
  self.partTipList = {}
end

HalloweenUIHelper:init()
