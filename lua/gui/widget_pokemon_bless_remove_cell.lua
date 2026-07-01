local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_bless_remove_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonBlessRemoveCellItemLayout = self:child("pokemon_bless_remove_cell-Item-Layout")
  self.txtPokemonBlessRemoveCellUseText = self:child("pokemon_bless_remove_cell-Use-Text")
  self.txtPokemonBlessRemoveCellUseNum = self:child("pokemon_bless_remove_cell-Use-Num")
  self.txtPokemonBlessRemoveCellRemoveText = self:child("pokemon_bless_remove_cell-Remove-Text")
  self.btnPokemonBlessRemoveCellSubButton = self:child("pokemon_bless_remove_cell-Sub-Button")
  self.btnPokemonBlessRemoveCellAddButton = self:child("pokemon_bless_remove_cell-Add-Button")
  self.imgPokemonBlessRemoveCellRemoveBg = self:child("pokemon_bless_remove_cell-Remove-Bg")
  self.txtPokemonBlessRemoveCellRemoveNum = self:child("pokemon_bless_remove_cell-Remove-Num")
  self.txtPokemonBlessRemoveCellUseText:SetText(Lang:toText("gui.bless.used.num"))
  self.lytPokemonBlessRemoveCellItemLayout = self:child("pokemon_bless_remove_cell-Item-Layout")
  self.imgPokemonBlessingItem = UIMgr:new_widget("pokemon_item_cell")
  self.imgPokemonBlessingItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPokemonBlessRemoveCellItemLayout:AddChildWindow(self.imgPokemonBlessingItem)
end

function M:initEvent()
  self:subscribe(self.btnPokemonBlessRemoveCellAddButton, UIEvent.EventButtonClick, function()
    local curNum = tonumber(self.txtPokemonBlessRemoveCellRemoveNum:GetText())
    local hasUsed = tonumber(self.txtPokemonBlessRemoveCellUseNum:GetText())
    if curNum < hasUsed then
      self.txtPokemonBlessRemoveCellRemoveNum:SetText(curNum + 1)
    end
  end)
  self:subscribe(self.btnPokemonBlessRemoveCellSubButton, UIEvent.EventButtonClick, function()
    local curNum = tonumber(self.txtPokemonBlessRemoveCellRemoveNum:GetText())
    if 0 < curNum then
      self.txtPokemonBlessRemoveCellRemoveNum:SetText(curNum - 1)
    end
  end)
end

function M:setData(fullName, hasUsed, bless_level)
  self.fullName = fullName
  self.txtPokemonBlessRemoveCellUseNum:SetText(hasUsed or 0)
  self.txtPokemonBlessRemoveCellRemoveNum:SetText(0)
  self.imgPokemonBlessingItem:invoke("initViewDataWithoutAdapter", fullName)
  self.btnPokemonBlessRemoveCellSubButton:SetVisible(bless_level ~= 1)
  self.btnPokemonBlessRemoveCellAddButton:SetVisible(bless_level ~= 1)
  self.imgPokemonBlessRemoveCellRemoveBg:SetVisible(bless_level ~= 1)
  self.txtPokemonBlessRemoveCellRemoveText:SetText(Lang:toText(bless_level ~= 1 and "gui.bless.remove" or "gui.bless.not.remove"))
end

function M:getData()
  return {
    fullName = self.fullName,
    removeNum = tonumber(self.txtPokemonBlessRemoveCellRemoveNum:GetText())
  }
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
