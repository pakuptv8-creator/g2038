local TenderingPublicManager = T(Lib, "TenderingPublicManager")
local DefaultSceneRatio = 1.7777777777777777
local BiddingUIName = "tenderPublicity"
local tenderingLandInfo = {}

function TenderingPublicManager:init()
  self.UIPool = {}
  self:initSceneUIPool(BiddingUIName, 50)
  self:initEvent()
end

function TenderingPublicManager:initSceneUIPool(uiName, maxCount)
  local data = {
    name = uiName,
    creator = function(param)
      return assert(UIMgr:new_wnd(uiName))
    end,
    destFun = function(window)
      UI:closeSceneWnd(window:root():data("signUIKey"))
      UI:closeWnd(window)
    end,
    formatFun = function(window)
      local key = window:root():data("signUIKey")
      if key then
        UI:closeWnd(window)
        window:root():setData("signUIKey", nil)
        GUISystem.instance:UnbindWorldWindow(key)
      end
    end,
    maxCount = maxCount
  }
  self.UIPool[uiName] = Pool.new(data)
end

function TenderingPublicManager:initEvent()
  Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    self:loadMapSignUI()
  end)
end

function TenderingPublicManager:loadMapSignUI()
  for signKey, info in pairs(tenderingLandInfo) do
    if info.uiParams then
      self:hideSignUI(signKey)
    end
  end
  local UIShowName = BiddingUIName
  self.UIPool[UIShowName]:dctor()
  self.UIPool = {}
  self:initSceneUIPool(BiddingUIName, 50)
  self:startCheckDistanceTick()
end

function TenderingPublicManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("TenderingPublicManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("TenderingPublicManager/checkDistanceTick")
    return true
  end)
end

function TenderingPublicManager:checkDistanceTick()
  local playerPos = Me:getPosition()
  for signKey, info in pairs(tenderingLandInfo) do
    local uiParams = info.uiParams
    if uiParams and uiParams.viewDistance > 0 then
      local isInRange = Lib.getPosDistance(playerPos, uiParams.position) <= uiParams.viewDistance
      local needShow = isInRange and World.CurMap.name == uiParams.mapName
      if info.isShow and not needShow then
        self:hideSignUI(signKey)
      elseif not info.isShow and needShow then
        self:showSignUI(signKey)
      end
    end
  end
end

function TenderingPublicManager:updateSignUIData(data, signKey)
  if not tenderingLandInfo[signKey] then
    self:createSignUI(signKey)
  end
  tenderingLandInfo[signKey].data = data
  if tenderingLandInfo[signKey].isShow and tenderingLandInfo[signKey].ui then
    tenderingLandInfo[signKey].ui:updateContentInfo(data)
  end
end

function TenderingPublicManager:updateSignUIParams(signKey, uiParams, cfg)
  if not tenderingLandInfo[signKey] then
    return
  end
  local UIShowName = BiddingUIName
  local signUIKey = UIShowName .. signKey
  tenderingLandInfo[signKey].uiParams = uiParams
  tenderingLandInfo[signKey].cfg = cfg
  tenderingLandInfo[signKey].signUIKey = signUIKey
  self:hideSignUI(signKey)
end

function TenderingPublicManager:createSignUI(signKey, uiParams, cfg)
  local UIShowName = BiddingUIName
  local signUIKey = UIShowName .. signKey
  tenderingLandInfo[signKey] = {
    uiParams = uiParams,
    isShow = false,
    data = nil,
    signUIKey = signUIKey,
    ui = nil,
    cfg = cfg
  }
end

function TenderingPublicManager:showSignUI(signKey)
  local signInfo = tenderingLandInfo[signKey]
  if not signInfo then
    return
  end
  if signInfo.isShow then
    return
  end
  if not signInfo.uiParams then
    return
  end
  if not signInfo.cfg then
    return
  end
  if not signInfo.data then
    return
  end
  local uiParams = signInfo.uiParams
  local width = uiParams.width
  local height = uiParams.height
  assert(width or height, "must have width or height")
  if not width then
    width = height * DefaultSceneRatio
  else
    height = height or width / DefaultSceneRatio
  end
  local UIShowName = BiddingUIName
  local ui = self.UIPool[UIShowName]:get()
  ui:root():setData("signUIKey", signInfo.signUIKey)
  ui:show()
  ui:onOpen(signInfo.data)
  GUISystem.instance:BindWorldWindow(signInfo.signUIKey, ui:root(), width, height, uiParams.rotate, uiParams.position, -1)
  tenderingLandInfo[signKey].isShow = true
  tenderingLandInfo[signKey].ui = ui
end

function TenderingPublicManager:hideSignUI(signKey)
  local signInfo = tenderingLandInfo[signKey]
  if not signInfo then
    return
  end
  if signInfo.ui then
    local cfg = signInfo.cfg
    local UIShowName = BiddingUIName
    self.UIPool[UIShowName]:push(signInfo.ui)
  end
  tenderingLandInfo[signKey].isShow = false
end

function TenderingPublicManager:updateTenderingLandInfo(params)
  for mapName, info in pairs(params or {}) do
    for key, v in pairs(info or {}) do
      local cfg = v.cfg
      local finalPos = Lib.v3(v.pos.x + cfg.publicOffset.x, v.pos.y + cfg.publicOffset.y, v.pos.z + cfg.publicOffset.z)
      local uiParams = {
        width = 303,
        viewDistance = cfg.publicRange,
        rotate = cfg.publicRotate,
        position = finalPos,
        mapId = v.mapId,
        mapName = mapName,
        signKey = key
      }
      if cfg.curBuildings and cfg.curBuildings ~= "" then
        if tenderingLandInfo[key] then
          self:updateSignUIParams(key, uiParams, cfg)
        else
          self:createSignUI(key, uiParams, cfg)
        end
      end
    end
  end
end

TenderingPublicManager:init()
