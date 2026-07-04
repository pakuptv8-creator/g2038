local handles = T(Player, "PackageHandlers")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local RegionEffectsConfig = T(Config, "RegionEffectsConfig")
local PartUIClientManager = T(Lib, "PartUIClientManager")
local PartTipsClientManager = T(Lib, "PartTipsClientManager")
local PlayerPhotographManager = T(Lib, "PlayerPhotographManager")
local setting = require("common.setting")
local PartCfg = setting:mod("part")

function handles:bombReady(packet)
  print("bomb ready---------------------------")
  if Me.map.name ~= packet.mapName then
    return
  end
  local isInEditorMode = Plugins.CallTargetPluginFunc("inner_mobile_editor", "isInEditorMode")
  if isInEditorMode and Me.platformUserId ~= packet.fromUserId then
    return
  end
  local effectPos = packet.pos
  local targetID = packet.targetPartID
  local bombID = packet.bombPartID
  local path = packet.effect and "assert/effect/" .. packet.effect or "assert/effect/g2052_c4_explode.effect"
  Blockman.instance:playEffectByPos(path, effectPos, 0, packet.effectTime or 600, {
    x = 2,
    y = 2,
    z = 2
  })
  if packet.sound and packet.sound ~= "" then
    Me:play3dSoundByKey(packet.sound, effectPos)
  end
end

function handles:eventBroadcast(packet)
  local eventType = packet.type
  if eventType == Define.PART_EVENT.Explode_Vault_Gate then
  elseif eventType == Define.PART_EVENT.Explode_House_Safe then
    local fromUid = packet.fromUid
    if fromUid ~= Me.platformUserId then
      AsyncProcess.GetOnePlayerDetailData(fromUid, function(ret)
        if ret and ret.nickName then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", string.format(Lang:toText("g2052.event.explode.house.safe"), ret.nickName))
        end
      end)
    end
  end
end

function handles:onTouchLadderEnd(packet)
  PlayerControl.forceJump()
end

