require("common.entity_engine_overwrite")
require("common.define_engine_overwrite")
require("common.packet_convert_engine_overwrite")
require("common.instance_expand")
require("common.skill_overwrite")
require("common.event_engine_overwrite")
require("common.lib_overwrite")
require("common.map_overwrite")
if World.isClient then
  require("client.entity.entity_prop_engine_overwrite")
  require("client.entity.entity_event_engine_overwrite")
  require("client.entity.entity_click_engine_overwrite")
  require("client.gate_engine_overwrite")
  require("client.ui.grid_view_helper")
  require("client.player_control")
  require("client.ui_lib")
  require("client.skill.base_engine_overwrite")
  require("client.skill.skill_engine_overwrite")
  require("client.player.player_engine_overwrite")
  require("client.chat_manager_engine_overwrite")
  require("client.player.player_packet_engine_overwrite")
  local tickEngineRenderHandler = L("tickEngineRenderHandler", handle_render_tick)
  
  function handle_render_tick(frameTime, interpolationFraction)
    tickEngineRenderHandler(frameTime, interpolationFraction)
    if Me then
      if not Me.renderTickCount then
        Me.renderTickCount = 1
      else
        Me.renderTickCount = Me.renderTickCount + 1
      end
      if not Me.beginRenderTickTime and Me.renderTickCount == 300 then
        Me.beginRenderTickTime = os.time()
        Me.renderTickCount = 1
      end
      if not Me.detectLowAFPSTime then
        Me.detectLowAFPSTime = os.time()
      end
      if not Me.lowAFPSSum then
        Me.lowAFPSSum = 0
      end
      if Me.renderTickCount % 300 == 0 then
        local afps = Me.renderTickCount / (os.time() - Me.beginRenderTickTime)
        Me:sendPacket({
          pid = "sendRenderTickCount",
          afps = math.floor(afps + 0.5)
        })
        local level = Me:getFarClipLevel()
        if 0 < level then
          local detectLowAFPSDelay = World.cfg.lowAFPSFarClipSetting.detectLowAFPSDelay or 60
          local detectLowAFPSValue = World.cfg.lowAFPSFarClipSetting.detectLowAFPSValue or 20
          local detectLowAFPSNum = World.cfg.lowAFPSFarClipSetting.detectLowAFPSNum or 3
          if detectLowAFPSDelay <= os.time() - Me.detectLowAFPSTime and afps < detectLowAFPSValue then
            Me.lowAFPSSum = Me.lowAFPSSum + 1
            if detectLowAFPSNum <= Me.lowAFPSSum then
              CameraManager.Instance():getMainCamera():setFarClip(Me:getFarClipValue(level - 1))
              Me:setFarClipLevel(level - 1)
              Lib.emitEvent(Event.EVENT_CHANGE_FAR_CLIP, level - 1)
            end
          end
        end
      end
    end
  end
else
  require("server.entity.entity_prop_engine_overwrite")
  require("server.player.player_engine_overwrite")
  require("server.async_process")
  require("server.gate_engine_overwrite")
  require("server.entity.entity_click_engine_overwrite")
  require("server.entity.entity_engine_overwrite")
  require("server.entity.ai.ai_control_engine_overwrite")
end
local Pool = {}
local InteractEventConfig = T(Config, "InteractEventConfig")
local PartInteractHelper = T(Lib, "PartInteractHelper")
local handlers = {}

function handlers.defaultSetting()
  return {
    settingKey = "engineOverwriteSetting"
  }
end

function handlers.ENTER_SCENE(context)
  local part = context.part1
  if part and part:isValid() then
    if part.className == "RegionPart" then
      local map = part.map
      if map and map.updateSceneRegionByRegionPart then
        map:updateSceneRegionByRegionPart(part, true)
      end
    else
      local interactInfo = InteractEventConfig:getCfgById(part.name) or {}
      if PartInteractHelper[interactInfo.func] then
        PartInteractHelper[interactInfo.func](Define.PART_INTERACT_TYPE.PART_SPAWN, part, interactInfo.params)
      end
    end
  end
