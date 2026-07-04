local widget_base = require("ui.widget.widget_base")
local WidgetDramaHistoryItem = Lib.derive(widget_base)
local DramaCoverConfig = T(Config, "DramaCoverConfig")
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WidgetDramaHistoryItem:init()
  widget_base.init(self, "DramaHistoryItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaHistoryItem:initUI()
  self.txtDramaName = self:child("DramaHistoryItem-DramaName")
  self.txtDramaDetail = self:child("DramaHistoryItem-DramaDetail")
  self.txtLikeNum = self:child("DramaHistoryItem-LikeNum")
  self.btnUseBtn = self:child("DramaHistoryItem-UseBtn")
  self.btnUseBtn:SetText(Lang:toText("g2052.gui.drama.use"))
  self.txtRoleNum = self:child("DramaHistoryItem-RoleNum")
  self.lytRoleList = self:child("DramaHistoryItem-RoleList")
  self.btnPreBtn = self:child("DramaHistoryItem-ArrowLeft")
  self.btnNextBtn = self:child("DramaHistoryItem-ArrowRight")
  self.imgSmallCover = self:child("DramaHistoryItem-SmallCoverImage")
  self:initRoleAdapter()
end

function WidgetDramaHistoryItem:initRoleAdapter()
  self.roleGridView = UIMgr:new_widget("grid_view")
  self.lytRoleList:AddChildWindow(self.roleGridView)
  self.roleGridView:SetMoveAble(false)
  self.roleGridView:SethScorllMoveAble(false)
  self.roleGridView:SetvScorllMoveAble(false)
  self.roleGridView:SetAutoColumnCount(false)
  self.roleGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.roleCells = {}
  self.roleGridView:InitConfig(0, 0, 4)
  for i = 1, 4 do
    local cell = UIMgr:new_widget("dramaHistoryRoleItem")
    self.roleGridView:AddItem(cell)
    self.roleCells[i] = cell
    self.roleCells[i]:invoke("setRoleVisible", false)
  end
end

function WidgetDramaHistoryItem:initEvent()
  self:subscribe(self.btnUseBtn, UIEvent.EventButtonClick, function()
    if self.data then
      Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_CREATE_INFO, self.data)
    end
    UI:closeWnd("dramaHistory")
    Plugins.CallTargetPluginFunc("report", "report", "script_lastuse", nil, Me)
  end)
end

function WidgetDramaHistoryItem:onDataChanged(data)
  self.data = data
  if not data.roleList then
    data.roleList = DramaClientHelper:dealScriptDataToModList(data.scriptData)
    for key, role in pairs(self.data.roleList) do
      self.data.roleList[key].userIdList = {}
      self.data.roleList[key].roleSelects = 0
    end
  end
  self.txtDramaName:SetText(data.scriptName)
  self.txtDramaDetail:SetText(data.summary)
  self.txtLikeNum:SetText(data.likes)
  self.txtRoleNum:SetText(data.maxNumber)
  local cfg = DramaCoverConfig:getCfgById(data.scriptPic)
  if cfg then
    self.imgSmallCover:SetImage(cfg.smallImg)
  end
  self:updateRoleListShow(1)
end

function WidgetDramaHistoryItem:updateRoleListShow(pageNum)
  self.curPageNo = pageNum
  for i = 1, 4 do
    local index = (pageNum - 1) * 4 + i
    if self.data.roleList[index] then
      self.roleCells[i]:invoke("setRoleVisible", true)
      self.roleCells[i]:invoke("updateRoleInfo", self.data.roleList[index])
    else
      self.roleCells[i]:invoke("setRoleVisible", false)
    end
  end
end

function WidgetDramaHistoryItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaHistoryItem
