local GridViewHelper = require("client.ui.grid_view_helper")
local PetConfig = T(Config, "PetConfig")
local WinPartner = M
local tabIcon = {
  {
    tabIcon = "set:g2052_function.json image:icon_0_all",
    type = Define.PET_TYPE.None,
    text = "all"
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_pets",
    type = Define.PET_TYPE.Pet,
    text = "pets"
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_mounts",
    type = Define.PET_TYPE.Mount,
    text = "mounts"
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_monsters",
    type = Define.PET_TYPE.Monster,
    text = "monsters"
  }
}

function WinPartner:init()
  WinBase.init(self, "Partner.json")
  self._allEvent = {}
  self.curPetType = 0
  self:initUI()
  self:initEvent()
end

function WinPartner:initUI()
  self.lytMask = self:child("Partner-Mask")
  self.imgInterface = self:child("Partner-Interface")
  self.txtTitle = self:child("Partner-PartnerTitle")
  self.txtTitle:SetText(Lang:toText("g2052.gui.partner.title"))
  self.lytInterfaceDataList = self:child("Partner-Interface-Data-List")
  self.btnClose = self:child("Partner-Close")
  self.txtNameTitle = self:child("Partner-NameTitle")
  self.txtNameTitle:SetText(Lang:toText("g2052.gui.child.name"))
  self.imgNameBg = self:child("Partner-NameBg")
  self.txtNameTxt = self:child("Partner-NameTxt")
  self.txtNameTxt:SetText(Lang:toText("g2052.gui.child.edit.placeholder"))
  self.btnUndo = self:child("Partner-Undo")
  self.lytTabList = self:child("Partner-PanelTab")
  self.txtAdTips = self:child("Partner-AdTips")
  self.txtAdTips:SetText(Lang:toText("g2052.advertisement.use.car.tips"))
  self.petList = GridViewHelper.new({
    xCellNum = 2,
    moveAble = true,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    widgetWidth = 130,
    widgetHeight = 130,
    yDis = 18,
    xDis = 11,
    widgetJson = "PartnerCell.json",
    widgetName = "partnerCell",
    gvParent = self.lytInterfaceDataList,
    cellSelectedCb = function(data, index, dx, dy)
    end
  })
  self:initPagingList()
end

function WinPartner:initPagingList()
  self._tabGridView = GridViewHelper.new({
    name = "tabGridView",
    xCellNum = 1,
    yDis = 28,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    widgetWidth = 60,
    widgetHeight = 45,
    widgetJson = "TabItem.json",
    widgetName = "tabItem",
    gvParent = self.lytTabList,
    cellSelectedCb = function(data, dx, dy, index)
      self:updateTabContent(data)
    end
  })
  self._tabGridView:setData(tabIcon, 1, nil, true)
end

function WinPartner:updateTabContent(data)
  if not data then
    return
  end
  self.curPetType = data.type
  self:updatePetList(self.curPetType)
  self.petList:getAdapter():setScrollOffset(0)
end

function WinPartner:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnUndo, UIEvent.EventButtonClick, function()
    self:undoChildFollow()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    Me:simulationClickOnScene()
    self:onHide()
  end)
  self:subscribe(self.imgNameBg, UIEvent.EventWindowClick, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.ChildName, function(newName, newColor)
      self:inputCallback(newName, newColor)
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_OPEN_PET_NAME_SETTING, function()
    UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.ChildName, function(newName, newColor)
      self:inputCallback(newName, newColor)
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_WATCH_AD_UPDATE, function()
    self.petList:getAdapter():notifyDataChange()
  end)
end

function WinPartner:subscribeEvent()
end

function WinPartner:inputCallback(newName, newColor)
  local oldName = Me:getPetName()
  local oldColor = Me:getPetNameColor()
  if newName == oldName and newColor == oldColor then
    return
  end
  if newName ~= "" then
    self.txtNameTxt:SetText(newName)
  else
    self.txtNameTxt:SetText(Lang:toText("g2052.gui.child.edit.placeholder"))
  end
  self.txtNameTxt:SetTextColor(Lib.getTextColor(newColor))
  Me:petRename(newName, newColor)
end

function WinPartner:initView(petId)
  self:updatePetList()
  if petId then
    local carryPetId = Me:getCurCarryPetId()
    local petData = Me:getPetDataByPetId(carryPetId)
    if petData and petData.cfgId == petId then
      return
    else
      local data = PetConfig:getCfgById(petId)
      if data then
        Me:changePartner(data)
      end
    end
    self.petList:getAdapter():setScrollOffset(0)
  end
end

function WinPartner:updatePetList(petType)
  local type = petType or self.curPetType
  local data = PetConfig:getAllAvailablePets(Me, type)
  self.petList:setData(data)
end

function WinPartner:undoChildFollow()
  local carryPetId = Me:getCurCarryPetId()
  if carryPetId == 0 then
    return
  end
  Me:recoverPartner()
end

function WinPartner:onHide()
  UI:closeWnd("partner")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinPartner:onOpen(petId)
  Me:uiMutualExclusion("partner")
  self:initPetNameAndColor()
  self:initView(petId)
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
end

function WinPartner:initPetNameAndColor()
  local petName = Me:getPetName()
  if petName ~= "" then
    self.txtNameTxt:SetText(petName)
  end
  local nameColor = Me:getPetNameColor()
  if nameColor ~= "" then
    self.txtNameTxt:SetTextColor(Lib.getTextColor(nameColor))
  end
end

function WinPartner:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
end

function WinPartner:resetHasInitListTag()
  self.hasInitList = nil
end

return WinPartner
