local PropsConfig = T(Config, "PropsConfig")
local RedDotConfig = T(Config, "RedDotConfig")
local cjson = require("cjson")
local Player = _ENV.Player

function Player:requestGiveProp(targetUserId, itemId)
  if not self.requestGivePropCache then
    self.requestGivePropCache = {}
  end
  if self.requestGivePropCache[targetUserId] and World.Now() < self.requestGivePropCache[targetUserId] + World.cfg.requestGivePropCd * 20 then
    Lib.logDebug(" ---------\231\187\153\233\129\147\229\133\183\229\134\183\229\141\180\228\184\173-------")
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.prop.send.CDTime"))
    return
  end
  self.requestGivePropCache[targetUserId] = World.Now()
  self:sendPacket({
    pid = "requestGiveProp",
    targetUserId = targetUserId,
    itemId = itemId
  })
end

function Player:selectPropLogic(data)
  local inUseProp = Me:getInUseProp()
  local itemId = data.id
  local itemInfo = PropsConfig:getCfgById(itemId)
  if itemInfo.throwCfgType == "entity" and itemInfo.throwTrigger == Define.ThrowObjTrigger.useItem then
    if Me:getInteractCarEnterID() ~= "" then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
      return
    end
    if itemInfo.rideOnPlayerIndex > 0 and (not inUseProp or inUseProp.itemId ~= itemId) then
      local footPos = Me:getPosition()
      local pos = Me:getEyePos()
      local midPos = Lib.v3(pos.x, (pos.y - footPos.y) / 2 + footPos.y, pos.z)
      local frontPos = Me:getFrontPos(1, false, false)
      local dir = Lib.v3cut(frontPos, pos)
      dir = Lib.v3normalize(dir)
      local dis = 1.5
      if itemId == 1655 then
        dis = 2.5
      end
      local chestResult = Me.map:getPhysicsWorld():raycast(pos, dir, dis, -1) or {}
      local chestResult_mid = Me.map:getPhysicsWorld():raycast(midPos, dir, dis, -1) or {}
      if chestResult.targetType ~= 0 or chestResult_mid.targetType ~= 0 then
        local isObstacle_eye = chestResult.targetType ~= 0
        local isObstacle_mid = chestResult_mid.targetType ~= 0
        
        local function checkAgain(chestResult)
          local chestTarget = chestResult.target
          if chestTarget and chestTarget.isPlayer then
            return false
          end
          if chestTarget and chestTarget.cfg and chestTarget:cfg() and chestTarget:cfg().isTrolley then
            return false
          end
          local isVisible = chestTarget:getProperty("isVisible")
          local materialAlpha = chestTarget:getProperty("materialAlpha")
          local useCollide = chestTarget:getProperty("useCollide")
          if (isVisible == "false" or materialAlpha == "0") and useCollide == "false" then
            return false
          end
          return true
        end
        
        isObstacle_eye = isObstacle_eye and checkAgain(chestResult)
        isObstacle_mid = isObstacle_mid and checkAgain(chestResult_mid)
        if isObstacle_eye or isObstacle_mid then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
          return
        end
      end
    end
  end
  self:clientItemUser(data.id)
  Me:sendPacket({
    pid = "OnOperationBag",
    params = {
      id = data.id
    }
  }, function(ret)
    if not ret then
      print("-- OnOperationBag no choice item--")
    end
  end)
end

local KEY_RED_DOT = {
  [0] = RedDotConfig.RD_KEY.BagHasNewAll,
  [1] = RedDotConfig.RD_KEY.BagHasNewLife,
  [2] = RedDotConfig.RD_KEY.BagHasNewGames,
  [3] = RedDotConfig.RD_KEY.BagHasNewCareer,
  [4] = RedDotConfig.RD_KEY.BagHasNewFood
}

function Player:updatePropsRedDotStatus()
  for idx, key in pairs(KEY_RED_DOT) do
    local props = Me:getPropUnlockedByType(idx)
    local hasNew = false
    for _, info in pairs(props) do
      if info.isNew == 1 then
        hasNew = true
        break
      end
    end
    Plugins.CallPluginFunc("resetRedDotState", key, hasNew and 1 or 0)
  end
end

function Player:loadNewPropsScanRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewPropsScanRecord-" .. userId .. ".json"
  local file = io.open(path, "r")
  if not file then
    self.newPropsScanRecord = {}
    return
  end
  file:close()
  self.newPropsScanRecord = Lib.read_json_file(path) or {}
  for id, _ in pairs(self.newPropsScanRecord) do
    PropsConfig:updateIsNewStatusById(tonumber(id))
  end
end

function Player:saveNewPropsScanRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewPropsScanRecord-" .. userId .. ".json"
  local file, errmsg = io.open(path, "w")
  if not file then
    print("\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129saveNewPropsScanRecord  error \239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129")
    print(errmsg)
    return false
  end
  local ok, content = pcall(cjson.encode, self.newPropsScanRecord)
  assert(ok, path)
  file:write(Lib.jsonToFormat(content))
  file:close()
end

local function updateCurSkin(self, itemId, add)
  local itemInfo = PropsConfig:getCfgById(itemId) or {}
  local skin = itemInfo.skin and itemInfo.skin[1]
  if skin then
    if add then
      self:applySkinPart(skin)
    else
      local reset = {}
      for m, _ in pairs(skin) do
        reset[m] = 0
      end
      self:applySkinPart(reset)
    end
  end
end

function Player:clientItemUser(itemId)
  if not self.clientBagsInfo then
    self:syncItemUserInfo()
  end
  local add = true
  local oldItemId = itemId
  local oldIndex
  for i, v in pairs(self.clientBagsInfo) do
    if v.inUse then
      oldItemId = v.itemId
      v.inUse = false
    end
    if v.itemId == itemId then
      oldIndex = i
      add = false
    end
  end
  local newItemId
  if add then
    if #self.clientBagsInfo >= Define.Prop.MaxHandBagCount then
      table.remove(self.clientBagsInfo, 1)
    end
    newItemId = itemId
    table.insert(self.clientBagsInfo, {
      inUse = true,
      index = 1,
      itemId = itemId
    })
  else
    table.remove(self.clientBagsInfo, oldIndex)
    if itemId ~= oldItemId then
      oldItemId = nil
    end
  end
  if oldItemId then
    updateCurSkin(self, oldItemId, false)
  end
  if newItemId then
    updateCurSkin(self, newItemId, true)
  end
  Lib.emitEvent(Event.EVENT_UPDATE_CLIENT_BAG_INFO)
end

function Player:syncItemUserInfo()
  self.clientBagsInfo = self:getHandbagsInfo()
end
