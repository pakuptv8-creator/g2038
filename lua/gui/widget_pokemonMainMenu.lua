local widget_base = require("ui.widget.widget_base")
local WidgetPokemonMainMenu = Lib.derive(widget_base)
local MainUiMenuBtnConfig = T(Config, "MainUiMenuBtnConfig")

function WidgetPokemonMainMenu:init()
  widget_base.init(self, "PokemonMainMenu.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonMainMenu:initUI()
  self.btnBtn = self:child("PokemonMainMenu-btn")
  self.txtTitle = self:child("PokemonMainMenu-title")
  self.imgIcon = self:child("PokemonMainMenu-Icon")
  self.imgEffect = self:child("PokemonMainMenu-effect")
end

function WidgetPokemonMainMenu:initEvent()
end

function WidgetPokemonMainMenu:initBtnData(btnInfo)
  self.btnInfo = btnInfo
  if btnInfo.title_name and btnInfo.title_name ~= "" then
    self.txtTitle:SetVisible(true)
    self.txtTitle:SetText(Lang:toText(btnInfo.title_name))
  else
    self.txtTitle:SetVisible(false)
  end
  if btnInfo.normal_res and btnInfo.normal_res ~= "" then
    self.imgIcon:SetImage(btnInfo.normal_res)
  else
    self.imgIcon:SetImage("")
  end
  if btnInfo.effect_name and btnInfo.effect_name ~= "" then
    self.imgEffect:SetVisible(true)
    self.imgEffect:UnprepareEffect()
    self.imgEffect:SetEffectName(btnInfo.effect_name)
    self.imgEffect:SetEffectScale(Lib.v2(btnInfo.effect_scale[1] or 1, btnInfo.effect_scale[2] or 1))
  else
    self.imgEffect:SetVisible(false)
  end
  self.touchCallBack = btnInfo.call_func
  self:root():SetArea({0, 0}, {0, 0}, {
    0,
    btnInfo.button_size[1]
  }, {
    0,
    btnInfo.button_size[2]
  })
  self:lightSubscribe("error!!!!! script_client PokemonMainMenu-btn event : EventButtonClick", self.btnBtn, UIEvent.EventButtonClick, function()
    Me:playSoundByKey(btnInfo.click_sound)
    if self.touchCallBack then
      UIMgr.MainUIMenuManage[self.touchCallBack](UIMgr.MainUIMenuManage, self.btnInfo.button_name)
    end
  end)
end

function WidgetPokemonMainMenu:SetVerticalAlignment(value)
  self:root():SetVerticalAlignment(value)
end

function WidgetPokemonMainMenu:SetHorizontalAlignment(value)
  self:root():SetHorizontalAlignment(value)
end

function WidgetPokemonMainMenu:SetVisible(value)
  self:root():SetVisible(value)
end

function WidgetPokemonMainMenu:SetXPosition(value)
  self:root():SetXPosition(value)
end

function WidgetPokemonMainMenu:SetYPosition(value)
  self:root():SetYPosition(value)
end

function WidgetPokemonMainMenu:SetMenuBtnSize(btnWidth, btnHeight)
  UIMgr.UIShowManage:adapterFixedSize(self:root(), btnWidth, btnHeight)
end

function WidgetPokemonMainMenu:getMenuBtnRoot()
  return self:root()
end

function WidgetPokemonMainMenu:setMenuBtnColorProgram(colorState)
  self.btnBtn:setProgram(colorState)
end

function WidgetPokemonMainMenu:onInvoke(key, ...)
  local fn = WidgetPokemonMainMenu[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonMainMenu
