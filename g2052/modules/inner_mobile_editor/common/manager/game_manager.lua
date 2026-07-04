local util = require("common.util.util")
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local LuaTimer = T(Lib, "LuaTimer")
local BM = Blockman.Instance()
local GameManager = T(MobileEditor, "GameManager")
local CommandManager = T(MobileEditor, "CommandManager")
GameManager:addState("Edit", require("common.state.game.edit_state"))
GameManager:addState("Create", require("common.state.game.create_state"))
GameManager:addState("MultipleSelection", require("common.state.game.multiple_selection_state"))
GameManager:addState("CaptureScreen", require("common.state.game.capture_screen_state"))
GameManager:addState("HoldDown", require("common.state.game.hold_down_state"))
GameManager:addState("Environment", require("common.state.game.environment_state"))
local IInstance = require("common.engine.engine_instance")
local BaseNode = require("common.node.base_node")

function GameManager:initialize()
  Lib.logDebug("GameManager:initialize")
  self.root = nil
  self.createModId = nil
  self.isTouchBegin = false
  self.isTouchMove = false
  self.touchBeginId = nil
  self.touchEndId = nil
  self.touchBeginPos = nil
  self.clickCount = 0
  self.clickDelay = 0.5
  self.clickTime = 0
  self.pressTime = 0
  self.pressDelay = 1.0
  self.selectedNodes = {}
  self.nodes = {}
  self.floor = nil
  self.birthId = nil
  self:subscribeEvents()
  self:initUpdateTimer()
end

function GameManager:finalize()
  self:popAllStates()
  self:reset()
end

function GameManager:subscribeEvents()
  Lib.subscribeEvent(Event.EVENT_ENTER_PLAY_MODE, function()
  end)
  Lib.subscribeEvent(Event.EVENT_ENTER_EDIT_MODE, function()
  end)
  Lib.subscribeEvent(Event.EVENT_DESTROY_NODE, function(id)
    self:destroyNode(id)
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_BEGIN, function(id, curX, curY, prevX, prevY)
    Lib.logDebug("EVENT_TOUCH_BEGIN id and x and y = ", id, curX, curY)
    if self:getCurrentState() == "Create" then
      self:touchBegin(curX, curY)
    elseif self:getCurrentState() == "Edit" then
      self:touchBegin(curX, curY)
    elseif self:getCurrentState() == "MultipleSelection" then
      self:touchBegin(curX, curY)
    elseif self:getCurrentState() == "CaptureScreen" then
      self:touchBegin(curX, curY)
    elseif self:getCurrentState() == "Environment" then
      self:touchBegin(curX, curY)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_MOVE, function(id, curX, curY, prevX, prevY)
    if self:getCurrentState() == "Create" then
      self:touchMove(curX, curY, prevX, prevY)
    elseif self:getCurrentState() == "Edit" then
      self:touchMove(curX, curY, prevX, prevY)
    elseif self:getCurrentState() == "MultipleSelection" then
      self:touchMove(curX, curY, prevX, prevY)
    elseif self:getCurrentState() == "HoldDown" then
      self:touchMove(curX, curY, prevX, prevY)
    elseif self:getCurrentState() == "CaptureScreen" then
      self:touchMove(curX, curY, prevX, prevY)
    elseif self:getCurrentState() == "Environment" then
      self:touchMove(curX, curY, prevX, prevY)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_END, function(id, curX, curY, prevX, prevY)
    if self:getCurrentState() == "Create" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "Edit" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "MultipleSelection" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "HoldDown" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "CaptureScreen" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "Environment" then
      self:touchEnd(curX, curY)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_CANCEL, function(id, curX, curY, prevX, prevY)
    if self:getCurrentState() == "Create" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "Edit" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "MultipleSelection" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "HoldDown" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "CaptureScreen" then
      self:touchEnd(curX, curY)
    elseif self:getCurrentState() == "Environment" then
      self:touchEnd(curX, curY)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTER_CAPTURE_STATE, function()
    GameManager:instance():pushState("CaptureScreen")
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_CAPTURE_STATE, function()
    GameManager:instance():popState("CaptureScreen")
  end)
  Lib.subscribeEvent(Event.EVENT_ENTER_ENVIRONMENT_STATE, function()
    GameManager:instance():pushState("Environment")
  end)
  Lib.subscribeEvent(Event.EVENT_EXIT_ENVIRONMENT_STATE, function()
    GameManager:instance():popState("Environment")
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_DOWN_NODE, function(cfgId)
    if cfgId then
      GameManager:instance():pushState("Create", cfgId)
    else
      GameManager:instance():popState("Create")
    end
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_MOVE_NODE, function(x, y)
    if self:getCurrentState() == "Create" then
      local TargetManager = T(MobileEditor, "TargetManager")
      local targets = TargetManager:instance():getTargets()
      if Lib.getTableSize(targets) > 0 then
        self:touchMove(x, y)
      else
        self:touchBegin(x, y)
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_TOUCH_END_NODE, function(x, y)
    if self:getCurrentState() == "Create" then
      self:popState("Create")
      local TargetManager = T(MobileEditor, "TargetManager")
      local targets = TargetManager:instance():getTargets()
      if Lib.getTableSize(targets) > 0 then
        local node = self:getNode(targets[1])
        if node then
          Lib.emitEvent(Event.EVENT_UPDATE_COMMAND, {
            pos = node:getPosition()
          })
          Lib.emitEvent(Event.EVENT_SELECT_TARGET)
        end
      end
    end
  end)
  Lib.subscribeEvent(Event.EVENT_DELETE_NODE, function(id)
    self:destroyNode(id)
  end)
  Lib.subscribeEvent(Event.EVENT_ENABLE_MULTIPLE, function(multiple)
    if multiple == true then
      self:pushState("MultipleSelection")
    else
      self:popState("MultipleSelection")
    end
  end)
  Lib.subscribeEvent(Event.EVENT_NEW_NODE, function(cfg, pos)
    local node = self:createNode(cfg)
    if node then
      if pos then
        node:setPosition(pos)
      end
      Lib.emitEvent(Event.EVENT_ADD_TARGET, node:getId())
    end
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_NODE, function(id, object, reset)
    self:updateNode(id, object, reset)
  end)