function handles:playerDoSwing(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  local part = Instance.getByInstanceId(packet.partID)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  PartManagerHelper:startSwing(entity, part, packet.oldGravity)
end

function handles:playerStopSwing(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if not entity or not entity:isValid() then
    return
  end
  PartManagerHelper:stopSwing(entity)
end

function handles:onStartSlideLadderInteract(packet)
  local player = World.CurWorld:getEntity(packet.objID)
  if player and player:isValid() then
    player:setActorHide(true)
  end
  local entity = World.CurWorld:getEntity(packet.targetID)
  if not entity or not entity:isValid() then
    return
  end
  local mirror = World.CurWorld:getEntity(packet.mirrorID)
  if mirror and mirror:isValid() then
    mirror:copyHeadInfo(player)
  end
  if entity:isActorPrepared() then
    PartManagerHelper:startSlideLadder(entity, player, packet)
  else
    local waiteActorPreparedTime = 0
    World.Timer(1, function()
      if not entity or not entity:isValid() then
        return false
      end
      waiteActorPreparedTime = waiteActorPreparedTime + 1
      if 100 <= waiteActorPreparedTime then
        return false
      end
      if entity:isActorPrepared() then
        PartManagerHelper:startSlideLadder(entity, player, packet)
        return false
      end
      return true
    end)
  end
end

function handles:onStopSlideLadderInteract(packet)
  PartManagerHelper:stopSlideLadder(packet.targetID, packet.objID)
end

function handles:SCUpdateEffectOnPart(packet)
  self:clientDoPlayerPartEffect(packet)
end

function handles:SCPushPartEffectState(packet)
  for _, effectInfo in pairs(packet.dataList) do
    self:clientDoPlayerPartEffect(effectInfo)
  end
end

function handles:SCPushPartLightState(packet)
  for _, effectInfo in pairs(packet.dataList) do
    self:clientDoPartLight(effectInfo)
  end
end

function handles:partLightOnFireState(packet)
  self:clientDoPartLight(packet)
end

function handles:SCPushFurnitureInteractState(packet)
  PartManagerHelper:updateFurnitureInteractState(packet)
  if self == Me then
    if packet.isSitDown then
      Me:setProp("rotateCheckCollideProp", 0)
    else
      Me:setProp("rotateCheckCollideProp", Me.useTrolley and 1 or 0)
    end
  end
end

function handles:SyncFurnitureInteractState(packet)
  PartManagerHelper:SyncFurnitureInteractState(packet)
end

function handles:SyncSingleInteractState(packet)
  PartManagerHelper:SyncSingleInteractState(packet)
end

function handles:SCPushSingleInteractState(packet)
  PartManagerHelper:updateSingleInteractState(packet)
end

function handles:SyncPrinterInteractState(packet)
  PartManagerHelper:SyncPrinterInteractState(packet)
end

function handles:SCPushPrinterInteractState(packet)
  PartManagerHelper:updatePrinterInteractState(packet)
end

function handles:hideEntity(packet)
  local player = World.CurWorld:getEntity(packet.objID)
  if player and player:isValid() then
    player:setActorHide(true)
  end
end

function handles:initPartRegionEffect(packet)
  local visualDistance = World.cfg.worldEffectVisualDistance
  if visualDistance then
    Blockman.instance.gameSettings:setWorldEffectVisualDistance(visualDistance)
  end
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(Player.CurPlayer.map.obj)
  local posList = packet.pos
  for id, pos in pairs(posList) do
    local conf = RegionEffectsConfig:getCfgById(id)
    if conf then
      local effectName = conf.effectName
      local scale = conf.scale
      local rotation = conf.rotation or Lib.v3(0, 0, 0)
      local yaw = conf.yaw
      local effectNode = EffectNode.Load(effectName)
      effectNode:start()
      effectNode:setWorldPosition(Lib.v3(pos.x, pos.y, pos.z))
      effectNode:setWorldScale(Lib.v3(scale.x, scale.y, scale.z))
      effectNode:setWorldRotation(rotation)
      scene:getRoot():addChild(effectNode)
      if not Me:data("main").PartRegionEffect then
        Me:data("main").PartRegionEffect = {}
      end
      Me:data("main").PartRegionEffect[id] = effectNode
    end
  end
end

function handles:createClientFootball(packet)
  local player = World.CurWorld:getEntity(packet.objID)
  if player and player:isValid() then
    local cfg = PartCfg:get(packet.cfgName)
    if not cfg then
      return
    end
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getOrCreateScene(player.map.obj)
    local part = Instance.newInstance(cfg, player.map)
    if part then
      part:setParent(scene:getRoot())
      local pos = player:getFrontPos(1, true, false)
      local throwPos = packet.throwPos
      if throwPos then
        pos = pos + Lib.v3(throwPos[2] or 0, throwPos[3] or 0, throwPos[4] or 0)
      end
      part:setPosition(pos)
      if not Me:data("main").football then
        Me:data("main").football = {}
      end
      Me:data("main").football[packet.objID] = part
    end
  end
end

function handles:CancelClientThrowProp(packet)
  if Me:data("main").football and Me:data("main").football[packet.objID] then
    local football = Me:data("main").football[packet.objID]
    if football and football:isValid() then
      football:destroy()
    end
    Me:data("main").football[packet.objID] = nil
  end
end

function handles:UpdatePolicePictureShow(packet)
  if not Me.policePictureUI then
    Me.policePictureUI = {}
  end
  if not Me.policePictureUI[packet.partID] then
    local uiName = "policePicture"
    local pictureUIKey = uiName .. packet.partID
    local height = packet.width / Define.DefaultSceneRatio
    Me.policePictureUI[packet.partID] = UI:openSceneWnd(pictureUIKey, uiName, packet.width / 64, height / 64, packet.rotate, packet.position, packet.playerList)
  else
    Me.policePictureUI[packet.partID]:initView(packet.playerList)
  end
end

function handles:SCPlayerPhotographShow(packet)
  PlayerPhotographManager:updatePlayerPhotographShow(packet)
end

function handles:SCPushClientBiddingPart(packet)
  PartManagerHelper:updateClientBiddingPart(packet.params)
end

function handles:SCPartUIMapInfo(packet)
  PartTipsClientManager:updatePartSceneUIInfo(packet.mapName, packet.partUIData)
end

function handles:SCPartContentMapInfo(packet)
  PartUIClientManager:updatePartSceneUIInfo(packet.mapName, packet.partUIData)
end

function handles:SCOpenPartContentEditWnd(packet)
  PartUIClientManager:openPartContentEditWnd(packet.partID, packet.mapName, packet.partParams)
end

function handles:SCUpdatePartContentShow(packet)
  PartUIClientManager:updatePartContentShow(packet.partID, packet.partUIInfo, packet.mapName)
end

function handles:SCPushClientBindPart(packet)
  PartManagerHelper:updateClientBindPart(packet.params)
end

function handles:SCPushOccupationResult(packet)
  if packet.resultType == 1 then
    local desc = Lang:toText({
      "g2052.gui.occupation.others",
      Lang:toText(packet.goodsName or "")
    })
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", desc)
  elseif packet.resultType == 2 then
    local desc = Lang:toText({
      "g2052.gui.occupation.own",
      Lang:toText(packet.goodsName or "")
    })
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", desc)
  end
end
