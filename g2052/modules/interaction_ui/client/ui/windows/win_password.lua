local table_concat = table.concat
local table_insert = table.insert
local table_remove = table.remove
local WinPassword = M

function WinPassword:init()
  WinBase.init(self, "Password.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPassword:initUI()
  self.lytMask = self:child("Password-mask")
  self.imgInterface = self:child("Password-Interface")
  self.imgResultBg = self:child("Password-ResultBg")
  self.txtInputResult = self:child("Password-InputResult")
  self.lytOperationContainer = self:child("Password-Operation-Container")
  self.btnBackspace = self:child("Password-Backspace")
  self.btnClear = self:child("Password-Clear")
  self.btnClose = self:child("Password-Close")
  for i = 0, 9 do
    self["btnNum" .. i] = self:child("Password-Num" .. i)
    self["btnNum" .. i]:SetText(i)
  end
  self.btnBackspace:SetText("X")
  self.btnClear:SetText("C")
end

function WinPassword:initEvent()
  for i = 0, 9 do
    self:subscribe(self["btnNum" .. i], UIEvent.EventButtonClick, function()
      if #self._inputNum < self.length_password then
        table_insert(self._inputNum, i)
        self:updateInputShow()
        local isValid = self:checkIsValid()
        if isValid then
          if self.callback then
            self.callback()
          end
          UI:closeWnd(self)
        end
      end
    end)
  end
  self:subscribe(self.btnBackspace, UIEvent.EventButtonClick, function()
    table_remove(self._inputNum)
    self:updateInputShow()
  end)
  self:subscribe(self.btnClear, UIEvent.EventButtonClick, function()
    self._inputNum = {}
    self:updateInputShow()
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
end

function WinPassword:subscribeEvent()
end

function WinPassword:initView()
  self.txtInputResult:SetText("")
end

function WinPassword:updateInputShow()
  local inputStr = table_concat(self._inputNum)
  self.txtInputResult:SetText(inputStr)
end

function WinPassword:checkIsValid()
  local curInput = self.txtInputResult:GetText()
  if #curInput < #self.password then
    return false
  elseif #curInput == #self.password then
    if curInput == self.password then
      return true
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.password.error"))
      return false
    end
  end
end

function WinPassword:onOpen(password, callback)
  self.password = password or "****"
  self.callback = callback
  self.length_password = #self.password
  self._inputNum = {}
  self:initView()
  self:subscribeEvent()
end

function WinPassword:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPassword
