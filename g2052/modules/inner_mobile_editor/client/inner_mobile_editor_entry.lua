local ConfigManager = T(MobileEditor, "ConfigManager")
local CommandManager = T(MobileEditor, "CommandManager")
local GizmoManager = T(MobileEditor, "GizmoManager")
local CameraManager = T(MobileEditor, "CameraManager")
local InputManager = T(MobileEditor, "InputManager")
local DataManager = T(MobileEditor, "DataManager")
local TargetManager = T(MobileEditor, "TargetManager")
local GameManager = T(MobileEditor, "GameManager")
local ModeManager = T(MobileEditor, "ModeManager")
local main = {}

function main:init()
  DrawRender.instance:setLineWidth(3)
  local gui = GUISystem.instance
  local lw, lh = gui:GetLogicWidth(), gui:GetLogicHeight()
  local sw, sh = gui:GetScreenWidth(), gui:GetScreenHeight()
  local deadZoneX = 6 / lw * sw
  local deadZoneY = 6 / lh * sh
  Blockman.Instance().gameSettings:setDeadZone(Lib.v2(deadZoneX, deadZoneY))
  ConfigManager:instance()
  CommandManager:instance()
  GizmoManager:instance()
  CameraManager:instance()
  DataManager:instance()
  TargetManager:instance()
  GameManager:instance()
  ModeManager:instance()
  InputSystem.instance:addHandler(InputManager:instance(), 698)
  InputManager:instance().enabled = false
end

main:init()

function handle_input(frameTime)
  if not ModeManager:instance():isInEditorMode() then
    Profiler:begin("handle_input")
    PlayerControl.UpdateControl(frameTime)
    Instance.runAllMoveNodeTick()
    Profiler:finish("handle_input")
  end
end

local debugport = require("common.debugport")
local tickEngineHandler = L("tickEngineHandler", handle_tick)

function handle_tick(frameTime)
  if ModeManager:instance():isInEditorMode() then
    World.Tick()
    debugport.Tick()
    if Me and Me.onTick then
      Me:onTick(frameTime)
    end
    local LuaTimer = T(Lib, "LuaTimer")
    LuaTimer:onTick(frameTime)
    GameManager:instance():tick()
  else
    tickEngineHandler(frameTime)
  end
end

function gizmo_event_begin()
  GizmoManager:instance():handleEventBegin()
end

function gizmo_event_move(...)
  GizmoManager:instance():handleEventMove(...)
end

function gizmo_event_end()
  GizmoManager:instance():handleEventEnd()
end
