local widget_base = require("ui.widget.widget_base")
local WidgetDramaItem = Lib.derive(widget_base)
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WidgetDramaItem:init()
  widget_base.init(self, "DramaItem.json")
  self:root():SetName("DramaItem")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaItem:initUI()
  self.lytContentPanel = self:child("DramaItem-ContentPanel")
  self.imgItemBg = self:child("DramaItem-ItemBg")
  self.lytHeadPanel = self:child("DramaItem-HeadPanel")
  self.imgHeadIcon = self:child("DramaItem-HeadIcon")
  self.imgHeadFrame = self:child("DramaItem-HeadFrame")
  self.imgLikeBg = self:child("DramaItem-LikeBg")
  self.txtLikesNum = self:child("DramaItem-LikesNum")
  self.txtMasterName = self:child("DramaItem-MasterName")
  self.lytPlayerPanel = self:child("DramaItem-PlayerPanel")
  self.imgPlayerIcon = self:child("DramaItem-PlayerIcon")
  self.txtPlayerNum = self:child("DramaItem-PlayerNum")
  self.btnJoinBtn = self:child("DramaItem-JoinBtn")
  self.lytClickPanel = self:child("DramaItem-ClickPanel")
end

function WidgetDramaItem:initEvent()
  self:subscribe(self.btnJoinBtn, UIEvent.EventButtonClick, function()
    Me:requestJoinDrama(self.data.id)
  end)
  self:subscribe(self.lytClickPanel, UIEvent.EventWindowClick, function()
    if self.data.userId == Me.platformUserId then
      UI:openWnd("dramaTemplateEdit", self.data)
    else
      UI:getWnd("dramaTemplateInfo"):onShow(true, self.data)
    end
  end)
  self:subscribe(self.lytHeadPanel, UIEvent.EventWindowClick, function()
  end)
end

function WidgetDramaItem:getOneShortContent(inputText)
  local content = World.CurWorld:filterWord(inputText)
  local endIndex = Lib.subStringGetTotalIndex(content)
  local maxLen = World.cfg.dramaSetting.listShowDescMax or 50
  if endIndex > maxLen then
    local content = Lib.subStringUTF8(content, 1, maxLen)
    return content .. "..."
  end
  return content
end

function WidgetDramaItem:onDataChanged(data)
  self.data = data
  self.txtMasterName:SetText(data.scriptName and Lang:toText(data.scriptName) or "")
  if data.picUrl and #data.picUrl > 0 then
    self.imgHeadIcon:SetImageUrl(data.picUrl)
  else
    self.imgHeadIcon:SetImage(World.cfg.defaultAvatar)
  end
  self.txtLikesNum:SetText(Lib.toNewThousandthString(data.likes or 0))
  self.txtPlayerNum:SetText(data.currentNumber .. "/" .. data.maxNumber)
  if DramaClientHelper.curDramaInfo and DramaClientHelper.curDramaInfo.id == self.data.id then
    self.btnJoinBtn:SetVisible(false)
  elseif data.currentNumber < data.maxNumber then
    self.btnJoinBtn:SetVisible(true)
  else
    self.btnJoinBtn:SetVisible(false)
  end
end

function WidgetDramaItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaItem
