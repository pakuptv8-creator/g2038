local widget_base = require("ui.widget.widget_base")
local WidgetModMainSelect = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModMainSelect:init()
  widget_base.init(self, "ModMainSelect.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.MainRecommend
  self.reqRecommendKey = "ModMainSelect_Recommend"
  self.reqTopEventKey = "ModMainSelect_TopEvent"
  ModAsyncProxy:regDelegateRequest(self.reqRecommendKey, AsyncProcess.GetRecommendGameList, Event.EVENT_MOD_EDITOR_UPDATE_RECOMMEND)
  ModAsyncProxy:regDelegateRequest(self.reqTopEventKey, AsyncProcess.GetModTopEventList, Event.EVENT_MOD_MAIN_TOP_EVENT_SHOW)
end

function WidgetModMainSelect:initUI()
  self.lytContentPanel = self:child("ModMainSelect-ContentPanel")
  self.lytEditPanel = self:child("ModMainSelect-EditPanel")
  self.imgEditBg = self:child("ModMainSelect-editBg")
  self.editSearchEdit = self:child("ModMainSelect-searchEdit")
  self.btnGlass = self:child("ModMainSelect-glass")
  self.btnEditClose = self:child("ModMainSelect-editClose")
  self.btnEditClose:SetVisible(false)
  self.lytContentList = self:child("ModMainSelect-ContentList")
  self.secondBottom = UIMgr:new_widget("modSelectBottom")
  self.secondBottom:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytContentList:AddChildWindow(self.secondBottom)
  self.gridViewRight = UIMgr:new_widget("grid_view")
  self.gridViewRight:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gridViewRight:InitConfig(0, 1, 1)
  self.lytContentList:AddChildWindow(self.gridViewRight)
  self.gridViewRight:SetAutoColumnCount(false)
  self.searchUIWidget = UIMgr:new_widget("modSearch")
  self.searchUIWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytContentList:AddChildWindow(self.searchUIWidget)
  self.searchUIWidget:SetVisible(false)
  self.modTopPanel = UIMgr:new_widget("modSelectTop")
  self.gridViewRight:AddItem(self.modTopPanel)
  self.modBottomPanel = UIMgr:new_widget("modSelectBottomTop")
  self.gridViewRight:AddItem(self.modBottomPanel)
  self.recommendGameData = {}
  self.isRequestingData = 0
  self:updateBottomStateShow(1)
end

function WidgetModMainSelect:initEvent()
  self:subscribe(self.btnGlass, UIEvent.EventButtonClick, function()
    self:openSearchUI()
  end)
  self:subscribe(self.btnEditClose, UIEvent.EventButtonClick, function()
    self:closeSearchUI()
  end)
  self:subscribe(self.editSearchEdit, UIEvent.EventEditTextInput, function()
    local inputText = string.format(self.editSearchEdit:GetPropertyString("Text", ""))
    inputText = Lib.standardizingInput(inputText, World.cfg.modSearchMaxWordsNum or 24)
    if self.lastInput and self.lastInput == inputText then
      return
    end
    self.lastInput = inputText
    self.editSearchEdit:SetProperty("Text", inputText)
    self:openSearchUI()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_EDITOR_UPDATE_RECOMMEND, function(data)
    self:updateRecommendViewShow(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_SELECT_BOTTOM_STATE, function(state)
    self:updateBottomStateShow(state)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_MAIN_TOP_EVENT_SHOW, function(data)
    self:updateEventViewShow(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_NOTIFY_CHANGE_RECOMMEND_MAP, function(pageNo)
    if not pageNo then
      return
    end
    self:requestEditorRecommendMod(pageNo)
  end)
  self:subscribe(self.gridViewRight, UIEvent.EventScrollMoveChange, function()
    local offset = self.gridViewRight:GetScrollOffset()
    local minOffset = self.gridViewRight:GetMinScrollOffset()
    if offset < minOffset then
      if #self.recommendGameData <= 8 then
        if os.time() - self.isRequestingData > 1 then
          self.isRequestingData = os.time()
          self:requestEditorRecommendMod()
        end
      else
        self:updateBottomStateShow(2)
      end
    elseif 0 < offset then
    end
  end)
end

function WidgetModMainSelect:reload(needInitData)
  ModReportProxy:openUIReport(self.reportName)
  self.lastInput = nil
  if needInitData then
    self.recommendGameData = {}
    self.secondBottom:invoke("resetRecommendData")
    self.modBottomPanel:invoke("resetRecommendData")
    self:requestEditorRecommendMod(0)
    self:requestModMainEvent()
  end
  self.gridViewRight:ResetPos()
  self.secondBottom:invoke("resetPos")
  self:updateBottomStateShow(1)
end

function WidgetModMainSelect:requestEditorRecommendMod(pageNo)
  local mPageNo = self.pageNo or 0
  local pageNo = pageNo or mPageNo + 1
  local pageSize = Define.ModMapOnceNum
  ModAsyncProxy:request(self.reqRecommendKey, pageNo, pageSize)
end

function WidgetModMainSelect:requestModMainEvent()
  ModAsyncProxy:request(self.reqTopEventKey)
end

function WidgetModMainSelect:updateRecommendViewShow(data)
  self.pageNo = data.pageNo or 0
  for _, val in pairs(data.data or {}) do
    Lib.attachModItemInfo(val, World.cfg.modUIInfo.modItemFromPathMappings.MainRecommend)
    table.insert(self.recommendGameData, val)
  end
  self.modBottomPanel:invoke("updateItemByData", data)
  self.secondBottom:invoke("updateItemByData", data)
end

function WidgetModMainSelect:updateEventViewShow(data)
  self.modTopPanel:invoke("updateItemByData", data)
end

function WidgetModMainSelect:updateBottomStateShow(state)
  self.bottomState = state
  if state == 1 then
    self.secondBottom:SetVisible(false)
    self.gridViewRight:SetVisible(true)
  else
    self.secondBottom:SetVisible(true)
    self.gridViewRight:SetVisible(false)
  end
end

function WidgetModMainSelect:onClose()
  if self.isOpenSearchUI == true then
    self:closeSearchUI()
  end
  self.lastInput = nil
  ModReportProxy:closeUIReport(self.reportName)
end

function WidgetModMainSelect:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqRecommendKey)
  ModAsyncProxy:unRegDelegateRequest(self.reqTopEventKey)
end

function WidgetModMainSelect:openSearchUI(str)
  self.isOpenSearchUI = true
  local inputText = str or string.format(self.editSearchEdit:GetPropertyString("Text", ""))
  inputText = Lib.standardizingInput(inputText, World.cfg.modSearchMaxWordsNum or 24)
  self.searchUIWidget:invoke("reload", inputText)
  Lib.logDebug("--WidgetModMainSelect input:" .. inputText)
  self.gridViewRight:SetVisible(false)
  self.searchUIWidget:SetVisible(true)
  self.btnEditClose:SetVisible(true)
  self.secondBottom:SetVisible(false)
end

function WidgetModMainSelect:closeSearchUI()
  self.isOpenSearchUI = false
  self:updateBottomStateShow(self.bottomState or 1)
  self.searchUIWidget:SetVisible(false)
  self.searchUIWidget:invoke("onClose")
  self.btnEditClose:SetVisible(false)
  self.editSearchEdit:SetProperty("Text", "")
end

return WidgetModMainSelect
