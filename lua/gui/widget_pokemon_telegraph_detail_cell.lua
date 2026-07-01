local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local GymConfig = T(Config, "GymConfig")

function M:init()
  widget_base.init(self, "pokemon_telegraph_detail_cell.json")
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
end

function M:initWnd()
  self.btnTelegraph = self:child("pokemon_telegraph_detail_cell-btn")
  self.stInfo = self:child("pokemon_telegraph_detail_cell-info")
  self.siComplete = self:child("pokemon_telegraph_detail_cell-complete")
  self.siComplete:SetVisible(false)
  self.siLock = self:child("pokemon_telegraph_detail_cell-lock")
  self.siLock:SetVisible(false)
end

function M:initEvent()
end

function M:initViewDataWithoutAdapter(id, name, in_region_id, is_team, unlock)
  self.id = id
  self.name = name
  self.stInfo:SetText(Lang:toText(name))
  self.regionId = in_region_id
  self.is_team = is_team
  self.unlock = unlock
  self.state = 0
  if Me:isJoinTeam() then
    if self.is_team == 0 then
      self.state = 1
      self.siComplete:SetVisible(false)
      self.siLock:SetVisible(true)
      self.btnTelegraph:SetPushedImage("set:pokemon_pvp.json image:img_9_transfer_locked_bg")
      self.btnTelegraph:SetNormalImage("set:pokemon_pvp.json image:img_9_transfer_locked_bg")
    end
  elseif Me:getGymFinish(self.id) == 1 then
    local gym_config = GymConfig:getGymById(self.id)
    self.state = 0
    self.siComplete:SetVisible(true)
    self.siLock:SetVisible(false)
    self.btnTelegraph:SetPushedImage("set:pokemon_pvp.json image:img_9_transfer_complete_bg")
    self.btnTelegraph:SetNormalImage("set:pokemon_pvp.json image:img_9_transfer_complete_bg")
  elseif self.unlock ~= 0 and Me:getGymFinish(self.unlock) ~= 1 then
    self.state = 3
    self.siComplete:SetVisible(false)
    self.siLock:SetVisible(true)
    self.btnTelegraph:SetPushedImage("set:pokemon_pvp.json image:img_9_transfer_locked_bg")
    self.btnTelegraph:SetNormalImage("set:pokemon_pvp.json image:img_9_transfer_locked_bg")
  end
  self:subscribe(self.btnTelegraph, UIEvent.EventButtonClick, function()
    Lib.logDebug("click telegraph root state = ", self.state)
    if self.state == 0 then
      local packet = {
        pid = "TelegraphToRegion",
        regionId = self.regionId,
        gymId = self.id
      }
      Lib.logDebug("TelegraphToRegion packet = ", Lib.v2s(packet))
      Me:sendPacket(packet)
      UI:closeWnd("pokemonTelegraph")
      Lib.emitEvent(Event.EVENT_RESUME_BLOCK)
      Me:resetDialog()
    elseif self.state == 1 then
      Lib.logDebug("team cannot telegraph")
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.telegraph.team"), 60)
    elseif self.state == 2 then
      Lib.logDebug("is complete")
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.telegraph.complete"), 60)
    elseif self.state == 3 then
      Lib.logDebug("unlock the first gym")
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.telegraph.unlock"), 60)
    end
  end)
end

function M:initItem(data)
end

function M:onDataChanged(data)
  self:initItem(data)
end

function M:onDestroy()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