end

function GameManager:initUpdateTimer()
  if self.updateTimer then
    LuaTimer:cancel(self.updateTimer)
  end
  self.updateTimer = LuaTimer:schedule(function()
    Lib.emitEvent(Event.EVENT_SAVE_MAP_CHANGE)
  end, 0, 60000)
end

function GameManager:createMod(id, hitPos, normal)
  local ConfigManager = T(MobileEditor, "ConfigManager")
  local config = ConfigManager:instance():getConfig("modConfig", id)
  if config then
    local cfg = PartCfg:get("myplugin/" .. config.cfgName)
    if cfg then
      local snapPos
      if config.type == "geometry" then
        snapPos = util:snap(hitPos, Define.MOD_INTERVAL.GEOMETRY)
      else
        snapPos = util:snap(hitPos, Define.MOD_INTERVAL.PROP)
      end
      if config.cfgName == "birth" then
        local CommandBirthNew = require("common.command.command_birth_new")
        CommandManager:instance():register(CommandBirthNew:new(nil, cfg, snapPos, normal, id))
      else
        local CommandNew = require("common.command.command_new")
        CommandManager:instance():register(CommandNew:new(nil, cfg, snapPos, normal, id))
      end
    end
  end
end

function GameManager:createNode(cfg)
  if cfg then
    local node = BaseNode:new(cfg)
    node:gotoState("Place")
    self.nodes[node:getId()] = node
    Lib.emitEvent(Event.EVENT_UPDATE_MAP_OBJECT_COUNT)
    return node
  end
  return nil
end

function GameManager:destroyNode(id)
  local node = self.nodes[id]
  if node then
    node:destroy()
    self.nodes[id] = nil
    Lib.emitEvent(Event.EVENT_UPDATE_MAP_OBJECT_COUNT)
  end
end

function GameManager:updateNode(id, object, reset)
  if object then
    local className = IInstance:getClassName(object)
    if className then
      local node = BaseNode:new(nil, false)
      node:setObject(object)
      node:setNodeType(util:getNodeType(className))
      node:gotoState("Place")
      if reset then
        node:resetMaterialColor()
      end
      self.nodes[id] = node
    end
  else
    self.nodes[id] = nil
  end
end

