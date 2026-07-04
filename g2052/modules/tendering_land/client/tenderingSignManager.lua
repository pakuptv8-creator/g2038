local TenderingSignManager = T(Lib, "TenderingSignManager")
local DefaultSceneRatio = 1.7777777777777777
local BiddingUIName = "tenderBoard"
local tenderingLandInfo = {}

function TenderingSignManager:init()
  self.UIPool = {}
  self:initSceneUIPool(BiddingUIName, 50)
  self:initEvent()
end

function TenderingSignManager:initSceneUIPool(uiName, maxCount)
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

function TenderingSignManager:initEvent()
  Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    self:loadMapSignUI()
  end)
end

function TenderingSignManager:loadMapSignUI()
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

function TenderingSignManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("TenderingSignManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("TenderingSignManager/checkDistanceTick")
    return true
  end)
end

function TenderingSignManager:checkDistanceTick()
  local playerPos = Me:getPosition()
  for signKey, info in pairs(tenderingLandInfo) do
    local uiParams = info.uiParams
    if uiParams and uiParams.viewDistance > 0 then
      local tenderState = info.tenderState
      local isInRange = Lib.getPosDistance(playerPos, uiParams.position) <= uiParams.viewDistance
      local needShow = isInRange and tenderState ~= Define.BIDDING_STATUS.NORMAL and World.CurMap.name == uiParams.mapName
      if info.isShow and not needShow then
        self:hideSignUI(signKey)
      elseif not info.isShow and needShow then
        self:showSignUI(signKey)
      end
    end
  end
end

function TenderingSignManager:updateSignUIData(data, signKey, tenderState)
  if not tenderingLandInfo[signKey] then
    self:createSignUI(signKey)
  end
  tenderingLandInfo[signKey].tenderState = tenderState
  tenderingLandInfo[signKey].data = data
  if tenderState == Define.BIDDING_STATUS.NORMAL then
    if tenderingLandInfo[signKey].isShow then
      self:hideSignUI(signKey)
    end
  elseif tenderingLandInfo[signKey].isShow and tenderingLandInfo[signKey].ui then
    tenderingLandInfo[signKey].ui:updateContentInfo(data, tenderState)
  end
end

function TenderingSignManager:updateSignUIParams(signKey, uiParams, cfg)
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

function TenderingSignManager:createSignUI(signKey, uiParams, cfg)
  local UIShowName = BiddingUIName
  local signUIKey = UIShowName .. signKey
  tenderingLandInfo[signKey] = {
    uiParams = uiParams,
    isShow = false,
    data = nil,
    tenderState = Define.BIDDING_STATUS.NORMAL,
    signUIKey = signUIKey,
    ui = nil,
    cfg = cfg
  }
end

function TenderingSignManager:showSignUI(signKey)
  local signInfo = tenderingLandInfo[signKey]
  if not signInfo then
    return
  end
  if signInfo.isShow then
    return
  end
  if signInfo.tenderState == Define.BIDDING_STATUS.NORMAL then
    return
  end
  if not signInfo.uiParams then
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
  ui:onOpen(signInfo.data, signInfo.tenderState)
  GUISystem.instance:BindWorldWindow(signInfo.signUIKey, ui:root(), width, height, uiParams.rotate, uiParams.position, -1)
  tenderingLandInfo[signKey].isShow = true
  tenderingLandInfo[signKey].ui = ui
end

function TenderingSignManager:checkTenderPartInteract(signKey, partName)
  local signInfo = tenderingLandInfo[signKey]
  if not signInfo then
    return false
  end
  if signInfo.tenderState == Define.BIDDING_STATUS.NORMAL or signInfo.tenderState == Define.BIDDING_STATUS.WAIT then
    return false
  end
  local InteractEventConfig = T(Config, "InteractEventConfig")
  local prop = InteractEventConfig:getCfgById(partName)
  if not prop then
    return false
  end
  if prop.func == "onClickBiddingNoticeBoard" then
    return true
  elseif prop.func == "onClickBiddingNoticeRank" then
    if signInfo.tenderState == Define.BIDDING_STATUS.ELECTION or signInfo.tenderState == Define.BIDDING_STATUS.SELECT or signInfo.tenderState == Define.BIDDING_STATUS.FINALS or signInfo.tenderState == Define.BIDDING_STATUS.PUBLICITY then
      return true
    else
      return false
    end
  end
  return false
end

function TenderingSignManager:hideSignUI(signKey)
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

function TenderingSignManager:updateTenderingLandInfo(params)
  for mapName, info in pairs(params or {}) do
    for key, v in pairs(info or {}) do
      local cfg = v.cfg
      local finalPos = Lib.v3(v.pos.x + cfg.billboardOffset.x, v.pos.y + cfg.billboardOffset.y, v.pos.z + cfg.billboardOffset.z)
      local uiParams = {
        width = 303,
        viewDistance = cfg.billboardRange,
        rotate = cfg.billboardRotate,
        position = finalPos,
        mapId = v.mapId,
        mapName = mapName,
        signKey = key
      }
      if tenderingLandInfo[key] then
        self:updateSignUIParams(key, uiParams, cfg)
      else
        self:createSignUI(key, uiParams, cfg)
      end
    end
  end
end

function TenderingSignManager:getTenderingLandCfg(signKey)
  if tenderingLandInfo[signKey] then
    return tenderingLandInfo[signKey].cfg
  end
  return {}
end

TenderingSignManager:init()
