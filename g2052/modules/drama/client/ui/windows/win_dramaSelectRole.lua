local WinDramaSelectRole = M
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WinDramaSelectRole:init()
  WinBase.init(self, "DramaSelectRole.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaSelectRole:initUI()
  self.lytPanel = self:child("DramaSelectRole-Panel")
  self.btnButtonClose = self:child("DramaSelectRole-ButtonClose")
  self.lytListPanel = self:child("DramaSelectRole-ListPanel")
  self.btnButtonNO = self:child("DramaSelectRole-ButtonNO")
  self.btnButtonYes = self:child("DramaSelectRole-ButtonYes")
  self:child("DramaSelectRole-TextTitle"):SetText(Lang:toText("g2052.gui.drama.select.role"))
  self:child("DramaSelectRole-TextNo"):SetText(Lang:toText("g2052.gui.cancel"))
  self:child("DramaSelectRole-TextYes"):SetText(Lang:toText("g2052.gui.confirm"))
  self:initAdapter()
end

function WinDramaSelectRole:initAdapter()
  local params = {
    xDis = 4,
    yDis = 5,
    xCellNum = 2,
    widgetWidth = 213,
    widgetHeight = 130,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    moveAble = true,
    vScorllMoveAble = true,
    widgetJson = "DramaSelectRoleItem.json",
    widgetName = "dramaSelectRoleItem",
    gvParent = self.lytListPanel,
    dataList = {},
    cellSelectedCb = function(data, dx, dy, index)
      self:selectRole(data)
    end
  }
  self.roleListView = GridViewHelper.new(params)
end

function WinDramaSelectRole:selectRole(data)
  self.selectedRoleName = data.roleName
  self.selectedRoleKey = data.roleKey
end

function WinDramaSelectRole:initEvent()
  self:subscribe(self.btnButtonClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("dramaSelectRole")
  end)
  self:subscribe(self.btnButtonNO, UIEvent.EventButtonClick, function()
    UI:closeWnd("dramaSelectRole")
  end)
  self:subscribe(self.btnButtonYes, UIEvent.EventButtonClick, function()
    if self.selectTimeStamp == 0 then
      self.selectTimeStamp = os.time()
    end
    if self.selectedRoleKey then
      Me:sendPacket({
        pid = "trySelectRoleC2S",
        roleName = self.selectedRoleName,
        roleKey = self.selectedRoleKey
      }, function(ret)
        if ret == Define.DramaSelectRoleStatus.SUCCESS then
          UI:closeWnd("dramaSelectRole")
          if not self.isInitSelectRole then
            Plugins.CallTargetPluginFunc("report", "report", "script_character_msgchange", nil, Me)
          end
        elseif ret == Define.DramaSelectRoleStatus.FULL then
          UI:closeWnd("dramaSelectRole")
        else
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.drama.select.role.fail"))
          if self.isInitSelectRole then
            self.failCounter = self.failCounter + 1
            if self.failCounter > 3 and 3 < os.time() - self.selectTimeStamp then
              Me:sendPacket({
                pid = "recordSelectRoleFailC2S"
              })
              UI:closeWnd("dramaSelectRole")
            end
          end
        end
      end)
    elseif self.isDramaFull and self.isInitSelectRole then
      UI:closeWnd("dramaSelectRole")
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.drama.have.to.select.role"))
    end
  end)
end

function WinDramaSelectRole:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_CUR_DETAIL, function()
    if DramaClientHelper.curDramaInfo then
      self:updateRoleList(DramaClientHelper.curDramaInfo.roleList)
    end
  end)
end

function WinDramaSelectRole:initView(isInit)
  self.btnButtonClose:SetVisible(not isInit)
  self.btnButtonNO:SetVisible(not isInit)
  if isInit then
    self.btnButtonYes:SetXPosition({0, 0})
  else
    self.btnButtonYes:SetXPosition({0, 100})
  end
end

function WinDramaSelectRole:onOpen(isInit, dramaInf)
  self.selectedRoleName = nil
  self.selectedRoleKey = nil
  self.isInitSelectRole = isInit
  self:initView(isInit)
  self:subscribeEvent()
  if dramaInf and dramaInf.roleList then
    self:updateRoleList(dramaInf.roleList)
  end
  self.failCounter = 0
  self.selectTimeStamp = 0
end

function WinDramaSelectRole:updateRoleList(roleList)
  if not roleList then
    return
  end
  self.roleListView:setData(roleList, -1)
  self.isDramaFull = self:checkDramaFull(roleList)
end

function WinDramaSelectRole:checkDramaFull(roleList)
  if not roleList then
    return true
  end
  for _, role in pairs(roleList) do
    if role.roleNum > role.roleSelects then
      return false
    end
  end
  return true
end

function WinDramaSelectRole:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinDramaSelectRole
