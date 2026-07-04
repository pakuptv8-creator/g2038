local BillboardHelper = T(Lib, "BillboardHelper")
local DefaultSceneRatio = 1.7777777777777777

function BillboardHelper:init()
  self:initEvent()
end

function BillboardHelper:initEvent()
  Lib.subscribeEvent(Event.EVENT_UPDATE_BILLBOARD_SHOW, function(objID)
    self:checkShowBillboardUI(objID)
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    self:checkShowBillboardUI(objID)
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_REMOVED, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity then
      return
    end
    if entity:data("main").billboardUI then
      self:hideBillboardUI(entity, objID)
    end
    if entity:data("main").sceneUITimer then
      entity:data("main").sceneUITimer()
      entity:data("main").sceneUITimer = nil
    end
  end)
end

function BillboardHelper:checkShowBillboardUI(objID)
  local entity = World.CurWorld:getEntity(objID)
  if not entity or not entity:isValid() then
    return
  end
  local billboardState = entity:getBillboardState()
  if billboardState then
    if entity.platformUserId == Me.platformUserId then
      self:showBillboardUI(entity, objID)
    else
      local cfg = World.cfg.sceneBillUI
      if entity.platformUserId ~= Me.platformUserId and cfg.distance then
        if entity:data("main").sceneUITimer then
          entity:data("main").sceneUITimer()
        end
        entity:data("main").sceneUITimer = entity:lightTimer("sceneUITimer check distance", 10, function()
          if Me:distance(entity) <= cfg.distance then
            self:showBillboardUI(entity, objID)
          else
            local ui = entity:data("main").billboardUI
            if ui and ui:root():data("sceneKey") == cfg.key .. objID then
              self:hideBillboardUI(entity, objID)
            end
          end
          return true
        end)
      else
        self:showBillboardUI(entity, objID)
      end
    end
  else
    self:hideBillboardUI(entity, objID)
  end
end

function BillboardHelper:showBillboardUI(entity, objID)
  if not entity or not entity:isValid() then
    return
  end
  if entity:data("main").billboardUI then
    return
  end
  local billboardState = entity:getBillboardState()
  if not billboardState then
    return
  end
  local cfg = World.cfg.sceneBillUI
  local width = cfg.width
  local height = cfg.height
  assert(width or height, "must have width or height")
  if not width then
    width = height * DefaultSceneRatio
  else
    height = height or width / DefaultSceneRatio
  end
  local ui = UIMgr:new_wnd("billboardText")
  ui:root():setData("sceneKey", cfg.key .. objID)
  ui:show()
  ui:onOpen(objID)
  entity:data("main").billboardUI = ui
  local shapeScale = 1
  local DramaClientHelper = T(Lib, "DramaClientHelper")
  if DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    shapeScale = entity:getGiantShape() or 1
  else
    shapeScale = entity:getShapeScale() or 1
  end
  local uiPos = Lib.v3(cfg.position.x, cfg.position.y, cfg.position.z)
  if 1 < shapeScale then
    uiPos.z = uiPos.z - 0.05
    uiPos = uiPos * shapeScale
  end
  GUISystem.instance:CreateWorldWindow(cfg.key .. objID, ui:root(), width, height, cfg.rotate, uiPos, objID, cfg.bonePoint)
end

function BillboardHelper:hideBillboardUI(entity, objID)
  local cfg = World.cfg.sceneBillUI
  local ui = entity:data("main").billboardUI
  if ui then
    ui:root():setData("sceneKey", nil)
    ui:hide()
    ui:onClose()
    GUISystem.instance:RemoveWorldWindow(cfg.key .. objID)
    entity:data("main").billboardUI = nil
  end
end

BillboardHelper:init()
