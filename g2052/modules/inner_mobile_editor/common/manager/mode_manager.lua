local util = require("common.util.util")
local ModeManager = T(MobileEditor, "ModeManager")

function ModeManager:initialize()
  self.mode = Define.EDITOR_MODE.OFF
  self.blockId = nil
  self.needBidding = false
  self.screenShootUrl = nil
  self.mapUrl = nil
  self.mapObjCount = 0
  Lib.subscribeEvent(Event.EVENT_SAVE_MAP_FINISH, function()
    if not self.needUploadMap then
      return
    end
    self.needUploadMap = false
    local blockId = self.blockId
    local mapPath = "map/" .. Me.platformUserId .. "_map/" .. self.blockId .. "/setting.json"
    local newCompletePath = Lib.combinePath(Root.Instance():getGamePath(), mapPath)
    if not Lib.fileExists(newCompletePath) then
      return
    end
    Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, true)
    local DataManager = T(MobileEditor, "DataManager")
    DataManager:instance():compressMapJson()
    util:uploadMap(newCompletePath, function(data, uploadMapSuccess)
      if not uploadMapSuccess then
        self.needBidding = false
        Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, false)
        Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, uploadMapSuccess and Lang:toText("ui.setting.upload.success") or Lang:toText("ui.setting.upload.fail"))
        return
      end
      self.mapUrl = data
      local needBidding = self.needBidding
      util:pushMapData(self.blockId, self.screenShootUrl or "", self.mapUrl, Define.UPDATE_MAP_TYPE.NORMAL, function(isSuccess)
        if not needBidding then
          Lib.emitEvent(Event.EVENT_UPLOAD_MAP_DATA_FINISH, Define.UPDATE_MAP_TYPE.NORMAL, isSuccess)
          Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, isSuccess and Lang:toText("ui.setting.upload.success") or Lang:toText("ui.setting.upload.fail"))
          World.Timer(30, function()
            Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, false)
          end)
        end
      end)
      if needBidding then
        self.needBidding = false
        if not self:isCanBidding() or self:isUpperLimitReached() then
          Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.bidding.limit_count"))
          Lib.emitEvent(Event.EVENT_UPLOAD_MAP_DATA_FINISH, Define.UPDATE_MAP_TYPE.BIDDING, false)
          Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, false)
          return
        end
        local CameraManager = T(MobileEditor, "CameraManager")
        local viewData = CameraManager:instance():getCurViewData()
        local screenShot = self.data.screenShot
        if screenShot then
          Lib.emitEvent(Event.EVENT_SET_CAMERA, screenShot.pos, screenShot.yaw, screenShot.pitch, 0)
        end
        World.Timer(20, function()
          util:screenShot(blockId, function(path)
            Lib.emitEvent(Event.EVENT_SET_CAMERA, viewData.pos, viewData.yaw, viewData.pitch, 0)
            Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.setting.screen.shot.success"))
            util:uploadMapScreenShot(Me.platformUserId, blockId, path.rectangle, function(data)
              self.screenShootUrl = data
              util:pushMapData(self.blockId, self.screenShootUrl, self.mapUrl, Define.UPDATE_MAP_TYPE.BIDDING, function(isSuccess)
                Lib.emitEvent(Event.EVENT_UPLOAD_MAP_DATA_FINISH, Define.UPDATE_MAP_TYPE.BIDDING, isSuccess)
                Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, isSuccess and Lang:toText("ui.setting.join.bidding") or Lang:toText("ui.setting.upload.fail"))
                Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, false)
              end)
            end)
          end)
        end)
      end
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_UPLOAD_MAP_DATA, function(needUploadMap, needBidding)
    self.needUploadMap = needUploadMap
    self.needBidding = needBidding
    Lib.emitEvent(Event.EVENT_SAVE_MAP_CHANGE)
  end)
  Lib.subscribeEvent(Event.EVENT_EDITOR_RELOAD_MAP, function(isRemote)
    if isRemote then
      Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, true)
      util:getMapBlockData(self.blockId, function(data)
        if data then
          self.mapUrl = data.mapResourceUrl
          util:downloadMap(Me.platformUserId, self.blockId, self.mapUrl, function()
            Lib.emitEvent(Event.EVENT_REENTER_MAP)
            Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, false)
            Plugins.CallTargetPluginFunc("inner_mobile_editor", "reEnterEditorMode", self.data, true)
          end)
        else
          Lib.emitEvent(Event.EVENT_REENTER_MAP)
          Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, false)
          Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.setting.remote.not_data"))
        end
      end)
    else
      Plugins.CallTargetPluginFunc("inner_mobile_editor", "reEnterEditorMode", self.data)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_PLAY_BACK_EDIT_MODE, function()
    Plugins.CallTargetPluginFunc("inner_mobile_editor", "reEnterEditorMode", self.cacheData, true)
    self.cacheData = nil
  end)
  Lib.subscribeEvent(Event.EVENT_UPDATE_MAP_OBJECT_COUNT, function()
    self:updateMapObjCount()
  end)
end

function ModeManager:enterEditorMode(data)
  self.data = data
  self.mode = Define.EDITOR_MODE.ON
  self.blockId = data.blockId
  self:updateMapObjCount()
end

function ModeManager:leaveEditorMode()
  self.mode = Define.EDITOR_MODE.OFF
  self.needBidding = false
  self.needUploadMap = false
  self.blockId = nil
  self.screenShootUrl = nil
  self.mapUrl = nil
  self.mapObjCount = 0
end

function ModeManager:isInEditorMode()
  return self.mode == Define.EDITOR_MODE.ON
end

function ModeManager:isUpperLimitReached()
  return self.mapObjCount >= World.cfg.innerMobileEditorSetting.mapObjCountUpperLimit
end

function ModeManager:isCanBidding()
  return self.mapObjCount >= World.cfg.innerMobileEditorSetting.biddingMapObjLimit
end

function ModeManager:getBlockId()
  return self.blockId
end

function ModeManager:updateMapObjCount()
  if not self:isInEditorMode() then
    return
  end
  local mapObjCount = 0
  local manager = World.CurWorld:getSceneManager()
  local sceneTable = World.CurWorld.CurMap:GetSceneAsTable(manager:getCurScene())
  for _, data in ipairs(sceneTable) do
    if data.class == "Model" or data.class == "Part" or data.class == "PartOperation" or data.class == "MeshPart" then
      mapObjCount = mapObjCount + (0 < #data.children and #data.children or 1)
    end
  end
  self.mapObjCount = mapObjCount
end

function ModeManager:getMapObjRemainCount()
  return World.cfg.innerMobileEditorSetting.mapObjCountUpperLimit - self.mapObjCount
end

function ModeManager:cacheModeData()
  self.cacheData = self.data
end

return ModeManager
