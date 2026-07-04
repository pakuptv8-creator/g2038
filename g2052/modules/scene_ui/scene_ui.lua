require("common.event_scene_ui")
require("common.define_scene_ui")
if World.isClient then
  require("client.map.scene_ui_manager")
  require("client.gate_scene_ui")
end
if World.isClient then
  local SceneUIManager = T(Lib, "SceneUIManager")
  Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    SceneUIManager:loadMapSceneUI()
    for level = 1, 3 do
      Blockman.Instance():setQualityLevelData(level - 1, 16, 0)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CLOSE_SCENE_UI, function(ui, ui_name)
    SceneUIManager:closeMapSceneUI(ui, ui_name)
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity or not entity:isValid() then
      return
    end
    if not entity:cfg().sceneUI then
      return
    end
    local cfg = entity:cfg().sceneUI
    local width = cfg.width
    local height = cfg.height
    assert(width or height, "must have width or height")
    if not width then
      width = height * Define.DefaultSceneRatio
    else
      height = height or width / Define.DefaultSceneRatio
    end
    local key = cfg.key .. objID
    local ui = Plugins.CallTargetPluginFunc("scene_ui", "getSceneUI", key)
    local uiName = cfg.key
    local rotate = entity:getRotation()
    rotate.y = rotate.y / math.abs(rotate.y) * (360 - math.abs(rotate.y))
    if cfg.rotate then
      rotate = rotate + Lib.v3(cfg.rotate.x, cfg.rotate.y, cfg.rotate.z)
    end
    local pos = entity:getPosition()
    if cfg.position then
      pos = pos + Lib.correctMoveDistance(rotate, Lib.v3(cfg.position.x, cfg.position.y, cfg.position.z))
    end
    local default = {
      width = width,
      height = height,
      viewDistance = cfg.viewDistance or 32,
      uiName = uiName,
      rotate = rotate,
      position = pos,
      key = key,
      params = {objID = objID}
    }
    if ui then
      Plugins.CallTargetPluginFunc("scene_ui", "updateSceneUI", ui, default)
    else
      Plugins.CallTargetPluginFunc("scene_ui", "createSceneUI", default)
    end
  end)
end
local handlers = {}
if World.isClient then
  local SceneUIManager = T(Lib, "SceneUIManager")
  
  function handlers.createSceneUI(data)
    return SceneUIManager:createSceneUI(data)
  end
  
  function handlers.closeMapSceneUI(ui, ui_name)
    SceneUIManager:closeMapSceneUI(ui, ui_name)
  end
  
  function handlers.getSceneUI(key)
    return SceneUIManager:getSceneUI(key)
  end
  
  function handlers.getAllSceneUI()
    return SceneUIManager:getAllSceneUI()
  end
  
  function handlers.updateSceneUI(ui, uiCfg)
    SceneUIManager:updateSceneUI(ui, uiCfg)
  end
  
  function handlers.updateUIViewShow(key, params)
    SceneUIManager:updateUIViewShow(key, params)
  end
  
  function handlers.getSceneUICfg(key)
    return SceneUIManager:getSceneUICfg(key)
  end
  
  function handlers.getAllSceneUICfg()
    return SceneUIManager:getAllSceneUICfg()
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
