local setting = require("common.setting")
local PartCfg = setting:mod("part")
local HalloweenHelperClient = T(Lib, "HalloweenHelperClient")
local HalloweenGhostConfig = T(Config, "HalloweenGhostConfig")
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")

function HalloweenHelperClient:init()
  Lib.subscribeEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, function()
    print("-----------------------HalloweenHelperClient  receive  EVENT_HALLOWEEN_OPEN_STATE_UPDATE ", HalloweenHelperCommon:isHalloweenDay())
    if HalloweenHelperCommon:isHalloweenDay() then
      self:createGhost()
    else
      self:clearAllGhost()
    end
  end)
end

function HalloweenHelperClient:createGhost()
  if self.halloweenGhostList then
    return
  end
  self.halloweenGhostList = {}
  self.remainGhostNum = 0
  local cfgList = HalloweenGhostConfig:getAllCfgs()
  local findGhostRecord = Me:getHalloweenFindGhostRecord()
  for _, cfg in pairs(cfgList) do
    if cfg.id and not findGhostRecord[cfg.id] then
      self:_createOneGhost(cfg)
    end
  end
  print("++++++++++++++++++++++++++ create ghost,total:", self.remainGhostNum)
end

function HalloweenHelperClient:_createOneGhost(cfg)
  local ghostSetting = PartCfg:get(cfg.cfgName)
  if not ghostSetting then
    return
  end
  local scene = World.CurWorld:getSceneManager():getOrCreateScene(Me.map.obj)
  local ghost = Lib.createPartHelper(ghostSetting, scene, Me.map, cfg.pos.rotation, cfg.pos.position)
  if ghost then
    ghost:onClientCreated()
    self:_addGhostToList(ghost:getInstanceID(), cfg)
  end
end

function HalloweenHelperClient:_addGhostToList(objID, cfg)
  local data = {
    id = cfg.id,
    objID = objID
  }
  self.halloweenGhostList[objID] = data
  self.remainGhostNum = self.remainGhostNum + 1
end

local lastShowFailTipsTime = 0
local showFailTipsInterval = 2

function HalloweenHelperClient:catchGhost(ghost)
  if not ghost or not self.halloweenGhostList then
    return
  end
  local findGhostLimit = World.cfg.halloweenSetting.findGhostMaxCount or 10
  if findGhostLimit <= Me:getCandyDayCountByType(Define.GetCandyType.FindGhost) then
    if os.time() - lastShowFailTipsTime > showFailTipsInterval then
      lastShowFailTipsTime = os.time()
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.halloween.findGhost.limit"))
    end
    return
  end
  local ghostData = self.halloweenGhostList[ghost:getInstanceID()]
  if not ghostData then
    return
  end
  print("+++++++++++++++++++++  catchGhost ", ghostData.id)
  ghost.isGhostDie = true
  self:removeOneGhost(ghostData.objID, true)
  local cfg = HalloweenGhostConfig:getCfgById(ghostData.id)
  if cfg then
    local disappearEffectName = World.cfg.halloweenSetting.findGhostDisappearEffect[cfg.type]
    if disappearEffectName then
      Blockman.instance:playEffectByPos(disappearEffectName, cfg.pos.position, cfg.pos.rotation.y, -1)
      World.Timer(30.0, function()
        Blockman.instance:delEffect(disappearEffectName, cfg.pos.position)
      end)
    end
    World.Timer(14.0, function()
      Me:sendPacket({
        pid = "findGhostGetCandyC2S",
        ghostId = ghostData.id
      })
      local reportData = {
        ghost_id = ghostData.id
      }
      Plugins.CallTargetPluginFunc("report", "report", "halloween_ghost", reportData, Me)
      local candyEffectName = World.cfg.halloweenSetting.findGhostCandyEffect[cfg.type]
      if candyEffectName then
        Blockman.instance:playEffectByPos(candyEffectName, cfg.pos.position, cfg.pos.rotation.y, -1)
        World.Timer(30.0, function()
          Blockman.instance:delEffect(candyEffectName, cfg.pos.position)
        end)
      end
      local ghostDeadSoundKey = World.cfg.halloweenSetting.ghostDeadSoundKey
      if ghostDeadSoundKey then
        Me:playSoundByKey(ghostDeadSoundKey)
      end
    end)
  end
end

function HalloweenHelperClient:removeOneGhost(objID, showTips)
  if not objID then
    return
  end
  local ghost = Instance.getByInstanceId(objID)
  if ghost and ghost:isValid() then
    ghost:destroy()
  end
  self.halloweenGhostList[objID] = nil
  self.remainGhostNum = self.remainGhostNum - 1
  if showTips then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText({
      "g2052.gui.halloween.find.ghost.num",
      self.remainGhostNum
    }))
    if self.remainGhostNum <= 0 then
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  all ghost found ! ")
    end
  end
end

function HalloweenHelperClient:clearAllGhost()
  if not self.halloweenGhostList then
    return
  end
  for i, v in pairs(self.halloweenGhostList) do
    local ghost = Instance.getByInstanceId(v.objID)
    if ghost and ghost:isValid() then
      self:removeOneGhost(v.objID)
      print("<<<--------------------------------- HalloweenHelperClient:clearAllGhost, ", v.id)
    end
  end
end

HalloweenHelperClient:init()
