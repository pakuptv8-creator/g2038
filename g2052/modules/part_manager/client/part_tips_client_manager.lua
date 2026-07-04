local PartTipsClientManager = T(Lib, "PartTipsClientManager")
local PartSceneNameConfig = T(Config, "PartSceneNameConfig")

function PartTipsClientManager:init()
  self.partTipList = {}
end

function PartTipsClientManager:updateMapPartUI(mapName)
  for signKey, info in pairs(self.partTipList) do
    if info.uiParams and info.uiParams.mapName ~= mapName then
      self:destroyPartTipsUI(signKey)
    end
  end
  self:startCheckDistanceTick()
end

function PartTipsClientManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("PartTipsClientManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("PartTipsClientManager/checkDistanceTick")
    return true
  end)
end

function PartTipsClientManager:checkDistanceTick()
  local playerPos = Me:getPosition()
  for signKey, info in pairs(self.partTipList) do
    local uiParams = info.uiParams
    if uiParams and uiParams.viewDistance > 0 then
      local isInRange = Lib.getPosDistance(playerPos, uiParams.position) <= uiParams.viewDistance
      local needShow = isInRange and World.CurMap.name == uiParams.mapName
      if info.isShow and not needShow then
        self:hidePartTipsUI(signKey)
      elseif not info.isShow and needShow then
        self:showPartTipsUI(signKey)
      end
    end
  end
end

function PartTipsClientManager:destroyPartTipsUI(signKey)
  local signInfo = self.partTipList[signKey]
  if not signInfo then
    return
  end
  if signInfo.removeFun then
    signInfo.removeFun()
  end
  self.partTipList[signKey] = nil
end

function PartTipsClientManager:createPartTipsUI(signKey)
  local signInfo = self.partTipList[signKey]
  if not signInfo then
    return
  end
  local partTipUI = UIMgr:new_widget(signInfo.uiParams.uiName)
  partTipUI:invoke("updatePartTipsInfo", signInfo.cfg)
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

function PartTipsClientManager:createPartTipsInfo(signKey, uiParams, cfg)
  self.partTipList[signKey] = {
    uiParams = uiParams,
    isShow = false,
    ui = nil,
    cfg = cfg,
    removeFun = nil
  }
end

function PartTipsClientManager:showPartTipsUI(signKey)
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

function PartTipsClientManager:hidePartTipsUI(signKey)
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

function PartTipsClientManager:updatePartSceneUIInfo(mapName, partUIData)
  self:updateMapPartUI(mapName)
  for partId, info in pairs(partUIData or {}) do
    local cfg = PartSceneNameConfig:getCfgById(info.partName)
    if cfg then
      local signKey = partId
      local uiParams = {
        viewDistance = cfg.showRange,
        position = info.pos,
        mapName = mapName,
        signKey = signKey,
        uiName = "partSceneTips"
      }
      self:createPartTipsInfo(signKey, uiParams, cfg)
    end
  end
end

PartTipsClientManager:init()
