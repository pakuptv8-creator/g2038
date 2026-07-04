local PartUIClientManager = T(Lib, "PartUIClientManager")
local InteractEventConfig = T(Config, "InteractEventConfig")
local PartUIName = "partContentView"
local partSceneUIInfo = {}

function PartUIClientManager:init()
  self.UIPool = {}
  self:initSceneUIPool(PartUIName, 50)
  self:initEvent()
end

function PartUIClientManager:initSceneUIPool(uiName, maxCount)
  local data = {
    name = uiName,
    creator = function(param)
      return assert(UIMgr:new_wnd(uiName))
    end,
    destFun = function(window)
      UI:closeSceneWnd(window:root():data("partUIKey"))
      UI:closeWnd(window)
    end,
    formatFun = function(window)
      local key = window:root():data("partUIKey")
      if key then
        UI:closeWnd(window)
        window:root():setData("partUIKey", nil)
        GUISystem.instance:UnbindWorldWindow(key)
      end
    end,
    maxCount = maxCount
  }
  self.UIPool[uiName] = Pool.new(data)
end

function PartUIClientManager:initEvent()
end

function PartUIClientManager:updateMapPartUI(mapName)
  for signKey, info in pairs(partSceneUIInfo) do
    if info.uiParams and info.uiParams.mapName ~= mapName then
      self:hideSignUI(signKey)
    end
  end
  self:startCheckDistanceTick()
end

function PartUIClientManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("PartUIClientManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("PartUIClientManager/checkDistanceTick")
    return true
  end)
end

function PartUIClientManager:checkDistanceTick()
  local playerPos = Me:getPosition()
  for signKey, info in pairs(partSceneUIInfo) do
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

function PartUIClientManager:createSignUI(signKey, uiParams, cfg)
  local UIShowName = PartUIName
  local partUIKey = UIShowName .. signKey
  partSceneUIInfo[signKey] = {
    uiParams = uiParams,
    isShow = false,
    partUIKey = partUIKey,
    ui = nil,
    cfg = cfg
  }
end

function PartUIClientManager:showSignUI(signKey)
  local signInfo = partSceneUIInfo[signKey]
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
  local uiParams = signInfo.uiParams
  local width = uiParams.width
  local height = uiParams.height
  local UIShowName = PartUIName
  local ui = self.UIPool[UIShowName]:get()
  ui:root():setData("partUIKey", signInfo.partUIKey)
  ui:show()
  ui:onOpen(signInfo.uiParams)
  GUISystem.instance:BindWorldWindow(signInfo.partUIKey, ui:root(), width, height, uiParams.rotate, uiParams.position, -1)
  partSceneUIInfo[signKey].isShow = true
  partSceneUIInfo[signKey].ui = ui
end

function PartUIClientManager:hideSignUI(signKey)
  local signInfo = partSceneUIInfo[signKey]
  if not signInfo then
    return
  end
  if signInfo.ui then
    local UIShowName = PartUIName
    self.UIPool[UIShowName]:push(signInfo.ui)
  end
  partSceneUIInfo[signKey].isShow = false
end

function PartUIClientManager:updatePartSceneUIInfo(mapName, partUIData)
  self:updateMapPartUI(mapName)
  for partId, info in pairs(partUIData or {}) do
    local cfg = InteractEventConfig:getCfgById(info.partName)
    if cfg then
      local key = partId
      local showOffset = Lib.createV3ByString(cfg.params[1])
      local showRange = Lib.createV3ByString(cfg.params[2])
      local size = Lib.splitString(cfg.params[4], "#", true)
      local finalPos = Lib.v3(info.pos.x + showOffset.x, info.pos.y + showOffset.y, info.pos.z + showOffset.z)
      local uiParams = {
        width = size[1],
        height = size[2],
        viewDistance = tonumber(cfg.params[3]),
        rotate = showRange,
        position = finalPos,
        mapName = mapName,
        signKey = key,
        info = info
      }
      self:createSignUI(key, uiParams, cfg)
    end
  end
end

local function ColorToHEX(r, g, b)
  return string.format("%02X%02X%02X", math.ceil(r * 255), math.ceil(g * 255), math.ceil(b * 255))
end

function PartUIClientManager:openPartContentEditWnd(signKey, mapName, partParams)
  local signInfo = partSceneUIInfo[signKey]
  if not signInfo then
    return
  end
  if partParams[7] and partParams[7] ~= "" then
    UI:openWnd("partContentEdit", signInfo.uiParams, mapName)
  else
    local function inputCallback(newName, newColor)
      local packet = {
        pid = "RequestChangePartContent",
        
        mapName = mapName,
        partId = signInfo.uiParams.info.partId,
        contentTxt = newName,
        signName = Me:getNameContent(),
        signColor = Lib.getTextColor(Me:getNameColor()),
        contentColor = Lib.getTextColor(newColor)
      }
      Me:sendPacket(packet)
    end
    
    local text = Lang:toText(signInfo.uiParams.info.contentTxt or "")
    local initColor = "000000"
    if signInfo.uiParams.info.contentColor then
      local color = signInfo.uiParams.info.contentColor
      initColor = ColorToHEX(color[1] or 0, color[2] or 0, color[3] or 0)
    elseif partParams[6] then
      local len = string.len(partParams[6])
      if len == 6 then
        initColor = partParams[6]
      else
        initColor = partParams[6]
        for i = 1, 6 - len do
          initColor = "0" .. initColor
        end
      end
    end
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.PartContent, inputCallback, text, initColor)
  end
end

function PartUIClientManager:updatePartContentShow(signKey, partUIInfo, mapName)
  local signInfo = partSceneUIInfo[signKey]
  if not signInfo then
    return
  end
  partSceneUIInfo[signKey].uiParams.info = partUIInfo
  if partSceneUIInfo[signKey].isShow and partSceneUIInfo[signKey].ui then
    partSceneUIInfo[signKey].ui:updateContentShow(partUIInfo)
  end
end

PartUIClientManager:init()