function GameManager:all(targets, func)
  local list = {}
  for i = 1, #targets do
    local id = targets[i]
    local node = self:getNode(id)
    if node then
      if func(node) then
        table.insert(list, node:getObject())
      else
        return nil
      end
    end
  end
  return list
end

function GameManager:filter(targets, func, includeChildren)
  local function listChildren(object, list)
    if not object or not object:isValid() then
      return
    end
    local count = object:getChildrenCount()
    for i = 1, count do
      local child = object:getChildAt(i - 1)
      if child then
        table.insert(list, child)
      end
      listChildren(child, list)
    end
  end
  
  local list = {}
  for i = 1, #targets do
    local id = targets[i]
    local node = self:getNode(id)
    if node then
      if not func or func(node) then
        table.insert(list, node:getObject())
      end
      if includeChildren then
        listChildren(node:getObject(), list)
      end
    end
  end
  return list
end

function GameManager:getNodes(targets)
  if targets and Lib.getTableSize(targets) > 0 then
    local nodes = {}
    for i = 1, #targets do
      local node = self:getNode(targets[i])
      if node then
        table.insert(nodes, node)
      end
    end
    return nodes
  else
    return self.nodes
  end
end

function GameManager:getNode(id)
  return self.nodes[id]
end

function GameManager:load()
  local manager = World.CurWorld:getSceneManager()
  local scene = manager:getCurScene()
  self.root = scene:getRoot()
  local count = self.root:getChildrenCount()
  for i = 1, count do
    local child = self.root:getChildAt(i - 1)
    if child then
      local className = IInstance:getClassName(child)
      if className then
        local node = BaseNode:new(nil, false)
        node:setObject(child)
        node:loadAttributes()
        node:setNodeType(util:getNodeType(className))
        node:gotoState("Place")
        self.nodes[child:getInstanceID()] = node
        if node:get("name") == "floor" then
          self.floor = node
        elseif node:get("name") == "birth" then
          self.birthId = node:getId()
        end
      end
    end
  end
  Lib.logDebug("node size = ", Lib.getTableSize(self.nodes))
end

function GameManager:getBirthId()
  return self.birthId
end

function GameManager:setBirthId(birthId)
  self.birthId = birthId
end

function GameManager:getCenter(targets)
  local nodes = {}
  for i = 1, #targets do
    local id = targets[i]
    local node = GameManager:instance():getNode(id)
    if node then
      table.insert(nodes, node)
    end
  end
  return util:getCenter(nodes)
end

function GameManager:getFloorBound()
  local bounds = {
    min = {
      x = -64,
      y = 31,
      z = -64
    },
    max = {
      x = 64,
      y = 64,
      z = 64
    }
  }
  if World.CurMap.cfg and World.CurMap.cfg.floorBound and next(World.CurMap.cfg.floorBound) then
    local bound1 = World.CurMap.cfg.floorBound[1]
    local bound2 = World.CurMap.cfg.floorBound[2]
    bounds = {
      min = {
        x = math.min(bound1.x, bound2.x),
        y = math.min(bound1.y, bound2.y),
        z = math.min(bound1.z, bound2.z)
      },
      max = {
        x = math.max(bound1.x, bound2.x),
        y = math.max(bound1.y, bound2.y),
        z = math.max(bound1.z, bound2.z)
      }
    }
  end
  return bounds
end

function GameManager:panCamera(curX, curY, prevX, prevY)
  local prevResult = BM:getScreenIntersectPlane(Lib.v2(prevX, prevY), Lib.v3(0, 1, 0), Lib.v3(0, 31, 0))
  local curResult = BM:getScreenIntersectPlane(Lib.v2(curX, curY), Lib.v3(0, 1, 0), Lib.v3(0, 31, 0))
  local delta = prevResult.intersect - curResult.intersect
  Lib.emitEvent(Event.EVENT_PAN_CAMERA, delta)
end

function GameManager:tick()
end

function GameManager:reset()
  self.root = nil
  self.createModId = nil
  self.isTouchBegin = false
  self.isTouchMove = false
  self.touchBeginId = nil
  self.touchEndId = nil
  self.touchBeginPos = nil
  self.nodes = {}
  self.selectedNodes = {}
  self.floor = nil
  self.birth = nil
end

return GameManager
