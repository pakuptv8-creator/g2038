require("common.entity_inner_mobile_editor")
if World.isClient then
  require("common.manager.manager_init")
  require("common.gm.gm_client")
  require("common.util.sound_util")
  require("inner_mobile_editor_define")
  require("inner_mobile_editor_event_define")
  require("client.world.inner_mobile_map")
  require("client.inner_mobile_editor_entry")
  require("client.async_process_inner_mobile_editor")
  require("client.inner_mobile_editor_common_ui")
  Lib.subscribeEvent(Event.EVENT_ENTER_EDITOR_MODE, function()
    Root.Instance():setEnableScreenSpaceCull(false)
    Me:startScanningSurroundingParts(true)
    DebugDraw.instance:setEnabled(true)
    DebugDraw.instance:setDrawSelectedPartAABBEnabled(true)
    Blockman.Instance():control():setMove(0, 0)
  end)
  Lib.subscribeEvent(Event.EVENT_LEAVE_EDITOR_MODE, function()
    Root.Instance():setEnableScreenSpaceCull(World.cfg.screenSpaceCull)
    DebugDraw.instance:setEnabled(false)
    DebugDraw.instance:setDrawSelectedPartAABBEnabled(false)
  end)
else
  require("server.player.packet_inner_mobile_editor")
end
local handlers = {}
if World.isClient then
  local ModeManager = T(MobileEditor, "ModeManager")
  local InputManager = T(MobileEditor, "InputManager")
  
  local function enterEditorMode(data)
    if Me.inEnterEditorMode then
      return
    end
    Me.inEnterEditorMode = true
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getOrCreateScene(World.CurWorld.CurMap.obj)
    manager:setCurScene(scene)
    ModeManager:instance():enterEditorMode(data)
    local CameraManager = T(MobileEditor, "CameraManager")
    CameraManager:instance():gotoState("ThirdPerson")
    local GameManager = T(MobileEditor, "GameManager")
    GameManager:instance():load()
    GameManager:instance():gotoState("Edit")
    CameraManager:setCollision(false)
    local blockId = ModeManager:instance():getBlockId()
    local filePath = string.format("map/%s/setting.json", blockId)
    local obj = Lib.readGameJson(filePath)
    local initPos = obj.initPos
    if initPos then
      local camPos = Lib.v3(initPos.x, initPos.y + 10, initPos.z)
      Lib.emitEvent(Event.EVENT_SET_CAMERA, camPos, 0, 15, 0)
    end
    InputManager:instance().enabled = true
    if not Me.showPlayUI then
      Me.showPlayUI = UI:hideOpenedWnd({"gm"})
    end
    Me:setEntityHide(true)
    Blockman.instance.gameSettings:setLockViewPos(true)
    if UI:isOpen("mobileEditorMain") then
      UI:closeWnd("mobileEditorMain")
    end
    UI:openWnd("mobileEditorMain")
    Lib.emitEvent(Event.EVENT_ENTER_EDITOR_MODE)
  end
  
  local function leaveEditorMode(isReEnter)
    if not Me.inEnterEditorMode then
      return
    end
    Me.inEnterEditorMode = false
    ModeManager:instance():leaveEditorMode()
    local CameraManager = T(MobileEditor, "CameraManager")
    CameraManager:instance():finalize()
    local GameManager = T(MobileEditor, "GameManager")
    GameManager:instance():finalize()
    local CommandManager = T(MobileEditor, "CommandManager")
    CameraManager:setCollision(true)
    CommandManager:instance():finalize()
    local GizmoManager = T(MobileEditor, "GizmoManager")
    GizmoManager:instance():finalize()
    local TargetManager = T(MobileEditor, "TargetManager")
    TargetManager:instance():finalize()
    InputManager:instance().enabled = false
    Lib.emitEvent(Event.EVENT_LEAVE_EDIT_MODE)
    if not isReEnter then
      Me:setEntityHide(false)
    end
    Blockman.instance.gameSettings:setLockViewPos(false)
    if UI:isOpen("mobileEditorMain") then
      UI:closeWnd("mobileEditorMain")
    end
    if Me.showPlayUI then
      Me.showPlayUI()
      Me.showPlayUI = nil
    end
    Lib.emitEvent(Event.EVENT_LEAVE_EDITOR_MODE)
  end
  
  function handlers.isInEditorMode()
    return ModeManager:instance():isInEditorMode()
  end
  
  function handlers.enterEditorMode(data)
    if World.isClient then
      if Me.inEnterEditorMode or Me.requestEnterEditorMode then
        return
      end
      Me.requestEnterEditorMode = true
      Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
      Plugins.CallTargetPluginFunc("interaction_ui", "cancelInteractiveAction")
      local blockId = data.blockId
      local mapPath = Me.platformUserId .. "_map/" .. blockId
      local newCombinePath = Lib.combinePath(Root.Instance():getGamePath(), "map/" .. mapPath .. "/setting.json")
      if not Lib.fileExists(newCombinePath) then
        Me.targetMap = blockId
      else
        Me.targetMap = mapPath
      end
      Plugins.CallPluginFunc("CHANGE_MAIN_WND_PLAY_MODEL", "MobileEditor", {})
      Me:sendPacket({
        pid = "EnterEditorMode"
      }, function()
        Me.requestEnterEditorMode = false
        enterEditorMode(data)
      end)
    end
  end
  
  function handlers.enterEditorPlayerMode()
    if World.isClient then
      if not Me.inEnterEditorMode then
        return
      end
      local DataManager = T(MobileEditor, "DataManager")
      DataManager:instance():compressMapJson()
      local data = DataManager:instance():getMapJsonData()
      if data and not Me.inEditorPlay then
        Me.inEditorPlay = true
        Me:sendPacket({
          pid = "EditorPlayerModel",
          mapName = data.mapName,
          mapCfg = data.mapJson
        }, function()
          ModeManager:instance():cacheModeData()
          leaveEditorMode()
          UI:openWnd("mobileEditorPlay")
          Me.inEditorPlay = false
        end)
      end
    end
  end
  
  function handlers.leaveEditorMode()
    if not Me.inEnterEditorMode then
      return
    end
    if not ModeManager:instance():isInEditorMode() then
      return
    end
    Me:sendPacket({
      pid = "LeaveEditorMode"
    }, function()
      leaveEditorMode()
    end)
  end
  
  function handlers.reEnterEditorMode(data, isUserMap)
    if Me.inReEnterEditorMode then
      return
    end
    Me.inReEnterEditorMode = true
    Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
    Plugins.CallTargetPluginFunc("interaction_ui", "cancelInteractiveAction")
    Me:sendPacket({
      pid = "LeaveEditorMode",
      leaveType = "reEnter"
    }, function()
      Me.inReEnterEditorMode = false
      leaveEditorMode(true)
      local blockId = data.blockId
      local mapPath = Me.platformUserId .. "_map/" .. blockId
      local newCombinePath = Lib.combinePath(Root.Instance():getGamePath(), "map/" .. mapPath .. "/setting.json")
      Me.targetMap = blockId
      if isUserMap and Lib.fileExists(newCombinePath) then
        Me.targetMap = mapPath
      end
      Plugins.CallPluginFunc("CHANGE_MAIN_WND_PLAY_MODEL", "WaitChange", {})
      Me:sendPacket({
        pid = "EnterEditorMode"
      }, function()
        enterEditorMode(data)
      end)
    end)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
