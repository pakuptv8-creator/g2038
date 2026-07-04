local WeatherMgr = T(Lib, "WeatherMgr")
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "QuickItem.json", true)
  self.btnConfirm = self:child("QuickItem-Confirm")
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "QuickUseItem",
      item = self.item
    })
  end)
  self.statusTimer = LuaTimer:schedule(function()
    self:updateIcon()
  end, 0, 500)
end

function M:onOpen(item)
  self.item = item
end

function M:updateIcon()
  local img = WeatherMgr:usingUmbrella() and "set:g2052_main.json image:img_0_umbrella02" or "set:g2052_main.json image:img_0_umbrella01"
  self.btnConfirm:SetNormalImage(img)
  self.btnConfirm:SetPushedImage(img)
end

function M:onClose()
  if self.statusTimer then
    LuaTimer:cancel(self.statusTimer)
    self.statusTimer = nil
  end
end
