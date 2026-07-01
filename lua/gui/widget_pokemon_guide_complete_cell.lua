local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_guide_complete_cell.json")
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.data = nil
end

function M:initWnd()
  self.stDesc = self:child("pokemon_guide_complete_cell-desc")
  self.ltUpgrade = self:child("pokemon_guide_complete_cell-upgrade")
  self.stLevelFrom = self:child("pokemon_guide_complete_cell-level-from")
  self.siArrow = self:child("pokemon_guide_complete_cell-arrow")
  self.stLevelTo = self:child("pokemon_guide_complete_cell-level-to")
  self.ltUnlock = self:child("pokemon_guide_complete_cell-unlock")
  self.stUnlockText1 = self:child("pokemon_guide_complete_cell-unlock-text-1")
  self.stUnlockText2 = self:child("pokemon_guide_complete_cell-unlock-text-2")
end

function M:initEvent()
end

function M:initItem(data)
  self.data = data
  Lib.logDebug("guide detail data = ", Lib.v2s(self.data))
  local id = tonumber(self.data[1])
  if id == 1 then
    local from = self.data[2]
    Lib.logDebug("from = ", from)
    local to = self.data[3]
    Lib.logDebug("to = ", to)
    self.stDesc:SetText(Lang:toText("gui.guide.roleupgrade"))
    self.ltUnlock:SetVisible(false)
    self.ltUpgrade:SetVisible(true)
    self.stLevelFrom:SetText("Lv " .. from)
    self.stLevelTo:SetText("Lv " .. to)
  elseif id == 2 then
    local from = self.data[2]
    Lib.logDebug("from = ", from)
    local to = self.data[3]
    Lib.logDebug("to = ", to)
    self.stDesc:SetText(Lang:toText("gui.guide.pokemonlevelcap"))
    self.ltUnlock:SetVisible(false)
    self.ltUpgrade:SetVisible(true)
    self.stLevelFrom:SetText("Lv " .. from)
    self.stLevelTo:SetText("Lv " .. to)
  elseif id == 3 then
    table.remove(self.data, 1)
    Lib.logDebug("unlock mode detail = ", Lib.v2s(self.data))
    local unlockContent = ""
    for i = 1, #self.data do
      unlockContent = unlockContent .. Lang:toText("unlock_mod_" .. self.data[i]) .. ". "
    end
    Lib.logDebug("unlockContent = ", unlockContent)
    self.stDesc:SetText(Lang:toText("gui.guide.unlock"))
    self.ltUnlock:SetVisible(true)
    self.ltUpgrade:SetVisible(false)
    self.stUnlockText1:SetText(Lang:toText({
      "gui.guide.open",
      Me:getPlayerLevel()
    }))
    self.stUnlockText2:SetText(unlockContent)
  end
end

function M:onDataChanged(data)
  self:initItem(data)
end

function M:onDestroy()
  self.data = nil
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
