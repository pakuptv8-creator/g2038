local DramaClientHelper = T(Lib, "DramaClientHelper")
local cjson = require("cjson")
local DramaCommonHelper = T(Lib, "DramaCommonHelper")
local templateExclusionContent = World.cfg.dramaSetting.templateExclusionContent or {}

function DramaClientHelper:init()
  self.thumbUpList = {}
  self:initEvent()
end

function DramaClientHelper:initEvent()
  Lib.subscribeEvent(Event.EVENT_CLOSE_WINDOW, function(uiName)
    if uiName == "alternativeDialog" then
      Plugins.CallTargetPluginFunc("game_common", "UpdateCommonWaitWndShow", false)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not (entity and entity:isValid()) or not entity.isPlayer then
      return
    end
    if not Lib.isGameDrama() then
      return
    end
    if self:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
      local value = entity:getGiantShape()
      entity:updateActorShape(value, World.cfg.dramaSetting.giantSetting.shapeEyeHeight)
    end
  end)
end

function DramaClientHelper:doDramaThumbUpPlayer(targetUserId)
  if self.thumbUpList[targetUserId] then
    return
  end
  local packet = {
    pid = "RequestDramaThumbUpPlayer",
    targetUserId = targetUserId
  }
  Me:sendPacket(packet)
end

function DramaClientHelper:updateCurDramaInfo(curDramaInfo)
  if curDramaInfo and curDramaInfo.scriptData then
    self.curDramaInfo = curDramaInfo
    self.curDramaInfo.roleList = self:dealScriptDataToModList(curDramaInfo.scriptData)
    if curDramaInfo and curDramaInfo.scriptData then
      DramaCommonHelper:initTemplate(DramaCommonHelper:dealScriptDataToModList(curDramaInfo.scriptData))
    end
  else
    self.curDramaInfo = nil
  end
  Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_CUR_DETAIL)
end

function DramaClientHelper:requestLeaveDrama()
  if not self.curDramaInfo then
    return
  end
  UI:getWnd("commonDialog"):onShow(true, {
    title = "g2052.gui.tendering.tips",
    desc = "g2052.gui.drama.confirm.leave",
    confirmCallback = function()
      local packet = {
        pid = "RequestLeaveDrama"
      }
      Me:sendPacket(packet)
    end,
    cancelCallback = function()
    end
  })
end

function DramaClientHelper:requestDissolveDrama()
  if not self.curDramaInfo then
    return
  end
  UI:getWnd("commonDialog"):onShow(true, {
    title = "g2052.gui.tendering.tips",
    desc = "g2052.gui.drama.confirm.dissolve",
    confirmCallback = function()
      local packet = {
        pid = "RequestDissolveDrama"
      }
      Me:sendPacket(packet)
    end,
    cancelCallback = function()
    end
  })
end

function DramaClientHelper:updateClientRegionId(regionId)
  self.regionId = regionId
end

function DramaClientHelper:dealScriptDataToModList(scriptData)
  return DramaCommonHelper:dealScriptDataToModList(scriptData)
end

function DramaClientHelper:requestDramaInfoList(tabType, pageNo, pageSize, lastRecordCreateTimeLong, lastRecordCurrentNumber, lastRecordId)
  local pageSize = pageSize or World.cfg.dramaSetting.dramaPageSize
  AsyncProcess.GetDramaListWithPage(function(data)
    Lib.emitEvent(Event.EVENT_DRAMA_CONTENT_UPDATE, tabType, data, pageNo)
  end, pageNo, pageSize, tabType, lastRecordCreateTimeLong, lastRecordCurrentNumber, lastRecordId)
end

function DramaClientHelper:getDramaModList()
  local modList = {}
  if self.curDramaInfo and self.curDramaInfo.scriptData then
    modList = DramaCommonHelper:dealScriptDataToModList(self.curDramaInfo.scriptData)
    self.curDramaInfo.modList = modList
  end
  return modList
end

function DramaClientHelper:checkInTemplateMod(templateKey)
  if not Lib.isGameDrama() then
    return false
  end
  local modList = self:getDramaModList()
  for _, key in pairs(modList) do
    if key == templateKey then
      return true
    end
  end
  return false
end

function DramaClientHelper:getsTemplateExclusionContent(type)
  local data = {}
  if not Lib.isGameDrama() then
    return data
  end
  local modList = self:getDramaModList()
  for _, key in pairs(modList) do
    local info = templateExclusionContent[tostring(key)]
    if info and info[tostring(type)] then
      for _, v in pairs(info[tostring(type)]) do
        data[v] = true
      end
    end
  end
  return data
end

DramaClientHelper:init()