end

function handlers.ON_DESTROY(context)
  local part = context.part1
  if part and part:isValid() then
    if not World.isClient then
      T(Lib, "VehicleManager"):onPartDestroyed(part)
    end
    if part.className == "RegionPart" then
      local map = part.map
      if map and map.updateSceneRegionByRegionPart then
        map:updateSceneRegionByRegionPart(part, false)
      end
    end
    if part.className == "PartClient" and part.name == "house_area" then
      Me:sendPacket({
        pid = "LeaveHouseArea"
      })
    end
  end
end

function handlers.ON_EXIT_SCENE(context)
  local part = context.part1
  if part and part:isValid() and part.className == "RegionPart" then
    local map = part.map
    if map and map.updateSceneRegionByRegionPart then
      map:updateSceneRegionByRegionPart(part, false)
    end
  end
end

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    print("!!!!!!!!!!!!!!!!!!", entity.objID, [[



]])
    entity:recordPlayerActive(os.time())
    local BrightnessScaleHelper = T(Lib, "brightnessScaleHelper")
    BrightnessScaleHelper:sendPlayerList(entity)
  else
  end
end

function handlers.ENTITY_LEAVE(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    entity:autoDataExpire()
  else
  end
end

function handlers.ENTITY_TOUCHDOWN(context)
  context.canDoDamage = false
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    local pos = entity.map.cfg.initPos or World.cfg.initPos
    entity:setMapPos(entity.map, pos)
  else
  end
end

function handlers.ENTITY_STATUS_CHANGE(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  local newState = context.newState
  local oldState = context.oldState
  if entity.isPlayer then
    entity:stopWithPet()
  end
end

function handlers.initAdapterView(params)
  local res = {}
  local GridViewHelper = _ENV.GridViewHelper
  if not params then
    return nil
  end
  res = GridViewHelper.new({
    xDis = params.xDis,
    yDis = params.yDis,
    xCellNum = params.xCellNum,
    area = {
      {0, 1},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    widgetWidth = params.widgetWidth,
    widgetHeight = params.widgetHeight,
    widgetJson = params.widgetJson,
    widgetName = params.widgetName,
    gvParent = params.gvParent,
    cellSelectedCb = params.cellSelectedCb
  })
  res:setData(params.dataList, -1, nil, true)
  return res
end

local MapOverWrite = T(Lib, "MapOverWrite")

function handlers.addMapCfg(key, cfg)
  MapOverWrite:addMapCfg(key, cfg)
end

function handlers.removeMapCfg(key)
  MapOverWrite:removeMapCfg(key)
end

if World.isClient then
  local poolClass = require("client.pool.pool")
  
  function handlers.initPool(key, params)
    Pool[key] = poolClass.new(params)
  end
  
  function handlers.getObj(key)
    local pool = Pool[key]
    return pool:get()
  end
  
  function handlers.pushObj(key, ui)
    local pool = Pool[key]
    return pool:push(ui)
  end
  
  function handlers.showGM()
    local window = UI:openWnd("gm")
    window:root():SetLevel(1)
  end
  
  local function toBigNum(num)
    if not num then
      return 0
    end
    num = tostring(math.floor(num or 0))
    local ans = string.reverse(num)
    local res = ""
    for i = 1, #ans do
      res = res .. string.sub(ans, i, i)
      if i % 3 == 0 and i ~= #ans then
        res = res .. ","
      end
    end
    local ans = string.reverse(res)
    return ans
  end
  
  function handlers.toBigIntegerString(num)
    return toBigNum(num)
  end
else
  function handlers.OnPlayerLogin(player)
    player:sendLoginMessageToSystem("g2052.gui.chat.system.login", player.name)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
