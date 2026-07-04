local WinModMapReport = M
local IsOpenMenu = false
local ReportReason = Define.ModMapReportReason
local SelectReasonIndex
local ReportText = ""
local ModAsyncProxy = T(Lib, "ModAsyncProxy")

local function CanSendReport()
  local len = Lib.getStringLen(ReportText)
  local minWords = World.cfg.modReportMinWordsNum or 10
  return len >= minWords and SelectReasonIndex ~= nil
end

function WinModMapReport:init()
  WinBase.init(self, "ModMapReport.json")
  self._allEvent = {}
  self:initUI()
  self.reqReportKey = "ModMapReport_Report"
  ModAsyncProxy:regDelegateRequest(self.reqReportKey, AsyncProcess.ModMapReport, Event.EVENT_MOD_RESPONSE_ADD_REPORT)
  self:initEvent()
end

function WinModMapReport:initUI()
  self.imgBg = self:child("ModMapReport-Bg")
  self.btnClose = self:child("ModMapReport-Close")
  self.btnConfirm = self:child("ModMapReport-Confirm")
  self.btnConfirm:SetText(Lang:toText("g2052.gui.mod_report.confirm"))
  self.lytReasonView = self:child("ModMapReport-ReasonView")
  self.imgReasonBg = self:child("ModMapReport-Reason-Bg")
  self.editReasonInput = self:child("ModMapReport-Reason-Input")
  self.txtReasonShow = self:child("ModMapReport-Reason-Show")
  self.lytTitle = self:child("ModMapReport-Title")
  self.txtTitleText = self:child("ModMapReport-Title-Text")
  self.txtTitleText:SetText(Lang:toText("g2052.gui.mod_report.title"))
  self.lytDropDown = self:child("ModMapReport-DropDown")
  self.lytDropDownBox = self:child("ModMapReport-DropDown-Box")
  self.imgDropDownBoxBg = self:child("ModMapReport-DropDown-Box-Bg")
  self.txtDropDownBoxText = self:child("ModMapReport-DropDown-Box-Text")
  self.imgDropDownBoxIcon = self:child("ModMapReport-DropDown-Box-Icon")
  self.lytDropDownMenu = self:child("ModMapReport-DropDown-Menu")
  self.lytDropDownMenu:SetVisible(false)
  self.btnCloseMenu = self:child("ModMapReport-DropDown-Menu-Close")
  self.gvDropDown = GridViewHelper.new({
    name = "gvDropDown",
    xCellNum = 1,
    yDis = 0,
    xDis = 0,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = true,
    widgetWidth = 466,
    widgetHeight = 40,
    widgetJson = "ModMapReportDropDownItem.json",
    widgetName = "modMapReportDropDownItem",
    gvParent = self.lytDropDownMenu,
    cellSelectedCb = function(data, dx, dy, index)
      self:onDropDownMenuClick(index)
    end
  })
  self.gvDropDown:setData(ReportReason, -1, nil, true)
end

function WinModMapReport:onDropDownMenuClick(index)
  Lib.logDebug("--onDropDownMenuClick : " .. index)
  SelectReasonIndex = index
  self:updateDropDownBox()
  self:updateSendBtnStat()
  self:closeMenu()
end

function WinModMapReport:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    Lib.logDebug("-------------self.btnConfirm-------------")
    if not CanSendReport() then
      return
    end
    ModAsyncProxy:request(self.reqReportKey, self.gameId, SelectReasonIndex, nil, ReportText)
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.guid.mod_report_success"))
    self:onHide()
  end)
  self:subscribe(self.imgDropDownBoxIcon, UIEvent.EventWindowClick, function()
    if IsOpenMenu then
      self:closeMenu()
    else
      self:openMenu()
    end
  end)
  self:subscribe(self.btnCloseMenu, UIEvent.EventWindowClick, function()
    self:closeMenu()
  end)
  self:subscribe(self.editReasonInput, UIEvent.EventEditTextInput, function()
    local inputText = string.format(self.editReasonInput:GetPropertyString("Text", ""))
    ReportText = Lib.standardizingInput(inputText, 100)
    self.editReasonInput:SetProperty("Text", ReportText)
    self:updateSendBtnStat()
    self:updateReasonShow()
    Lib.logDebug("--WinModMapReport editReasonInput:" .. inputText)
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_ADD_REPORT, function(data)
  end)
end

function WinModMapReport:subscribeEvent()
end

function WinModMapReport:initView()
  self.gvDropDown:setData(ReportReason, -1, nil, true)
  self:updateDropDownBox()
  self:updateSendBtnStat()
  self:updateReasonShow()
end

function WinModMapReport:updateDropDownBox()
  local lang = SelectReasonIndex and ReportReason[SelectReasonIndex].lang or "g2052.gui.mod_report.chose"
  self.txtDropDownBoxText:SetText(Lang:toText(lang))
end

local SendBtnEnableImage = "set:g2052_buttons.json image:btn_9_general01"
local SendBtnUnEnableImage = "set:g2052_buttons.json image:btn_9_general01"

function WinModMapReport:updateSendBtnStat()
  local can = CanSendReport()
  self.btnConfirm:SetEnabled(can)
end

function WinModMapReport:updateReasonShow()
  self.txtReasonShow:SetText(ReportText)
end

function WinModMapReport:onHide()
  UI:closeWnd("modMapReport")
end

function WinModMapReport:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("modMapReport")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinModMapReport:onOpen(gameId)
  if not gameId then
    return
  end
  self.gameId = gameId
  self:initView()
  self:subscribeEvent()
end

function WinModMapReport:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  SelectReasonIndex = nil
  ReportText = ""
  self:closeMenu()
end

local upAry = "set:g2052_buttons.json image:btn_0_expand01"
local downAry = "set:g2052_buttons.json image:btn_0_expand02"

function WinModMapReport:openMenu()
  self.imgDropDownBoxIcon:SetImage(upAry)
  self.lytDropDownMenu:SetVisible(true)
  IsOpenMenu = true
end

function WinModMapReport:closeMenu()
  self.imgDropDownBoxIcon:SetImage(downAry)
  self.lytDropDownMenu:SetVisible(false)
  IsOpenMenu = false
end

return WinModMapReport
