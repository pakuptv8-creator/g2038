local WinDance = M
local DanceConfig = T(Config, "DanceConfig")

function WinDance:init()
  WinBase.init(self, "Dance.json")
  self:initUI()
  self:initEvent()
end

function WinDance:initUI()
  self.lytMask = self:child("Dance-mask")
  self.imgInterface = self:child("Dance-Interface")
  self.lytInterfaceDataList = self:child("Dance-Interface-Data-List")
  self.btnClose = self:child("Dance-Close")
  self.txtDanceTitle = self:child("Dance-DanceTitle")
  local ratio = UIMgr.UIShowManage:getAdapterRatio()
  self.itemsGrid = UIMgr:new_widget("grid_view", self.lytInterfaceDataList)
  self.itemsGrid:InitConfig(10, 18, 2)
  self.itemsAdapter = UIMgr:new_adapter("danceItem", 130, 67)
  self.itemsGrid:invoke("setAdapter", self.itemsAdapter)
  self:updateCurDanceId(0)
  self:updateOldDanceId(0)
  self.txtDanceTitle:SetText(Lang:toText("g2052.gui.dance.dance_title"))
end

function WinDance:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    Me:simulationClickOnScene()
    self:onHide()
  end)
  Lib.subscribeEvent(Event.EVENT_DANCE_ACTION_CLICK, function(actionId)
    self:selectDance(actionId)
  end)
end

function WinDance:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DANCE_ITEM_SHOW, function()
    self:updateItemsShow()
  end)
end

function WinDance:updateCurDanceId(actionId)
  self.curPlayDanceId = actionId or 0
end

function WinDance:updateOldDanceId(actionId)
  self.oldPlayDanceId = actionId or 0
end

function WinDance:selectDance(actionId)
  if actionId == self.curPlayDanceId then
    Me:requestStopDanceAction()
  else
    Me:requestDoDanceAction(actionId)
    if not Me.firstDoDanceAction then
      local defaultData = {action_id = actionId}
      Plugins.CallTargetPluginFunc("report", "report", "first_action", defaultData, Me)
      Me.firstDoDanceAction = true
    end
  end
  self:updateItemsShow()
end

function WinDance:updateItemsShow()
  local curPlayDance = self.curPlayDanceId
  for _, info in pairs(self.danceData or {}) do
    if 0 < curPlayDance and info.id == curPlayDance then
      info.select = true
    else
      info.select = false
    end
  end
  self.itemsAdapter:notifyDataChange()
end

function WinDance:initView()
  if not self.initGridView then
    self.initGridView = true
    local danceInfo = Lib.copy(DanceConfig:getAllCfgs())
    self.itemsAdapter:clearItems()
    self.itemsGrid:ResetPos()
    local curPlayDance = self.curPlayDanceId
    self.danceData = {}
    for _, val in pairs(danceInfo) do
      if val.showRight == 1 then
        if 0 < curPlayDance and val.id == curPlayDance then
          val.select = true
        end
        table.insert(self.danceData, val)
      end
    end
    table.sort(self.danceData, function(a, b)
      return (a.sort or 0) < (b.sort or 0)
    end)
    self.itemsAdapter:setData(self.danceData)
  else
    self:updateItemsShow()
  end
end

local function initSomeData(self)
  for _, fun in pairs(self._allEvent or {}) do
    fun()
  end
  for _, timer in pairs(self._timer or {}) do
    if timer then
      timer()
    end
  end
  self._allEvent = {}
  self._timer = {}
end

function WinDance:onHide()
  UI:closeWnd("dance")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinDance:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dance")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDance:onOpen()
  Me:uiMutualExclusion("dance")
  initSomeData(self)
  self:subscribeEvent()
  self:initView()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
end

function WinDance:onClose()
  initSomeData(self)
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
end

return WinDance
