local SceneUIManager = T(Lib, "SceneUIManager")
local ui_pool = {}
local cur_map_scene_ui = {}
local scene_ui_cfg = {}
local player_last_pos
local index = 1

local function uid()
  index = index + 1
  return index
end

local function initSceneUIPool(uiName, sceneUIParam)
  sceneUIParam = sceneUIParam or {}
  local data = {
    name = uiName,
    creator = function(param)
      return assert(UIMgr:new_wnd(uiName))
    end,
    destFun = function(window)
      GUISystem.instance:UnbindWorldWindow(window:root():data("sceneKey"))
      UI:closeWnd(window)
    end,
    formatFun = function(window)
      local key = window:root():data("sceneKey")
      if key then
        UI:closeWnd(window)
        window:root():setData("sceneKey", nil)
        GUISystem.instance:UnbindWorldWindow(key)
      end
    end,
    maxCount = sceneUIParam.maxCount or 1
  }
  ui_pool[uiName] = Pool.new(data)
  return ui_pool[uiName]
end

function SceneUIManager:getPool(ui_name)
  return ui_pool[ui_name]
end

function SceneUIManager:getUI(ui_name)
  local pool = ui_pool[ui_name]
  pool = pool or initSceneUIPool(ui_name)
  local ui = pool:get()
  return ui
end

function SceneUIManager:getSceneUI(key)
  for i, ui in pairs(cur_map_scene_ui) do
    local uiParams = ui:root():data("sceneUIParams")
    if key == uiParams.key then
      return ui
    end
  end
end

function SceneUIManager:getAllSceneUI()
  return cur_map_scene_ui
end

function SceneUIManager:getAllSceneUICfg()
  return World.CurMap.cfg.sceneUI or {}
end

function SceneUIManager:getSceneUICfg(key)
  local cfg = World.CurMap.cfg
  local sceneCfgList = cfg.sceneUI or {}
  for i, sceneCfg in ipairs(sceneCfgList) do
    if sceneCfg.key == key then
      return sceneCfg
    end
  end
  return scene_ui_cfg[key]
end

function SceneUIManager:updateSceneUI(ui, uiCfg)
  local uiParams = ui:root():data("sceneUIParams")
  self:closeMapSceneUI(ui, uiParams.ui_name)
  self:createSceneUI(uiCfg)
end

function SceneUIManager:updateUIViewShow(key, params)
  local ui = self:getSceneUI(key)
  if ui then
    ui:initView(params)
    self:getSceneUICfg(key).params = params
  end
end

function SceneUIManager:createSceneUI(data)
  local ui_name = data.uiName
  local key = data.key
  local width = data.width
  local height = 1
  if data.sceneRatio then
    height = width / data.sceneRatio
  else
    height = width / Define.DefaultSceneRatio
  end
  local ui = self:getUI(ui_name, data.sceneUIParam)
  local sceneKey = key .. "|" .. uid()
  ui:root():setData("sceneKey", sceneKey)
  ui:root():setData("sceneUIParams", {
    sceneKey = sceneKey,
    key = key,
    ui_name = ui_name,
    width = width,
    height = height,
    sceneRatio = data.sceneRatio or Define.DefaultSceneRatio,
    rotate = data.rotate,
    position = data.position,
    viewDistance = data.viewDistance * data.viewDistance,
    isShow = true
  })
  ui:show()
  ui:onOpen(data.params)
  scene_ui_cfg[data.key] = data
  GUISystem.instance:BindWorldWindow(sceneKey, ui:root(), width, height, data.rotate, data.position, data.objId or -1)
  table.insert(cur_map_scene_ui, ui)
  return ui
end

function SceneUIManager:loadMapSceneUI()
  self:destroyMapSceneUI()
  local mapName = World.CurMap.name
  local cfg = World.CurMap.cfg
  for i, uiCfg in pairs(cfg.sceneUI or {}) do
    self:createSceneUI(uiCfg)
  end
  self:startCheckDistanceTick()
end

function SceneUIManager:closeMapSceneUI(ui, ui_name)
  local sceneKey = ui:root():data("sceneKey")
  local pool = self:getPool(ui_name)
  for i, _ui in pairs(cur_map_scene_ui) do
    if ui == _ui then
      table.remove(cur_map_scene_ui, i)
      break
    end
  end
  if pool then
    pool:push(ui)
  end
  if sceneKey then
    GUISystem.instance:UnbindWorldWindow(sceneKey)
  end
end

function SceneUIManager:hideMapSceneUI(ui)
  local uiParams = ui:root():data("sceneUIParams")
  uiParams.isShow = false
  GUISystem.instance:UnbindWorldWindow(uiParams.sceneKey)
end

function SceneUIManager:showMapSceneUI(ui)
  local uiParams = ui:root():data("sceneUIParams")
  uiParams.isShow = true
  GUISystem.instance:BindWorldWindow(uiParams.sceneKey, ui:root(), uiParams.width, uiParams.height, uiParams.rotate, uiParams.position, -1)
end

function SceneUIManager:destroyMapSceneUI()
  local count = #cur_map_scene_ui
  local i = count
  while 1 <= i do
    local ui = cur_map_scene_ui[i]
    local uiParams = ui:root():data("sceneUIParams")
    self:closeMapSceneUI(ui, uiParams.ui_name)
    i = i - 1
  end
  cur_map_scene_ui = {}
end

function SceneUIManager:startCheckDistanceTick()
  if self.tickTimer then
    return
  end
  self.tickTimer = World.Timer(10, function()
    Profiler:begin("SceneUIManager/checkDistanceTick")
    self:checkDistanceTick()
    Profiler:finish("SceneUIManager/checkDistanceTick")
    return true
  end)
end

local function compareDistance(pos, distance)
  return distance > pos.x * pos.x + pos.y * pos.y + pos.z * pos.z
end

function SceneUIManager:checkDistanceTick()
  local camera = Camera:getActiveCamera()
  local pos = camera:getPosition()
  if player_last_pos and player_last_pos == pos then
    return
  end
  for i, ui in pairs(cur_map_scene_ui) do
    local uiParams = ui:root():data("sceneUIParams")
    if uiParams.viewDistance > 0 then
      local subPos = uiParams.position - pos
      local needShow = compareDistance(subPos, uiParams.viewDistance)
      if uiParams.isShow and not needShow then
        self:hideMapSceneUI(ui)
      elseif not uiParams.isShow and needShow then
        self:showMapSceneUI(ui)
      end
    end
  end
  player_last_pos = pos
end
