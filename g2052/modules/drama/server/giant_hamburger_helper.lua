local GiantHamburgerHelper = T(Lib, "GiantHamburgerHelper")
local setting = require("common.setting")
local PartCfg = setting:mod("part")

function GiantHamburgerHelper:init()
  self.lastBornTime = 0
  self.curHamburgerList = {}
end

function GiantHamburgerHelper:updatePlayerLoginMap(entity)
  if not Lib.isGameDrama() then
    return
  end
  if not DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    return
  end
  if not self.hamburgerTimer then
    self.map = entity.map
    self:startHamburgerTimer()
  end
end

function GiantHamburgerHelper:startHamburgerTimer()
  self.hamburgerTimer = World.Timer(20, function()
    local curTime = os.time()
    if curTime - self.lastBornTime > World.cfg.dramaSetting.giantSetting.hamburgerCD then
      self:removeAllHamburger()
      self:createHamburgerList()
      self.lastBornTime = curTime
    end
    return true
  end)
end

function GiantHamburgerHelper:createHamburgerList()
  local bornList = Lib.copy(World.cfg.dramaSetting.giantSetting.hamburgerBornList)
  local totalNum = #bornList
  local key = 1
  while key <= World.cfg.dramaSetting.giantSetting.hamburgerMaxNum do
    local index = math.random(1, totalNum - key + 1)
    if bornList[index] and bornList[index].mapName == self.map.name then
      self:createOneHamburger(bornList[index].position)
      table.remove(bornList, index)
    end
    key = key + 1
  end
  T(Lib, "MessageNoticeManager"):broadcastNotice(16)
end

function GiantHamburgerHelper:createOneHamburger(pos)
  local giantSetting = World.cfg.dramaSetting.giantSetting
  local partCfg = PartCfg:get(giantSetting.hamburgerCfg)
  if not partCfg then
    Lib.logError("--error-GiantHamburgerHelper:createOneHamburger-partCfg-:", giantSetting.hamburgerCfg)
    return
  end
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local inst = Instance.newInstance(partCfg, self.map)
  if not inst then
    return
  end
  inst:setParent(scene:getRoot())
  inst:setPosition(pos)
  local partId = inst:getInstanceID()
  self.curHamburgerList[partId] = inst
end

function GiantHamburgerHelper:removeOneHamburger(partId)
  local part = Instance.getByInstanceId(partId)
  if not part or not part:isValid() then
    return
  end
  part:destroy()
  self.curHamburgerList[partId] = nil
end

function GiantHamburgerHelper:removeAllHamburger()
  for partId, _ in pairs(self.curHamburgerList) do
    self:removeOneHamburger(partId)
  end
end

GiantHamburgerHelper:init()
