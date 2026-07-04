local GraffitiMgr = T(Lib, "GraffitiMgr")
local GraffitiConfig = T(Config, "GraffitiConfig")
local graffitiSetting = World.cfg.graffitiSetting

function GraffitiMgr:init()
  self.doodleEffectDict = {}
  self.materialList = {}
  self.doodleEffectTimer = World.Timer(20, function()
    local curTime = os.time()
    for _, doodleList in pairs(self.doodleEffectDict) do
      for i = #doodleList, 1, -1 do
        local data = doodleList[i]
        if data and curTime >= data.disappearTime then
          data.maskTimer()
          self:cacheMaterial(data.material)
          data.part:destroy()
          table.remove(doodleList, i)
        end
      end
    end
    return true
  end)
end

function GraffitiMgr:createDoodleEffect(data)
  local config = GraffitiConfig:getCfgById(data.doodleId)
  if config then
    local doodleList = self.doodleEffectDict[data.objID]
    if not doodleList then
      doodleList = {}
      self.doodleEffectDict[data.objID] = doodleList
    end
    if #doodleList >= graffitiSetting.MaxSprayNum then
      local data = table.remove(doodleList, 1)
      if data then
        data.maskTimer()
        self:cacheMaterial(data.material)
        data.part:destroy()
      end
    end
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getOrCreateScene(Me.map.obj)
    local material = self:getMaterial()
    local index = 1
    material:activeTexture(0, config.imagePath)
    self:setDoodleMask(index, material)
    local part = PlaneNode.Create(material)
    part:setPosition(data.pos)
    part:setScale(Lib.v3(2, 2, 0.1))
    if data.isGround then
      part:setLocalQuaternion(Quaternion.fromEulerAngle(-90, data.yaw or 0, data.roll or 0))
    else
      part:setLocalQuaternion(Quaternion.fromEulerAngle(0, data.yaw or 0, data.roll or 0))
    end
    part:setParent(scene:getRoot())
    local maskTimer = World.Timer(1, function()
      index = index + 1
      self:setDoodleMask(index, material)
      if 16 <= index then
        return false
      end
      return true
    end)
    local effectData = {
      effectName = config.imagePath,
      part = part,
      disappearTime = os.time() + graffitiSetting.SprayTime,
      material = material,
      maskTimer = maskTimer
    }
    table.insert(self.doodleEffectDict[data.objID], effectData)
  end
end

function GraffitiMgr:setDoodleMask(index, material)
  material:activeTexture(1, "doodle_mask" .. index .. ".png")
end

function GraffitiMgr:getMaterial()
  local material
  if #self.materialList > 0 then
    material = table.remove(self.materialList, 1)
    Lib.logWarning("get by pool")
  else
    material = Material.CreateFromTemplate("planeNode.json")
    Lib.logWarning("get by create")
  end
  return material
end

function GraffitiMgr:cacheMaterial(material)
  Lib.logWarning("cacheMaterial")
  table.insert(self.materialList, material)
end

GraffitiMgr:init()
