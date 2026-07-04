local WinCommonDialog = M
local LuaTimer = T(Lib, "LuaTimer")

function WinCommonDialog:init()
  WinBase.init(self, "CommonDialog.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinCommonDialog:initData()
  self.widgetName = nil
  self.confirmCallback = nil
  self.cancelCallback = nil
  self.config = nil
  self.title = nil
  self.desc = nil
end

function WinCommonDialog:initUI()
  self.imgContent = self:child("CommonDialog-Content")
  self.imgContentTopBar = self:child("CommonDialog-Content-TopBar")
  self.txtContentTopBarTitle = self:child("CommonDialog-Content-TopBar-Title")
  self.btnContentTopBarBtnClose = self:child("CommonDialog-Content-TopBar-BtnClose")
  self.lytContentBody = self:child("CommonDialog-Content-Body")
  self.btnContentBodyBtnConfirm = self:child("CommonDialog-Content-Body-BtnConfirm")
  self.btnContentBodyBtnCancel = self:child("CommonDialog-Content-Body-BtnCancel")
  self.lytContentWidget = self:child("CommonDialog-Content-Widget")
  self.txtTimeCount = self:child("CommonDialog-TimeCount")
  self.txtContentDesc = self:child("CommonDialog-Content-Desc")
  self.btnContentBodyBtnCenter = self:child("CommonDialog-Content-Body-BtnCenter")
  self.txtContentDesc:SetText(Lang:toText("g2052.gui.confirm"))
  self.btnContentBodyBtnConfirm:SetText(Lang:toText("g2052.gui.confirm"))
  self.btnContentBodyBtnCancel:SetText(Lang:toText("g2052.gui.cancel"))
end

function WinCommonDialog:initEvent()
  self:subscribe(self.btnContentTopBarBtnClose, UIEvent.EventButtonClick, function()
    if self.autoCloseCallback then
      self.autoCloseCallback()
    end
    self:onHide()
  end)
  self:subscribe(self.btnContentBodyBtnConfirm, UIEvent.EventButtonClick, function()
    local data
    if self.content then
      data = self.content:invoke("getData")
      Lib.logDebug("btnContentBodyBtnConfirm data = ", data)
    end
    if self.confirmCallback and type(self.confirmCallback) == "function" then
      self.confirmCallback(data)
      self:onHide()
    end
  end)
  self:subscribe(self.btnContentBodyBtnCancel, UIEvent.EventButtonClick, function()
    self.cancelCallback()
    self:onHide()
  end)
  self:subscribe(self.btnContentBodyBtnCenter, UIEvent.EventButtonClick, function()
    self.centerCallback()
    self:onHide()
  end)
end

function WinCommonDialog:subscribeEvent()
end

function WinCommonDialog:initView()
  if self.title then
    self.txtContentTopBarTitle:SetText(Lang:toText(self.title))
  end
  if self.desc then
    self.txtContentDesc:SetText(Lang:toText(self.desc))
  end
  if self.descHAlignment then
    self.txtContentDesc:SetTextHorzAlign(self.descHAlignment)
  end
  if self.widgetName then
    self.content = UIMgr:new_widget(self.widgetName)
    self.lytContentWidget:AddChildWindow(self.content)
    self.content:invoke("updateData", self.config)
  end
  if self.confirmCallback then
    self.btnContentBodyBtnConfirm:SetVisible(true)
  else
    self.btnContentBodyBtnConfirm:SetVisible(false)
  end
  if self.cancelCallback then
    self.btnContentBodyBtnCancel:SetVisible(true)
  else
    self.btnContentBodyBtnCancel:SetVisible(false)
  end
  if self.centerCallback then
    self.btnContentBodyBtnCenter:SetVisible(true)
    self.txtTimeCount:SetXPosition({0, 0})
  else
    self.btnContentBodyBtnCenter:SetVisible(false)
    self.txtTimeCount:SetXPosition({0, -120})
  end
  self.btnContentBodyBtnCenter:SetText(Lang:toText("g2052.gui.confirm"))
  if self.centerBtnTitle then
    self.btnContentBodyBtnCenter:SetText(Lang:toText(self.centerBtnTitle))
  end
end

function WinCommonDialog:onHide()
  UI:closeWnd("commonDialog")
  if self.autoCloserTimer then
    LuaTimer:cancel(self.autoCloserTimer)
    self.autoCloserTimer = nil
  end
end

function WinCommonDialog:onShow(isShow, params)
  if isShow then
    if not UI:isOpen(self) then
      self.config = params.config
      self.title = params.title
      self.desc = params.desc
      self.descHAlignment = params.descHAlignment
      self.widgetName = params.widgetName
      self.confirmCallback = params.confirmCallback
      self.cancelCallback = params.cancelCallback
      self.centerCallback = params.centerCallback
      self.centerBtnTitle = params.centerBtnTitle
      self.autoCloseCallback = params.autoCloseCallback
      self.txtTimeCount:SetVisible(false)
      if self.autoCloserTimer then
        LuaTimer:cancel(self.autoCloserTimer)
        self.autoCloserTimer = nil
      end
      if params.autoClose then
        self.txtTimeCount:SetVisible(true)
        local time = params.autoClose
        self.txtTimeCount:SetText(time)
        self.autoCloserTimer = LuaTimer:scheduleTimer(function()
          time = time - 1
          self.txtTimeCount:SetText(time)
          if time <= 0 then
            LuaTimer:cancel(self.autoCloserTimer)
            self.autoCloserTimer = nil
            if self.autoCloseCallback then
              self.autoCloseCallback()
            end
            self:onHide()
          end
        end, 1000, params.autoClose)
      end
      UI:openWnd("commonDialog")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinCommonDialog:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function WinCommonDialog:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.content ~= nil then
    GUIWindowManager.instance:DestroyGUIWindow(self.content)
    self.content = nil
  end
  self.title = nil
  self.txtContentTopBarTitle:SetText("")
  self.desc = nil
  self.txtContentDesc:SetText("")
  self.txtContentDesc:SetTextHorzAlign(1)
  self.config = nil
  self.widgetName = nil
  self.confirmCallback = nil
  self.cancelCallback = nil
end

return WinCommonDialog
