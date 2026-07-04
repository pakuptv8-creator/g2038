local Player = _ENV.Player
local Entity = _ENV.Entity
local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")

function Entity:getHeadPostContent()
  if World.cfg.tenderAwardSetting.isIgnoreTenderAward then
    return ""
  end
  if self.isPlayer then
    local winTxt, winColor = TenderClientAwardManager:getTenderingWinPostStr(self.platformUserId)
    if winTxt then
      return "[C=FF" .. winColor .. "]" .. Lang:toText(winTxt)
    else
      return ""
    end
  end
  return ""
end

function Player:onOpenTenderingTransfer(type, part, params)
  if part and part:isValid() then
    Plugins.CallTargetPluginFunc("tendering_land", "openTenderSignWnd")
  end
end

function Player:onUpdateMayorStatueUI(isShow, objId, name)
  if isShow then
    local entity = World.CurWorld:getEntity(objId)
    if not entity or not entity:isValid() then
      self:onUpdateMayorStatueUI(false)
      return
    end
    if not self.mayorStatueUI then
      self:createMayorStatueUI(objId)
    end
    if name then
      self.mayorStatueUI:updateNameInfo(name)
    else
      self.mayorStatueUI:updateNameInfo(TenderClientAwardManager:getNormalMayorName())
    end
  elseif self.mayorStatueUI then
    UI:closeSceneWnd(self.mayorStatueUI:root():data("sceneKey"))
    UI:closeWnd(self.mayorStatueUI)
    self.mayorStatueUI = nil
  end
end

function Player:createMayorStatueUI(objId)
  local width = 100
  local height = 100
  local position = World.cfg.tenderAwardSetting.mayorOffset
  local rotate = World.cfg.tenderAwardSetting.mayorRotate
  local uiKey = "tenderMayorName" .. objId
  self.mayorStatueUI = UIMgr:new_wnd("tenderMayorName")
  self.mayorStatueUI:root():setData("sceneKey", uiKey)
  self.mayorStatueUI:show()
  self.mayorStatueUI:onOpen()
  GUISystem.instance:BindWorldWindow(uiKey, self.mayorStatueUI:root(), width, height, rotate, position, objId)
end
